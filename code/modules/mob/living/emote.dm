/datum/emote/living/deathgasp
	key = "deathgasp"
	key_third_person = "deathgasps"
	message = "seizes up and falls limp, their eyes dead and lifeless..."
	message_robot = "shudders violently for a moment before falling still, its eyes slowly darkening."
	message_AI = "lets out a flurry of sparks, its screen flickering as its systems slowly halt."
	message_alien = "lets out a waning guttural screech, green blood bubbling from its maw..."
	message_larva = "lets out a sickly hiss of air and falls limply to the floor..."
	message_monkey = "lets out a faint chimper as it collapses and stops moving..."
	message_simple =  "stops moving..."
	stat_allowed = UNCONSCIOUS

/datum/emote/living/custom
	key = "me"
	key_third_person = "custom"
	message = null

/datum/emote/living/custom/proc/check_invalid(mob/user, input)
	. = TRUE
	if(copytext(input,1,5) == "says")
		to_chat(user, "<span class='danger'>Invalid emote.</span>")
	else if(copytext(input,1,9) == "exclaims")
		to_chat(user, "<span class='danger'>Invalid emote.</span>")
	else if(copytext(input,1,6) == "yells")
		to_chat(user, "<span class='danger'>Invalid emote.</span>")
	else if(copytext(input,1,5) == "asks")
		to_chat(user, "<span class='danger'>Invalid emote.</span>")
	else
		. = FALSE

/datum/emote/living/custom/run_emote(mob/user, params, type_override = null)
	//if(is_banned_from(user.ckey, "Emote"))
	if(FALSE)//not_actual
		to_chat(user, "You cannot send custom emotes (banned).")
		return FALSE
	else if(QDELETED(user))
		return FALSE
	//else if(user.client && user.client.prefs.muted & MUTE_IC)
	else if (FALSE)//not_actual
		to_chat(user, "You cannot send IC messages (muted).")
		return FALSE
	//else if(!params)
	//	var/custom_emote = copytext(sanitize(input("Choose an emote to display.") as text|null), 1, MAX_MESSAGE_LEN)
	//	if(custom_emote && !check_invalid(user, custom_emote))
	//		var/type = input("Is this a visible or hearable emote?") as null|anything in list("Visible", "Hearable")
	//		switch(type)
	//			if("Visible")
	//				emote_type = EMOTE_VISIBLE
	//			if("Hearable")
	//				emote_type = EMOTE_AUDIBLE
	//			else
	//				alert("Unable to use this emote, must be either hearable or visible.")
	//				return
	//		message = custom_emote
	else
		message = params
		if(type_override)
			emote_type = type_override
	. = ..()
	message = null
	emote_type = EMOTE_VISIBLE

/datum/emote/living/custom/replace_pronoun(mob/user, message)
	return message