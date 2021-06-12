GLOBAL_DATUM_INIT(fire_overlay, /mutable_appearance, mutable_appearance('icons/effects/fire.dmi', "fire"))

/obj/item
	name = "item"
	icon = 'icons/obj/items_and_weapons.dmi'
	var/item_state = null
	var/lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	var/righthand_file = 'icons/mob/inhands/items_righthand.dmi'

	obj_flags = NONE
	var/item_flags = NONE

	var/hitsound = null
	var/usesound = null
	var/throwhitsound = null
	var/w_class = WEIGHT_CLASS_NORMAL
	var/slot_flags = 0
	pass_flags = PASSTABLE
	pressure_resistance = 4

	var/heat_protection = 0
	var/cold_protection = 0
	var/max_heat_protection_temperature
	var/min_cold_protection_temperature

	var/list/actions
	var/list/actions_types

	var/flags_inv

	var/interaction_flags_item = INTERACT_ITEM_ATTACK_HAND_PICKUP

	var/item_color = null

	var/body_parts_covered = 0
	var/gas_transfer_coefficient = 1
	var/permeability_coefficient = 1
	var/siemens_coefficient = 1
	var/slowdown = 0
	var/armour_penetration = 0
	var/list/allowed = null
	var/equip_delay_self = 0
	var/equip_delay_other = 20
	var/strip_delay = 40
	var/list/materials

	var/list/attack_verb

	var/mob/thrownby = null

	var/flags_cover = 0
	var/heat = 0
	var/sharpness = IS_BLUNT

	var/tool_behaviour = NONE
	var/toolspeed = 1

	var/datum/dog_fashion/dog_fashion = null

	var/force_string

	var/trigger_guard = TRIGGER_GUARD_NONE

	var/list/grind_results
	var/list/juice_results

/obj/item/Initialize()

	materials =	typelist("materials", materials)

	//if (attack_verb)
	//	attack_verb = typelist("attack_verb", attack_verb)

	. = ..()
	for(var/path in actions_types)
		new path(src)
	actions_types = null

	//if(GLOB.rpg_loot_items)
	//	rpg_loot = new(src)

	if(force_string)
		item_flags |= FORCE_STRING_OVERRIDE

	if(!hitsound)
		if(damtype == "fire")
			hitsound = 'sound/items/welder.ogg'
		if(damtype == "brute")
			hitsound = "swing_hit"

	//if (!embedding)
	//	embedding = getEmbeddingBehavior()
	//else if (islist(embedding))
	//	embedding = getEmbeddingBehavior(arglist(embedding))
	//else if (!istype(embedding, /datum/embedding_behavior))
	//	stack_trace("Invalid type [embedding.type] found in .embedding during /obj/item Initialize()")

/obj/item/Destroy()
	item_flags &= ~DROPDEL
	if(ismob(loc))
		var/mob/m = loc
		m.temporarilyRemoveItemFromInventory(src, TRUE)
	for(var/X in actions)
		qdel(X)
	//QDEL_NULL(rpg_loot)
	return ..()

/obj/item/proc/check_allowed_items(atom/target, not_inside, target_self)
	if(((src in target) && !target_self) || (!isturf(target.loc) && !isturf(target) && not_inside))
		return 0
	else
		return 1

/obj/item/proc/suicide_act(mob/user)
	return

/obj/item/examine(mob/user)
	..()
	var/pronoun
	if(src.gender == PLURAL)
		pronoun = "They are"
	else
		pronoun = "It is"
	var/size = weightclass2text(src.w_class)
	to_chat(user, "[pronoun] a [size] item." )

	if(!user.research_scanner)
		return

	var/list/research_msg = list("<font color='purple'>Research prospects:</font> ")
	var/sep = ""
	//var/list/boostable_nodes = techweb_item_boost_check(src)
	//if (boostable_nodes)
	//	for(var/id in boostable_nodes)
	//		var/datum/techweb_node/node = SSresearch.techweb_node_by_id(id)
	//		if(!node)
	//			continue
	//		research_msg += sep
	//		research_msg += node.display_name
	//		sep = ", "
	//var/list/points = techweb_item_point_check(src)
	//if (length(points))
	//	sep = ", "
	//	research_msg += techweb_point_display_generic(points)

	if (!sep)
		research_msg += "None"

	research_msg += ".<br><font color='purple'>Extractable materials:</font> "
	if (materials.len)
		sep = ""
		for(var/mat in materials)
			research_msg += sep
			research_msg += CallMaterialName(mat)
			sep = ", "
	else
		research_msg += "None"
	research_msg += "."
	to_chat(user, research_msg.Join())

/obj/item/interact(mob/user)
	add_fingerprint(user)
	ui_interact(user)

/obj/item/ui_act(action, params)
	add_fingerprint(usr)
	return ..()

/obj/item/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(!user)
		return
	if(anchored)
		return

	if(resistance_flags & ON_FIRE)
		var/mob/living/carbon/C = user
		var/can_handle_hot = FALSE
		if(!istype(C))
			can_handle_hot = TRUE
		else if(C.gloves && (C.gloves.max_heat_protection_temperature > 360))
			can_handle_hot = TRUE
		else if(C.has_trait(TRAIT_RESISTHEAT) || C.has_trait(TRAIT_RESISTHEATHANDS))
			can_handle_hot = TRUE

		if(can_handle_hot)
			extinguish()
			to_chat(user, "<span class='notice'>You put out the fire on [src].</span>")
		else
			to_chat(user, "<span class='warning'>You burn your hand on [src]!</span>")
			var/obj/item/bodypart/affecting = C.get_bodypart("[(user.active_hand_index % 2 == 0) ? "r" : "l" ]_arm")
			if(affecting && affecting.receive_damage( 0, 5 ))
				C.update_damage_overlays()
			return

	//if(acid_level > 20 && !ismob(loc))
	//	var/mob/living/carbon/C = user
	//	if(istype(C))
	//		if(!C.gloves || (!(C.gloves.resistance_flags & (UNACIDABLE|ACID_PROOF))))
	//			to_chat(user, "<span class='warning'>The acid on [src] burns your hand!</span>")
	//			var/obj/item/bodypart/affecting = C.get_bodypart("[(user.active_hand_index % 2 == 0) ? "r" : "l" ]_arm")
	//			if(affecting && affecting.receive_damage( 0, 5 ))
	//				C.update_damage_overlays()

	if(!(interaction_flags_item & INTERACT_ITEM_ATTACK_HAND_PICKUP))
		return

	var/grav = user.has_gravity()
	if(grav > STANDARD_GRAVITY)
		var/grav_power = min(3,grav - STANDARD_GRAVITY)
		to_chat(user,"<span class='notice'>You start picking up [src]...</span>")
		if(!do_mob(user,src,30*grav_power))
			return


	SEND_SIGNAL(loc, COMSIG_TRY_STORAGE_TAKE, src, user.loc, TRUE)

	if(throwing)
		throwing.finalize(FALSE)
	if(loc == user)
		if(!allow_attack_hand_drop(user) || !user.temporarilyRemoveItemFromInventory(src))
			return

	pickup(user)
	add_fingerprint(user)
	if(!user.put_in_active_hand(src, FALSE, FALSE))
		user.dropItemToGround(src)

/obj/item/attack_paw(mob/user)
	if(!user)
		return
	if(anchored)
		return

	SEND_SIGNAL(loc, COMSIG_TRY_STORAGE_TAKE, src, user.loc, TRUE)

	if(throwing)
		throwing.finalize(FALSE)
	if(loc == user)
		if(!user.temporarilyRemoveItemFromInventory(src))
			return

	pickup(user)
	add_fingerprint(user)
	if(!user.put_in_active_hand(src, FALSE, FALSE))
		user.dropItemToGround(src)

/obj/item/proc/allow_attack_hand_drop(mob/user)
	return TRUE

/obj/item/proc/talk_into(mob/M, input, channel, spans, datum/language/language)
	return ITALICS | REDUCE_RANGE

/obj/item/proc/dropped(mob/user)
	for(var/X in actions)
		var/datum/action/A = X
		A.Remove(user)
	if(item_flags & DROPDEL)
		qdel(src)
	item_flags &= ~IN_INVENTORY
	SEND_SIGNAL(src, COMSIG_ITEM_DROPPED,user)

/obj/item/proc/pickup(mob/user)
	SEND_SIGNAL(src, COMSIG_ITEM_PICKUP, user)
	item_flags |= IN_INVENTORY

/obj/item/proc/on_found(mob/finder)
	return

/obj/item/proc/equipped(mob/user, slot)
	SEND_SIGNAL(src, COMSIG_ITEM_EQUIPPED, user, slot)
	for(var/X in actions)
		var/datum/action/A = X
		if(item_action_slot_check(slot, user))
			A.Grant(user)
	item_flags |= IN_INVENTORY

/obj/item/proc/item_action_slot_check(slot, mob/user)
	if(slot == SLOT_IN_BACKPACK || slot == SLOT_LEGCUFFED)
		return FALSE
	return TRUE

/obj/item/proc/mob_can_equip(mob/living/M, mob/living/equipper, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	if(!M)
		return FALSE

	return M.can_equip(src, slot, disable_warning, bypass_equip_delay_self)


/obj/item/verb/verb_pickup()
	//set src in oview(1)
	set category = "Object"
	set name = "Pick up"

	if(usr.incapacitated() || !Adjacent(usr))
		return

	if(isliving(usr))
		var/mob/living/L = usr
		if(!(L.mobility_flags & MOBILITY_PICKUP))
			return

	if(usr.get_active_held_item() == null)
		usr.UnarmedAttack(src)

/obj/item/proc/ui_action_click(mob/user, actiontype)
	attack_self(user)

/obj/item/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, force)
	thrownby = thrower
	callback = CALLBACK(src, .proc/after_throw, callback)
	. = ..(target, range, speed, thrower, spin, diagonals_first, callback, force)

/obj/item/proc/after_throw(datum/callback/callback)
	if (callback)
		. = callback.Invoke()
	throw_speed = initial(throw_speed)
	item_flags &= ~IN_INVENTORY

/obj/item/proc/get_belt_overlay()
	return mutable_appearance('icons/obj/clothing/belt_overlays.dmi', icon_state)

/obj/item/proc/is_hot()
	return heat

/obj/item/proc/is_sharp()
	return sharpness

/obj/item/proc/open_flame(flame_heat=700)
	var/turf/location = loc
	if(ismob(location))
		var/mob/M = location
		var/success = FALSE
		if(src == M.get_item_by_slot(SLOT_WEAR_MASK))
			success = TRUE
		if(success)
			location = get_turf(M)
	if(isturf(location))
		location.hotspot_expose(flame_heat, 5)

/obj/item/proc/ignition_effect(atom/A, mob/user)
	if(is_hot())
		. = "<span class='notice'>[user] lights [A] with [src].</span>"
	else
		. = ""

/obj/item/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	return

/obj/item/proc/microwave_act(obj/machinery/microwave/M)
	if(istype(M) && M.dirty < 100)
		M.dirty++

/obj/item/proc/on_mob_death(mob/living/L, gibbed)

/obj/item/proc/grind_requirements(obj/machinery/reagentgrinder/R)
	return TRUE

/obj/item/proc/on_grind()

/obj/item/proc/use_tool(atom/target, mob/living/user, delay, amount=0, volume=0, datum/callback/extra_checks)
	if(!delay && !tool_start_check(user, amount))
		return

	delay *= toolspeed
	
	play_tool_sound(target, volume)

	if(delay)
		var/datum/callback/tool_check = CALLBACK(src, .proc/tool_check_callback, user, amount, extra_checks)

		if(ismob(target))
			if(!do_mob(user, target, delay, extra_checks=tool_check))
				return

		else
			if(!do_after(user, delay, target=target, extra_checks=tool_check))
				return
	else
		if(extra_checks && !extra_checks.Invoke())
			return

	if(amount && !use(amount))
		return

	if(delay >= MIN_TOOL_SOUND_DELAY)
		play_tool_sound(target, volume)
	
	return TRUE

/obj/item/proc/tool_start_check(mob/living/user, amount=0)
	return tool_use_check(user, amount)

/obj/item/proc/tool_use_check(mob/living/user, amount)
	return !amount

/obj/item/proc/use(used)
	return !used

/obj/item/proc/play_tool_sound(atom/target, volume=50)
	if(target && usesound && volume)
		var/played_sound = usesound

		if(islist(usesound))
			played_sound = pick(usesound)

		playsound(target, played_sound, volume, 1)

/obj/item/proc/tool_check_callback(mob/living/user, amount, datum/callback/extra_checks)
	return tool_use_check(user, amount) && (!extra_checks || extra_checks.Invoke())

/obj/item/proc/get_part_rating()
	return 0