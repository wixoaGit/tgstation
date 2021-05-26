/obj/item/proc/can_trigger_gun(mob/living/user)
	if(!user.can_use_guns(src))
		return FALSE
	return TRUE