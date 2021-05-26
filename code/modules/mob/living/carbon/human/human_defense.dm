/mob/living/carbon/human/getarmor(def_zone, type)
	var/armorval = 0
	var/organnum = 0

	if(def_zone)
		if(isbodypart(def_zone))
			return checkarmor(def_zone, type)
		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(def_zone))
		return checkarmor(affecting, type)

	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		armorval += checkarmor(BP, type)
		organnum++
	return (armorval/max(organnum, 1))

/mob/living/carbon/human/proc/checkarmor(obj/item/bodypart/def_zone, d_type)
	if(!d_type)
		return 0
	var/protection = 0
	var/list/body_parts = list(head, wear_mask, wear_suit, w_uniform, back, gloves, shoes, belt, s_store, glasses, ears, wear_id)
	for(var/bp in body_parts)
		if(!bp)
			continue
		if(bp && istype(bp , /obj/item/clothing))
			var/obj/item/clothing/C = bp
			if(C.body_parts_covered & def_zone.body_part)
				protection += C.armor.getRating(d_type)
	protection += physiology.armor.getRating(d_type)
	return protection

/mob/living/carbon/human/proc/check_block()
	//if(mind)
	//	if(mind.martial_art && prob(mind.martial_art.block_chance) && mind.martial_art.can_use(src) && in_throw_mode && !incapacitated(FALSE, TRUE))
	//		return TRUE
	return FALSE

/mob/living/carbon/human/attack_hand(mob/user)
	if(..())
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		dna.species.spec_attack_hand(H, src)

/mob/living/carbon/human/ex_act(severity, target, origin)
	//if(origin && istype(origin, /datum/spacevine_mutation) && isvineimmune(src))
	//	return
	..()
	if (!severity)
		return
	var/b_loss = 0
	var/f_loss = 0
	var/bomb_armor = getarmor(null, "bomb")

	switch (severity)
		if (1)
			if(prob(bomb_armor))
				b_loss = 500
				var/atom/throw_target = get_edge_target_turf(src, get_dir(src, get_step_away(src, src)))
				throw_at(throw_target, 200, 4)
				damage_clothes(400 - bomb_armor, BRUTE, "bomb")
			else
				for(var/I in contents)
					var/atom/A = I
					A.ex_act(severity)
				gib()
				return

		if (2)
			b_loss = 60
			f_loss = 60
			if(bomb_armor)
				b_loss = 30*(2 - round(bomb_armor*0.01, 0.05))
				f_loss = b_loss
			damage_clothes(200 - bomb_armor, BRUTE, "bomb")
			//if (!istype(ears, /obj/item/clothing/ears/earmuffs))
			//	adjustEarDamage(30, 120)
			if (prob(max(70 - (bomb_armor * 0.5), 0)))
				Unconscious(200)

		if(3)
			b_loss = 30
			if(bomb_armor)
				b_loss = 15*(2 - round(bomb_armor*0.01, 0.05))
			damage_clothes(max(50 - bomb_armor, 0), BRUTE, "bomb")
			//if (!istype(ears, /obj/item/clothing/ears/earmuffs))
			//	adjustEarDamage(15,60)
			if (prob(max(50 - (bomb_armor * 0.5), 0)))
				Unconscious(160)

	take_overall_damage(b_loss,f_loss)

	//if(severity <= 2 || !bomb_armor)
	//	var/max_limb_loss = round(4/severity)
	//	for(var/X in bodyparts)
	//		var/obj/item/bodypart/BP = X
	//		if(prob(50/severity) && !prob(getarmor(BP, "bomb")) && BP.body_zone != BODY_ZONE_HEAD && BP.body_zone != BODY_ZONE_CHEST)
	//			BP.brute_dam = BP.max_damage
	//			//BP.dismember()
	//			max_limb_loss--
	//			if(!max_limb_loss)
	//				break

/mob/living/carbon/human/damage_clothes(damage_amount, damage_type = BRUTE, damage_flag = 0, def_zone)
	if(damage_type != BRUTE && damage_type != BURN)
		return
	damage_amount *= 0.5
	var/list/torn_items = list()

	if(!def_zone || def_zone == BODY_ZONE_HEAD)
		var/obj/item/clothing/head_clothes = null
		if(glasses)
			head_clothes = glasses
		if(wear_mask)
			head_clothes = wear_mask
		if(wear_neck)
			head_clothes = wear_neck
		if(head)
			head_clothes = head
		if(head_clothes)
			torn_items += head_clothes
		else if(ears)
			torn_items += ears

	if(!def_zone || def_zone == BODY_ZONE_CHEST)
		var/obj/item/clothing/chest_clothes = null
		if(w_uniform)
			chest_clothes = w_uniform
		if(wear_suit)
			chest_clothes = wear_suit
		if(chest_clothes)
			torn_items += chest_clothes

	if(!def_zone || def_zone == BODY_ZONE_L_ARM || def_zone == BODY_ZONE_R_ARM)
		var/obj/item/clothing/arm_clothes = null
		if(gloves)
			arm_clothes = gloves
		if(w_uniform && ((w_uniform.body_parts_covered & HANDS) || (w_uniform.body_parts_covered & ARMS)))
			arm_clothes = w_uniform
		if(wear_suit && ((wear_suit.body_parts_covered & HANDS) || (wear_suit.body_parts_covered & ARMS)))
			arm_clothes = wear_suit
		if(arm_clothes)
			torn_items |= arm_clothes

	if(!def_zone || def_zone == BODY_ZONE_L_LEG || def_zone == BODY_ZONE_R_LEG)
		var/obj/item/clothing/leg_clothes = null
		if(shoes)
			leg_clothes = shoes
		if(w_uniform && ((w_uniform.body_parts_covered & FEET) || (w_uniform.body_parts_covered & LEGS)))
			leg_clothes = w_uniform
		if(wear_suit && ((wear_suit.body_parts_covered & FEET) || (wear_suit.body_parts_covered & LEGS)))
			leg_clothes = wear_suit
		if(leg_clothes)
			torn_items |= leg_clothes

	for(var/obj/item/I in torn_items)
		I.take_damage(damage_amount, damage_type, damage_flag, 0)