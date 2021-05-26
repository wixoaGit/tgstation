/client/Topic(href, href_list, hsrc)
	if(!usr || usr != mob)
		return

	//if(href_list["asset_cache_confirm_arrival"])
	//	var/job = text2num(href_list["asset_cache_confirm_arrival"])
	//	if (job && job <= last_asset_job && !(job in completed_asset_jobs))
	//		completed_asset_jobs += job
	//		return
	//	else if (job in completed_asset_jobs)
	//		to_chat(src, "<span class='danger'>An error has been detected in how your client is receiving resources. Attempting to correct.... (If you keep seeing these messages you might want to close byond and reconnect)</span>")
	//		src << browse("...", "window=asset_cache_browser")

	//var/mtl = CONFIG_GET(number/minute_topic_limit)
	//if (!holder && mtl)
	//	var/minute = round(world.time, 600)
	//	if (!topiclimiter)
	//		topiclimiter = new(LIMITER_SIZE)
	//	if (minute != topiclimiter[CURRENT_MINUTE])
	//		topiclimiter[CURRENT_MINUTE] = minute
	//		topiclimiter[MINUTE_COUNT] = 0
	//	topiclimiter[MINUTE_COUNT] += 1
	//	if (topiclimiter[MINUTE_COUNT] > mtl)
	//		var/msg = "Your previous action was ignored because you've done too many in a minute."
	//		if (minute != topiclimiter[ADMINSWARNED_AT])
	//			topiclimiter[ADMINSWARNED_AT] = minute
	//			msg += " Administrators have been informed."
	//			log_game("[key_name(src)] Has hit the per-minute topic limit of [mtl] topic calls in a given game minute")
	//			message_admins("[ADMIN_LOOKUPFLW(src)] [ADMIN_KICK(usr)] Has hit the per-minute topic limit of [mtl] topic calls in a given game minute")
	//		to_chat(src, "<span class='danger'>[msg]</span>")
	//		return

	//var/stl = CONFIG_GET(number/second_topic_limit)
	//if (!holder && stl)
	//	var/second = round(world.time, 10)
	//	if (!topiclimiter)
	//		topiclimiter = new(LIMITER_SIZE)
	//	if (second != topiclimiter[CURRENT_SECOND])
	//		topiclimiter[CURRENT_SECOND] = second
	//		topiclimiter[SECOND_COUNT] = 0
	//	topiclimiter[SECOND_COUNT] += 1
	//	if (topiclimiter[SECOND_COUNT] > stl)
	//		to_chat(src, "<span class='danger'>Your previous action was ignored because you've done too many in a second</span>")
	//		return

	//if(!(href_list["_src_"] == "chat" && href_list["proc"] == "ping" && LAZYLEN(href_list) == 2))
	//	log_href("[src] (usr:[usr]\[[COORD(usr)]\]) : [hsrc ? "[hsrc] " : ""][href]")

	//if(href_list["priv_msg"])
	//	cmd_admin_pm(href_list["priv_msg"],null)
	//	return

	switch(href_list["_src_"])
		if("holder")
			hsrc = holder
		if("usr")
			hsrc = mob
		if("prefs")
			if (inprefs)
				return
			inprefs = TRUE
			. = prefs.process_link(usr,href_list)
			inprefs = FALSE
			return
		//if("vars")
		//	return view_var_Topic(href,href_list,hsrc)
		if("chat")
			return chatOutput.Topic(href, href_list)

	//switch(href_list["action"])
	//	if("openLink")
	//		src << link(href_list["link"])
	if (hsrc)
		var/datum/real_src = hsrc
		if(QDELETED(real_src))
			return

	..()

/client/New(TopicData)
	var/tdata = TopicData
	chatOutput = new /datum/chatOutput(src)
	TopicData = null

	//if(connection != "seeker" && connection != "web")
	//	return null

	GLOB.clients += src
	GLOB.directory[ckey] = src

	//GLOB.ahelp_tickets.ClientLogin(src)
	var/connecting_admin = FALSE
	//holder = GLOB.admin_datums[ckey]
	holder = new /datum/admins(new /datum/admin_rank("Admin", R_EVERYTHING, 0, 0), ckey, TRUE, TRUE)//not_actual
	if(holder)
		GLOB.admins |= src
		holder.owner = src
		connecting_admin = TRUE
	//else if(GLOB.deadmins[ckey])
	//	verbs += /client/proc/readmin
	//	connecting_admin = TRUE
	prefs = GLOB.preferences_datums[ckey]
	if(prefs)
		prefs.parent = src
	else
		prefs = new /datum/preferences(src)
		GLOB.preferences_datums[ckey] = prefs

	. = ..()

	chatOutput.start()

	if(holder)
		add_admin_verbs()
		//to_chat(src, get_message_output("memo"))
		//adminGreet()

/client/Del()
	//if(credits)
	//	QDEL_LIST(credits)
	//log_access("Logout: [key_name(src)]")
	//if(holder)
	//	adminGreet(1)
	//	holder.owner = null
	//	GLOB.admins -= src
	//	if (!GLOB.admins.len && SSticker.IsRoundInProgress())=
	//		var/cheesy_message = pick(
	//			"I have no admins online!",\
	//			"I'm all alone :(",\
	//			"I'm feeling lonely :(",\
	//			"I'm so lonely :(",\
	//			"Why does nobody love me? :(",\
	//			"I want a man :(",\
	//			"Where has everyone gone?",\
	//			"I need a hug :(",\
	//			"Someone come hold me :(",\
	//			"I need someone on me :(",\
	//			"What happened? Where has everyone gone?",\
	//			"Forever alone :("\
	//		)

	//		send2irc("Server", "[cheesy_message] (No admins online)")

	//GLOB.ahelp_tickets.ClientLogout(src)
	GLOB.directory -= ckey
	GLOB.clients -= src
	//QDEL_LIST_ASSOC_VAL(char_render_holders)
	//if(movingmob != null)
	//	movingmob.client_mobs_in_contents -= mob
	//	UNSETEMPTY(movingmob.client_mobs_in_contents)
	//Master.UpdateTickRate()
	return ..()

///client/Destroy()
//	return QDEL_HINT_HARDDEL_NOW