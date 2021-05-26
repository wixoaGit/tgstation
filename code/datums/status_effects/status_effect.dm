/datum/status_effect
	var/id = "effect"
	var/duration = -1
	var/tick_interval = 10
	var/mob/living/owner
	var/status_type = STATUS_EFFECT_UNIQUE
	var/on_remove_on_mob_delete = FALSE
	var/examine_text
	//var/alert_type = /obj/screen/alert/status_effect
	//var/obj/screen/alert/status_effect/linked_alert = null

/datum/status_effect/New(list/arguments)
	on_creation(arglist(arguments))

///datum/status_effect/proc/on_creation(mob/living/new_owner, ...)
/datum/status_effect/proc/on_creation(mob/living/new_owner)//not_actual
	if(new_owner)
		owner = new_owner
	if(owner)
		LAZYADD(owner.status_effects, src)
	if(!owner || !on_apply())
		qdel(src)
		return
	if(duration != -1)
		duration = world.time + duration
	tick_interval = world.time + tick_interval
	//if(alert_type)
	//	var/obj/screen/alert/status_effect/A = owner.throw_alert(id, alert_type)
	//	A.attached_effect = src
	//	linked_alert = A
	START_PROCESSING(SSfastprocess, src)
	return TRUE

/datum/status_effect/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	if(owner)
		//owner.clear_alert(id)
		LAZYREMOVE(owner.status_effects, src)
		on_remove()
		owner = null
	return ..()

/datum/status_effect/process()
	if(!owner)
		qdel(src)
		return
	if(tick_interval < world.time)
		tick()
		tick_interval = world.time + initial(tick_interval)
	if(duration != -1 && duration < world.time)
		qdel(src)

/datum/status_effect/proc/on_apply()
	return TRUE
/datum/status_effect/proc/tick()
/datum/status_effect/proc/on_remove()
/datum/status_effect/proc/be_replaced()
	//owner.clear_alert(id)
	LAZYREMOVE(owner.status_effects, src)
	owner = null
	qdel(src)

/datum/status_effect/proc/refresh()
	var/original_duration = initial(duration)
	if(original_duration == -1)
		return
	duration = world.time + original_duration

/datum/status_effect/proc/nextmove_modifier()
	return 1

/datum/status_effect/proc/nextmove_adjust()
	return 0

///mob/living/proc/apply_status_effect(effect, ...)
/mob/living/proc/apply_status_effect(effect)//not_actual
	. = FALSE
	var/datum/status_effect/S1 = effect
	LAZYINITLIST(status_effects)
	for(var/datum/status_effect/S in status_effects)
		if(S.id == initial(S1.id) && S.status_type)
			if(S.status_type == STATUS_EFFECT_REPLACE)
				S.be_replaced()
			else if(S.status_type == STATUS_EFFECT_REFRESH)
				S.refresh()
				return
			else
				return
	var/list/arguments = args.Copy()
	arguments[1] = src
	S1 = new effect(arguments)
	. = S1

/mob/living/proc/has_status_effect(effect)
	. = FALSE
	if(status_effects)
		var/datum/status_effect/S1 = effect
		for(var/datum/status_effect/S in status_effects)
			if(initial(S1.id) == S.id)
				return S