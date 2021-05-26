/mob/living/proc/apply_damage(damage = 0,damagetype = BRUTE, def_zone = null, blocked = FALSE)
	var/hit_percent = (100-blocked)/100
	if(!damage || (hit_percent <= 0))
		return 0
	switch(damagetype)
		if(BRUTE)
			adjustBruteLoss(damage * hit_percent)
		if(BURN)
			adjustFireLoss(damage * hit_percent)
		if(TOX)
			adjustToxLoss(damage * hit_percent)
		if(OXY)
			adjustOxyLoss(damage * hit_percent)
		if(CLONE)
			adjustCloneLoss(damage * hit_percent)
		if(STAMINA)
			adjustStaminaLoss(damage * hit_percent)
		if(BRAIN)
			adjustBrainLoss(damage * hit_percent)
	return 1

/mob/living/proc/apply_damage_type(damage = 0, damagetype = BRUTE)
	switch(damagetype)
		if(BRUTE)
			return adjustBruteLoss(damage)
		if(BURN)
			return adjustFireLoss(damage)
		if(TOX)
			return adjustToxLoss(damage)
		if(OXY)
			return adjustOxyLoss(damage)
		if(CLONE)
			return adjustCloneLoss(damage)
		if(STAMINA)
			return adjustStaminaLoss(damage)
		if(BRAIN)
			return adjustBrainLoss(damage)

/mob/living/proc/apply_effect(effect = 0,effecttype = EFFECT_STUN, blocked = FALSE)
	var/hit_percent = (100-blocked)/100
	if(!effect || (hit_percent <= 0))
		return 0
	switch(effecttype)
		//if(EFFECT_STUN)
		//	Stun(effect * hit_percent)
		//if(EFFECT_KNOCKDOWN)
		//	Knockdown(effect * hit_percent)
		//if(EFFECT_PARALYZE)
		//	Paralyze(effect * hit_percent)
		//if(EFFECT_IMMOBILIZE)
		//	Immobilize(effect * hit_percent)
		if(EFFECT_UNCONSCIOUS)
			Unconscious(effect * hit_percent)
		//if(EFFECT_IRRADIATE)
		//	radiation += max(effect * hit_percent, 0)
		//if(EFFECT_SLUR)
		//	slurring = max(slurring,(effect * hit_percent))
		//if(EFFECT_STUTTER)
		//	if((status_flags & CANSTUN) && !has_trait(TRAIT_STUNIMMUNE))
		//		stuttering = max(stuttering,(effect * hit_percent))
		//if(EFFECT_EYE_BLUR)
		//	blur_eyes(effect * hit_percent)
		//if(EFFECT_DROWSY)
		//	drowsyness = max(drowsyness,(effect * hit_percent))
		//if(EFFECT_JITTER)
		//	if((status_flags & CANSTUN) && !has_trait(TRAIT_STUNIMMUNE))
		//		jitteriness = max(jitteriness,(effect * hit_percent))
		//if(EFFECT_PARALYZE)
		//	Paralyze(effect * hit_percent)
		//if(EFFECT_IMMOBILIZE)
		//	Immobilize(effect * hit_percent)
	return 1

/mob/living/proc/apply_effects(stun = 0, knockdown = 0, unconscious = 0, irradiate = 0, slur = 0, stutter = 0, eyeblur = 0, drowsy = 0, blocked = FALSE, stamina = 0, jitter = 0, paralyze = 0, immobilize = 0)
	if(blocked >= 100)
		return 0
	//if(stun)
	//	apply_effect(stun, EFFECT_STUN, blocked)
	//if(knockdown)
	//	apply_effect(knockdown, EFFECT_KNOCKDOWN, blocked)
	if(unconscious)
		apply_effect(unconscious, EFFECT_UNCONSCIOUS, blocked)
	//if(paralyze)
	//	apply_effect(paralyze, EFFECT_PARALYZE, blocked)
	//if(immobilize)
	//	apply_effect(immobilize, EFFECT_IMMOBILIZE, blocked)
	//if(irradiate)
	//	apply_effect(irradiate, EFFECT_IRRADIATE, blocked)
	//if(slur)
	//	apply_effect(slur, EFFECT_SLUR, blocked)
	//if(stutter)
	//	apply_effect(stutter, EFFECT_STUTTER, blocked)
	//if(eyeblur)
	//	apply_effect(eyeblur, EFFECT_EYE_BLUR, blocked)
	//if(drowsy)
	//	apply_effect(drowsy, EFFECT_DROWSY, blocked)
	if(stamina)
		apply_damage(stamina, STAMINA, null, blocked)
	//if(jitter)
	//	apply_effect(jitter, EFFECT_JITTER, blocked)
	return 1

/mob/living/proc/getBruteLoss()
	return bruteloss

/mob/living/proc/adjustBruteLoss(amount, updating_health = TRUE, forced = FALSE, required_status)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	//bruteloss = CLAMP((bruteloss + (amount * CONFIG_GET(number/damage_multiplier))), 0, maxHealth * 2)
	bruteloss = CLAMP((bruteloss + amount), 0, maxHealth * 2)//not_actual
	if(updating_health)
		updatehealth()
	return amount

/mob/living/proc/getOxyLoss()
	return oxyloss

/mob/living/proc/adjustOxyLoss(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	//oxyloss = CLAMP((oxyloss + (amount * CONFIG_GET(number/damage_multiplier))), 0, maxHealth * 2)
	oxyloss = CLAMP((oxyloss + amount), 0, maxHealth * 2)//not_actual
	if(updating_health)
		updatehealth()
	return amount

/mob/living/proc/setOxyLoss(amount, updating_health = TRUE, forced = FALSE)
	if(status_flags & GODMODE)
		return 0
	oxyloss = amount
	if(updating_health)
		updatehealth()
	return amount

/mob/living/proc/getToxLoss()
	return toxloss

/mob/living/proc/adjustToxLoss(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	//toxloss = CLAMP((toxloss + (amount * CONFIG_GET(number/damage_multiplier))), 0, maxHealth * 2)
	toxloss = CLAMP((toxloss + amount), 0, maxHealth * 2)//not_actual
	if(updating_health)
		updatehealth()
	return amount

/mob/living/proc/setToxLoss(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	toxloss = amount
	if(updating_health)
		updatehealth()
	return amount

/mob/living/proc/getFireLoss()
	return fireloss

/mob/living/proc/adjustFireLoss(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	//fireloss = CLAMP((fireloss + (amount * CONFIG_GET(number/damage_multiplier))), 0, maxHealth * 2)
	fireloss = CLAMP((fireloss + amount), 0, maxHealth * 2)//not_actual
	if(updating_health)
		updatehealth()
	return amount

/mob/living/proc/getCloneLoss()
	return cloneloss

/mob/living/proc/adjustCloneLoss(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	//cloneloss = CLAMP((cloneloss + (amount * CONFIG_GET(number/damage_multiplier))), 0, maxHealth * 2)
	cloneloss = CLAMP((cloneloss + amount), 0, maxHealth * 2)//not_actual
	if(updating_health)
		updatehealth()
	return amount

/mob/living/proc/setCloneLoss(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	cloneloss = amount
	if(updating_health)
		updatehealth()
	return amount

/mob/living/proc/getBrainLoss()
	. = 0

/mob/living/proc/adjustBrainLoss(amount, maximum = BRAIN_DAMAGE_DEATH)
	return

/mob/living/proc/setBrainLoss(amount)
	return

/mob/living/proc/getStaminaLoss()
	return staminaloss

/mob/living/proc/adjustStaminaLoss(amount, updating_stamina = TRUE, forced = FALSE)
	return

/mob/living/proc/setStaminaLoss(amount, updating_stamina = TRUE, forced = FALSE)
	return

/mob/living/proc/heal_bodypart_damage(brute = 0, burn = 0, stamina = 0, updating_health = TRUE, required_status)
	adjustBruteLoss(-brute, FALSE)
	adjustFireLoss(-burn, FALSE)
	adjustStaminaLoss(-stamina, FALSE)
	if(updating_health)
		updatehealth()
		update_stamina()

/mob/living/proc/take_bodypart_damage(brute = 0, burn = 0, stamina = 0, updating_health = TRUE, required_status)
	adjustBruteLoss(brute, FALSE)
	adjustFireLoss(burn, FALSE)
	adjustStaminaLoss(stamina, FALSE)
	if(updating_health)
		updatehealth()
		update_stamina()

/mob/living/proc/heal_overall_damage(brute = 0, burn = 0, stamina = 0, required_status, updating_health = TRUE)
	adjustBruteLoss(-brute, FALSE)
	adjustFireLoss(-burn, FALSE)
	adjustStaminaLoss(-stamina, FALSE)
	if(updating_health)
		updatehealth()
		update_stamina()

/mob/living/proc/take_overall_damage(brute = 0, burn = 0, stamina = 0, updating_health = TRUE, required_status = null)
	adjustBruteLoss(brute, FALSE)
	adjustFireLoss(burn, FALSE)
	adjustStaminaLoss(stamina, FALSE)
	if(updating_health)
		updatehealth()
		update_stamina()