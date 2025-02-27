/proc/priority_announce(text, title = "", sound = 'sound/ai/attention.ogg', type , sender_override)
	if(!text)
		return

	var/announcement

	if(type == "Priority")
		announcement += "<h1 class='alert'>Priority Announcement</h1>"
		if (title && length(title) > 0)
			announcement += "<br><h2 class='alert'>[html_encode(title)]</h2>"
	else if(type == "Captain")
		announcement += "<h1 class='alert'>Captain Announces</h1>"
		//GLOB.news_network.SubmitArticle(text, "Captain's Announcement", "Station Announcements", null)

	else
		if(!sender_override)
			announcement += "<h1 class='alert'>[command_name()] Update</h1>"
		else
			announcement += "<h1 class='alert'>[sender_override]</h1>"
		if (title && length(title) > 0)
			announcement += "<br><h2 class='alert'>[html_encode(title)]</h2>"

		//if(!sender_override)
		//	if(title == "")
		//		GLOB.news_network.SubmitArticle(text, "Central Command Update", "Station Announcements", null)
		//	else
		//		GLOB.news_network.SubmitArticle(title + "<br><br>" + text, "Central Command", "Station Announcements", null)

	announcement += "<br><span class='alert'>[html_encode(text)]</span><br>"
	announcement += "<br>"

	var/s = sound(sound)
	for(var/mob/M in GLOB.player_list)
		if(!isnewplayer(M) && M.can_hear())
			to_chat(M, announcement)
			//if(M.client.prefs.toggles & SOUND_ANNOUNCEMENTS)
			if(TRUE)//not_actual
				SEND_SOUND(M, s)

/proc/minor_announce(message, title = "Attention:", alert)
	if(!message)
		return

	for(var/mob/M in GLOB.player_list)
		if(!isnewplayer(M) && M.can_hear())
			to_chat(M, "<span class='big bold'><font color = red>[html_encode(title)]</font color><BR>[html_encode(message)]</span><BR>")
			//if(M.client.prefs.toggles & SOUND_ANNOUNCEMENTS)
			//	if(alert)
			//		SEND_SOUND(M, sound('sound/misc/notice1.ogg'))
			//	else
			//		SEND_SOUND(M, sound('sound/misc/notice2.ogg'))