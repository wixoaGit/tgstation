/mob/living/proc/IsStun()
	return has_status_effect(STATUS_EFFECT_STUN)

/mob/living/proc/IsKnockdown()
	return has_status_effect(STATUS_EFFECT_KNOCKDOWN)

/mob/living/proc/IsParalyzed()
	return has_status_effect(STATUS_EFFECT_PARALYZED)

/mob/living/proc/IsUnconscious()
	return has_status_effect(STATUS_EFFECT_UNCONSCIOUS)

/mob/living/proc/Unconscious(amount, updating = TRUE, ignore_canstun = FALSE)
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_UNCONSCIOUS, amount, updating, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(((status_flags & CANUNCONSCIOUS) && !has_trait(TRAIT_STUNIMMUNE))  || ignore_canstun)
		var/datum/status_effect/incapacitating/unconscious/U = IsUnconscious()
		if(U)
			U.duration = max(world.time + amount, U.duration)
		else if(amount > 0)
			U = apply_status_effect(STATUS_EFFECT_UNCONSCIOUS, amount, updating)
		return U

/mob/living/proc/SetUnconscious(amount, updating = TRUE, ignore_canstun = FALSE)
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_UNCONSCIOUS, amount, updating, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(((status_flags & CANUNCONSCIOUS) && !has_trait(TRAIT_STUNIMMUNE)) || ignore_canstun)
		var/datum/status_effect/incapacitating/unconscious/U = IsUnconscious()
		if(amount <= 0)
			if(U)
				qdel(U)
		else if(U)
			U.duration = world.time + amount
		else
			U = apply_status_effect(STATUS_EFFECT_UNCONSCIOUS, amount, updating)
		return U

/mob/living/proc/AdjustUnconscious(amount, updating = TRUE, ignore_canstun = FALSE)
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_UNCONSCIOUS, amount, updating, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(((status_flags & CANUNCONSCIOUS) && !has_trait(TRAIT_STUNIMMUNE)) || ignore_canstun)
		var/datum/status_effect/incapacitating/unconscious/U = IsUnconscious()
		if(U)
			U.duration += amount
		else if(amount > 0)
			U = apply_status_effect(STATUS_EFFECT_UNCONSCIOUS, amount, updating)
		return U