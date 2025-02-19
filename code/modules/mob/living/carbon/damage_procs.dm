/mob/living/carbon/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked = FALSE)
	var/hit_percent = (100-blocked)/100
	if(!damage || hit_percent <= 0)
		return 0

	var/obj/item/bodypart/BP = null
	if(isbodypart(def_zone))
		BP = def_zone
	else
		if(!def_zone)
			def_zone = ran_zone(def_zone)
		BP = get_bodypart(check_zone(def_zone))
		if(!BP)
			BP = bodyparts[1]

	switch(damagetype)
		if(BRUTE)
			if(BP)
				if(BP.receive_damage(damage * hit_percent, 0))
					update_damage_overlays()
			else
				adjustBruteLoss(damage * hit_percent)
		if(BURN)
			if(BP)
				if(BP.receive_damage(0, damage * hit_percent))
					update_damage_overlays()
			else
				adjustFireLoss(damage * hit_percent)
		if(TOX)
			adjustToxLoss(damage * hit_percent)
		if(OXY)
			adjustOxyLoss(damage * hit_percent)
		if(CLONE)
			adjustCloneLoss(damage * hit_percent)
		if(STAMINA)
			if(BP)
				if(BP.receive_damage(0, 0, damage * hit_percent))
					update_damage_overlays()
			else
				adjustStaminaLoss(damage * hit_percent)
		if(BRAIN)
			adjustBrainLoss(damage * hit_percent)
	return TRUE


/mob/living/carbon/getBruteLoss()
	var/amount = 0
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		amount += BP.brute_dam
	return amount

/mob/living/carbon/getFireLoss()
	var/amount = 0
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		amount += BP.burn_dam
	return amount


/mob/living/carbon/adjustBruteLoss(amount, updating_health = TRUE, forced = FALSE, required_status)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	if(amount > 0)
		take_overall_damage(amount, 0, 0, updating_health, required_status)
	else
		heal_overall_damage(abs(amount), 0, 0, required_status ? required_status : BODYPART_ORGANIC, updating_health)
	return amount

/mob/living/carbon/adjustFireLoss(amount, updating_health = TRUE, forced = FALSE, required_status)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	if(amount > 0)
		take_overall_damage(0, amount, 0, updating_health, required_status)
	else
		heal_overall_damage(0, abs(amount), 0, required_status ? required_status : BODYPART_ORGANIC, updating_health)
	return amount

/mob/living/carbon/adjustToxLoss(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && has_trait(TRAIT_TOXINLOVER))
		amount = -amount
		if(amount > 0)
			blood_volume -= 5*amount
		else
			blood_volume -= amount
	return ..()

/mob/living/carbon/getStaminaLoss()
	. = 0
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		. += round(BP.stamina_dam * BP.stam_damage_coeff, DAMAGE_PRECISION)

/mob/living/carbon/adjustStaminaLoss(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	if(amount > 0)
		take_overall_damage(0, 0, amount, updating_health)
	else
		heal_overall_damage(0, 0, abs(amount), null, updating_health)
	return amount

/mob/living/carbon/setStaminaLoss(amount, updating = TRUE, forced = FALSE)
	var/current = getStaminaLoss()
	var/diff = amount - current
	if(!diff)
		return
	adjustStaminaLoss(diff, updating, forced)

/mob/living/carbon/proc/get_damaged_bodyparts(brute = FALSE, burn = FALSE, stamina = FALSE, status)
	var/list/obj/item/bodypart/parts = list()
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		if(status && (BP.status != status))
			continue
		if((brute && BP.brute_dam) || (burn && BP.burn_dam) || (stamina && BP.stamina_dam))
			parts += BP
	return parts

/mob/living/carbon/proc/get_damageable_bodyparts(status)
	var/list/obj/item/bodypart/parts = list()
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		if(status && (BP.status != status))
			continue
		if(BP.brute_dam + BP.burn_dam < BP.max_damage)
			parts += BP
	return parts

/mob/living/carbon/heal_bodypart_damage(brute = 0, burn = 0, stamina = 0, updating_health = TRUE, required_status)
	var/list/obj/item/bodypart/parts = get_damaged_bodyparts(brute,burn,stamina,required_status)
	if(!parts.len)
		return
	var/obj/item/bodypart/picked = pick(parts)
	if(picked.heal_damage(brute, burn, stamina, required_status))
		update_damage_overlays()

/mob/living/carbon/take_bodypart_damage(brute = 0, burn = 0, stamina = 0, updating_health = TRUE, required_status)
	var/list/obj/item/bodypart/parts = get_damageable_bodyparts(required_status)
	if(!parts.len)
		return
	var/obj/item/bodypart/picked = pick(parts)
	if(picked.receive_damage(brute, burn, stamina))
		update_damage_overlays()

/mob/living/carbon/heal_overall_damage(brute = 0, burn = 0, stamina = 0, required_status, updating_health = TRUE)
	var/list/obj/item/bodypart/parts = get_damaged_bodyparts(brute, burn, stamina, required_status)

	var/update = NONE
	while(parts.len && (brute > 0 || burn > 0 || stamina > 0))
		var/obj/item/bodypart/picked = pick(parts)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam
		var/stamina_was = picked.stamina_dam

		update |= picked.heal_damage(brute, burn, stamina, required_status, FALSE)

		brute = round(brute - (brute_was - picked.brute_dam), DAMAGE_PRECISION)
		burn = round(burn - (burn_was - picked.burn_dam), DAMAGE_PRECISION)
		stamina = round(stamina - (stamina_was - picked.stamina_dam), DAMAGE_PRECISION)

		parts -= picked
	if(updating_health)
		updatehealth()
		update_stamina()
	if(update)
		update_damage_overlays()

/mob/living/carbon/take_overall_damage(brute = 0, burn = 0, stamina = 0, updating_health = TRUE, required_status)
	if(status_flags & GODMODE)
		return

	var/list/obj/item/bodypart/parts = get_damageable_bodyparts(required_status)
	var/update = 0
	while(parts.len && (brute > 0 || burn > 0 || stamina > 0))
		var/obj/item/bodypart/picked = pick(parts)
		var/brute_per_part = round(brute/parts.len, DAMAGE_PRECISION)
		var/burn_per_part = round(burn/parts.len, DAMAGE_PRECISION)
		var/stamina_per_part = round(stamina/parts.len, DAMAGE_PRECISION)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam
		var/stamina_was = picked.stamina_dam


		update |= picked.receive_damage(brute_per_part, burn_per_part, stamina_per_part, FALSE, required_status)

		brute	= round(brute - (picked.brute_dam - brute_was), DAMAGE_PRECISION)
		burn	= round(burn - (picked.burn_dam - burn_was), DAMAGE_PRECISION)
		stamina = round(stamina - (picked.stamina_dam - stamina_was), DAMAGE_PRECISION)

		parts -= picked
	if(updating_health)
		updatehealth()
	if(update)
		update_damage_overlays()
	update_stamina()