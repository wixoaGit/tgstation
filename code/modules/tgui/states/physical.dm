//GLOBAL_DATUM_INIT(physical_state, /datum/ui_state/physical, new)
GLOBAL_DATUM_INIT(physical_state, /datum/ui_state/physical, new /datum/ui_state/physical)//not_actual

/datum/ui_state/physical/can_use_topic(src_object, mob/user)
	. = user.shared_ui_interaction(src_object)
	if(. > UI_CLOSE)
		return min(., user.physical_can_use_topic(src_object))

/mob/proc/physical_can_use_topic(src_object)
	return UI_CLOSE

/mob/living/physical_can_use_topic(src_object)
	return shared_living_ui_distance(src_object)

///mob/living/silicon/physical_can_use_topic(src_object)
//	return max(UI_UPDATE, shared_living_ui_distance(src_object))

///mob/living/silicon/ai/physical_can_use_topic(src_object)
//	return UI_UPDATE