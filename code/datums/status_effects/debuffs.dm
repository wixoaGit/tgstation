/datum/status_effect/incapacitating
	tick_interval = 0
	status_type = STATUS_EFFECT_REPLACE
	//alert_type = null
	var/needs_update_stat = FALSE

/datum/status_effect/incapacitating/on_creation(mob/living/new_owner, set_duration, updating_canmove)
	if(isnum(set_duration))
		duration = set_duration
	. = ..()
	if(.)
		if(updating_canmove)
			owner.update_mobility()
			if(needs_update_stat || issilicon(owner))
				owner.update_stat()

/datum/status_effect/incapacitating/on_remove()
	owner.update_mobility()
	if(needs_update_stat || issilicon(owner))
		owner.update_stat()

/datum/status_effect/incapacitating/stun
	id = "stun"

/datum/status_effect/incapacitating/knockdown
	id = "knockdown"

/datum/status_effect/incapacitating/immobilized
	id = "immobilized"

/datum/status_effect/incapacitating/paralyzed
	id = "paralyzed"

/datum/status_effect/incapacitating/unconscious
	id = "unconscious"
	needs_update_stat = TRUE

/datum/status_effect/incapacitating/unconscious/tick()
	if(owner.getStaminaLoss())
		owner.adjustStaminaLoss(-0.3)