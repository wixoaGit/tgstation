var/global/list/timers = new /list()//not_actual

SUBSYSTEM_DEF(timer)
	name = "Timer"
	wait = 1
	init_order = INIT_ORDER_TIMER
	
	flags = SS_TICKER|SS_NO_INIT

///datum/controller/subsystem/timer/stat_entry(msg)
//	..("B:[bucket_count] P:[length(second_queue)] H:[length(hashes)] C:[length(clienttime_timers)] S:[length(timer_id_dict)]")

/datum/controller/subsystem/fire()
	for (var/datum/timedevent/ev in timers)
		if (ev.time <= world.time)
			ev.Invoke()
			timers -= ev

/datum/timedevent
	var/datum/callback/callBack
	var/time

/datum/timedevent/New(callBack, time)
	src.callBack = callBack
	src.time = world.time + time

/datum/timedevent/Destroy()
	..()
	//if (flags & TIMER_UNIQUE && hash)
	//	SStimer.hashes -= hash

	//if (callBack && callBack.object && callBack.object != GLOBAL_PROC && callBack.object.active_timers)
	//	callBack.object.active_timers -= src
	//	UNSETEMPTY(callBack.object.active_timers)

	callBack = null

	//if (flags & TIMER_STOPPABLE)
	//	SStimer.timer_id_dict -= id

	//if (flags & TIMER_CLIENT_TIME)
	//	if (!spent)
	//		spent = world.time
	//		SStimer.clienttime_timers -= src
	//	return QDEL_HINT_IWILLGC

	//if (!spent)
	//	spent = world.time
	//	bucketEject()
	//else
	//	if (prev && prev.next == src)
	//		prev.next = next
	//	if (next && next.prev == src)
	//		next.prev = prev
	//next = null
	//prev = null
	return QDEL_HINT_IWILLGC

/datum/timedevent/proc/Invoke()
	callBack.Invoke()

/proc/addtimer(datum/callback/callback, wait = 0, flags = 0)
	var/datum/timedevent/timer = new /datum/timedevent(callback, wait)

	timers |= timer //not_actual