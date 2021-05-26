/mob/living/carbon
	blood_volume = BLOOD_VOLUME_NORMAL

/mob/living/carbon/Initialize()
	. = ..()
	create_reagents(1000)
	update_body_parts()
	GLOB.carbon_list += src

/mob/living/carbon/Destroy()
	. =  ..()

	//QDEL_LIST(internal_organs)
	//QDEL_LIST(stomach_contents)
	QDEL_LIST(bodyparts)
	//QDEL_LIST(implants)
	//remove_from_all_data_huds()
	QDEL_NULL(dna)
	GLOB.carbon_list -= src

/mob/living/carbon/swap_hand(held_index)
	if(!held_index)
		held_index = (active_hand_index % held_items.len)+1

	//var/obj/item/item_in_hand = src.get_active_held_item()
	//if(item_in_hand)
	//	var/obj/item/twohanded/TH = item_in_hand
	//	if(istype(TH))
	//		if(TH.wielded == 1)
	//			to_chat(usr, "<span class='warning'>Your other hand is too busy holding [TH]</span>")
	//			return
	var/oindex = active_hand_index
	active_hand_index = held_index
	if(hud_used)
		var/obj/screen/inventory/hand/H
		H = hud_used.hand_slots["[oindex]"]
		if(H)
			H.update_icon()
		H = hud_used.hand_slots["[held_index]"]
		if(H)
			H.update_icon()

/mob/living/carbon/proc/toggle_throw_mode()
	if(stat)
		return
	if(in_throw_mode)
		throw_mode_off()
	else
		throw_mode_on()


/mob/living/carbon/proc/throw_mode_off()
	in_throw_mode = 0
	if(client && hud_used)
		hud_used.throw_icon.icon_state = "act_throw_off"


/mob/living/carbon/proc/throw_mode_on()
	in_throw_mode = 1
	if(client && hud_used)
		hud_used.throw_icon.icon_state = "act_throw_on"

/mob/proc/throw_item(atom/target)
	SEND_SIGNAL(src, COMSIG_MOB_THROW, target)
	return

/mob/living/carbon/throw_item(atom/target)
	. = ..()
	throw_mode_off()
	if(!target || !isturf(loc))
		return
	if(istype(target, /obj/screen))
		return

	var/atom/movable/thrown_thing
	var/obj/item/I = get_active_held_item()

	if(!I)
		if(pulling && isliving(pulling) && grab_state >= GRAB_AGGRESSIVE)
			var/mob/living/throwable_mob = pulling
			if(!throwable_mob.buckled)
				thrown_thing = throwable_mob
				stop_pulling()
				if(has_trait(TRAIT_PACIFISM))
					to_chat(src, "<span class='notice'>You gently let go of [throwable_mob].</span>")
				var/turf/start_T = get_turf(loc)
				var/turf/end_T = get_turf(target)
				if(start_T && end_T)
					log_combat(src, throwable_mob, "thrown", addition="grab from tile in [AREACOORD(start_T)] towards tile at [AREACOORD(end_T)]")

	else if(!(I.item_flags & (NODROP | ABSTRACT)))
		thrown_thing = I
		dropItemToGround(I)

		if(has_trait(TRAIT_PACIFISM) && I.throwforce)
			to_chat(src, "<span class='notice'>You set [I] down gently on the ground.</span>")
			return

	if(thrown_thing)
		visible_message("<span class='danger'>[src] has thrown [thrown_thing].</span>")
		//log_message("has thrown [thrown_thing]", LOG_ATTACK)
		newtonian_move(get_dir(target, src))
		thrown_thing.safe_throw_at(target, thrown_thing.throw_range, thrown_thing.throw_speed, src, null, null, null, move_force)

/mob/living/carbon/hallucinating()
	if(hallucination)
		return TRUE
	else
		return FALSE

/mob/living/carbon/get_standard_pixel_y_offset(lying = 0)
	if(lying)
		return -6
	else
		return initial(pixel_y)

/mob/living/carbon/Stat()
	..()
	//if(statpanel("Status"))
	//	var/obj/item/organ/alien/plasmavessel/vessel = getorgan(/obj/item/organ/alien/plasmavessel)
	//	if(vessel)
	//		stat(null, "Plasma Stored: [vessel.storedPlasma]/[vessel.max_plasma]")
	//	if(locate(/obj/item/assembly/health) in src)
	//		stat(null, "Health: [health]")

	//add_abilities_to_panel()

/mob/living/carbon/fully_replace_character_name(oldname,newname)
	..()
	if(dna)
		dna.real_name = real_name

/mob/living/carbon/update_mobility()
	. = ..()
	if(!(mobility_flags & MOBILITY_STAND))
		add_movespeed_modifier(MOVESPEED_ID_CARBON_CRAWLING, TRUE, multiplicative_slowdown = CRAWLING_ADD_SLOWDOWN)
	else
		remove_movespeed_modifier(MOVESPEED_ID_CARBON_CRAWLING, TRUE)

/mob/living/carbon/updatehealth()
	if(status_flags & GODMODE)
		return
	var/total_burn	= 0
	var/total_brute	= 0
	var/total_stamina = 0
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		total_brute	+= (BP.brute_dam * BP.body_damage_coeff)
		total_burn	+= (BP.burn_dam * BP.body_damage_coeff)
		total_stamina += (BP.stamina_dam * BP.stam_damage_coeff)
	health = round(maxHealth - getOxyLoss() - getToxLoss() - getCloneLoss() - total_burn - total_brute, DAMAGE_PRECISION)
	staminaloss = round(total_stamina, DAMAGE_PRECISION)
	update_stat()
	update_mobility()
	//if(((maxHealth - total_burn) < HEALTH_THRESHOLD_DEAD) && stat == DEAD )
	//	become_husk("burn")
	//med_hud_set_health()
	if(stat == SOFT_CRIT)
		add_movespeed_modifier(MOVESPEED_ID_CARBON_SOFTCRIT, TRUE, multiplicative_slowdown = SOFTCRIT_ADD_SLOWDOWN)
	//else
	//	remove_movespeed_modifier(MOVESPEED_ID_CARBON_SOFTCRIT, TRUE)

/mob/living/carbon/update_stamina()
	var/stam = getStaminaLoss()
	if(stam > DAMAGE_PRECISION)
		var/total_health = (health - stam)
		if(total_health <= crit_threshold && !stat)
			//if(!IsParalyzed())
			//	to_chat(src, "<span class='notice'>You're too exhausted to keep going...</span>")
			//Paralyze(100)
			update_health_hud()

/mob/living/carbon/update_health_hud(shown_health_amount)
	if(!client || !hud_used)
		return
	if(hud_used.healths)
		if(stat != DEAD)
			. = 1
			if(!shown_health_amount)
				shown_health_amount = health
			if(shown_health_amount >= maxHealth)
				hud_used.healths.icon_state = "health0"
			else if(shown_health_amount > maxHealth*0.8)
				hud_used.healths.icon_state = "health1"
			else if(shown_health_amount > maxHealth*0.6)
				hud_used.healths.icon_state = "health2"
			else if(shown_health_amount > maxHealth*0.4)
				hud_used.healths.icon_state = "health3"
			else if(shown_health_amount > maxHealth*0.2)
				hud_used.healths.icon_state = "health4"
			else if(shown_health_amount > 0)
				hud_used.healths.icon_state = "health5"
			else
				hud_used.healths.icon_state = "health6"
		else
			hud_used.healths.icon_state = "health7"

/mob/living/carbon/proc/update_internals_hud_icon(internal_state = 0)
	if(hud_used && hud_used.internals)
		hud_used.internals.icon_state = "internal[internal_state]"

/mob/living/carbon/update_stat()
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(health <= HEALTH_THRESHOLD_DEAD && !has_trait(TRAIT_NODEATH))
			death()
			return
		//if(IsUnconscious() || IsSleeping() || getOxyLoss() > 50 || (has_trait(TRAIT_DEATHCOMA)) || (health <= HEALTH_THRESHOLD_FULLCRIT && !has_trait(TRAIT_NOHARDCRIT)))
		if(health <= HEALTH_THRESHOLD_FULLCRIT)//not_actual
			stat = UNCONSCIOUS
			//blind_eyes(1)
			//if(CONFIG_GET(flag/near_death_experience) && health <= HEALTH_THRESHOLD_NEARDEATH && !has_trait(TRAIT_NODEATH))
			//	add_trait(TRAIT_SIXTHSENSE, "near-death")
			//else
			//	remove_trait(TRAIT_SIXTHSENSE, "near-death")
		else
			if(health <= crit_threshold && !has_trait(TRAIT_NOSOFTCRIT))
				stat = SOFT_CRIT
			else
				stat = CONSCIOUS
			//adjust_blindness(-1)
			remove_trait(TRAIT_SIXTHSENSE, "near-death")
		update_mobility()
	update_damage_hud()
	update_health_hud()
	//med_hud_set_status()

/mob/living/carbon/fully_heal(admin_revive = FALSE)
	if(reagents)
		reagents.clear_reagents()
	//var/obj/item/organ/liver/L = getorganslot(ORGAN_SLOT_LIVER)
	//if(L)
	//	L.damage = 0
	//var/obj/item/organ/brain/B = getorgan(/obj/item/organ/brain)
	//if(B)
	//	B.brain_death = FALSE
	//	B.damaged_brain = FALSE
	//for(var/thing in diseases)
	//	var/datum/disease/D = thing
	//	if(D.severity != DISEASE_SEVERITY_POSITIVE)
	//		D.cure(FALSE)
	if(admin_revive)
		//regenerate_limbs()
		//regenerate_organs()
		handcuffed = initial(handcuffed)
		//for(var/obj/item/restraints/R in contents)
		//	qdel(R)
		//update_handcuffed()
		if(reagents)
			reagents.addiction_list = list()
	//cure_all_traumas(TRAUMA_RESILIENCE_MAGIC)
	..()
	//restoreEars()

/mob/living/carbon/can_be_revived()
	. = ..()
	//if(!getorgan(/obj/item/organ/brain) && (!mind || !mind.has_antag_datum(/datum/antagonist/changeling)))
	//	return 0

/mob/living/carbon/proc/create_bodyparts()
	var/l_arm_index_next = -1
	var/r_arm_index_next = 0
	for(var/X in bodyparts)
		var/obj/item/bodypart/O = new X()
		O.owner = src
		bodyparts.Remove(X)
		bodyparts.Add(O)
		if(O.body_part == ARM_LEFT)
			l_arm_index_next += 2
			O.held_index = l_arm_index_next
			hand_bodyparts += O
		else if(O.body_part == ARM_RIGHT)
			r_arm_index_next += 2
			O.held_index = r_arm_index_next
			hand_bodyparts += O