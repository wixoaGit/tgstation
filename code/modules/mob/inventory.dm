/mob/proc/get_active_held_item()
	return get_item_for_held_index(active_hand_index)

/mob/proc/get_inactive_held_item()
	return get_item_for_held_index(get_inactive_hand_index())

/mob/proc/get_inactive_hand_index()
	var/other_hand = 0
	if(!(active_hand_index % 2))
		other_hand = active_hand_index-1
	else
		other_hand = active_hand_index+1
	if(other_hand < 0 || other_hand > held_items.len)
		other_hand = 0
	return other_hand

/mob/proc/get_item_for_held_index(i)
	if(i > 0 && i <= held_items.len)
		return held_items[i]
	return FALSE

/mob/proc/is_holding_tool_quality(quality)
	var/obj/item/best_item
	var/best_quality = INFINITY

	for(var/obj/item/I in held_items)
		if(I.tool_behaviour == quality && I.toolspeed < best_quality)
			best_item = I
			best_quality = I.toolspeed

	return best_item

/mob/proc/get_held_index_name(i)
	var/list/hand = list()
	if(i > 2)
		hand += "upper "
	var/num = 0
	if(!(i % 2))
		num = i-2
		hand += "right hand"
	else
		num = i-1
		hand += "left hand"
	num -= (num*0.5)
	if(num > 1)
		hand += " #[num]"
	return hand.Join()

/mob/proc/can_equip(obj/item/I, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	return FALSE

/mob/proc/held_index_to_dir(i)
	if(!(i % 2))
		return "r"
	return "l"

/mob/proc/has_hand_for_held_index(i)
	return TRUE

/mob/proc/has_active_hand()
	return has_hand_for_held_index(active_hand_index)

/mob/proc/get_empty_held_index_for_side(side = "left", all = FALSE)
	var/start = 0
	var/static/list/lefts = list("l" = TRUE,"L" = TRUE,"LEFT" = TRUE,"left" = TRUE)
	var/static/list/rights = list("r" = TRUE,"R" = TRUE,"RIGHT" = TRUE,"right" = TRUE)
	if(lefts[side])
		start = 1
	else if(rights[side])
		start = 2
	if(!start)
		return FALSE
	var/list/empty_indexes
	for(var/i in start to held_items.len step 2)
		if(!held_items[i])
			if(!all)
				return i
			if(!empty_indexes)
				empty_indexes = list()
			empty_indexes += i
	return empty_indexes

/mob/proc/get_held_items_for_side(side = "left", all = FALSE)
	var/start = 0
	var/static/list/lefts = list("l" = TRUE,"L" = TRUE,"LEFT" = TRUE,"left" = TRUE)
	var/static/list/rights = list("r" = TRUE,"R" = TRUE,"RIGHT" = TRUE,"right" = TRUE)
	if(lefts[side])
		start = 1
	else if(rights[side])
		start = 2
	if(!start)
		return FALSE
	var/list/holding_items
	for(var/i in start to held_items.len step 2)
		var/obj/item/I = held_items[i]
		if(I)
			if(!all)
				return I
			if(!holding_items)
				holding_items = list()
			holding_items += I
	return holding_items

/mob/proc/get_empty_held_indexes()
	var/list/L
	for(var/i in 1 to held_items.len)
		if(!held_items[i])
			if(!L)
				L = list()
			L += i
	return L

/mob/proc/get_held_index_of_item(obj/item/I)
	return held_items.Find(I)

/mob/proc/is_holding(obj/item/I)
	return get_held_index_of_item(I)

/mob/proc/is_holding_item_of_type(typepath)
	for(var/obj/item/I in held_items)
		if(istype(I, typepath))
			return I
	return FALSE

/mob/proc/can_put_in_hand(I, hand_index)
	if(hand_index > held_items.len)
		return FALSE
	if(!put_in_hand_check(I))
		return FALSE
	if(!has_hand_for_held_index(hand_index))
		return FALSE
	return !held_items[hand_index]

/mob/proc/put_in_hand(obj/item/I, hand_index, forced = FALSE, ignore_anim = TRUE)
	if(forced || can_put_in_hand(I, hand_index))
		//if(isturf(I.loc) && !ignore_anim)
		//	I.do_pickup_animation(src)
		if(hand_index == null)
			return FALSE
		if(get_item_for_held_index(hand_index) != null)
			dropItemToGround(get_item_for_held_index(hand_index), force = TRUE)
		I.forceMove(src)
		held_items[hand_index] = I
		I.layer = ABOVE_HUD_LAYER
		//I.plane = ABOVE_HUD_PLANE
		I.equipped(src, SLOT_HANDS)
		if(I.pulledby)
			I.pulledby.stop_pulling()
		update_inv_hands()
		I.pixel_x = initial(I.pixel_x)
		I.pixel_y = initial(I.pixel_y)
		return hand_index || TRUE
	return FALSE

/mob/proc/put_in_l_hand(obj/item/I)
	return put_in_hand(I, get_empty_held_index_for_side("l"))

/mob/proc/put_in_r_hand(obj/item/I)
	return put_in_hand(I, get_empty_held_index_for_side("r"))

/mob/proc/put_in_hand_check(obj/item/I)
	return FALSE

/mob/living/put_in_hand_check(obj/item/I)
	if(istype(I) && ((mobility_flags & MOBILITY_PICKUP) || (I.item_flags & ABSTRACT)))
		return TRUE
	return FALSE

/mob/proc/put_in_active_hand(obj/item/I, forced = FALSE, ignore_animation = TRUE)
	return put_in_hand(I, active_hand_index, forced, ignore_animation)

/mob/proc/put_in_hands(obj/item/I, del_on_fail = FALSE, merge_stacks = TRUE, forced = FALSE)
	if(!I)
		return FALSE

	if (istype(I, /obj/item/stack))
		var/obj/item/stack/I_stack = I
		var/obj/item/stack/active_stack = get_active_held_item()
	
		if (I_stack.zero_amount())
			return FALSE
	
		if (merge_stacks)
			if (istype(active_stack) && istype(I_stack, active_stack.merge_type))
				if (I_stack.merge(active_stack))
					to_chat(usr, "<span class='notice'>Your [active_stack.name] stack now contains [active_stack.get_amount()] [active_stack.singular_name]\s.</span>")
					return TRUE
			else
				var/obj/item/stack/inactive_stack = get_inactive_held_item()
				if (istype(inactive_stack) && istype(I_stack, inactive_stack.merge_type))
					if (I_stack.merge(inactive_stack))
						to_chat(usr, "<span class='notice'>Your [inactive_stack.name] stack now contains [inactive_stack.get_amount()] [inactive_stack.singular_name]\s.</span>")
						return TRUE

	if(put_in_active_hand(I, forced))
		return TRUE

	var/hand = get_empty_held_index_for_side("l")
	if(!hand)
		hand =  get_empty_held_index_for_side("r")
	if(hand)
		if(put_in_hand(I, hand, forced))
			return TRUE
	if(del_on_fail)
		qdel(I)
		return FALSE
	I.forceMove(drop_location())
	I.layer = initial(I.layer)
	//I.plane = initial(I.plane)
	I.dropped(src)
	return FALSE

/mob/proc/drop_all_held_items()
	. = FALSE
	for(var/obj/item/I in held_items)
		. |= dropItemToGround(I)

/mob/proc/dropItemToGround(obj/item/I, force = FALSE)
	return doUnEquip(I, force, drop_location(), FALSE)

/mob/proc/transferItemToLoc(obj/item/I, newloc = null, force = FALSE)
	return doUnEquip(I, force, newloc, FALSE)

/mob/proc/temporarilyRemoveItemFromInventory(obj/item/I, force = FALSE, idrop = TRUE)
	return doUnEquip(I, force, null, TRUE, idrop)

/mob/proc/doUnEquip(obj/item/I, force, newloc, no_move, invdrop = TRUE)
	if(!I)
		return TRUE

	if((I.item_flags & NODROP) && !force)
		return FALSE

	var/hand_index = get_held_index_of_item(I)
	if(hand_index)
		held_items[hand_index] = null
		update_inv_hands()
	if(I)
		if(client)
			client.screen -= I
		I.layer = initial(I.layer)
		//I.plane = initial(I.plane)
		//I.appearance_flags &= ~NO_CLIENT_COLOR
		if(!no_move && !(I.item_flags & DROPDEL))
			if (isnull(newloc))
				I.moveToNullspace()
			else
				I.forceMove(newloc)
		I.dropped(src)
	return TRUE

/mob/living/proc/get_equipped_items(include_pockets = FALSE)
	return

/mob/living/carbon/get_equipped_items(include_pockets = FALSE)
	var/list/items = list()
	if(back)
		items += back
	if(head)
		items += head
	if(wear_mask)
		items += wear_mask
	if(wear_neck)
		items += wear_neck
	return items

/mob/living/carbon/human/get_equipped_items(include_pockets = FALSE)
	var/list/items = ..()
	if(belt)
		items += belt
	if(ears)
		items += ears
	if(glasses)
		items += glasses
	if(gloves)
		items += gloves
	if(shoes)
		items += shoes
	if(wear_id)
		items += wear_id
	if(wear_suit)
		items += wear_suit
	if(w_uniform)
		items += w_uniform
	if(include_pockets)
		if(l_store)
			items += l_store
		if(r_store)
			items += r_store
		if(s_store)
			items += s_store
	return items

/mob/living/carbon/proc/check_obscured_slots(transparent_protection)
	var/list/obscured = list()
	var/hidden_slots = NONE

	for(var/obj/item/I in get_equipped_items())
		hidden_slots |= I.flags_inv
		//if(transparent_protection)
		//	hidden_slots |= I.transparent_protection

	if(hidden_slots & HIDENECK)
		obscured |= SLOT_NECK
	if(hidden_slots & HIDEMASK)
		obscured |= SLOT_WEAR_MASK
	if(hidden_slots & HIDEEYES)
		obscured |= SLOT_GLASSES
	if(hidden_slots & HIDEEARS)
		obscured |= SLOT_EARS
	if(hidden_slots & HIDEGLOVES)
		obscured |= SLOT_GLOVES
	if(hidden_slots & HIDEJUMPSUIT)
		obscured |= SLOT_W_UNIFORM
	if(hidden_slots & HIDESHOES)
		obscured |= SLOT_SHOES
	if(hidden_slots & HIDESUITSTORAGE)
		obscured |= SLOT_S_STORE

	return obscured

/obj/item/proc/equip_to_best_slot(mob/M)
	if(src != M.get_active_held_item())
		to_chat(M, "<span class='warning'>You are not holding anything to equip!</span>")
		return FALSE

	if(M.equip_to_appropriate_slot(src))
		M.update_inv_hands()
		return TRUE
	else
		if(equip_delay_self)
			return

	if(M.active_storage && M.active_storage.parent && SEND_SIGNAL(M.active_storage.parent, COMSIG_TRY_STORAGE_INSERT, src,M))
		return TRUE

	var/list/obj/item/possible = list(M.get_inactive_held_item(), M.get_item_by_slot(SLOT_BELT), M.get_item_by_slot(SLOT_GENERC_DEXTROUS_STORAGE), M.get_item_by_slot(SLOT_BACK))
	for(var/i in possible)
		if(!i)
			continue
		var/obj/item/I = i
		if(SEND_SIGNAL(I, COMSIG_TRY_STORAGE_INSERT, src, M))
			return TRUE

	to_chat(M, "<span class='warning'>You are unable to equip that!</span>")
	return FALSE

/mob/verb/quick_equip()
	set name = "quick-equip"
	set hidden = 1

	var/obj/item/I = get_active_held_item()
	if (I)
		I.equip_to_best_slot(src)