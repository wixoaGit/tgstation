SUBSYSTEM_DEF(garbage)
	name = "Garbage"
	priority = FIRE_PRIORITY_GARBAGE
	wait = 2 SECONDS
	flags = SS_POST_FIRE_TIMING|SS_BACKGROUND|SS_NO_INIT
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY
	init_order = INIT_ORDER_GARBAGE

	var/list/collection_timeout = list(0, 2 MINUTES, 10 SECONDS)

	var/delslasttick = 0
	var/gcedlasttick = 0
	var/totaldels = 0
	var/totalgcs = 0

	var/highest_del_time = 0
	var/highest_del_tickusage = 0

	var/list/pass_counts
	var/list/fail_counts

	var/list/items = list()

	var/list/queues

	#ifdef TESTING
	var/list/reference_find_on_fail = list()
	#endif

/datum/controller/subsystem/garbage/PreInit()
	queues = new(GC_QUEUE_COUNT)
	pass_counts = new(GC_QUEUE_COUNT)
	fail_counts = new(GC_QUEUE_COUNT)
	for(var/i in 1 to GC_QUEUE_COUNT)
		queues[i] = list()
		pass_counts[i] = 0
		fail_counts[i] = 0

/datum/controller/subsystem/garbage/stat_entry(msg)
	var/list/counts = list()
	for (var/list/L in queues)
		counts += length(L)
	msg += "Q:[counts.Join(",")]|D:[delslasttick]|G:[gcedlasttick]|"
	msg += "GR:"
	if (!(delslasttick+gcedlasttick))
		msg += "n/a|"
	else
		msg += "[round((gcedlasttick/(delslasttick+gcedlasttick))*100, 0.01)]%|"

	msg += "TD:[totaldels]|TG:[totalgcs]|"
	if (!(totaldels+totalgcs))
		msg += "n/a|"
	else
		msg += "TGR:[round((totalgcs/(totaldels+totalgcs))*100, 0.01)]%"
	msg += " P:[pass_counts.Join(",")]"
	msg += "|F:[fail_counts.Join(",")]"
	..(msg)

/datum/controller/subsystem/garbage/proc/HardDelete(datum/D)
	var/time = world.timeofday
	var/tick = TICK_USAGE
	var/ticktime = world.time
	++delslasttick
	++totaldels
	var/type = D.type
	var/refID = "\ref[D]"

	del(D)

	tick = (TICK_USAGE-tick+((world.time-ticktime)/world.tick_lag*100))

	//var/datum/qdel_item/I = items[type]

	//I.hard_deletes++
	//I.hard_delete_time += TICK_DELTA_TO_MS(tick)


	//if (tick > highest_del_tickusage)
	//	highest_del_tickusage = tick
	//time = world.timeofday - time
	//if (!time && TICK_DELTA_TO_MS(tick) > 1)
	//	time = TICK_DELTA_TO_MS(tick)/100
	//if (time > highest_del_time)
	//	highest_del_time = time
	//if (time > 10)
	//	log_game("Error: [type]([refID]) took longer than 1 second to delete (took [time/10] seconds to delete)")
	//	message_admins("Error: [type]([refID]) took longer than 1 second to delete (took [time/10] seconds to delete).")
	//	postpone(time)

/proc/qdel(datum/D, force=FALSE, ...)
	if(!istype(D))
		del(D)
		return
	
	if(isnull(D.gc_destroyed))
		if (SEND_SIGNAL(D, COMSIG_PARENT_PREQDELETED, force))
			return
		D.gc_destroyed = GC_CURRENTLY_BEING_QDELETED
		var/start_time = world.time
		var/start_tick = world.tick_usage
		var/hint = D.Destroy(arglist(args.Copy(2)))
		SEND_SIGNAL(D, COMSIG_PARENT_QDELETED, force, hint)
		//if(world.time != start_time)
		//	I.slept_destroy++
		//else
		//	I.destroy_time += TICK_USAGE_TO_MS(start_tick)
		if(!D)
			return
		switch(hint)
			if (QDEL_HINT_QUEUE)
				//SSgarbage.Queue(D)
			if (QDEL_HINT_IWILLGC)
				D.gc_destroyed = world.time
				return
			if (QDEL_HINT_LETMELIVE)
				if(!force)
					D.gc_destroyed = null
					return
				//#ifdef TESTING
				//if(!I.no_respect_force)
				//	testing("WARNING: [D.type] has been force deleted, but is \
				//		returning an immortal QDEL_HINT, indicating it does \
				//		not respect the force flag for qdel(). It has been \
				//		placed in the queue, further instances of this type \
				//		will also be queued.")
				//#endif
				//I.no_respect_force++

				//SSgarbage.Queue(D)
			if (QDEL_HINT_HARDDEL)
				//SSgarbage.Queue(D, GC_QUEUE_HARDDELETE)
			if (QDEL_HINT_HARDDEL_NOW)
				SSgarbage.HardDelete(D)
			if (QDEL_HINT_FINDREFERENCE)
				//SSgarbage.Queue(D)
				//#ifdef TESTING
				//D.find_references()
				//#endif
			if (QDEL_HINT_IFFAIL_FINDREFERENCE)
				//SSgarbage.Queue(D)
				//#ifdef TESTING
				//SSgarbage.reference_find_on_fail[REF(D)] = TRUE
				//#endif
			else
				//#ifdef TESTING
				//if(!I.no_hint)
				//	testing("WARNING: [D.type] is not returning a qdel hint. It is being placed in the queue. Further instances of this type will also be queued.")
				//#endif
				//I.no_hint++
				//SSgarbage.Queue(D)
	else if(D.gc_destroyed == GC_CURRENTLY_BEING_QDELETED)
		//CRASH("[D.type] destroy proc was called multiple times, likely due to a qdel loop in the Destroy logic")