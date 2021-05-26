#define EMOTE_VISIBLE 1
#define EMOTE_AUDIBLE 2

/datum/emote
	var/key = ""
	var/key_third_person = ""
	var/message = ""
	var/message_mime = ""
	var/message_alien = ""
	var/message_larva = ""
	var/message_robot = ""
	var/message_AI = ""
	var/message_monkey = ""
	var/message_simple = ""
	var/message_param = ""
	var/emote_type = EMOTE_VISIBLE
	var/restraint_check = FALSE
	var/muzzle_ignore = FALSE
	//var/list/mob_type_allowed_typecache = /mob
	//var/list/mob_type_blacklist_typecache
	//var/list/mob_type_ignore_stat_typecache
	var/stat_allowed = CONSCIOUS
	var/sound
	var/vary = FALSE
	var/only_forced_audio = FALSE

	//var/static/list/emote_list = list()


/datum/emote/New()
	if(key_third_person)
		//emote_list[key_third_person] = src
		GLOB.emote_list[key_third_person] = src//not_actual
	//if (ispath(mob_type_allowed_typecache))
	//	switch (mob_type_allowed_typecache)
	//		if (/mob)
	//			mob_type_allowed_typecache = GLOB.typecache_mob
	//		if (/mob/living)
	//			mob_type_allowed_typecache = GLOB.typecache_living
	//		else
	//			mob_type_allowed_typecache = typecacheof(mob_type_allowed_typecache)
	//else
	//	mob_type_allowed_typecache = typecacheof(mob_type_allowed_typecache)
	//mob_type_blacklist_typecache = typecacheof(mob_type_blacklist_typecache)
	//mob_type_ignore_stat_typecache = typecacheof(mob_type_ignore_stat_typecache)

/datum/emote/proc/run_emote(mob/user, params, type_override, intentional = FALSE)
	. = TRUE
	//if(!can_run_emote(user, TRUE, intentional))
	//	return FALSE
	var/msg = select_message_type(user)
	if(params && message_param)
		msg = select_param(user, params)

	msg = replace_pronoun(user, msg)

	//if(isliving(user))
	//	var/mob/living/L = user
	//	for(var/obj/item/implant/I in L.implants)
	//		I.trigger(key, L)

	if(!msg)
		return

	//user.log_message(msg, LOG_EMOTE)
	msg = "<b>[user]</b> " + msg

	//var/tmp_sound = get_sound(user)
	//if(tmp_sound && (!only_forced_audio || !intentional))
	//	playsound(user, tmp_sound, 50, vary)

	//for(var/mob/M in GLOB.dead_mob_list)
	//	if(!M.client || isnewplayer(M))
	//		continue
	//	var/T = get_turf(user)
	//	if(M.stat == DEAD && M.client && (M.client.prefs.chat_toggles & CHAT_GHOSTSIGHT) && !(M in viewers(T, null)))
	//		M.show_message(msg)

	if(emote_type == EMOTE_AUDIBLE)
		user.audible_message(msg)
	else
		user.visible_message(msg)

/datum/emote/proc/replace_pronoun(mob/user, message)
	if(findtext(message, "their"))
		message = replacetext(message, "their", user.p_their())
	if(findtext(message, "them"))
		message = replacetext(message, "them", user.p_them())
	if(findtext(message, "%s"))
		message = replacetext(message, "%s", user.p_s())
	return message

/datum/emote/proc/select_message_type(mob/user)
	. = message
	//if(!muzzle_ignore && user.is_muzzled() && emote_type == EMOTE_AUDIBLE)
	//	return "makes a [pick("strong ", "weak ", "")]noise."
	//if(user.mind && user.mind.miming && message_mime)
	//	. = message_mime
	//if(isalienadult(user) && message_alien)
	//	. = message_alien
	//else if(islarva(user) && message_larva)
	//	. = message_larva
	//else if(iscyborg(user) && message_robot)
	//	. = message_robot
	//else if(isAI(user) && message_AI)
	//	. = message_AI
	//else if(ismonkey(user) && message_monkey)
	//	. = message_monkey
	//else if(isanimal(user) && message_simple)
	//	. = message_simple

/datum/emote/proc/select_param(mob/user, params)
	return replacetext(message_param, "%t", params)