/mob/living/carbon/human/proc/get_assignment(if_no_id = "No id", if_no_job = "No job", hand_first = TRUE)
	var/obj/item/card/id/id = get_idcard(hand_first)
	if(id)
		. = id.assignment
	else
		var/obj/item/pda/pda = wear_id
		if(istype(pda))
			. = pda.ownjob
		else
			return if_no_id
	if(!.)
		return if_no_job

/mob/living/carbon/human/proc/get_authentification_name(if_no_id = "Unknown")
	var/obj/item/card/id/id = get_idcard(FALSE)
	if(id)
		return id.registered_name
	var/obj/item/pda/pda = wear_id
	if(istype(pda))
		return pda.owner
	return if_no_id

/mob/living/carbon/human/proc/get_face_name(if_no_face="Unknown")
	if( wear_mask && (wear_mask.flags_inv&HIDEFACE) )
		return if_no_face
	if( head && (head.flags_inv&HIDEFACE) )
		return if_no_face
	var/obj/item/bodypart/O = get_bodypart(BODY_ZONE_HEAD)
	if( !O || (has_trait(TRAIT_DISFIGURED)) || (O.brutestate+O.burnstate)>2 || cloneloss>50 || !real_name )
		return if_no_face
	return real_name

/mob/living/carbon/human/get_idcard(hand_first = TRUE)
	var/obj/item/card/id/id_card
	var/obj/item/held_item
	held_item = get_active_held_item()
	if(held_item)
		id_card = held_item.GetID()
	if(!id_card)
		held_item = get_inactive_held_item()
		if(held_item)
			id_card = held_item.GetID()

	if(id_card)
		if(hand_first)
			return id_card
		else
			. = id_card

	if(wear_id)
		id_card = wear_id.GetID()
		if(id_card)
			return id_card
	else if(belt)
		id_card = belt.GetID()
		if(id_card)
			return id_card

/mob/living/carbon/human/IsAdvancedToolUser()
	if(has_trait(TRAIT_MONKEYLIKE))
		return FALSE
	return TRUE