/datum/outfit
	var/name = "Naked"

	var/uniform = null
	var/suit = null
	var/toggle_helmet = TRUE
	var/back = null
	var/belt = null
	var/gloves = null
	var/shoes = null
	var/head = null
	var/mask = null
	var/neck = null
	var/ears = null
	var/glasses = null
	var/id = null
	var/l_pocket = null
	var/r_pocket = null
	var/suit_store = null
	var/r_hand = null
	var/l_hand = null
	var/internals_slot = null
	var/list/backpack_contents = null
	var/box
	var/list/implants = null
	var/accessory = null

	var/can_be_admin_equipped = TRUE
	var/list/chameleon_extras

/datum/outfit/proc/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	return

/datum/outfit/proc/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	return

/datum/outfit/proc/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	pre_equip(H, visualsOnly)
	
	if(uniform)
		H.equip_to_slot_or_del(new uniform(H),SLOT_W_UNIFORM)
	if(suit)
		H.equip_to_slot_or_del(new suit(H),SLOT_WEAR_SUIT)
	if(back)
		H.equip_to_slot_or_del(new back(H),SLOT_BACK)
	if(belt)
		H.equip_to_slot_or_del(new belt(H),SLOT_BELT)
	if(gloves)
		H.equip_to_slot_or_del(new gloves(H),SLOT_GLOVES)
	if(shoes)
		H.equip_to_slot_or_del(new shoes(H),SLOT_SHOES)
	if(head)
		H.equip_to_slot_or_del(new head(H),SLOT_HEAD)
	if(mask)
		H.equip_to_slot_or_del(new mask(H),SLOT_WEAR_MASK)
	if(neck)
		H.equip_to_slot_or_del(new neck(H),SLOT_NECK)
	if(ears)
		H.equip_to_slot_or_del(new ears(H),SLOT_EARS)
	if(glasses)
		H.equip_to_slot_or_del(new glasses(H),SLOT_GLASSES)
	if(id)
		H.equip_to_slot_or_del(new id(H),SLOT_WEAR_ID)
	if(suit_store)
		H.equip_to_slot_or_del(new suit_store(H),SLOT_S_STORE)
	
	//if(accessory)
	//	var/obj/item/clothing/under/U = H.w_uniform
	//	if(U)
	//		U.attach_accessory(new accessory(H))
	//	else
	//		WARNING("Unable to equip accessory [accessory] in outfit [name]. No uniform present!")
	
	if(l_hand)
		H.put_in_l_hand(new l_hand(H))
	if(r_hand)
		H.put_in_r_hand(new r_hand(H))
	
	if(!visualsOnly)
		if(l_pocket)
			H.equip_to_slot_or_del(new l_pocket(H),SLOT_L_STORE)
		if(r_pocket)
			H.equip_to_slot_or_del(new r_pocket(H),SLOT_R_STORE)

		if(box)
			if(!backpack_contents)
				backpack_contents = list()
			backpack_contents.Insert(1, box)
			backpack_contents[box] = 1

		if(backpack_contents)
			for(var/path in backpack_contents)
				var/number = backpack_contents[path]
				if(!isnum(number))
					number = 1
				for(var/i in 1 to number)
					H.equip_to_slot_or_del(new path(H),SLOT_IN_BACKPACK)
	
	//if(!H.head && toggle_helmet && istype(H.wear_suit, /obj/item/clothing/suit/space/hardsuit))
	//	var/obj/item/clothing/suit/space/hardsuit/HS = H.wear_suit
	//	HS.ToggleHelmet()
	
	post_equip(H, visualsOnly)

	//if(!visualsOnly)
	//	apply_fingerprints(H)
	//	if(internals_slot)
	//		H.internal = H.get_item_by_slot(internals_slot)
	//		H.update_action_buttons_icon()
	//	if(implants)
	//		for(var/implant_type in implants)
	//			var/obj/item/implant/I = new implant_type(H)
	//			I.implant(H, null, TRUE)
	
	H.update_body()
	return TRUE