//GLOBAL_DATUM_INIT(inventory_state, /datum/ui_state/inventory_state, new)
GLOBAL_DATUM_INIT(inventory_state, /datum/ui_state/inventory_state, new /datum/ui_state/inventory_state)//not_actual

/datum/ui_state/inventory_state/can_use_topic(src_object, mob/user)
	if(!(src_object in user))
		return UI_CLOSE
	return user.shared_ui_interaction(src_object)