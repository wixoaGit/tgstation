/datum/proc/ui_status(mob/user, datum/ui_state/state)
	var/src_object = ui_host(user)
	. = UI_CLOSE
	if(!state)
		return

	if(isobserver(user))
		//if(IsAdminGhost(user))
		//	. = max(., UI_INTERACTIVE)

		//var/clientviewlist = getviewsize(user.client.view)
		//if(get_dist(src_object, user) < max(clientviewlist[1],clientviewlist[2]))
		//	. = max(., UI_UPDATE)

	var/result = state.can_use_topic(src_object, user)
	. = max(., result)

/datum/ui_state/proc/can_use_topic(src_object, mob/user)
	return UI_CLOSE

/mob/proc/shared_ui_interaction(src_object)
	if(!client)
		return UI_CLOSE
	else if(stat)
		return UI_DISABLED
	else if(incapacitated())
		return UI_UPDATE
	return UI_INTERACTIVE

/mob/living/shared_ui_interaction(src_object)
	. = ..()
	if(!(mobility_flags & MOBILITY_UI) && . == UI_INTERACTIVE)
		return UI_UPDATE

/atom/proc/contents_ui_distance(src_object, mob/living/user)
	return user.shared_living_ui_distance(src_object)

/mob/living/proc/shared_living_ui_distance(atom/movable/src_object)
	if(!(src_object in view(src)))
		return UI_CLOSE

	var/dist = get_dist(src_object, src)
	if(dist <= 1)
		return UI_INTERACTIVE
	else if(dist <= 2)
		return UI_UPDATE
	else if(dist <= 5)
		return UI_DISABLED
	return UI_CLOSE

/mob/living/carbon/human/shared_living_ui_distance(atom/movable/src_object)
	//if(dna.check_mutation(TK) && tkMaxRangeCheck(src, src_object))
	//	return UI_INTERACTIVE
	return ..()