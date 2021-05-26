/mob/living/carbon/Life()
	//set invisibility = 0

	if(notransform)
		return

	//if(damageoverlaytemp)
	//	damageoverlaytemp = 0
	//	update_damage_hud()

	//if(stat != DEAD)
	//	handle_organs()

	. = ..()

	if (QDELETED(src))
		return

	//if(.)
	//	handle_blood()

	if(stat != DEAD)
		var/bprv = handle_bodyparts()
		if(bprv & BODYPART_LIFE_UPDATE_HEALTH)
			updatehealth()
			update_stamina()

	//if(stat != DEAD)
	//	handle_brain_damage()

	//if(stat != DEAD)
	//	handle_liver()

	//if(stat == DEAD)
	//	stop_sound_channel(CHANNEL_HEARTBEAT)
	//	LoadComponent(/datum/component/rot/corpse)

	//handle_changeling()

	if(stat != DEAD)
		return 1

/mob/living/carbon/proc/handle_blood()
	return

/mob/living/carbon/proc/handle_bodyparts()
	for(var/I in bodyparts)
		var/obj/item/bodypart/BP = I
		if(BP.needs_processing)
			. |= BP.on_life()

/mob/living/carbon/proc/undergoing_liver_failure()
	//var/obj/item/organ/liver/liver = getorganslot(ORGAN_SLOT_LIVER)
	//if(liver && liver.failing)
	//	return TRUE

/mob/living/carbon/proc/return_liver_damage()
	//var/obj/item/organ/liver/liver = getorganslot(ORGAN_SLOT_LIVER)
	//if(liver)
	//	return liver.damage
	return 0//not_actual

/mob/living/carbon/proc/undergoing_cardiac_arrest()
	//var/obj/item/organ/heart/heart = getorganslot(ORGAN_SLOT_HEART)
	//if(istype(heart) && heart.beating)
	//	return FALSE
	//else if(!needs_heart())
	//	return FALSE
	return TRUE