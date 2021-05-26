/datum/saymode
	var/key
	var/mode

/datum/saymode/proc/handle_message(mob/living/user, message, datum/language/language)
	return TRUE