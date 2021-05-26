/datum/chatOutput
	var/client/owner
	var/loaded       = FALSE
	var/list/messageQueue
	var/cookieSent   = FALSE
	var/broken       = FALSE
	var/list/connectionHistory
	var/adminMusicVolume = 25

/datum/chatOutput/New(client/C)
	owner = C
	messageQueue = list()
	connectionHistory = list()

/datum/chatOutput/proc/start()
	if(!owner)
		return FALSE

	//if(!winexists(owner, "browseroutput"))
	//	set waitfor = FALSE
	//	broken = TRUE
	//	message_admins("Couldn't start chat for [key_name_admin(owner)]!")
	//	. = FALSE
	//	alert(owner.mob, "Updated chat window does not exist. If you are using a custom skin file please allow the game to update.")
	//	return

	//if(winget(owner, "browseroutput", "is-visible") == "true")
	if (FALSE)//not_actual
		doneLoading()

	else
		load()

	return TRUE

/datum/chatOutput/proc/load()
	set waitfor = FALSE
	if(!owner)
		return

	var/datum/asset/stuff = get_asset_datum(/datum/asset/group/goonchat)
	stuff.send(owner)

	owner << browse(file('code/modules/goonchat/browserassets/html/browserOutput.html'), "window=browseroutput")

/datum/chatOutput/Topic(href, list/href_list)
	if(usr.client != owner)
		return TRUE

	var/list/params = list()
	for(var/key in href_list)
		if(length(key) > 7 && findtext(key, "param"))
			var/param_name = copytext(key, 7, -1)
			var/item       = href_list[key]

			params[param_name] = item

	var/data
	switch(href_list["proc"])
		if("doneLoading")
			data = doneLoading(arglist(params))

		//if("debug")
		//	data = debug(arglist(params))

		if("ping")
			data = ping(arglist(params))

		//if("analyzeClientData")
		//	data = analyzeClientData(arglist(params))

		if("setMusicVolume")
			data = setMusicVolume(arglist(params))

	if(data)
		ehjax_send(data = data)

/datum/chatOutput/proc/doneLoading()
	if(loaded)
		return

	//testing("Chat loaded for [owner.ckey]")
	loaded = TRUE
	showChat()


	for(var/message in messageQueue)
		to_chat(owner, message, handle_whitespace=FALSE)

	messageQueue = null
	sendClientData()

	//SEND_TEXT(owner, "<span class=\"userdanger\">Failed to load fancy chat, reverting to old chat. Certain features won't work.</span>")
	SEND_TEXT(owner, "<span class='userdanger'>Failed to load fancy chat, reverting to old chat. Certain features won't work.</span>")//not_actual

/datum/chatOutput/proc/showChat()
	//winset(owner, "output", "is-visible=false")
	//winset(owner, "browseroutput", "is-disabled=false;is-visible=true")

///datum/chatOutput/proc/ehjax_send(client/C = owner, window = "browseroutput", data)
/datum/chatOutput/proc/ehjax_send(client/C, window = "browseroutput", data)//not_actual
	if (C == null) C = owner//not_actual
	if(islist(data))
		data = json_encode(data)
	C << output("[data]", "[window]:ehjaxCallback")

/datum/chatOutput/proc/setMusicVolume(volume = "")
	if(volume)
		adminMusicVolume = CLAMP(text2num(volume), 0, 100)

/datum/chatOutput/proc/sendClientData()
	//var/list/deets = list("clientData" = list())
	var/list/deets = list()//not_actual
	var/list/clientData = list()//not_actual
	clientData["ckey"] = owner.ckey//not_actual
	deets["clientData"] = clientData//not_actual
	//deets["clientData"]["ckey"] = owner.ckey
	//deets["clientData"]["ip"] = owner.address
	//deets["clientData"]["compid"] = owner.computer_id
	var/data = json_encode(deets)
	ehjax_send(data = data)

/datum/chatOutput/proc/ping()
	return "pong"

/proc/to_chat(target, message, handle_whitespace=TRUE)
	if(!target)
		return

	//if (istype(target, /savefile))
	//	CRASH("Invalid message! [message]")

	if(!istext(message))
		if (istype(message, /image) || istype(message, /sound))
			CRASH("Invalid message! [message]")
		return

	if(target == world)
		target = GLOB.clients

	var/original_message = message
	//message = replacetext(message, "\improper", "")
	//message = replacetext(message, "\proper", "")
	if(handle_whitespace)
		message = replacetext(message, "\n", "<br>")
		//message = replacetext(message, "\t", "[GLOB.TAB][GLOB.TAB]")

	if(islist(target))
		var/twiceEncoded = url_encode(url_encode(message))
		for(var/I in target)
			//var/client/C = CLIENT_FROM_VAR(I)
			//not_actual
			var/client/C
			if (istype(I, /client)) C = I
			else if (istype(I, /mob))
				var/mob/M = I
				C = M.client
			else CRASH("INVALID I, browserOutput.dm 1")

			if (!C)
				continue

			SEND_TEXT(C, original_message)

			if(!C.chatOutput || C.chatOutput.broken)
				continue

			if(!C.chatOutput.loaded)
				C.chatOutput.messageQueue += message
				continue

			C << output(twiceEncoded, "browseroutput:output")
	else
		//var/client/C = CLIENT_FROM_VAR(target)
		//not_actual
		var/client/C
		if (istype(target, /client)) C = target
		else if (istype(target, /mob))
			var/mob/M = target
			C = M.client
		else CRASH("INVALID I, browserOutput.dm 1")

		if (!C)
			return

		SEND_TEXT(C, original_message)

		if(!C.chatOutput || C.chatOutput.broken)
			return

		if(!C.chatOutput.loaded)
			C.chatOutput.messageQueue += message
			return

		C << output(url_encode(url_encode(message)), "browseroutput:output")