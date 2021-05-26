/mob/living/carbon/human/can_equip(obj/item/I, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	return dna.species.can_equip(I, slot, disable_warning, src, bypass_equip_delay_self)

/mob/living/carbon/human/get_item_by_slot(slot_id)
	switch(slot_id)
		if(SLOT_BACK)
			return back
		if(SLOT_WEAR_MASK)
			return wear_mask
		//if(SLOT_NECK)
		//	return wear_neck
		//if(SLOT_HANDCUFFED)
		//	return handcuffed
		//if(SLOT_LEGCUFFED)
		//	return legcuffed
		if(SLOT_BELT)
			return belt
		if(SLOT_WEAR_ID)
			return wear_id
		if(SLOT_EARS)
			return ears
		if(SLOT_GLASSES)
			return glasses
		if(SLOT_GLOVES)
			return gloves
		if(SLOT_HEAD)
			return head
		if(SLOT_SHOES)
			return shoes
		if(SLOT_WEAR_SUIT)
			return wear_suit
		if(SLOT_W_UNIFORM)
			return w_uniform
		if(SLOT_L_STORE)
			return l_store
		if(SLOT_R_STORE)
			return r_store
		if(SLOT_S_STORE)
			return s_store
	return null

/mob/living/carbon/human/equip_to_slot(obj/item/I, slot)
	if(!..())
		return

	var/not_handled = FALSE
	switch(slot)
		if(SLOT_BELT)
			belt = I
			update_inv_belt()
		if(SLOT_WEAR_ID)
			wear_id = I
			//sec_hud_set_ID()
			update_inv_wear_id()
		if(SLOT_EARS)
			ears = I
			update_inv_ears()
		if(SLOT_GLASSES)
			glasses = I
		//	var/obj/item/clothing/glasses/G = I
		//	if(G.glass_colour_type)
		//		update_glasses_color(G, 1)
		//	if(G.tint)
		//		update_tint()
		//	if(G.vision_correction)
		//		clear_fullscreen("nearsighted")
		//		clear_fullscreen("eye_damage")
		//	if(G.vision_flags || G.darkness_view || G.invis_override || G.invis_view || !isnull(G.lighting_alpha))
		//		update_sight()
			update_inv_glasses()
		if(SLOT_GLOVES)
			gloves = I
			update_inv_gloves()
		if(SLOT_SHOES)
			shoes = I
			update_inv_shoes()
		if(SLOT_WEAR_SUIT)
			wear_suit = I
		//	if(I.flags_inv & HIDEJUMPSUIT)
		//		update_inv_w_uniform()
		//	if(wear_suit.breakouttime)
		//		stop_pulling() //can't pull if restrained
		//		update_action_buttons_icon()
			update_inv_wear_suit()
		if(SLOT_W_UNIFORM)
			w_uniform = I
		//	update_suit_sensors()
			update_inv_w_uniform()
		if(SLOT_L_STORE)
			l_store = I
			update_inv_pockets()
		if(SLOT_R_STORE)
			r_store = I
			update_inv_pockets()
		if(SLOT_S_STORE)
			s_store = I
			update_inv_s_store()
		else
			to_chat(src, "<span class='danger'>You are trying to equip this item to an unsupported inventory slot. Report this to a coder!</span>")

	if(!not_handled)
		I.equipped(src, slot)

	return not_handled

/mob/living/carbon/human/doUnEquip(obj/item/I, force, newloc, no_move, invdrop = TRUE)
	var/index = get_held_index_of_item(I)
	. = ..()
	if(!. || !I)
		return
	//if(index && !QDELETED(src) && dna.species.mutanthands)
	//	put_in_hand(new dna.species.mutanthands(), index)
	if(I == wear_suit)
		if(s_store && invdrop)
			dropItemToGround(s_store, TRUE)
		//if(wear_suit.breakouttime)
		//	drop_all_held_items()
		//	update_action_buttons_icon()
		wear_suit = null
		if(!QDELETED(src))
			//if(I.flags_inv & HIDEJUMPSUIT)
			//	update_inv_w_uniform()
			update_inv_wear_suit()
	else if(I == w_uniform)
		if(invdrop)
			if(r_store)
				dropItemToGround(r_store, TRUE)
			if(l_store)
				dropItemToGround(l_store, TRUE)
			if(wear_id)
				dropItemToGround(wear_id)
			if(belt)
				dropItemToGround(belt)
		w_uniform = null
		//update_suit_sensors()
		if(!QDELETED(src))
			update_inv_w_uniform()
	else if(I == gloves)
		gloves = null
		if(!QDELETED(src))
			update_inv_gloves()
	else if(I == glasses)
		glasses = null
		var/obj/item/clothing/glasses/G = I
		//if(G.glass_colour_type)
		//	update_glasses_color(G, 0)
		//if(G.tint)
		//	update_tint()
		//if(G.vision_correction)
		//	if(has_trait(TRAIT_NEARSIGHT))
		//		overlay_fullscreen("nearsighted", /obj/screen/fullscreen/impaired, 1)
		//	adjust_eye_damage(0)
		//if(G.vision_flags || G.darkness_view || G.invis_override || G.invis_view || !isnull(G.lighting_alpha))
		//	update_sight()
		if(!QDELETED(src))
			update_inv_glasses()
	else if(I == ears)
		ears = null
		if(!QDELETED(src))
			update_inv_ears()
	else if(I == shoes)
		shoes = null
		if(!QDELETED(src))
			update_inv_shoes()
	else if(I == belt)
		belt = null
		if(!QDELETED(src))
			update_inv_belt()
	else if(I == wear_id)
		wear_id = null
		//sec_hud_set_ID()
		if(!QDELETED(src))
			update_inv_wear_id()
	else if(I == r_store)
		r_store = null
		if(!QDELETED(src))
			update_inv_pockets()
	else if(I == l_store)
		l_store = null
		if(!QDELETED(src))
			update_inv_pockets()
	else if(I == s_store)
		s_store = null
		if(!QDELETED(src))
			update_inv_s_store()

/mob/living/carbon/human/wear_mask_update(obj/item/I, toggle_off = 1)
	if((I.flags_inv & (HIDEHAIR|HIDEFACIALHAIR)) || (initial(I.flags_inv) & (HIDEHAIR|HIDEFACIALHAIR)))
		update_hair()
	//if(toggle_off && internal && !getorganslot(ORGAN_SLOT_BREATHING_TUBE))
	//	update_internals_hud_icon(0)
	//	internal = null
	if(I.flags_inv & HIDEEYES)
		update_inv_glasses()
	//sec_hud_set_security_status()
	..()

/mob/living/carbon/human/head_update(obj/item/I, forced)
	if((I.flags_inv & (HIDEHAIR|HIDEFACIALHAIR)) || forced)
		update_hair()
	else
		var/obj/item/clothing/C = I
		if(istype(C) && C.dynamic_hair_suffix)
			update_hair()
	if(I.flags_inv & HIDEEYES || forced)
		update_inv_glasses()
	if(I.flags_inv & HIDEEARS || forced)
		update_body()
	//sec_hud_set_security_status()
	..()

/mob/living/carbon/human/proc/equipOutfit(outfit, visualsOnly = FALSE)
	var/datum/outfit/O = null

	if(ispath(outfit))
		O = new outfit
	else
		O = outfit
		if(!istype(O))
			return 0
	if(!O)
		return 0

	return O.equip(src, visualsOnly)