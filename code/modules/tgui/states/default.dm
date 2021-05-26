//GLOBAL_DATUM_INIT(default_state, /datum/ui_state/default, new)
GLOBAL_DATUM_INIT(default_state, /datum/ui_state/default, new /datum/ui_state/default())//not_actual

/datum/ui_state/default/can_use_topic(src_object, mob/user)
	return user.default_can_use_topic(src_object)

/mob/proc/default_can_use_topic(src_object)
	return UI_CLOSE

/mob/living/default_can_use_topic(src_object)
	. = shared_ui_interaction(src_object)
	if(. > UI_CLOSE && loc)
		. = min(., loc.contents_ui_distance(src_object, src))
	if(. == UI_INTERACTIVE)
		return UI_UPDATE

/mob/living/carbon/human/default_can_use_topic(src_object)
	. = shared_ui_interaction(src_object)
	if(. > UI_CLOSE)
		. = min(., shared_living_ui_distance(src_object))