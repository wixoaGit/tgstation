/datum
	var/gc_destroyed
	var/list/datum_components
	var/list/status_traits
	var/list/comp_lookup
	var/list/signal_procs
	var/signal_enabled = FALSE
	var/datum_flags = NONE

/datum/proc/Destroy(force=FALSE, ...)
	tag = null
	datum_flags &= ~DF_USE_TAG
	//weak_reference = null

	//var/list/timers = active_timers
	//active_timers = null
	//for(var/thing in timers)
	//	var/datum/timedevent/timer = thing
	//	if (timer.spent)
	//		continue
	//	qdel(timer)

	signal_enabled = FALSE

	var/list/dc = datum_components
	if(dc)
		var/all_components = dc[/datum/component]
		if(length(all_components))
			for(var/I in all_components)
				var/datum/component/C = I
				qdel(C, FALSE, TRUE)
		else
			var/datum/component/C = all_components
			qdel(C, FALSE, TRUE)
		dc.Cut()

	var/list/lookup = comp_lookup
	if(lookup)
		for(var/sig in lookup)
			var/list/comps = lookup[sig]
			if(length(comps))
				for(var/i in comps)
					var/datum/component/comp = i
					comp.UnregisterSignal(src, sig)
			else
				var/datum/component/comp = comps
				comp.UnregisterSignal(src, sig)
		comp_lookup = lookup = null

	for(var/target in signal_procs)
		UnregisterSignal(target, signal_procs[target])

	return QDEL_HINT_QUEUE