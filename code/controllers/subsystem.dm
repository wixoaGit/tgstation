/datum/controller/subsystem
	name = "fire coderbus"
	var/init_order = INIT_ORDER_DEFAULT
	var/wait = 20
	var/priority = FIRE_PRIORITY_DEFAULT

	var/flags = 0

	var/initialized = FALSE

	var/can_fire = TRUE

	var/last_fire = 0
	var/next_fire = 0
	var/cost = 0		
	var/tick_usage = 0	
	var/tick_overrun = 0
	var/state = SS_IDLE
	var/paused_ticks = 0
	var/paused_tick_usage
	var/ticks = 1
	var/times_fired = 0
	var/queued_time = 0
	var/queued_priority
	var/datum/controller/subsystem/queue_next
	var/datum/controller/subsystem/queue_prev

	var/runlevels = RUNLEVELS_DEFAULT

/datum/controller/subsystem/proc/PreInit()
	return

/datum/controller/subsystem/proc/ignite(resumed = 0)
	set waitfor = 0
	. = SS_SLEEPING
	fire(resumed)
	. = state
	if (state == SS_SLEEPING)
		state = SS_IDLE
	if (state == SS_PAUSING)
		var/QT = queued_time
		enqueue()
		state = SS_PAUSED
		queued_time = QT

/datum/controller/subsystem/proc/fire()
	flags |= SS_NO_FIRE
	//throw EXCEPTION("Subsystem [src]([type]) does not fire() but did not set the SS_NO_FIRE flag. Please add the SS_NO_FIRE flag to any subsystem that doesn't fire so it doesn't get added to the processing list and waste cpu.")

/datum/controller/subsystem/Destroy()
	dequeue()
	can_fire = 0
	flags |= SS_NO_FIRE
	Master.subsystems -= src
	return ..()

/datum/controller/subsystem/proc/enqueue()
	var/SS_priority = priority
	var/SS_flags = flags
	var/datum/controller/subsystem/queue_node
	var/queue_node_priority
	var/queue_node_flags

	for (queue_node = Master.queue_head; queue_node; queue_node = queue_node.queue_next)
		queue_node_priority = queue_node.queued_priority
		queue_node_flags = queue_node.flags

		if (queue_node_flags & SS_TICKER)
			if (!(SS_flags & SS_TICKER))
				continue
			if (queue_node_priority < SS_priority)
				break

		else if (queue_node_flags & SS_BACKGROUND)
			if (!(SS_flags & SS_BACKGROUND))
				break
			if (queue_node_priority < SS_priority)
				break

		else
			if (SS_flags & SS_BACKGROUND)
				continue
			if (SS_flags & SS_TICKER)
				break
			if (queue_node_priority < SS_priority)
				break

	queued_time = world.time
	queued_priority = SS_priority
	state = SS_QUEUED
	if (SS_flags & SS_BACKGROUND)
		Master.queue_priority_count_bg += SS_priority
	else
		Master.queue_priority_count += SS_priority

	queue_next = queue_node
	if (!queue_node)
		queue_prev = Master.queue_tail
		if (Master.queue_tail)
			Master.queue_tail.queue_next = src
		else
			Master.queue_head = src
		Master.queue_tail = src

	else if (queue_node == Master.queue_head)
		Master.queue_head.queue_prev = src
		Master.queue_head = src
		queue_prev = null
	else
		queue_node.queue_prev.queue_next = src
		queue_prev = queue_node.queue_prev
		queue_node.queue_prev = src

/datum/controller/subsystem/proc/dequeue()
	if (queue_next)
		queue_next.queue_prev = queue_prev
	if (queue_prev)
		queue_prev.queue_next = queue_next
	if (src == Master.queue_tail)
		Master.queue_tail = queue_prev
	if (src == Master.queue_head)
		Master.queue_head = queue_next
	queued_time = 0
	if (state == SS_QUEUED)
		state = SS_IDLE

/datum/controller/subsystem/proc/pause()
	. = 1
	switch(state)
		if(SS_RUNNING)
			state = SS_PAUSED
		if(SS_SLEEPING)
			state = SS_PAUSING

/datum/controller/subsystem/Initialize(start_timeofday)
	initialized = TRUE
	var/time = (REALTIMEOFDAY - start_timeofday) / 10
	var/msg = "Initialized [name] subsystem within [time] second[time == 1 ? "" : "s"]!"
	to_chat(world, "<span class='boldannounce'>[msg]</span>")
	log_world(msg)
	return time

/datum/controller/subsystem/stat_entry(msg)
	if(!statclick)
		statclick = new/obj/effect/statclick/debug(null, "Initializing...", src)



	if(can_fire && !(SS_NO_FIRE & flags))
		msg = "[round(cost,1)]ms|[round(tick_usage,1)]%([round(tick_overrun,1)]%)|[round(ticks,0.1)]\t[msg]"
	else
		msg = "OFFLINE\t[msg]"

	var/title = name
	if (can_fire)
		//title = "\[[state_letter()]][title]"
		title = "([state_letter()])[title]"//not_actual

	stat(title, statclick.update(msg))

/datum/controller/subsystem/proc/state_letter()
	switch (state)
		if (SS_RUNNING)
			. = "R"
		if (SS_QUEUED)
			. = "Q"
		if (SS_PAUSED, SS_PAUSING)
			. = "P"
		if (SS_SLEEPING)
			. = "S"
		if (SS_IDLE)
			. = "  "