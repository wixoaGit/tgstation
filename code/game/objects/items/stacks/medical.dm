/obj/item/stack/medical
	name = "medical pack"
	singular_name = "medical pack"
	icon = 'icons/obj/stack_objects.dmi'
	amount = 6
	max_amount = 6
	w_class = WEIGHT_CLASS_TINY
	full_w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	resistance_flags = FLAMMABLE
	max_integrity = 40
	novariants = FALSE
	var/heal_brute = 0
	var/heal_burn = 0
	var/stop_bleeding = 0
	var/self_delay = 50

/obj/item/stack/medical/attack(mob/living/M, mob/user)

	if(M.stat == DEAD)
		var/t_him = "it"
		if(M.gender == MALE)
			t_him = "him"
		else if(M.gender == FEMALE)
			t_him = "her"
		to_chat(user, "<span class='danger'>\The [M] is dead, you cannot help [t_him]!</span>")
		return

	//if(!iscarbon(M) && !isanimal(M))
	if (!iscarbon(M))//not_actual
		to_chat(user, "<span class='danger'>You don't know how to apply \the [src] to [M]!</span>")
		return 1

	var/obj/item/bodypart/affecting
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		affecting = C.get_bodypart(check_zone(user.zone_selected))
		if(!affecting)
			to_chat(user, "<span class='warning'>[C] doesn't have \a [parse_zone(user.zone_selected)]!</span>")
			return
		//if(ishuman(C))
		//	var/mob/living/carbon/human/H = C
		//	if(stop_bleeding)
		//		if(H.bleedsuppress)
		//			to_chat(user, "<span class='warning'>[H]'s bleeding is already bandaged!</span>")
		//			return
		//		else if(!H.bleed_rate)
		//			to_chat(user, "<span class='warning'>[H] isn't bleeding!</span>")
		//			return


	//if(isliving(M))
	//	if(!M.can_inject(user, 1))
	//		return

	if(user)
		if (M != user)
			//if (isanimal(M))
			//	var/mob/living/simple_animal/critter = M
			//	if (!(critter.healable))
			//		to_chat(user, "<span class='notice'> You cannot use [src] on [M]!</span>")
			//		return
			//	else if (critter.health == critter.maxHealth)
			//		to_chat(user, "<span class='notice'> [M] is at full health.</span>")
			//		return
			//	else if(src.heal_brute < 1)
			//		to_chat(user, "<span class='notice'> [src] won't help [M] at all.</span>")
			//		return
			user.visible_message("<span class='green'>[user] applies [src] on [M].</span>", "<span class='green'>You apply [src] on [M].</span>")
		else
			var/t_himself = "itself"
			if(user.gender == MALE)
				t_himself = "himself"
			else if(user.gender == FEMALE)
				t_himself = "herself"
			user.visible_message("<span class='notice'>[user] starts to apply [src] on [t_himself]...</span>", "<span class='notice'>You begin applying [src] on yourself...</span>")
			//if(!do_mob(user, M, self_delay, extra_checks=CALLBACK(M, /mob/living/proc/can_inject, user, TRUE)))
			if(!do_mob(user, M, self_delay))//not_actual
				return
			user.visible_message("<span class='green'>[user] applies [src] on [t_himself].</span>", "<span class='green'>You apply [src] on yourself.</span>")


	if(iscarbon(M))
		var/mob/living/carbon/C = M
		affecting = C.get_bodypart(check_zone(user.zone_selected))
		if(!affecting)
			to_chat(user, "<span class='warning'>[C] doesn't have \a [parse_zone(user.zone_selected)]!</span>")
			return
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			//if(stop_bleeding)
			//	if(!H.bleedsuppress)
			//		H.suppress_bloodloss(stop_bleeding)
		if(affecting.status == BODYPART_ORGANIC)
			if(affecting.heal_damage(heal_brute, heal_burn))
				C.update_damage_overlays()
		else
			to_chat(user, "<span class='notice'>Medicine won't work on a robotic limb!</span>")
	//else
	//	M.heal_bodypart_damage((src.heal_brute/2), (src.heal_burn/2))

	use(1)



/obj/item/stack/medical/bruise_pack
	name = "bruise pack"
	singular_name = "bruise pack"
	desc = "A therapeutic gel pack and bandages designed to treat blunt-force trauma."
	icon_state = "brutepack"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	heal_brute = 40
	self_delay = 20
	grind_results = list("styptic_powder" = 10)

/obj/item/stack/medical/ointment
	name = "ointment"
	desc = "Used to treat those nasty burn wounds."
	gender = PLURAL
	singular_name = "ointment"
	icon_state = "ointment"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	heal_burn = 40
	self_delay = 20
	grind_results = list("silver_sulfadiazine" = 10)