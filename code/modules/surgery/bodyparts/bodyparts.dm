/obj/item/bodypart
	name = "limb"
	desc = "Why is it detached..."
	icon = 'icons/mob/human_parts.dmi'
	icon_state = ""
	layer = BELOW_MOB_LAYER
	var/mob/living/carbon/owner = null
	var/mob/living/carbon/original_owner = null
	var/status = BODYPART_ORGANIC
	var/needs_processing = FALSE

	var/body_zone
	var/aux_zone
	var/aux_layer
	var/body_part = null
	var/use_digitigrade = NOT_DIGITIGRADE
	var/list/embedded_objects = list()
	var/held_index = 0
	var/is_pseudopart = FALSE

	var/disabled = BODYPART_NOT_DISABLED
	var/body_damage_coeff = 1
	var/stam_damage_coeff = 0.5
	var/brutestate = 0
	var/burnstate = 0
	var/brute_dam = 0
	var/burn_dam = 0
	var/stamina_dam = 0
	var/max_stamina_damage = 0
	var/max_damage = 0
	var/stam_heal_tick = 3

	var/brute_reduction = 0
	var/burn_reduction = 0

	var/skin_tone = ""
	var/body_gender = ""
	var/species_id = ""
	var/should_draw_gender = FALSE
	var/should_draw_greyscale = FALSE
	var/species_color = ""
	var/mutation_color = ""
	var/no_update = 0

	var/animal_origin = null
	var/dismemberable = 1
	
	var/dmg_overlay_type

	var/light_brute_msg = "bruised"
	var/medium_brute_msg = "battered"
	var/heavy_brute_msg = "mangled"

	var/light_burn_msg = "numb"
	var/medium_burn_msg = "blistered"
	var/heavy_burn_msg = "peeling away"

/obj/item/bodypart/examine(mob/user)
	..()
	if(brute_dam > DAMAGE_PRECISION)
		to_chat(user, "<span class='warning'>This limb has [brute_dam > 30 ? "severe" : "minor"] bruising.</span>")
	if(burn_dam > DAMAGE_PRECISION)
		to_chat(user, "<span class='warning'>This limb has [burn_dam > 30 ? "severe" : "minor"] burns.</span>")

///obj/item/bodypart/blob_act()
//	take_damage(max_damage)

/obj/item/bodypart/Destroy()
	if(owner)
		owner.bodyparts -= src
		owner = null
	return ..()

/obj/item/bodypart/proc/consider_processing()
	if(stamina_dam > DAMAGE_PRECISION)
		. = TRUE
	else
		. = FALSE
	needs_processing = .

/obj/item/bodypart/proc/on_life()
	if(stamina_dam > DAMAGE_PRECISION)
		if(heal_damage(0, 0, stam_heal_tick, null, FALSE))
			. |= BODYPART_LIFE_UPDATE_HEALTH

/obj/item/bodypart/proc/receive_damage(brute = 0, burn = 0, stamina = 0, updating_health = TRUE, required_status = null)
	if(owner && (owner.status_flags & GODMODE))
		return FALSE

	if(required_status && (status != required_status))
		return FALSE

	//var/dmg_mlt = CONFIG_GET(number/damage_multiplier)
	var/dmg_mlt = 1//not_actual
	brute = round(max(brute * dmg_mlt, 0),DAMAGE_PRECISION)
	burn = round(max(burn * dmg_mlt, 0),DAMAGE_PRECISION)
	stamina = round(max(stamina * dmg_mlt, 0),DAMAGE_PRECISION)
	brute = max(0, brute - brute_reduction)
	burn = max(0, burn - burn_reduction)

	if(!brute && !burn && !stamina)
		return FALSE

	//switch(animal_origin)
	//	if(ALIEN_BODYPART,LARVA_BODYPART)
	//		burn *= 2

	var/can_inflict = max_damage - get_damage()
	if(can_inflict <= 0)
		return FALSE

	var/total_damage = brute + burn

	if(total_damage > can_inflict)
		var/excess = total_damage - can_inflict
		brute = round(brute * (excess / total_damage),DAMAGE_PRECISION)
		burn = round(burn * (excess / total_damage),DAMAGE_PRECISION)

	brute_dam += brute
	burn_dam += burn

	var/current_damage = get_damage(TRUE)
	var/available_damage = max_damage - current_damage
	stamina_dam += round(CLAMP(stamina, 0, min(max_stamina_damage - stamina_dam, available_damage)), DAMAGE_PRECISION)

	if(owner && updating_health)
		owner.updatehealth()
		//if(stamina > DAMAGE_PRECISION)
		//	owner.update_stamina()
	consider_processing()
	//update_disabled()
	return update_bodypart_damage_state()

/obj/item/bodypart/proc/heal_damage(brute, burn, stamina, required_status, updating_health = TRUE)

	if(required_status && (status != required_status))
		return

	brute_dam	= round(max(brute_dam - brute, 0), DAMAGE_PRECISION)
	burn_dam	= round(max(burn_dam - burn, 0), DAMAGE_PRECISION)
	stamina_dam = round(max(stamina_dam - stamina, 0), DAMAGE_PRECISION)
	if(owner && updating_health)
		owner.updatehealth()
	consider_processing()
	//update_disabled()
	return update_bodypart_damage_state()

/obj/item/bodypart/proc/get_damage(include_stamina = FALSE)
	var/total = brute_dam + burn_dam
	if(include_stamina)
		total += stamina_dam
	return total

/obj/item/bodypart/proc/update_bodypart_damage_state()
	var/tbrute	= round( (brute_dam/max_damage)*3, 1 )
	var/tburn	= round( (burn_dam/max_damage)*3, 1 )
	if((tbrute != brutestate) || (tburn != burnstate))
		brutestate = tbrute
		burnstate = tburn
		return TRUE
	return FALSE

/obj/item/bodypart/proc/is_organic_limb()
	return (status == BODYPART_ORGANIC)

/obj/item/bodypart/proc/update_limb(dropping_limb, mob/living/carbon/source)
	var/mob/living/carbon/C
	if(source)
		C = source
		if(!original_owner)
			original_owner = source
	else if(original_owner && owner != original_owner)
		no_update = TRUE
	else
		C = owner
		no_update = FALSE

	if(C.has_trait(TRAIT_HUSK) && is_organic_limb())
		species_id = "husk"
		dmg_overlay_type = ""
		should_draw_gender = FALSE
		should_draw_greyscale = FALSE
		no_update = TRUE

	if(no_update)
		return

	if(!animal_origin)
		var/mob/living/carbon/human/H = C
		should_draw_greyscale = FALSE

		var/datum/species/S = H.dna.species
		species_id = S.limbs_id
		//species_flags_list = H.dna.species.species_traits

		if(S.use_skintones)
			skin_tone = H.skin_tone
			should_draw_greyscale = TRUE
		else
			skin_tone = ""

		body_gender = H.gender
		should_draw_gender = S.sexes

		//if((MUTCOLORS in S.species_traits) || (DYNCOLORS in S.species_traits))
		//	if(S.fixed_mut_color)
		//		species_color = S.fixed_mut_color
		//	else
		//		species_color = H.dna.features["mcolor"]
		//	should_draw_greyscale = TRUE
		//else
		//	species_color = ""

		//if(!dropping_limb && H.dna.check_mutation(HULK))
		//	mutation_color = "00aa00"
		//else
		//	mutation_color = ""

		dmg_overlay_type = S.damage_overlay_type

	//else if(animal_origin == MONKEY_BODYPART)
	//	dmg_overlay_type = animal_origin

	//if(status == BODYPART_ROBOTIC)
	//	dmg_overlay_type = "robotic"

	if(dropping_limb)
		no_update = TRUE

/obj/item/bodypart/proc/get_limb_icon(dropped)
	icon_state = ""

	. = list()

	var/image_dir = 0
	if(dropped)
		image_dir = SOUTH
		if(dmg_overlay_type)
			if(brutestate)
				. += image('icons/mob/dam_mob.dmi', "[dmg_overlay_type]_[body_zone]_[brutestate]0", -DAMAGE_LAYER, image_dir)
			if(burnstate)
				. += image('icons/mob/dam_mob.dmi', "[dmg_overlay_type]_[body_zone]_0[burnstate]", -DAMAGE_LAYER, image_dir)

	var/image/limb = image(layer = -BODYPARTS_LAYER, dir = image_dir)
	var/image/aux
	. += limb

	if(animal_origin)
		if(is_organic_limb())
			limb.icon = 'icons/mob/animal_parts.dmi'
			if(species_id == "husk")
				limb.icon_state = "[animal_origin]_husk_[body_zone]"
			else
				limb.icon_state = "[animal_origin]_[body_zone]"
		else
			limb.icon = 'icons/mob/augmentation/augments.dmi'
			limb.icon_state = "[animal_origin]_[body_zone]"
		return

	var/icon_gender = (body_gender == FEMALE) ? "f" : "m"

	if((body_zone != BODY_ZONE_HEAD && body_zone != BODY_ZONE_CHEST))
		should_draw_gender = FALSE

	if(is_organic_limb())
		if(should_draw_greyscale)
			limb.icon = 'icons/mob/human_parts_greyscale.dmi'
			if(should_draw_gender)
				limb.icon_state = "[species_id]_[body_zone]_[icon_gender]"
			else if(use_digitigrade)
				limb.icon_state = "digitigrade_[use_digitigrade]_[body_zone]"
			else
				limb.icon_state = "[species_id]_[body_zone]"
		else
			limb.icon = 'icons/mob/human_parts.dmi'
			if(should_draw_gender)
				limb.icon_state = "[species_id]_[body_zone]_[icon_gender]"
			else
				limb.icon_state = "[species_id]_[body_zone]"
		if(aux_zone)
			aux = image(limb.icon, "[species_id]_[aux_zone]", -aux_layer, image_dir)
			. += aux

	else
		limb.icon = icon
		if(should_draw_gender)
			limb.icon_state = "[body_zone]_[icon_gender]"
		else
			limb.icon_state = "[body_zone]"
		if(aux_zone)
			aux = image(limb.icon, "[aux_zone]", -aux_layer, image_dir)
			. += aux
		return

	if(should_draw_greyscale)
		var/draw_color = mutation_color || species_color || (skin_tone && skintone2hex(skin_tone))
		if(draw_color)
			limb.color = "#[draw_color]"
			if(aux_zone)
				aux.color = "#[draw_color]"

/obj/item/bodypart/chest
	name = BODY_ZONE_CHEST
	desc = "It's impolite to stare at a person's chest."
	icon_state = "default_human_chest"
	max_damage = 200
	body_zone = BODY_ZONE_CHEST
	body_part = CHEST

/obj/item/bodypart/l_arm
	name = "left arm"
	desc = "Did you know that the word 'sinister' stems originally from the \
		Latin 'sinestra' (left hand), because the left hand was supposed to \
		be possessed by the devil? This arm appears to be possessed by no \
		one though."
	icon_state = "default_human_l_arm"
	max_damage = 50
	body_zone = BODY_ZONE_L_ARM
	body_part = ARM_LEFT
	aux_zone = BODY_ZONE_PRECISE_L_HAND
	aux_layer = HANDS_PART_LAYER
	held_index = 1

/obj/item/bodypart/r_arm
	name = "right arm"
	desc = "Over 87% of humans are right handed. That figure is much lower \
		among humans missing their right arm."
	icon_state = "default_human_r_arm"
	max_damage = 50
	body_zone = BODY_ZONE_R_ARM
	body_part = ARM_RIGHT
	aux_zone = BODY_ZONE_PRECISE_R_HAND
	aux_layer = HANDS_PART_LAYER
	held_index = 2

/obj/item/bodypart/l_leg
	name = "left leg"
	desc = "Some athletes prefer to tie their left shoelaces first for good \
		luck. In this instance, it probably would not have helped."
	icon_state = "default_human_l_leg"
	max_damage = 50
	body_zone = BODY_ZONE_L_LEG
	body_part = LEG_LEFT

/obj/item/bodypart/r_leg
	name = "right leg"
	desc = "You put your right leg in, your right leg out. In, out, in, out, \
		shake it all about. And apparently then it detaches.\n\
		The hokey pokey has certainly changed a lot since space colonisation."
	icon_state = "default_human_r_leg"
	max_damage = 50
	body_zone = BODY_ZONE_R_LEG
	body_part = LEG_RIGHT