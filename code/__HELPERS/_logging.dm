#define DIRECT_OUTPUT(A, B) A << B
#define SEND_IMAGE(target, image) DIRECT_OUTPUT(target, image)
#define SEND_SOUND(target, sound) DIRECT_OUTPUT(target, sound)
#define SEND_TEXT(target, text) DIRECT_OUTPUT(target, text)
#define WRITE_FILE(file, text) DIRECT_OUTPUT(file, text)
#define WRITE_LOG(log, text) rustg_log_write(log, text)

//#define WARNING(MSG) warning("[MSG] in [__FILE__] at line [__LINE__] src: [src] usr: [usr].")
#define WARNING(MSG) warning("[MSG] in (__FILE__ macro not implemented) at line (__LINE__ macro not implemented) src: [src] usr: [usr].")//not_actual
/proc/warning(msg)
	msg = "## WARNING: [msg]"
	log_world(msg)

#ifdef TESTING
#define testing(msg) log_world("## TESTING: [msg]"); to_chat(world, "## TESTING: [msg]")
#else
#define testing(msg)
#endif

/proc/log_admin(text)
	GLOB.admin_log.Add(text)
	if (CONFIG_GET(flag/log_admin))
		WRITE_LOG(GLOB.world_game_log, "ADMIN: [text]")

/proc/log_game(text)
	if (CONFIG_GET(flag/log_game))
		WRITE_LOG(GLOB.world_game_log, "GAME: [text]")

/proc/log_manifest(ckey, datum/mind/mind,mob/body, latejoin = FALSE)
	if (CONFIG_GET(flag/log_manifest))
		WRITE_LOG(GLOB.world_manifest_log, "[ckey] \\ [body.real_name] \\ [mind.assigned_role] \\ [mind.special_role ? mind.special_role : "NONE"] \\ [latejoin ? "LATEJOIN":"ROUNDSTART"]")

/proc/log_telecomms(text)
	if (CONFIG_GET(flag/log_telecomms))
		WRITE_LOG(GLOB.world_telecomms_log, "TCOMMS: [text]")

/proc/log_world(text)
//#ifdef USE_CUSTOM_ERROR_HANDLER
	WRITE_LOG(GLOB.world_runtime_log, text)
//#endif
	SEND_TEXT(world.log, text)

/proc/log_config(text)
	WRITE_LOG(GLOB.config_error_log, text)
	SEND_TEXT(world.log, text)

/proc/start_log(log)
	WRITE_LOG(log, "Starting up round ID [GLOB.round_id].\n-------------------------")

/proc/key_name(whom, include_link = null, include_name = TRUE)
	var/mob/M
	var/client/C
	var/key
	var/ckey
	var/fallback_name

	if(!whom)
		return "*null*"
	if(istype(whom, /client))
		C = whom
		M = C.mob
		key = C.key
		ckey = C.ckey
	else if(ismob(whom))
		M = whom
		C = M.client
		key = M.key
		ckey = M.ckey
	else if(istext(whom))
		key = whom
		ckey = ckey(whom)
		C = GLOB.directory[ckey]
		if(C)
			M = C.mob
	else if(istype(whom,/datum/mind))
		var/datum/mind/mind = whom
		key = mind.key
		ckey = ckey(key)
		if(mind.current)
			M = mind.current
			if(M.client)
				C = M.client
		else
			fallback_name = mind.name
	else
		var/swhom = null

		if(istype(whom, /atom))
			var/atom/A = whom
			swhom = "[A.name]"
		else if(istype(whom, /datum))
			swhom = "[whom]"

		if(!swhom)
			swhom = "*invalid*"

		//return "\[[swhom]\]"
		return "([swhom])"//not_actual

	. = ""

	if(!ckey)
		include_link = FALSE

	if(key)
		//if(C && C.holder && C.holder.fakekey && !include_name)
		if(FALSE)//not_actual
			//if(include_link)
			//	. += "<a href='?priv_msg=[C.findStealthKey()]'>"
			. += "Administrator"
		else
			if(include_link)
				. += "<a href='?priv_msg=[ckey]'>"
			. += key
		if(!C)
			//. += "\[DC\]"
			. += "(DC)"//not_actual

		if(include_link)
			. += "</a>"
	else
		. += "*no key*"

	if(include_name)
		if(M)
			if(M.real_name)
				. += "/([M.real_name])"
			else if(M.name)
				. += "/([M.name])"
		else if(fallback_name)
			. += "/([fallback_name])"

	return .

/proc/key_name_admin(whom, include_name = TRUE)
	return key_name(whom, TRUE, include_name)

/proc/loc_name(atom/A)
	if(!istype(A))
		return "(INVALID LOCATION)"

	var/turf/T = A
	if (!istype(T))
		T = get_turf(A)

	if(istype(T))
		//return "([AREACOORD(T)])"
		return "(AREACOORD)"//not_actual
	else if(A.loc)
		return "(UNKNOWN (?, ?, ?))"