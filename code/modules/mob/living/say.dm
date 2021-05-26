GLOBAL_LIST_INIT(department_radio_prefixes, list(":", "."))

/*GLOBAL_LIST_INIT(department_radio_keys, list(
	MODE_KEY_R_HAND = MODE_R_HAND,
	MODE_KEY_L_HAND = MODE_L_HAND,
	MODE_KEY_INTERCOM = MODE_INTERCOM,

	MODE_KEY_DEPARTMENT = MODE_DEPARTMENT,
	RADIO_KEY_COMMAND = RADIO_CHANNEL_COMMAND,
	RADIO_KEY_SCIENCE = RADIO_CHANNEL_SCIENCE,
	RADIO_KEY_MEDICAL = RADIO_CHANNEL_MEDICAL,
	RADIO_KEY_ENGINEERING = RADIO_CHANNEL_ENGINEERING,
	RADIO_KEY_SECURITY = RADIO_CHANNEL_SECURITY,
	RADIO_KEY_SUPPLY = RADIO_CHANNEL_SUPPLY,
	RADIO_KEY_SERVICE = RADIO_CHANNEL_SERVICE,

	RADIO_KEY_SYNDICATE = RADIO_CHANNEL_SYNDICATE,
	RADIO_KEY_CENTCOM = RADIO_CHANNEL_CENTCOM,

	MODE_KEY_ADMIN = MODE_ADMIN,
	MODE_KEY_DEADMIN = MODE_DEADMIN,

	RADIO_KEY_AI_PRIVATE = RADIO_CHANNEL_AI_PRIVATE,
	MODE_KEY_VOCALCORDS = MODE_VOCALCORDS,

	"ê" = MODE_R_HAND,
	"ä" = MODE_L_HAND,
	"ø" = MODE_INTERCOM,

	"ð" = MODE_DEPARTMENT,
	"ñ" = RADIO_CHANNEL_COMMAND,
	"ò" = RADIO_CHANNEL_SCIENCE,
	"ü" = RADIO_CHANNEL_MEDICAL,
	"ó" = RADIO_CHANNEL_ENGINEERING,
	"û" = RADIO_CHANNEL_SECURITY,
	"ã" = RADIO_CHANNEL_SUPPLY,
	"ì" = RADIO_CHANNEL_SERVICE,

	"å" = RADIO_CHANNEL_SYNDICATE,
	"í" = RADIO_CHANNEL_CENTCOM,

	"ç" = MODE_ADMIN,
	"â" = MODE_ADMIN,

	"ù" = RADIO_CHANNEL_AI_PRIVATE,
	"÷" = MODE_VOCALCORDS
))*/
//not_actual
GLOBAL_LIST_INIT(department_radio_keys, list(
	MODE_KEY_R_HAND = MODE_R_HAND,
	MODE_KEY_L_HAND = MODE_L_HAND,
	MODE_KEY_INTERCOM = MODE_INTERCOM,

	MODE_KEY_DEPARTMENT = MODE_DEPARTMENT,
	RADIO_KEY_COMMAND = RADIO_CHANNEL_COMMAND,
	RADIO_KEY_SCIENCE = RADIO_CHANNEL_SCIENCE,
	RADIO_KEY_MEDICAL = RADIO_CHANNEL_MEDICAL,
	RADIO_KEY_ENGINEERING = RADIO_CHANNEL_ENGINEERING,
	RADIO_KEY_SECURITY = RADIO_CHANNEL_SECURITY,
	RADIO_KEY_SUPPLY = RADIO_CHANNEL_SUPPLY,
	RADIO_KEY_SERVICE = RADIO_CHANNEL_SERVICE,

	RADIO_KEY_SYNDICATE = RADIO_CHANNEL_SYNDICATE,
	RADIO_KEY_CENTCOM = RADIO_CHANNEL_CENTCOM,

	MODE_KEY_ADMIN = MODE_ADMIN,
	MODE_KEY_DEADMIN = MODE_DEADMIN,

	RADIO_KEY_AI_PRIVATE = RADIO_CHANNEL_AI_PRIVATE,
	MODE_KEY_VOCALCORDS = MODE_VOCALCORDS
))

/mob/living/say(message, bubble_type,var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	//var/static/list/crit_allowed_modes = list(MODE_WHISPER = TRUE, MODE_CHANGELING = TRUE, MODE_ALIEN = TRUE)
	//var/static/list/unconscious_allowed_modes = list(MODE_CHANGELING = TRUE, MODE_ALIEN = TRUE)
	var/list/crit_allowed_modes = list(MODE_WHISPER = TRUE, MODE_CHANGELING = TRUE, MODE_ALIEN = TRUE)//not_actual
	var/list/unconscious_allowed_modes = list(MODE_CHANGELING = TRUE, MODE_ALIEN = TRUE)//not_actual
	var/talk_key = get_key(message)

	//var/static/list/one_character_prefix = list(MODE_HEADSET = TRUE, MODE_ROBOT = TRUE, MODE_WHISPER = TRUE)
	var/list/one_character_prefix = list(MODE_HEADSET = TRUE, MODE_ROBOT = TRUE, MODE_WHISPER = TRUE)//not_actual

	if(sanitize)
		message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
	if(!message || message == "")
		return

	var/datum/saymode/saymode = SSradio.saymodes[talk_key]
	var/message_mode = get_message_mode(message)
	var/original_message = message
	var/in_critical = InCritical()

	if(one_character_prefix[message_mode])
		message = copytext(message, 2)
	else if(message_mode || saymode)
		message = copytext(message, 3)
	if(findtext(message, " ", 1, 2))
		message = copytext(message, 2)

	//if(message_mode == MODE_ADMIN)
	//	if(client)
	//		client.cmd_admin_say(message)
	//	return

	//if(message_mode == MODE_DEADMIN)
	//	if(client)
	//		client.dsay(message)
	//	return

	if(stat == DEAD)
		//say_dead(original_message)
		return

	if(check_emote(original_message) || !can_speak_basic(original_message, ignore_spam))
		return

	if(in_critical)
		if(!(crit_allowed_modes[message_mode]))
			return
	else if(stat == UNCONSCIOUS)
		if(!(unconscious_allowed_modes[message_mode]))
			return

	//var/datum/language/message_language = get_message_language(message)
	//if(message_language)
	//	if(can_speak_in_language(message_language))
	//		language = message_language
	//	message = copytext(message, 3)

	//	if(findtext(message, " ", 1, 2))
	//		message = copytext(message, 2)

	if(!language)
		language = get_default_language()

	if(saymode && !saymode.handle_message(src, message, language))
		return

	//if(!can_speak_vocal(message))
	//	to_chat(src, "<span class='warning'>You find yourself unable to speak!</span>")
	//	return

	var/message_range = 7

	var/succumbed = FALSE

	var/fullcrit = InFullCritical()
	if((InCritical() && !fullcrit) || message_mode == MODE_WHISPER)
		message_range = 1
		message_mode = MODE_WHISPER
		//src.log_talk(message, LOG_WHISPER)
		if(fullcrit)
			var/health_diff = round(-HEALTH_THRESHOLD_DEAD + health)
			var/message_len = length(message)
			message = copytext(message, 1, health_diff) + "[message_len > health_diff ? "-.." : "..."]"
			//message = Ellipsis(message, 10, 1)
			//last_words = message
			message_mode = MODE_WHISPER_CRIT
			succumbed = TRUE
	//else
	//	src.log_talk(message, LOG_SAY, forced_by=forced)

	message = treat_message(message)
	if(!message)
		return

	spans |= get_spans()

	//if(language)
	//	var/datum/language/L = GLOB.language_datum_instances[language]
	//	spans |= L.spans

	var/radio_return = radio(message, message_mode, spans, language)
	if(radio_return & ITALICS)
		spans |= SPAN_ITALICS
	if(radio_return & REDUCE_RANGE)
		message_range = 1
	if(radio_return & NOPASS)
		return 1

	//var/turf/T = get_turf(src)
	//var/datum/gas_mixture/environment = T.return_air()
	//var/pressure = (environment)? environment.return_pressure() : 0
	//if(pressure < SOUND_MINIMUM_PRESSURE)
	//	message_range = 1

	//if(pressure < ONE_ATMOSPHERE*0.4)
	//	spans |= SPAN_ITALICS

	send_speech(message, message_range, src, bubble_type, spans, language, message_mode)

	//if(succumbed)
	//	succumb(1)
	//	to_chat(src, compose_message(src, language, message, , spans, message_mode))

	return 1

/mob/living/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, message_mode)
	. = ..()
	if(!client)
		return
	var/deaf_message
	var/deaf_type
	if(speaker != src)
		if(!radio_freq)
			deaf_message = "<span class='name'>[speaker]</span> [speaker.verb_say] something but you cannot hear [speaker.p_them()]."
			deaf_type = 1
	else
		deaf_message = "<span class='notice'>You can't hear yourself!</span>"
		deaf_type = 2

	message = compose_message(speaker, message_language, raw_message, radio_freq, spans, message_mode)
	message = hear_intercept(message, speaker, message_language, raw_message, radio_freq, spans, message_mode)
	show_message(message, 2, deaf_message, deaf_type)
	return message

/mob/living/proc/hear_intercept(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, message_mode)
	return message

/mob/living/proc/can_speak_basic(message, ignore_spam = FALSE)
	//if(client)
	//	if(client.prefs.muted & MUTE_IC)
	//		to_chat(src, "<span class='danger'>You cannot speak in IC (muted).</span>")
	//		return 0
	//	if(!ignore_spam && client.handle_spam_prevention(message,MUTE_IC))
	//		return 0

	return 1

/mob/living/proc/get_key(message)
	var/key = copytext(message, 1, 2)
	if(key in GLOB.department_radio_prefixes)
		return lowertext(copytext(message, 2, 3))

/mob/living/proc/treat_message(message)
	//if(has_trait(TRAIT_UNINTELLIGIBLE_SPEECH))
	//	message = unintelligize(message)

	//if(derpspeech)
	//	message = derpspeech(message, stuttering)

	//if(stuttering)
	//	message = stutter(message)

	//if(slurring)
	//	message = slur(message)

	//if(cultslurring)
	//	message = cultslur(message)

	message = capitalize(message)

	return message

/mob/living/proc/radio(message, message_mode, list/spans, language)
	//var/obj/item/implant/radio/imp = locate() in src
	//if(imp && imp.radio.on)
	//	if(message_mode == MODE_HEADSET)
	//		imp.radio.talk_into(src, message, , spans, language)
	//		return ITALICS | REDUCE_RANGE
	//	if(message_mode == MODE_DEPARTMENT || message_mode in GLOB.radiochannels)
	//		imp.radio.talk_into(src, message, message_mode, spans, language)
	//		return ITALICS | REDUCE_RANGE

	switch(message_mode)
		if(MODE_WHISPER)
			return ITALICS
		if(MODE_R_HAND)
			for(var/obj/item/r_hand in get_held_items_for_side("r", all = TRUE))
				if (r_hand)
					return r_hand.talk_into(src, message, , spans, language)
				return ITALICS | REDUCE_RANGE
		if(MODE_L_HAND)
			for(var/obj/item/l_hand in get_held_items_for_side("l", all = TRUE))
				if (l_hand)
					return l_hand.talk_into(src, message, , spans, language)
				return ITALICS | REDUCE_RANGE

		//if(MODE_INTERCOM)
		//	for (var/obj/item/radio/intercom/I in view(1, null))
		//		I.talk_into(src, message, , spans, language)
		//	return ITALICS | REDUCE_RANGE

		if(MODE_BINARY)
			return ITALICS | REDUCE_RANGE

	return 0

/mob/living/say_mod(input, message_mode)
	if(message_mode == MODE_WHISPER)
		. = verb_whisper
	else if(message_mode == MODE_WHISPER_CRIT)
		. = "[verb_whisper] in [p_their()] last breath"
	else if(stuttering)
		. = "stammers"
	else if(derpspeech)
		. = "gibbers"
	else
		. = ..()