/mob/verb/say_verb(message as text)
	set name = "Say"
	set category = "IC"
	//if(GLOB.say_disabled)
	//	to_chat(usr, "<span class='danger'>Speech is currently admin-disabled.</span>")
	//	return
	if (message == "explode")
		explosion(get_turf(src), 5, 10, 15, 20)
	if(message)
		say(message)

/mob/proc/check_emote(message)
	if(copytext(message, 1, 2) == "*")
		emote(copytext(message, 2), intentional = TRUE)
		return 1

/mob/proc/get_message_mode(message)
	var/key = copytext(message, 1, 2)
	if(key == "#")
		return MODE_WHISPER
	else if(key == ";")
		return MODE_HEADSET
	else if(length(message) > 2 && (key in GLOB.department_radio_prefixes))
		var/key_symbol = lowertext(copytext(message, 2, 3))
		return GLOB.department_radio_keys[key_symbol]