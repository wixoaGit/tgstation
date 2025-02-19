/mob/living/carbon/get_item_by_slot(slot_id)
	switch(slot_id)
		if(SLOT_BACK)
			return back
		//if(SLOT_WEAR_MASK)
		//	return wear_mask
		//if(SLOT_NECK)
		//	return wear_neck
		if(SLOT_HEAD)
			return head
		//if(SLOT_HANDCUFFED)
		//	return handcuffed
		//if(SLOT_LEGCUFFED)
		//	return legcuffed
	return null

/mob/living/carbon/equip_to_slot(obj/item/I, slot)
	if(!slot)
		return
	if(!istype(I))
		return

	var/index = get_held_index_of_item(I)
	if(index)
		held_items[index] = null

	if(I.pulledby)
		I.pulledby.stop_pulling()

	I.screen_loc = null
	if(client)
		client.screen -= I
	//if(observers && observers.len)
	//	for(var/M in observers)
	//		var/mob/dead/observe = M
	//		if(observe.client)
	//			observe.client.screen -= I
	I.forceMove(src)
	I.layer = ABOVE_HUD_LAYER
	//I.plane = ABOVE_HUD_PLANE
	//I.appearance_flags |= NO_CLIENT_COLOR
	var/not_handled = FALSE
	switch(slot)
		if(SLOT_BACK)
			back = I
			update_inv_back()
		if(SLOT_WEAR_MASK)
			wear_mask = I
			wear_mask_update(I, toggle_off = 0)
		if(SLOT_HEAD)
			head = I
			head_update(I)
		//if(SLOT_NECK)
		//	wear_neck = I
		//	update_inv_neck(I)
		//if(SLOT_HANDCUFFED)
		//	handcuffed = I
		//	update_handcuffed()
		//if(SLOT_LEGCUFFED)
		//	legcuffed = I
		//	update_inv_legcuffed()
		if(SLOT_HANDS)
			put_in_hands(I)
			update_inv_hands()
		if(SLOT_IN_BACKPACK)
			if(!SEND_SIGNAL(back, COMSIG_TRY_STORAGE_INSERT, I, src, TRUE))
				not_handled = TRUE
		else
			not_handled = TRUE

	if(!not_handled)
		I.equipped(src, slot)

	return not_handled

/mob/living/carbon/doUnEquip(obj/item/I)
	. = ..()
	if(!. || !I)
		return

	if(I == head)
		head = null
		if(!QDELETED(src))
			head_update(I)
	else if(I == back)
		back = null
		if(!QDELETED(src))
			update_inv_back()
	else if(I == wear_mask)
		wear_mask = null
		if(!QDELETED(src))
			wear_mask_update(I, toggle_off = 1)
	//if(I == wear_neck)
	//	wear_neck = null
	//	if(!QDELETED(src))
	//		update_inv_neck(I)
	//else if(I == handcuffed)
	//	handcuffed = null
	//	if(buckled && buckled.buckle_requires_restraints)
	//		buckled.unbuckle_mob(src)
	//	if(!QDELETED(src))
	//		update_handcuffed()
	//else if(I == legcuffed)
	//	legcuffed = null
	//	if(!QDELETED(src))
	//		update_inv_legcuffed()

/mob/living/proc/wear_mask_update(obj/item/I, toggle_off = 1)
	update_inv_wear_mask()

/mob/living/carbon/wear_mask_update(obj/item/I, toggle_off = 1)
	//var/obj/item/clothing/C = I
	//if(istype(C) && (C.tint || initial(C.tint)))
	//	update_tint()
	update_inv_wear_mask()

/mob/living/carbon/proc/head_update(obj/item/I, forced)
	//if(istype(I, /obj/item/clothing))
		//var/obj/item/clothing/C = I
		//if(C.tint || initial(C.tint))
		//	update_tint()
		//update_sight()
	if(I.flags_inv & HIDEMASK || forced)
		update_inv_wear_mask()
	update_inv_head()