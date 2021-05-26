/mob/living/carbon/human/update_hair()
	dna.species.handle_hair(src)

/mob/living/carbon/human/update_body()
	remove_overlay(BODY_LAYER)
	dna.species.handle_body(src)
	..()

/mob/living/carbon/human/update_inv_w_uniform()
	remove_overlay(UNIFORM_LAYER)

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_W_UNIFORM]
		inv.update_icon()

	if(istype(w_uniform, /obj/item/clothing/under))
		var/obj/item/clothing/under/U = w_uniform
		U.screen_loc = ui_iclothing
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)
				client.screen += w_uniform
		//update_observer_view(w_uniform,1)

		if(wear_suit && (wear_suit.flags_inv & HIDEJUMPSUIT))
			return


		var/t_color = U.item_color
		if(!t_color)
			t_color = U.icon_state
		//if(U.adjusted == ALT_STYLE)
		//	t_color = "[t_color]_d"
		//else if(U.adjusted == DIGITIGRADE_STYLE)
		//	t_color = "[t_color]_l"

		var/mutable_appearance/uniform_overlay

		//if(dna && dna.species.sexes)
		//	var/G = (gender == FEMALE) ? "f" : "m"
		//	if(G == "f" && U.fitted != NO_FEMALE_UNIFORM)
		//		uniform_overlay = U.build_worn_icon(state = "[t_color]", default_layer = UNIFORM_LAYER, default_icon_file = 'icons/mob/uniform.dmi', isinhands = FALSE, femaleuniform = U.fitted)

		if(!uniform_overlay)
			uniform_overlay = U.build_worn_icon(state = "[t_color]", default_layer = UNIFORM_LAYER, default_icon_file = 'icons/mob/uniform.dmi', isinhands = FALSE)


		//if(OFFSET_UNIFORM in dna.species.offset_features)
		//	uniform_overlay.pixel_x += dna.species.offset_features[OFFSET_UNIFORM][1]
		//	uniform_overlay.pixel_y += dna.species.offset_features[OFFSET_UNIFORM][2]
		overlays_standing[UNIFORM_LAYER] = uniform_overlay

	apply_overlay(UNIFORM_LAYER)
	//update_mutant_bodyparts()

///mob/living/carbon/human/update_inv_head()
//	..()
	//update_mutant_bodyparts()
	//var/mutable_appearance/head_overlay = overlays_standing[HEAD_LAYER]
	//if(head_overlay)
	//	remove_overlay(HEAD_LAYER)
		//if(OFFSET_HEAD in dna.species.offset_features)
		//	head_overlay.pixel_x += dna.species.offset_features[OFFSET_HEAD][1]
		//	head_overlay.pixel_y += dna.species.offset_features[OFFSET_HEAD][2]
		//	overlays_standing[HEAD_LAYER] = head_overlay
	//apply_overlay(HEAD_LAYER)

/mob/living/carbon/proc/update_hud_wear_mask(obj/item/I)
	return

/mob/living/carbon/human/update_inv_belt()
	remove_overlay(BELT_LAYER)

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_BELT]
		inv.update_icon()

	if(belt)
		belt.screen_loc = ui_belt
		if(client && hud_used && hud_used.hud_shown)
			client.screen += belt
		//update_observer_view(belt)

		var/t_state = belt.item_state
		if(!t_state)
			t_state = belt.icon_state

		overlays_standing[BELT_LAYER] = belt.build_worn_icon(state = t_state, default_layer = BELT_LAYER, default_icon_file = 'icons/mob/belt.dmi')
		var/mutable_appearance/belt_overlay = overlays_standing[BELT_LAYER]
		//if(OFFSET_BELT in dna.species.offset_features)
		//	belt_overlay.pixel_x += dna.species.offset_features[OFFSET_BELT][1]
		//	belt_overlay.pixel_y += dna.species.offset_features[OFFSET_BELT][2]
		overlays_standing[BELT_LAYER] = belt_overlay

	apply_overlay(BELT_LAYER)

/mob/living/carbon/human/update_inv_wear_suit()
	remove_overlay(SUIT_LAYER)

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_WEAR_SUIT]
		inv.update_icon()

	if(istype(wear_suit, /obj/item/clothing/suit))
		wear_suit.screen_loc = ui_oclothing
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)
				client.screen += wear_suit
		//update_observer_view(wear_suit,1)

		overlays_standing[SUIT_LAYER] = wear_suit.build_worn_icon(state = wear_suit.icon_state, default_layer = SUIT_LAYER, default_icon_file = 'icons/mob/suit.dmi')
		var/mutable_appearance/suit_overlay = overlays_standing[SUIT_LAYER]
		//if(OFFSET_SUIT in dna.species.offset_features)
		//	suit_overlay.pixel_x += dna.species.offset_features[OFFSET_SUIT][1]
		//	suit_overlay.pixel_y += dna.species.offset_features[OFFSET_SUIT][2]
		overlays_standing[SUIT_LAYER] = suit_overlay
	update_hair()
	//update_mutant_bodyparts()

	apply_overlay(SUIT_LAYER)

/mob/living/carbon/human/update_inv_pockets()
	if(client && hud_used)
		var/obj/screen/inventory/inv

		inv = hud_used.inv_slots[SLOT_L_STORE]
		inv.update_icon()

		inv = hud_used.inv_slots[SLOT_R_STORE]
		inv.update_icon()

		if(l_store)
			l_store.screen_loc = ui_storage1
			if(hud_used.hud_shown)
				client.screen += l_store
			//update_observer_view(l_store)

		if(r_store)
			r_store.screen_loc = ui_storage2
			if(hud_used.hud_shown)
				client.screen += r_store
			//update_observer_view(r_store)

/mob/living/carbon/human/update_inv_wear_id()
	remove_overlay(ID_LAYER)

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_WEAR_ID]
		inv.update_icon()

	var/mutable_appearance/id_overlay = overlays_standing[ID_LAYER]

	if(wear_id)
		wear_id.screen_loc = ui_id
		if(client && hud_used && hud_used.hud_shown)
			client.screen += wear_id
		//update_observer_view(wear_id)

		id_overlay = wear_id.build_worn_icon(state = wear_id.item_state, default_layer = ID_LAYER, default_icon_file = 'icons/mob/mob.dmi')
		//if(OFFSET_ID in dna.species.offset_features)
		//	id_overlay.pixel_x += dna.species.offset_features[OFFSET_ID][1]
		//	id_overlay.pixel_y += dna.species.offset_features[OFFSET_ID][2]
		overlays_standing[ID_LAYER] = id_overlay

	apply_overlay(ID_LAYER)

/mob/living/carbon/human/update_inv_gloves()
	remove_overlay(GLOVES_LAYER)

	if(client && hud_used && hud_used.inv_slots[SLOT_GLOVES])
		var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_GLOVES]
		inv.update_icon()

	//if(!gloves && bloody_hands)
	//	var/mutable_appearance/bloody_overlay = mutable_appearance('icons/effects/blood.dmi', "bloodyhands", -GLOVES_LAYER)
	//	if(get_num_arms(FALSE) < 2)
	//		if(has_left_hand(FALSE))
	//			bloody_overlay.icon_state = "bloodyhands_left"
	//		else if(has_right_hand(FALSE))
	//			bloody_overlay.icon_state = "bloodyhands_right"

	//	overlays_standing[GLOVES_LAYER] = bloody_overlay

	var/mutable_appearance/gloves_overlay = overlays_standing[GLOVES_LAYER]
	if(gloves)
		gloves.screen_loc = ui_gloves
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)
				client.screen += gloves
		//update_observer_view(gloves,1)
		var/t_state = gloves.item_state
		if(!t_state)
			t_state = gloves.icon_state
		overlays_standing[GLOVES_LAYER] = gloves.build_worn_icon(state = t_state, default_layer = GLOVES_LAYER, default_icon_file = 'icons/mob/hands.dmi')
		gloves_overlay = overlays_standing[GLOVES_LAYER]
		//if(OFFSET_GLOVES in dna.species.offset_features)
		//	gloves_overlay.pixel_x += dna.species.offset_features[OFFSET_GLOVES][1]
		//	gloves_overlay.pixel_y += dna.species.offset_features[OFFSET_GLOVES][2]
	overlays_standing[GLOVES_LAYER] = gloves_overlay
	apply_overlay(GLOVES_LAYER)

/mob/living/carbon/human/update_inv_glasses()
	remove_overlay(GLASSES_LAYER)

	//if(!get_bodypart(BODY_ZONE_HEAD))
	//	return

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_GLASSES]
		inv.update_icon()

	if(glasses)
		glasses.screen_loc = ui_glasses
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)
				client.screen += glasses
		//update_observer_view(glasses,1)
		if(!(head && (head.flags_inv & HIDEEYES)) && !(wear_mask && (wear_mask.flags_inv & HIDEEYES)))
			overlays_standing[GLASSES_LAYER] = glasses.build_worn_icon(state = glasses.icon_state, default_layer = GLASSES_LAYER, default_icon_file = 'icons/mob/eyes.dmi')

		var/mutable_appearance/glasses_overlay = overlays_standing[GLASSES_LAYER]
		if(glasses_overlay)
		//	if(OFFSET_GLASSES in dna.species.offset_features)
		//		glasses_overlay.pixel_x += dna.species.offset_features[OFFSET_GLASSES][1]
		//		glasses_overlay.pixel_y += dna.species.offset_features[OFFSET_GLASSES][2]
			overlays_standing[GLASSES_LAYER] = glasses_overlay
	apply_overlay(GLASSES_LAYER)

/mob/living/carbon/human/update_inv_ears()
	remove_overlay(EARS_LAYER)

	//if(!get_bodypart(BODY_ZONE_HEAD))
	//	return

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_EARS]
		inv.update_icon()

	if(ears)
		ears.screen_loc = ui_ears
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)
				client.screen += ears
		//update_observer_view(ears,1)

		overlays_standing[EARS_LAYER] = ears.build_worn_icon(state = ears.icon_state, default_layer = EARS_LAYER, default_icon_file = 'icons/mob/ears.dmi')
		var/mutable_appearance/ears_overlay = overlays_standing[EARS_LAYER]
		//if(OFFSET_EARS in dna.species.offset_features)
		//	ears_overlay.pixel_x += dna.species.offset_features[OFFSET_EARS][1]
		//	ears_overlay.pixel_y += dna.species.offset_features[OFFSET_EARS][2]
		overlays_standing[EARS_LAYER] = ears_overlay
	apply_overlay(EARS_LAYER)

/mob/living/carbon/human/update_inv_shoes()
	remove_overlay(SHOES_LAYER)

	if(get_num_legs(FALSE) <2)
		return

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_SHOES]
		inv.update_icon()

	if(shoes)
		shoes.screen_loc = ui_shoes
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)
				client.screen += shoes
		//update_observer_view(shoes,1)
		overlays_standing[SHOES_LAYER] = shoes.build_worn_icon(state = shoes.icon_state, default_layer = SHOES_LAYER, default_icon_file = 'icons/mob/feet.dmi')
		var/mutable_appearance/shoes_overlay = overlays_standing[SHOES_LAYER]
		//if(OFFSET_SHOES in dna.species.offset_features)
		//	shoes_overlay.pixel_x += dna.species.offset_features[OFFSET_SHOES][1]
		//	shoes_overlay.pixel_y += dna.species.offset_features[OFFSET_SHOES][2]
		overlays_standing[SHOES_LAYER] = shoes_overlay

	apply_overlay(SHOES_LAYER)

/mob/living/carbon/human/update_inv_s_store()
	remove_overlay(SUIT_STORE_LAYER)

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_S_STORE]
		inv.update_icon()

	//if(s_store)
	//	s_store.screen_loc = ui_sstore1
	//	if(client && hud_used && hud_used.hud_shown)
	//		client.screen += s_store
	//	update_observer_view(s_store)
	//	var/t_state = s_store.item_state
	//	if(!t_state)
	//		t_state = s_store.icon_state
	//	overlays_standing[SUIT_STORE_LAYER]	= mutable_appearance('icons/mob/belt_mirror.dmi', t_state, -SUIT_STORE_LAYER)
	//	var/mutable_appearance/s_store_overlay = overlays_standing[SUIT_STORE_LAYER]
	//	if(OFFSET_S_STORE in dna.species.offset_features)
	//		s_store_overlay.pixel_x += dna.species.offset_features[OFFSET_S_STORE][1]
	//		s_store_overlay.pixel_y += dna.species.offset_features[OFFSET_S_STORE][2]
	//	overlays_standing[SUIT_STORE_LAYER] = s_store_overlay
	//apply_overlay(SUIT_STORE_LAYER)

/mob/living/carbon/human/update_hud_head(obj/item/I)
	I.screen_loc = ui_head
	if(client && hud_used && hud_used.hud_shown)
		if(hud_used.inventory_shown)
			client.screen += I
	//update_observer_view(I,1)

/mob/living/carbon/human/update_hud_wear_mask(obj/item/I)
	I.screen_loc = ui_mask
	if(client && hud_used && hud_used.hud_shown)
		if(hud_used.inventory_shown)
			client.screen += I
	//update_observer_view(I,1)

/mob/living/carbon/human/update_hud_back(obj/item/I)
	I.screen_loc = ui_back
	if(client && hud_used && hud_used.hud_shown)
		client.screen += I
	//update_observer_view(I)

/obj/item/proc/build_worn_icon(var/state = "", var/default_layer = 0, var/default_icon_file = null, var/isinhands = FALSE, var/femaleuniform = NO_FEMALE_UNIFORM)

	var/file2use
	//if(!isinhands && alternate_worn_icon)
	//	file2use = alternate_worn_icon
	if(!file2use)
		file2use = default_icon_file

	var/layer2use
	//if(alternate_worn_layer)
	//	layer2use = alternate_worn_layer
	if(!layer2use)
		layer2use = default_layer

	var/mutable_appearance/standing
	//if(femaleuniform)
	//	standing = wear_female_version(state,file2use,layer2use,femaleuniform)
	if(!standing)
		standing = mutable_appearance(file2use, state, -layer2use)

	//var/list/worn_overlays = worn_overlays(isinhands, file2use)
	//if(worn_overlays && worn_overlays.len)
	//	standing.overlays.Add(worn_overlays)

	//standing = center_image(standing, isinhands ? inhand_x_dimension : worn_x_dimension, isinhands ? inhand_y_dimension : worn_y_dimension)

	///var/mob/M = loc
	//if(istype(M))
	//	var/list/L = get_held_offsets()
	//	if(L)
	//		standing.pixel_x += L["x"]
	//		standing.pixel_y += L["y"]

	standing.alpha = alpha
	standing.color = color

	return standing