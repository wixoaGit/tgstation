//GLOBAL_DATUM_INIT(notcontained_state, /datum/ui_state/notcontained_state, new)
GLOBAL_DATUM_INIT(notcontained_state, /datum/ui_state/notcontained_state, new /datum/ui_state/notcontained_state)//not_actual

/datum/ui_state/notcontained_state/can_use_topic(atom/src_object, mob/user)
	. = user.shared_ui_interaction(src_object)
	if(. > UI_CLOSE)
		return min(., user.notcontained_can_use_topic(src_object))

/mob/proc/notcontained_can_use_topic(src_object)
	return UI_CLOSE

/mob/living/notcontained_can_use_topic(atom/src_object)
	if(src_object.contains(src))
		return UI_CLOSE
	return default_can_use_topic(src_object)

///mob/living/silicon/notcontained_can_use_topic(src_object)
//	return default_can_use_topic(src_object)

///mob/living/simple_animal/drone/notcontained_can_use_topic(src_object)
//	return default_can_use_topic(src_object)