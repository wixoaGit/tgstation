/mob/living/Initialize()
	. = ..()
	if(unique_name)
		name = "[name] ([rand(1, 1000)])"
		real_name = name
	//var/datum/atom_hud/data/human/medical/advanced/medhud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	//medhud.add_to_hud(src)
	//for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
	//	diag_hud.add_to_hud(src)
	faction += "[REF(src)]"
	GLOB.mob_living_list += src
	initialize_footstep()

/mob/living/proc/initialize_footstep()
	AddComponent(/datum/component/footstep)

/mob/living/Destroy()
	if(LAZYLEN(status_effects))
		for(var/s in status_effects)
			var/datum/status_effect/S = s
			if(S.on_remove_on_mob_delete)
				qdel(S)
			else
				S.be_replaced()
	//if(ranged_ability)
	//	ranged_ability.remove_ranged_ability(src)
	//if(buckled)
	//	buckled.unbuckle_mob(src,force=1)

	//remove_from_all_data_huds()
	GLOB.mob_living_list -= src
	//QDEL_LIST(diseases)
	return ..()

/mob/living/Bump(atom/A)
	if(..())
		return
	if (buckled || now_pushing)
		return
	if(ismob(A))
		var/mob/M = A
		if(MobBump(M))
			return
	if(isobj(A))
		var/obj/O = A
		if(ObjBump(O))
			return
	if(ismovableatom(A))
		var/atom/movable/AM = A
		if(PushAM(AM, 1))
			return

/mob/living/proc/MobBump(mob/M)
	return

/mob/living/proc/ObjBump(obj/O)
	return

/mob/living/proc/PushAM(atom/movable/AM, force = 1)
	if (now_pushing)
		return TRUE
	now_pushing = TRUE
	var/t = get_dir(src, AM)
	var/push_anchored = FALSE
	if (AM.anchored)
		now_pushing = FALSE
		return
	var/current_dir
	if(isliving(AM))
		current_dir = AM.dir
	if (step(AM, t))
		step(src, t)
	if (current_dir)
		AM.setDir(current_dir)
	now_pushing = FALSE

/mob/living/start_pulling(atom/movable/AM, state, force = pull_force, supress_message = FALSE)
	if(!AM || !src)
		return FALSE
	if(!(AM.can_be_pulled(src, state, force)))
		return FALSE
	if(throwing || !(mobility_flags & MOBILITY_PULL))
		return FALSE

	AM.add_fingerprint(src)

	if(pulling)
		if(AM == pulling)
			return
		stop_pulling()

	changeNext_move(CLICK_CD_GRABBING)

	if(AM.pulledby)
		if(!supress_message)
			visible_message("<span class='danger'>[src] has pulled [AM] from [AM.pulledby]'s grip.</span>")
		//log_combat(AM, AM.pulledby, "pulled from", src)
		AM.pulledby.stop_pulling()

	pulling = AM
	AM.pulledby = src
	if(!supress_message)
		playsound(src.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
	update_pull_hud_icon()

	if(ismob(AM))
		var/mob/M = AM

		//log_combat(src, M, "grabbed", addition="passive grab")
		if(!supress_message)
			visible_message("<span class='warning'>[src] has grabbed [M] passively!</span>")
		//if(!iscarbon(src))
		//	M.LAssailant = null
		//else
		//	M.LAssailant = usr
		//if(isliving(M))
		//	var/mob/living/L = M
		//	for(var/thing in diseases)
		//		var/datum/disease/D = thing
		//		if(D.spread_flags & DISEASE_SPREAD_CONTACT_SKIN)
		//			L.ContactContractDisease(D)

		//	for(var/thing in L.diseases)
		//		var/datum/disease/D = thing
		//		if(D.spread_flags & DISEASE_SPREAD_CONTACT_SKIN)
		//			ContactContractDisease(D)

		set_pull_offsets(M, state)

/mob/living/proc/set_pull_offsets(mob/living/M, grab_state = GRAB_PASSIVE)
	var/offset = 0
	switch(grab_state)
		if(GRAB_PASSIVE)
			offset = GRAB_PIXEL_SHIFT_PASSIVE
		if(GRAB_AGGRESSIVE)
			offset = GRAB_PIXEL_SHIFT_AGGRESSIVE
		if(GRAB_NECK)
			offset = GRAB_PIXEL_SHIFT_NECK
		if(GRAB_KILL)
			offset = GRAB_PIXEL_SHIFT_NECK
	M.setDir(get_dir(M, src))
	switch(M.dir)
		if(NORTH)
			animate(M, pixel_x = 0, pixel_y = offset, 3)
		if(SOUTH)
			animate(M, pixel_x = 0, pixel_y = -offset, 3)
		if(EAST)
			animate(M, pixel_x = offset, pixel_y = 0, 3)
		if(WEST)
			animate(M, pixel_x = -offset, pixel_y = 0, 3)

/mob/living/proc/reset_pull_offsets(mob/living/M)
	animate(M, pixel_x = 0, pixel_y = 0, 1)

///mob/living/verb/pulled(atom/movable/AM as mob|obj in oview(1))
/mob/living/verb/pulled(atom/movable/AM as mob|obj)//not_actual
	set name = "Pull"
	set category = "Object"

	if(istype(AM) && Adjacent(AM))
		start_pulling(AM)
	else
		stop_pulling()

/mob/living/stop_pulling()
	if(ismob(pulling))
		reset_pull_offsets(pulling)
	..()
	update_pull_hud_icon()

/mob/living/verb/stop_pulling1()
	set name = "Stop Pulling"
	set category = "IC"
	stop_pulling()

/mob/living/incapacitated(ignore_restraints = FALSE, ignore_grab = FALSE, check_immobilized = FALSE)
	//if(stat || IsUnconscious() || IsStun() || IsParalyzed() || (check_immobilized && IsImmobilized()) || (!ignore_restraints && restrained(ignore_grab)))
	if (stat || IsUnconscious())//not_actual
		return TRUE

/mob/living/proc/InCritical()
	return (health <= crit_threshold && (stat == SOFT_CRIT || stat == UNCONSCIOUS))

/mob/living/proc/InFullCritical()
	return (health <= HEALTH_THRESHOLD_FULLCRIT && stat == UNCONSCIOUS)

/mob/living/proc/set_resting(rest, silent = TRUE)
	if(!silent)
		if(rest)
			to_chat(src, "<span class='notice'>You are now resting.</span>")
		else
			to_chat(src, "<span class='notice'>You get up.</span>")
	resting = rest
	update_resting()

/mob/living/proc/update_resting()
	update_rest_hud_icon()
	update_mobility()

///mob/living/get_contents()
//	var/list/ret = list()
//	ret |= contents
//	for(var/i in ret.Copy())
//		var/atom/A = i
//		SEND_SIGNAL(A, COMSIG_TRY_STORAGE_RETURN_INVENTORY, ret)
//	for(var/obj/item/folder/F in ret.Copy())
//		ret |= F.contents
//	return ret

/mob/living/proc/can_inject()
	return TRUE

/mob/living/proc/updatehealth()
	if(status_flags & GODMODE)
		return
	health = maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss() - getCloneLoss()
	staminaloss = getStaminaLoss()
	update_stat()
	//med_hud_set_health()
	//med_hud_set_status()

/mob/living/proc/revive(full_heal = 0, admin_revive = 0)
	if(full_heal)
		fully_heal(admin_revive)
	if(stat == DEAD && can_be_revived())
		GLOB.dead_mob_list -= src
		GLOB.alive_mob_list += src
		set_suicide(FALSE)
		stat = UNCONSCIOUS
		//blind_eyes(1)
		updatehealth()
		update_mobility()
		//update_sight()
		//clear_alert("not_enough_oxy")
		reload_fullscreen()
		. = 1
		//if(mind)
		//	for(var/S in mind.spell_list)
		//		var/obj/effect/proc_holder/spell/spell = S
		//		spell.updateButtonIcon()

/mob/living/proc/fully_heal(admin_revive = 0)
	//restore_blood()
	setToxLoss(0, 0)
	setOxyLoss(0, 0)
	setCloneLoss(0, 0)
	setBrainLoss(0)
	setStaminaLoss(0, 0)
	SetUnconscious(0, FALSE)
	//set_disgust(0)
	//SetStun(0, FALSE)
	//SetKnockdown(0, FALSE)
	//SetImmobilized(0, FALSE)
	//SetParalyzed(0, FALSE)
	//SetSleeping(0, FALSE)
	radiation = 0
	//set_nutrition(NUTRITION_LEVEL_FED + 50)
	bodytemperature = BODYTEMP_NORMAL
	//set_blindness(0)
	//set_blurriness(0)
	//set_eye_damage(0)
	//cure_nearsighted()
	//cure_blind()
	//cure_husk()
	hallucination = 0
	heal_overall_damage(INFINITY, INFINITY, INFINITY, null, TRUE)
	//ExtinguishMob()
	fire_stacks = 0
	//confused = 0
	update_mobility()
	//GET_COMPONENT(mood, /datum/component/mood)
	//if (mood)
	//	mood.remove_temp_moods(admin_revive)

/mob/living/proc/can_be_revived()
	. = 1
	if(health <= HEALTH_THRESHOLD_DEAD)
		return 0

/mob/living/proc/update_damage_overlays()
	return

/mob/living/Move(atom/newloc, direct)
	if (buckled && buckled.loc != newloc)
		if (!buckled.anchored)
			return buckled.Move(newloc, direct)
		else
			return 0

	var/old_direction = dir
	var/turf/T = loc
	. = ..()

	if(pulledby && moving_diagonally != FIRST_DIAG_STEP && get_dist(src, pulledby) > 1 && (pulledby != moving_from_pull))
		pulledby.stop_pulling()
	else
		if(isliving(pulledby))
			var/mob/living/L = pulledby
			L.set_pull_offsets(src, pulledby.grab_state)

	if(active_storage && !(CanReach(active_storage.parent,view_only = TRUE)))
		active_storage.close(src)

	//if(!(mobility_flags & MOBILITY_STAND) && !buckled && prob(getBruteLoss()*200/maxHealth))
	//	makeTrail(newloc, T, old_direction)

/mob/living/experience_pressure_difference(pressure_difference, direction, pressure_resistance_prob_delta = 0)
	if(buckled)
		return
	if(client && client.move_delay >= world.time + world.tick_lag*2)
		pressure_resistance_prob_delta -= 30

	var/list/turfs_to_check = list()

	if(has_limbs)
		var/turf/T = get_step(src, angle2dir(dir2angle(direction)+90))
		if (T)
			turfs_to_check += T

		T = get_step(src, angle2dir(dir2angle(direction)-90))
		if(T)
			turfs_to_check += T

		for(var/t in turfs_to_check)
			T = t
			if(T.density)
				pressure_resistance_prob_delta -= 20
				continue
			for (var/atom/movable/AM in T)
				if (AM.density && AM.anchored)
					pressure_resistance_prob_delta -= 20
					break
	//if(!force_moving)
	if(TRUE)//not_actual
		..(pressure_difference, direction, pressure_resistance_prob_delta)

/mob/living/stripPanelUnequip(obj/item/what, mob/who, where)
	if(what.item_flags & NODROP)
		to_chat(src, "<span class='warning'>You can't remove \the [what.name], it appears to be stuck!</span>")
		return
	who.visible_message("<span class='danger'>[src] tries to remove [who]'s [what.name].</span>",
					"<span class='userdanger'>[src] tries to remove [who]'s [what.name].</span>")
	what.add_fingerprint(src)
	if(do_mob(src, who, what.strip_delay))
		if(what && Adjacent(who))
			if(islist(where))
				var/list/L = where
				if(what == who.get_item_for_held_index(L[2]))
					if(who.dropItemToGround(what))
						log_combat(src, who, "stripped [what] off")
			if(what == who.get_item_by_slot(where))
				if(who.dropItemToGround(what))
					log_combat(src, who, "stripped [what] off")

	if(Adjacent(who))
		who.show_inv(src)
	else
		src << browse(null,"window=mob[REF(who)]")

/mob/living/stripPanelEquip(obj/item/what, mob/who, where)
	what = src.get_active_held_item()
	if(what && (what.item_flags & NODROP))
		to_chat(src, "<span class='warning'>You can't put \the [what.name] on [who], it's stuck to your hand!</span>")
		return
	if(what)
		var/list/where_list
		var/final_where

		if(islist(where))
			where_list = where
			final_where = where[1]
		else
			final_where = where

		if(!what.mob_can_equip(who, src, final_where, TRUE, TRUE))
			to_chat(src, "<span class='warning'>\The [what.name] doesn't fit in that place!</span>")
			return

		visible_message("<span class='notice'>[src] tries to put [what] on [who].</span>")
		if(do_mob(src, who, what.equip_delay_other))
			if(what && Adjacent(who) && what.mob_can_equip(who, src, final_where, TRUE, TRUE))
				if(temporarilyRemoveItemFromInventory(what))
					if(where_list)
						if(!who.put_in_hand(what, where_list[2]))
							what.forceMove(get_turf(who))
					else
						who.equip_to_slot(what, where, TRUE)

		if(Adjacent(who))
			who.show_inv(src)
		else
			src << browse(null,"window=mob[REF(who)]")

/mob/living/proc/get_standard_pixel_x_offset(lying = 0)
	return initial(pixel_x)

/mob/living/proc/get_standard_pixel_y_offset(lying = 0)
	return initial(pixel_y)

/mob/living/canUseTopic(atom/movable/M, be_close=FALSE, no_dextery=FALSE, no_tk=FALSE)
	if(incapacitated())
		to_chat(src, "<span class='warning'>You can't do that right now!</span>")
		return FALSE
	if(be_close && !in_range(M, src))
		to_chat(src, "<span class='warning'>You are too far away!</span>")
		return FALSE
	if(!no_dextery)
		to_chat(src, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return FALSE
	return TRUE

/mob/living/proc/can_use_guns(obj/item/G)
	if(G.trigger_guard != TRIGGER_GUARD_ALLOW_ALL && !IsAdvancedToolUser())
		to_chat(src, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return FALSE
	return TRUE

/mob/living/proc/update_stamina()
	return

/mob/living/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback)
	stop_pulling()
	. = ..()

/mob/living/ConveyorMove()
	if((movement_type & FLYING) && !stat)
		return
	..()

/mob/living/proc/update_mobility()
	var/stat_softcrit = stat == SOFT_CRIT
	var/stat_conscious = (stat == CONSCIOUS) || stat_softcrit
	var/conscious = !IsUnconscious() && stat_conscious && !has_trait(TRAIT_DEATHCOMA)
	var/chokehold = pulledby && pulledby.grab_state >= GRAB_NECK
	var/restrained = restrained()
	var/has_legs = get_num_legs()
	var/has_arms = get_num_arms()
	var/paralyzed = IsParalyzed()
	var/stun = IsStun()
	var/knockdown = IsKnockdown()
	//var/ignore_legs = get_leg_ignore()
	var/ignore_legs = FALSE//not_actual
	//var/canmove = !IsImmobilized() && !stun && conscious && !paralyzed && !buckled && (!stat_softcrit || !pulledby) && !chokehold && !IsFrozen() && (has_arms || ignore_legs || has_legs)
	var/canmove = !stun && conscious && !paralyzed && !buckled && (!stat_softcrit || !pulledby) && !chokehold && (has_arms || ignore_legs || has_legs)//not_actual
	if(canmove)
		mobility_flags |= MOBILITY_MOVE
	else
		mobility_flags &= ~MOBILITY_MOVE
	var/canstand_involuntary = conscious && !stat_softcrit && !knockdown && !chokehold && !paralyzed && (ignore_legs || has_legs) && !(buckled && buckled.buckle_lying)
	var/canstand = canstand_involuntary && !resting

	if(canstand)
		mobility_flags |= MOBILITY_STAND
		lying = 0
		if(!restrained)
			mobility_flags |= (MOBILITY_UI | MOBILITY_PULL)
		else
			mobility_flags &= ~(MOBILITY_UI | MOBILITY_PULL)
	else
		mobility_flags &= ~(MOBILITY_UI | MOBILITY_PULL)

		var/should_be_lying = (buckled && (buckled.buckle_lying != -1)) ? buckled.buckle_lying : TRUE

		if(should_be_lying)
			mobility_flags &= ~MOBILITY_STAND
			if(!lying)
				lying = pick(90, 270)
		else
			mobility_flags |= MOBILITY_STAND
			if(lying)
				lying = 0

	var/canitem = !paralyzed && !stun && conscious && !chokehold && !restrained && has_arms
	if(canitem)
		mobility_flags |= (MOBILITY_USE | MOBILITY_PICKUP | MOBILITY_STORAGE)
	else
		mobility_flags &= ~(MOBILITY_USE | MOBILITY_PICKUP | MOBILITY_STORAGE)
	if(!(mobility_flags & MOBILITY_USE))
		drop_all_held_items()
	if(!(mobility_flags & MOBILITY_PULL))
		if(pulling)
			stop_pulling()
	if(!(mobility_flags & MOBILITY_UI))
		unset_machine()
	density = !lying
	var/changed = lying == lying_prev
	if(lying)
		if(!lying_prev)
			fall(!canstand_involuntary)
		if(layer == initial(layer))
			layer = LYING_MOB_LAYER
	else
		if(layer == LYING_MOB_LAYER)
			layer = initial(layer)
	update_transform()
	if(changed)
		if(client)
			client.move_delay = world.time + movement_delay()
	lying_prev = lying

/mob/living/proc/fall(forced)
	if(!(mobility_flags & MOBILITY_USE))
		drop_all_held_items()

/mob/living/proc/get_static_viruses()
	//if(!LAZYLEN(diseases))
	//	return
	var/list/datum/disease/result = list()
	//for(var/datum/disease/D in diseases)
	//	var/static_virus = D.Copy()
	//	result += static_virus
	return result

/mob/living/forceMove(atom/destination)
	stop_pulling()
	//if(buckled)
	//	buckled.unbuckle_mob(src, force = TRUE)
	//if(has_buckled_mobs())
	//	unbuckle_all_mobs(force = TRUE)
	. = ..()
	if(.)
		//if(client)
		//	reset_perspective()
		update_mobility()