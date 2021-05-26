/mob/living/carbon/could_speak_in_language(datum/language/dt)
	//var/obj/item/organ/tongue/T = getorganslot(ORGAN_SLOT_TONGUE)
	//if(T)
	if(TRUE)//not_actual
		//. = T.could_speak_in_language(dt)
		return TRUE//not_actual
	else
		. = initial(dt.flags) & TONGUELESS_SPEECH