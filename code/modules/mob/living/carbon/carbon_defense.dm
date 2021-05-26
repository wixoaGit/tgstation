/mob/living/carbon/is_mouth_covered(head_only = 0, mask_only = 0)
	if( (!mask_only && head && (head.flags_cover & HEADCOVERSMOUTH)) || (!head_only && wear_mask && (wear_mask.flags_cover & MASKCOVERSMOUTH)) )
		return TRUE

/mob/living/carbon/is_eyes_covered(check_glasses = TRUE, check_head = TRUE, check_mask = TRUE)
	if(check_head && head && (head.flags_cover & HEADCOVERSEYES))
		return head
	if(check_mask && wear_mask && (wear_mask.flags_cover & MASKCOVERSEYES))
		return wear_mask
	if(check_glasses && glasses && (glasses.flags_cover & GLASSESCOVERSEYES))
		return glasses

/mob/living/carbon/proc/can_catch_item(skip_throw_mode_check)
	. = FALSE
	if(!skip_throw_mode_check && !in_throw_mode)
		return
	if(get_active_held_item())
		return
	if(!(mobility_flags & MOBILITY_MOVE))
		return
	if(restrained())
		return
	return TRUE

/mob/living/carbon/hitby(atom/movable/AM, skipcatch, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	if(!skipcatch)
		if(can_catch_item())
			if(istype(AM, /obj/item))
				var/obj/item/I = AM
				if(isturf(I.loc))
					I.attack_hand(src)
					if(get_active_held_item() == I)
						visible_message("<span class='warning'>[src] catches [I]!</span>")
						throw_mode_off()
						return 1
	..()

/mob/living/carbon/attacked_by(obj/item/I, mob/living/user)
	var/obj/item/bodypart/affecting
	if(user == src)
		affecting = get_bodypart(check_zone(user.zone_selected))
	else
		affecting = get_bodypart(ran_zone(user.zone_selected))
	if(!affecting)
		affecting = bodyparts[1]
	SEND_SIGNAL(I, COMSIG_ITEM_ATTACK_ZONE, src, user, affecting)
	send_item_attack_message(I, user, affecting.name)
	if(I.force)
		apply_damage(I.force, I.damtype, affecting)
		//if(I.damtype == BRUTE && affecting.status == BODYPART_ORGANIC)
		//	if(prob(33))
		//		I.add_mob_blood(src)
		//		var/turf/location = get_turf(src)
		//		add_splatter_floor(location)
		//		if(get_dist(user, src) <= 1)
		//			user.add_mob_blood(src)
		//			if(ishuman(user))
		//				var/mob/living/carbon/human/dirtyboy
		//				dirtyboy.adjust_hygiene(-10)
		//		if(affecting.body_zone == BODY_ZONE_HEAD)
		//			if(wear_mask)
		//				wear_mask.add_mob_blood(src)
		//				update_inv_wear_mask()
		//			if(wear_neck)
		//				wear_neck.add_mob_blood(src)
		//				update_inv_neck()
		//			if(head)
		//				head.add_mob_blood(src)
		//				update_inv_head()

		//var/probability = I.get_dismemberment_chance(affecting)
		//if(prob(probability))
		//	if(affecting.dismember(I.damtype))
		//		I.add_mob_blood(src)
		//		playsound(get_turf(src), I.get_dismember_sound(), 80, 1)
		return TRUE

/mob/living/carbon/proc/help_shake_act(mob/living/carbon/M)
	if(on_fire)
		to_chat(M, "<span class='warning'>You can't put [p_them()] out with just your bare hands!</span>")
		return

	if(!(mobility_flags & MOBILITY_STAND))
		if(buckled)
			to_chat(M, "<span class='warning'>You need to unbuckle [src] first to do that!")
			return
		M.visible_message("<span class='notice'>[M] shakes [src] trying to get [p_them()] up!</span>", \
						"<span class='notice'>You shake [src] trying to get [p_them()] up!</span>")
	else
		M.visible_message("<span class='notice'>[M] hugs [src] to make [p_them()] feel better!</span>", \
					"<span class='notice'>You hug [src] to make [p_them()] feel better!</span>")
		//SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "hug", /datum/mood_event/hug)
		//for(var/datum/brain_trauma/trauma in M.get_traumas())
		//	trauma.on_hug(M, src)
	//AdjustStun(-60)
	//AdjustKnockdown(-60)
	AdjustUnconscious(-60)
	//AdjustSleeping(-100)
	//AdjustParalyzed(-60)
	//AdjustImmobilized(-60)
	set_resting(FALSE)

	playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

/mob/living/carbon/human/proc/check_self_for_injuries()
	visible_message("[src] examines [p_them()]self.", \
		"<span class='notice'>You check yourself for injuries.</span>")

	var/list/missing = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	for(var/X in bodyparts)
		var/obj/item/bodypart/LB = X
		missing -= LB.body_zone
		if(LB.is_pseudopart)
			continue
		var/limb_max_damage = LB.max_damage
		var/status = ""
		var/brutedamage = LB.brute_dam
		var/burndamage = LB.burn_dam
		if(hallucination)
			if(prob(30))
				brutedamage += rand(30,40)
			if(prob(30))
				burndamage += rand(30,40)

		if(has_trait(TRAIT_SELF_AWARE))
			status = "[brutedamage] brute damage and [burndamage] burn damage"
			if(!brutedamage && !burndamage)
				status = "no damage"

		else
			if(brutedamage > 0)
				status = LB.light_brute_msg
			if(brutedamage > (limb_max_damage*0.4))
				status = LB.medium_brute_msg
			if(brutedamage > (limb_max_damage*0.8))
				status = LB.heavy_brute_msg
			if(brutedamage > 0 && burndamage > 0)
				status += " and "

			if(burndamage > (limb_max_damage*0.8))
				status += LB.heavy_burn_msg
			else if(burndamage > (limb_max_damage*0.2))
				status += LB.medium_burn_msg
			else if(burndamage > 0)
				status += LB.light_burn_msg

			if(status == "")
				status = "OK"
		var/no_damage
		if(status == "OK" || status == "no damage")
			no_damage = TRUE
		to_chat(src, "\t <span class='[no_damage ? "notice" : "warning"]'>Your [LB.name] [has_trait(TRAIT_SELF_AWARE) ? "has" : "is"] [status].</span>")

		for(var/obj/item/I in LB.embedded_objects)
			to_chat(src, "\t <a href='?src=[REF(src)];embedded_object=[REF(I)];embedded_limb=[REF(LB)]' class='warning'>There is \a [I] embedded in your [LB.name]!</a>")

	for(var/t in missing)
		to_chat(src, "<span class='boldannounce'>Your [parse_zone(t)] is missing!</span>")

	if(bleed_rate)
		to_chat(src, "<span class='danger'>You are bleeding!</span>")
	if(getStaminaLoss())
		if(getStaminaLoss() > 30)
			to_chat(src, "<span class='info'>You're completely exhausted.</span>")
		else
			to_chat(src, "<span class='info'>You feel fatigued.</span>")
	if(has_trait(TRAIT_SELF_AWARE))
		if(toxloss)
			if(toxloss > 10)
				to_chat(src, "<span class='danger'>You feel sick.</span>")
			else if(toxloss > 20)
				to_chat(src, "<span class='danger'>You feel nauseated.</span>")
			else if(toxloss > 40)
				to_chat(src, "<span class='danger'>You feel very unwell!</span>")
		if(oxyloss)
			if(oxyloss > 10)
				to_chat(src, "<span class='danger'>You feel lightheaded.</span>")
			else if(oxyloss > 20)
				to_chat(src, "<span class='danger'>Your thinking is clouded and distant.</span>")
			else if(oxyloss > 30)
				to_chat(src, "<span class='danger'>You're choking!</span>")

	if(!has_trait(TRAIT_NOHUNGER))
		//switch(nutrition)
		//	if(NUTRITION_LEVEL_FULL to INFINITY)
		//		to_chat(src, "<span class='info'>You're completely stuffed!</span>")
		//	if(NUTRITION_LEVEL_WELL_FED to NUTRITION_LEVEL_FULL)
		//		to_chat(src, "<span class='info'>You're well fed!</span>")
		//	if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
		//		to_chat(src, "<span class='info'>You're not hungry.</span>")
		//	if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
		//		to_chat(src, "<span class='info'>You could use a bite to eat.</span>")
		//	if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
		//		to_chat(src, "<span class='info'>You feel quite hungry.</span>")
		//	if(0 to NUTRITION_LEVEL_STARVING)
		//		to_chat(src, "<span class='danger'>You're starving!</span>")
		//not_actual
		if (nutrition >= NUTRITION_LEVEL_FULL)
			to_chat(src, "<span class='info'>You're completely stuffed!</span>")
		else if (nutrition >= NUTRITION_LEVEL_WELL_FED)
			to_chat(src, "<span class='info'>You're well fed!</span>")
		else if (nutrition >= NUTRITION_LEVEL_FED)
			to_chat(src, "<span class='info'>You're not hungry.</span>")
		else if (nutrition >= NUTRITION_LEVEL_HUNGRY)
			to_chat(src, "<span class='info'>You could use a bite to eat.</span>")
		else if (nutrition >= NUTRITION_LEVEL_STARVING)
			to_chat(src, "<span class='info'>You feel quite hungry.</span>")
		else
			to_chat(src, "<span class='danger'>You're starving!</span>")
	
	//if(roundstart_quirks.len)
	//	to_chat(src, "<span class='notice'>You have these quirks: [get_trait_string()].</span>")

/mob/living/carbon/damage_clothes(damage_amount, damage_type = BRUTE, damage_flag = 0, def_zone)
	if(damage_type != BRUTE && damage_type != BURN)
		return
	damage_amount *= 0.5
	if(!def_zone || def_zone == BODY_ZONE_HEAD)
		var/obj/item/clothing/hit_clothes
		if(wear_mask)
			hit_clothes = wear_mask
		if(wear_neck)
			hit_clothes = wear_neck
		if(head)
			hit_clothes = head
		if(hit_clothes)
			hit_clothes.take_damage(damage_amount, damage_type, damage_flag, 0)