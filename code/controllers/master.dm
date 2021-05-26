GLOBAL_REAL(Master, /datum/controller/master) = new

/datum/controller/master
	name = "Master"

	var/processing = TRUE
	var/iteration = 0

	var/last_run

	var/list/subsystems

	var/init_timeofday
	var/init_time
	var/tickdrift = 0

	var/sleep_delta = 1

	var/make_runtime = 0

	var/initialization_finished_with_no_players_logged_in

	var/last_type_processed

	var/datum/controller/subsystem/queue_head
	var/datum/controller/subsystem/queue_tail
	var/queue_priority_count = 0
	var/queue_priority_count_bg = 0
	var/map_loading = FALSE

	var/current_runlevel
	var/sleep_offline_after_initializations = TRUE

	//var/static/restart_clear = 0
	//var/static/restart_timeout = 0
	//var/static/restart_count = 0

	//var/static/random_seed

	var/static/current_ticklimit = TICK_LIMIT_RUNNING

/datum/controller/master/New()
	if (!config)
		config = new

	//if(!random_seed)
	//	random_seed = (TEST_RUN_PARAMETER in world.params) ? 29051994 : rand(1, 1e9)
	//	rand_seed(random_seed)

	var/list/_subsystems = list()
	subsystems = _subsystems
	if (Master != src)
		var/list/subsytem_types = subtypesof(/datum/controller/subsystem)
		//sortTim(subsytem_types, /proc/cmp_subsystem_init)
		for(var/I in subsytem_types)
			_subsystems += new I
		Master = src

	if(!GLOB)
		new /datum/controller/global_vars

/datum/controller/master/Destroy()
	..()
	return QDEL_HINT_HARDDEL_NOW

/datum/controller/master/Shutdown()
	processing = FALSE
	sortTim(subsystems, /proc/cmp_subsystem_init)
	reverseRange(subsystems)
	for(var/datum/controller/subsystem/ss in subsystems)
		log_world("Shutting down [ss.name] subsystem...")
		ss.Shutdown()
	log_world("Shutdown complete")

/datum/controller/master/Initialize(delay, init_sss, tgs_prime)
	set waitfor = 0

	if(delay)
		sleep(delay)

	//if(tgs_prime)
	//	world.TgsInitializationComplete()

	if(init_sss)
		init_subtypes(/datum/controller/subsystem, subsystems)

	to_chat(world, "<span class='boldannounce'>Initializing subsystems...</span>")

	sortTim(subsystems, /proc/cmp_subsystem_init)

	var/start_timeofday = REALTIMEOFDAY
	current_ticklimit = CONFIG_GET(number/tick_limit_mc_init)
	for (var/datum/controller/subsystem/SS in subsystems)
		if (SS.flags & SS_NO_INIT)
			continue
		SS.Initialize(REALTIMEOFDAY)
		CHECK_TICK
	current_ticklimit = TICK_LIMIT_RUNNING
	var/time = (REALTIMEOFDAY - start_timeofday) / 10

	var/msg = "Initializations complete within [time] second[time == 1 ? "" : "s"]!"
	to_chat(world, "<span class='boldannounce'>[msg]</span>")
	log_world(msg)

	if (!current_runlevel)
		SetRunLevel(1)

	sortTim(subsystems, /proc/cmp_subsystem_display)
	//world.fps = CONFIG_GET(number/fps)
	var/initialized_tod = REALTIMEOFDAY

	//if(sleep_offline_after_initializations)
	//	world.sleep_offline = TRUE
	sleep(1)

	//if(sleep_offline_after_initializations && CONFIG_GET(flag/resume_after_initializations))
	//	world.sleep_offline = FALSE
	//initializations_finished_with_no_players_logged_in = initialized_tod < REALTIMEOFDAY - 10
	Master.StartProcessing(0)

/datum/controller/master/proc/SetRunLevel(new_runlevel)
	var/old_runlevel = current_runlevel
	if(isnull(old_runlevel))
		old_runlevel = "NULL"

	testing("MC: Runlevel changed from [old_runlevel] to [new_runlevel]")
	current_runlevel = log(2, new_runlevel) + 1
	if(current_runlevel < 1)
		CRASH("Attempted to set invalid runlevel: [new_runlevel]")

/datum/controller/master/proc/StartProcessing(delay)
	set waitfor = 0
	if(delay)
		sleep(delay)
	testing("Master starting processing")
	var/rtn = Loop()
	if (rtn > 0 || processing < 0)
		return
	log_game("MC crashed or runtimed, restarting")
	message_admins("MC crashed or runtimed, restarting")
	//var/rtn2 = Recreate_MC()
	//if (rtn2 <= 0)
	//	log_game("Failed to recreate MC (Error code: [rtn2]), it's up to the failsafe now")
	//	message_admins("Failed to recreate MC (Error code: [rtn2]), it's up to the failsafe now")
	//	Failsafe.defcon = 2

/datum/controller/master/proc/Loop()
	. = -1
	
	var/list/tickersubsystems = list()
	var/list/runlevel_sorted_subsystems = list(list())
	var/timer = world.time
	for (var/thing in subsystems)
		var/datum/controller/subsystem/SS = thing
		if (SS.flags & SS_NO_FIRE)
			continue
		SS.queued_time = 0
		SS.queue_next = null
		SS.queue_prev = null
		SS.state = SS_IDLE
		if (SS.flags & SS_TICKER)
			tickersubsystems += SS
			timer += world.tick_lag * rand(1, 5)
			SS.next_fire = timer
			continue
		
		var/ss_runlevels = SS.runlevels
		var/added_to_any = FALSE
		for(var/I in 1 to GLOB.bitflags.len)
			if(ss_runlevels & GLOB.bitflags[I])
				while(runlevel_sorted_subsystems.len < I)
					runlevel_sorted_subsystems += list(list())
				runlevel_sorted_subsystems[I] += SS
				added_to_any = TRUE
		if(!added_to_any)
			WARNING("[SS.name] subsystem is not SS_NO_FIRE but also does not have any runlevels set!")

	queue_head = null
	queue_tail = null
	sortTim(tickersubsystems, /proc/cmp_subsystem_priority)
	for(var/I in runlevel_sorted_subsystems)
		//sortTim(runlevel_sorted_subsystems, /proc/cmp_subsystem_priority) //sorting a list of lists with a cmp proc that doesn't expect lists?
		I += tickersubsystems
	
	var/cached_runlevel = current_runlevel
	var/list/current_runlevel_subsystems = runlevel_sorted_subsystems[cached_runlevel]

	init_timeofday = REALTIMEOFDAY
	init_time = world.time
	
	iteration = 1
	var/error_level = 0
	var/sleep_delta = 1
	var/list/subsystems_to_check
	
	while (1)
		tickdrift = max(0, MC_AVERAGE_FAST(tickdrift, (((REALTIMEOFDAY - init_timeofday) - (world.time - init_time)) / world.tick_lag)))
		var/starting_tick_usage = TICK_USAGE
		if (processing <= 0)
			current_ticklimit = TICK_LIMIT_RUNNING
			sleep(10)
			continue
		
		if (starting_tick_usage > TICK_LIMIT_MC)
			sleep_delta *= 2
			current_ticklimit = TICK_LIMIT_RUNNING * 0.5
			sleep(world.tick_lag * (processing * sleep_delta))
			continue
		
		if (last_run + CEILING(world.tick_lag * (processing * sleep_delta), world.tick_lag) < world.time)
			sleep_delta += 1
		
		sleep_delta = MC_AVERAGE_FAST(sleep_delta, 1)

		if (starting_tick_usage > (TICK_LIMIT_MC*0.75))
			sleep_delta += 1
		
		if (!queue_head || !(iteration % 3))
			var/checking_runlevel = current_runlevel
			if(cached_runlevel != checking_runlevel)
				cached_runlevel = checking_runlevel
				current_runlevel_subsystems = runlevel_sorted_subsystems[cached_runlevel]
				var/stagger = world.time
				for(var/I in current_runlevel_subsystems)
					var/datum/controller/subsystem/SS = I
					if(SS.next_fire <= world.time)
						stagger += world.tick_lag * rand(1, 5)
						SS.next_fire = stagger

			subsystems_to_check = current_runlevel_subsystems
		else
			subsystems_to_check = tickersubsystems
		
		if (CheckQueue(subsystems_to_check) <= 0)
			if (!SoftReset(tickersubsystems, runlevel_sorted_subsystems))
				log_world("MC: SoftReset() failed, crashing")
				return
			if (!error_level)
				iteration++
			error_level++
			current_ticklimit = TICK_LIMIT_RUNNING
			sleep(10)
			continue
		
		if (queue_head)
			if (RunQueue() <= 0)
				if (!SoftReset(tickersubsystems, runlevel_sorted_subsystems))
					log_world("MC: SoftReset() failed, crashing")
					return
				if (!error_level)
					iteration++
				error_level++
				current_ticklimit = TICK_LIMIT_RUNNING
				sleep(10)
				continue
		error_level--
		if (!queue_head)
			queue_priority_count = 0
			queue_priority_count_bg = 0

		iteration++
		last_run = world.time
		src.sleep_delta = MC_AVERAGE_FAST(src.sleep_delta, sleep_delta)
		current_ticklimit = TICK_LIMIT_RUNNING
		if (processing * sleep_delta <= world.tick_lag)
			current_ticklimit -= (TICK_LIMIT_RUNNING * 0.25)

		sleep(world.tick_lag * (processing * sleep_delta))

/datum/controller/master/proc/CheckQueue(list/subsystemstocheck)
	. = 0

	var/datum/controller/subsystem/SS
	var/SS_flags

	for (var/thing in subsystemstocheck)
		if (!thing)
			subsystemstocheck -= thing
		SS = thing
		if (SS.state != SS_IDLE)
			continue
		if (SS.can_fire <= 0)
			continue
		if (SS.next_fire > world.time)
			continue
		SS_flags = SS.flags
		if (SS_flags & SS_NO_FIRE)
			subsystemstocheck -= SS
			continue
		if ((SS_flags & (SS_TICKER|SS_KEEP_TIMING)) == SS_KEEP_TIMING && SS.last_fire + (SS.wait * 0.75) > world.time)
			continue
		SS.enqueue()
	. = 1

/datum/controller/master/proc/RunQueue()
	. = 0
	var/datum/controller/subsystem/queue_node
	var/queue_node_flags
	var/queue_node_priority
	var/queue_node_paused

	var/current_tick_budget
	var/tick_precentage
	var/tick_remaining
	var/ran = TRUE
	var/ran_non_ticker = FALSE
	var/bg_calc
	var/tick_usage

	while (ran && queue_head && TICK_USAGE < TICK_LIMIT_MC)
		ran = FALSE
		bg_calc = FALSE
		current_tick_budget = queue_priority_count
		queue_node = queue_head
		while (queue_node)
			if (ran && TICK_USAGE > TICK_LIMIT_RUNNING)
				break

			queue_node_flags = queue_node.flags
			queue_node_priority = queue_node.queued_priority

			if (queue_node_flags & SS_NO_TICK_CHECK)
				if (queue_node.tick_usage > TICK_LIMIT_RUNNING - TICK_USAGE && ran_non_ticker)
					queue_node.queued_priority += queue_priority_count * 0.1
					queue_priority_count -= queue_node_priority
					queue_priority_count += queue_node.queued_priority
					current_tick_budget -= queue_node_priority
					queue_node = queue_node.queue_next
					continue

			if ((queue_node_flags & SS_BACKGROUND) && !bg_calc)
				current_tick_budget = queue_priority_count_bg
				bg_calc = TRUE

			tick_remaining = TICK_LIMIT_RUNNING - TICK_USAGE

			if (current_tick_budget > 0 && queue_node_priority > 0)
				tick_precentage = tick_remaining / (current_tick_budget / queue_node_priority)
			else
				tick_precentage = tick_remaining

			tick_precentage = max(tick_precentage*0.5, tick_precentage-queue_node.tick_overrun)

			current_ticklimit = round(TICK_USAGE + tick_precentage)

			if (!(queue_node_flags & SS_TICKER))
				ran_non_ticker = TRUE
			ran = TRUE

			queue_node_paused = (queue_node.state == SS_PAUSED || queue_node.state == SS_PAUSING)
			last_type_processed = queue_node

			queue_node.state = SS_RUNNING

			tick_usage = TICK_USAGE
			var/state = queue_node.ignite(queue_node_paused)
			tick_usage = TICK_USAGE - tick_usage

			if (state == SS_RUNNING)
				state = SS_IDLE
			current_tick_budget -= queue_node_priority


			if (tick_usage < 0)
				tick_usage = 0
			queue_node.tick_overrun = max(0, MC_AVG_FAST_UP_SLOW_DOWN(queue_node.tick_overrun, tick_usage-tick_precentage))
			queue_node.state = state

			if (state == SS_PAUSED)
				queue_node.paused_ticks++
				queue_node.paused_tick_usage += tick_usage
				queue_node = queue_node.queue_next
				continue

			queue_node.ticks = MC_AVERAGE(queue_node.ticks, queue_node.paused_ticks)
			tick_usage += queue_node.paused_tick_usage

			queue_node.tick_usage = MC_AVERAGE_FAST(queue_node.tick_usage, tick_usage)

			queue_node.cost = MC_AVERAGE_FAST(queue_node.cost, TICK_DELTA_TO_MS(tick_usage))
			queue_node.paused_ticks = 0
			queue_node.paused_tick_usage = 0

			if (queue_node_flags & SS_BACKGROUND)
				queue_priority_count_bg -= queue_node_priority
			else
				queue_priority_count -= queue_node_priority

			queue_node.last_fire = world.time
			queue_node.times_fired++

			if (queue_node_flags & SS_TICKER)
				queue_node.next_fire = world.time + (world.tick_lag * queue_node.wait)
			else if (queue_node_flags & SS_POST_FIRE_TIMING)
				queue_node.next_fire = world.time + queue_node.wait + (world.tick_lag * (queue_node.tick_overrun/100))
			else if (queue_node_flags & SS_KEEP_TIMING)
				queue_node.next_fire += queue_node.wait
			else
				queue_node.next_fire = queue_node.queued_time + queue_node.wait + (world.tick_lag * (queue_node.tick_overrun/100))

			queue_node.queued_time = 0

			queue_node.dequeue()

			queue_node = queue_node.queue_next

	. = 1

/datum/controller/master/proc/SoftReset(list/ticker_SS, list/runlevel_SS)
	. = 0
	log_world("MC: SoftReset called, resetting MC queue state.")
	if (!istype(subsystems) || !istype(ticker_SS) || !istype(runlevel_SS))
		log_world("MC: SoftReset: Bad list contents: '[subsystems]' '[ticker_SS]' '[runlevel_SS]'")
		return
	var/subsystemstocheck = subsystems + ticker_SS
	for(var/I in runlevel_SS)
		subsystemstocheck |= I

	for (var/thing in subsystemstocheck)
		var/datum/controller/subsystem/SS = thing
		if (!SS || !istype(SS))
			subsystems -= list(SS)
			ticker_SS -= list(SS)
			for(var/I in runlevel_SS)
				I -= list(SS)
			log_world("MC: SoftReset: Found bad entry in subsystem list, '[SS]'")
			continue
		if (SS.queue_next && !istype(SS.queue_next))
			log_world("MC: SoftReset: Found bad data in subsystem queue, queue_next = '[SS.queue_next]'")
		SS.queue_next = null
		if (SS.queue_prev && !istype(SS.queue_prev))
			log_world("MC: SoftReset: Found bad data in subsystem queue, queue_prev = '[SS.queue_prev]'")
		SS.queue_prev = null
		SS.queued_priority = 0
		SS.queued_time = 0
		SS.state = SS_IDLE
	if (queue_head && !istype(queue_head))
		log_world("MC: SoftReset: Found bad data in subsystem queue, queue_head = '[queue_head]'")
	queue_head = null
	if (queue_tail && !istype(queue_tail))
		log_world("MC: SoftReset: Found bad data in subsystem queue, queue_tail = '[queue_tail]'")
	queue_tail = null
	queue_priority_count = 0
	queue_priority_count_bg = 0
	log_world("MC: SoftReset: Finished.")
	. = 1

/datum/controller/master/stat_entry()
	if(!statclick)
		statclick = new/obj/effect/statclick/debug(null, "Initializing...", src)

	stat("Byond:", "(FPS:[world.fps]) (TickCount:[world.time/world.tick_lag]) (TickDrift:[round(Master.tickdrift,1)]([round((Master.tickdrift/(world.time/world.tick_lag))*100,0.1)]%))")
	stat("Master Controller:", statclick.update("(TickRate:[Master.processing]) (Iteration:[Master.iteration])"))

/datum/controller/master/StartLoadingMap()
	while(map_loading)
		stoplag()
	for(var/S in subsystems)
		var/datum/controller/subsystem/SS = S
		SS.StartLoadingMap()
	map_loading = TRUE

/datum/controller/master/StopLoadingMap(bounds = null)
	map_loading = FALSE
	for(var/S in subsystems)
		var/datum/controller/subsystem/SS = S
		SS.StopLoadingMap()