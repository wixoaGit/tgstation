/mob/living/carbon/update_transform()
	var/matrix/ntransform = matrix(transform)
	var/final_pixel_y = pixel_y
	var/final_dir = dir
	var/changed = 0
	if(lying != lying_prev && rotate_on_lying)
		changed++
		ntransform.TurnTo(lying_prev , lying)
		if(!lying)
			final_pixel_y = get_standard_pixel_y_offset()
		else
			if(lying_prev == 0)
				pixel_y = get_standard_pixel_y_offset()
				final_pixel_y = get_standard_pixel_y_offset(lying)
				if(dir & (EAST|WEST))
					final_dir = pick(NORTH, SOUTH)

	//if(resize != RESIZE_DEFAULT_SIZE)
	//	changed++
	//	ntransform.Scale(resize)
	//	resize = RESIZE_DEFAULT_SIZE

	if(changed)
		animate(src, transform = ntransform, time = 2, pixel_y = final_pixel_y, dir = final_dir, easing = EASE_IN|EASE_OUT)
		setMovetype(movement_type & ~FLOATING)

/mob/living/carbon
	//var/list/overlays_standing[TOTAL_LAYERS]
	var/list/overlays_standing = new /list(TOTAL_LAYERS)//not_actual

/mob/living/carbon/update_body()
	update_body_parts()

/mob/living/carbon/proc/update_body_parts()
	var/oldkey = icon_render_key
	icon_render_key = generate_icon_render_key()
	if(oldkey == icon_render_key)
		return

	remove_overlay(BODYPARTS_LAYER)

	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		BP.update_limb()
	
	if(limb_icon_cache[icon_render_key])
		load_limb_from_cache()
		return

	var/list/new_limbs = list()
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		new_limbs += BP.get_limb_icon()
	if(new_limbs.len)
		overlays_standing[BODYPARTS_LAYER] = new_limbs
		limb_icon_cache[icon_render_key] = new_limbs

	apply_overlay(BODYPARTS_LAYER)
	update_damage_overlays()

/mob/living/carbon/proc/generate_icon_render_key()
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		. += "-[BP.body_zone]"
		if(BP.use_digitigrade)
			. += "-digitigrade[BP.use_digitigrade]"
		if(BP.animal_origin)
			. += "-[BP.animal_origin]"
		if(BP.status == BODYPART_ORGANIC)
			. += "-organic"
		else
			. += "-robotic"

	if(has_trait(TRAIT_HUSK))
		. += "-husk"

/mob/living/carbon/proc/load_limb_from_cache()
	if(limb_icon_cache[icon_render_key])
		remove_overlay(BODYPARTS_LAYER)
		overlays_standing[BODYPARTS_LAYER] = limb_icon_cache[icon_render_key]
		apply_overlay(BODYPARTS_LAYER)
	update_damage_overlays()

/mob/living/carbon/proc/apply_overlay(cache_index)
	if((. = overlays_standing[cache_index]))
		add_overlay(.)

/mob/living/carbon/proc/remove_overlay(cache_index)
	var/I = overlays_standing[cache_index]
	if(I)
		cut_overlay(I)
		overlays_standing[cache_index] = null

/mob/living/carbon/update_inv_hands()
	remove_overlay(HANDS_LAYER)
	//if (handcuffed)
	//	drop_all_held_items()
	//	return

	var/list/hands = list()
	for(var/obj/item/I in held_items)
		if(client && hud_used/* && hud_used.hud_version != HUD_STYLE_NOHUD*/)
			I.screen_loc = ui_hand_position(get_held_index_of_item(I))
			client.screen += I
			//if(observers && observers.len)
			//	for(var/M in observers)
			//		var/mob/dead/observe = M
			//		if(observe.client && observe.client.eye == src)
			//			observe.client.screen += I
			//		else
			//			observers -= observe
			//			if(!observers.len)
			//				observers = null
			//				break

		var/t_state = I.item_state
		if(!t_state)
			t_state = I.icon_state

		var/icon_file = I.lefthand_file
		if(get_held_index_of_item(I) % 2 == 0)
			icon_file = I.righthand_file

		hands += I.build_worn_icon(state = t_state, default_layer = HANDS_LAYER, default_icon_file = icon_file, isinhands = TRUE)

	overlays_standing[HANDS_LAYER] = hands
	apply_overlay(HANDS_LAYER)

/mob/living/carbon/update_damage_overlays()
	remove_overlay(DAMAGE_LAYER)

	var/mutable_appearance/damage_overlay = mutable_appearance('icons/mob/dam_mob.dmi', "blank", -DAMAGE_LAYER)
	overlays_standing[DAMAGE_LAYER] = damage_overlay

	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		if(BP.dmg_overlay_type)
			if(BP.brutestate)
				//damage_overlay.add_overlay("[BP.dmg_overlay_type]_[BP.body_zone]_[BP.brutestate]0")
				damage_overlay.icon_state = "[BP.dmg_overlay_type]_[BP.body_zone]_[BP.brutestate]0"//not_actual
			if(BP.burnstate)
				//damage_overlay.add_overlay("[BP.dmg_overlay_type]_[BP.body_zone]_0[BP.burnstate]")
				damage_overlay.icon_state = "[BP.dmg_overlay_type]_[BP.body_zone]_0[BP.burnstate]"//not_actual

	apply_overlay(DAMAGE_LAYER)

/mob/living/carbon/update_inv_wear_mask()
	remove_overlay(FACEMASK_LAYER)

	if(!get_bodypart(BODY_ZONE_HEAD))
		return

	//if(client && hud_used && hud_used.inv_slots[SLOT_WEAR_MASK])
	//	var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_WEAR_MASK]
	//	inv.update_icon()

	if(wear_mask)
		if(!(SLOT_WEAR_MASK in check_obscured_slots()))
			overlays_standing[FACEMASK_LAYER] = wear_mask.build_worn_icon(state = wear_mask.icon_state, default_layer = FACEMASK_LAYER, default_icon_file = 'icons/mob/mask.dmi')
		update_hud_wear_mask(wear_mask)

	apply_overlay(FACEMASK_LAYER)

/mob/living/carbon/update_inv_back()
	remove_overlay(BACK_LAYER)

	//if(client && hud_used && hud_used.inv_slots[SLOT_BACK])
	//	var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_BACK]
	//	inv.update_icon()

	if(back)
		overlays_standing[BACK_LAYER] = back.build_worn_icon(state = back.icon_state, default_layer = BACK_LAYER, default_icon_file = 'icons/mob/back.dmi')
		update_hud_back(back)

	apply_overlay(BACK_LAYER)

/mob/living/carbon/update_inv_head()
	remove_overlay(HEAD_LAYER)

	if(!get_bodypart(BODY_ZONE_HEAD))
		return

	//if(client && hud_used && hud_used.inv_slots[SLOT_BACK])
	//	var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_HEAD]
	//	inv.update_icon()

	if(head)
		overlays_standing[HEAD_LAYER] = head.build_worn_icon(state = head.icon_state, default_layer = HEAD_LAYER, default_icon_file = 'icons/mob/head.dmi')
		update_hud_head(head)

	apply_overlay(HEAD_LAYER)

/mob/living/carbon/proc/update_hud_head(obj/item/I)
	return

/mob/living/carbon/proc/update_hud_back(obj/item/I)
	return