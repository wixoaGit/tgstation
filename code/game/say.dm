GLOBAL_LIST_INIT(freqtospan, list(
	"[FREQ_SCIENCE]" = "sciradio",
	"[FREQ_MEDICAL]" = "medradio",
	"[FREQ_ENGINEERING]" = "engradio",
	"[FREQ_SUPPLY]" = "suppradio",
	"[FREQ_SERVICE]" = "servradio",
	"[FREQ_SECURITY]" = "secradio",
	"[FREQ_COMMAND]" = "comradio",
	"[FREQ_AI_PRIVATE]" = "aiprivradio",
	"[FREQ_SYNDICATE]" = "syndradio",
	"[FREQ_CENTCOM]" = "centcomradio",
	"[FREQ_CTF_RED]" = "redteamradio",
	"[FREQ_CTF_BLUE]" = "blueteamradio"
	))

/atom/movable/proc/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if(!can_speak())
		return
	if(message == "" || !message)
		return
	spans |= get_spans()
	if(!language)
		language = get_default_language()
	send_speech(message, 7, src, , spans, message_language=language)

/atom/movable/proc/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	SEND_SIGNAL(src, COMSIG_MOVABLE_HEAR, message, speaker, message_language, raw_message, radio_freq, spans, message_mode)

/atom/movable/proc/can_speak()
	return 1

/atom/movable/proc/send_speech(message, range = 7, obj/source = src, bubble_type, list/spans, datum/language/message_language = null, message_mode)
	var/rendered = compose_message(src, message_language, message, , spans, message_mode)
	for(var/_AM in get_hearers_in_view(range, source))
		var/atom/movable/AM = _AM
		AM.Hear(rendered, src, message_language, message, , spans, message_mode)

/atom/movable/proc/get_spans()
	return list()

/atom/movable/proc/compose_message(atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, message_mode, face_name = FALSE)
	var/spanpart1 = "<span class='[radio_freq ? get_radio_span(radio_freq) : "game say"]'>"
	var/spanpart2 = "<span class='name'>"
	var/freqpart = radio_freq ? "\[[get_radio_name(radio_freq)]\] " : ""
	var/namepart = "[speaker.GetVoice()][speaker.get_alt_name()]"
	if(face_name && ishuman(speaker))
		var/mob/living/carbon/human/H = speaker
		namepart = "[H.get_face_name()]"
	var/endspanpart = "</span>"

	var/messagepart = " <span class='message'>[lang_treat(speaker, message_language, raw_message, spans, message_mode)]</span></span>"

	var/languageicon = ""
	//var/datum/language/D = GLOB.language_datum_instances[message_language]
	//if(istype(D) && D.display_icon(src))
	//	languageicon = "[D.get_icon()] "

	return "[spanpart1][spanpart2][freqpart][languageicon][compose_track_href(speaker, namepart)][namepart][compose_job(speaker, message_language, raw_message, radio_freq)][endspanpart][messagepart]"

/atom/movable/proc/compose_track_href(atom/movable/speaker, message_langs, raw_message, radio_freq)
	return ""

/atom/movable/proc/compose_job(atom/movable/speaker, message_langs, raw_message, radio_freq)
	return ""

/atom/movable/proc/say_mod(input, message_mode)
	var/ending = copytext(input, length(input))
	if(copytext(input, length(input) - 1) == "!!")
		return verb_yell
	else if(ending == "?")
		return verb_ask
	else if(ending == "!")
		return verb_exclaim
	else
		return verb_say

/atom/movable/proc/say_quote(input, list/spans=list(), message_mode)
	if(!input)
		input = "..."

	if(copytext(input, length(input) - 1) == "!!")
		spans |= SPAN_YELL

	var/spanned = attach_spans(input, spans)
	return "[say_mod(input, message_mode)], \"[spanned]\""
/atom/movable/proc/lang_treat(atom/movable/speaker, datum/language/language, raw_message, list/spans, message_mode)
	//if(has_language(language))
	if (TRUE)//not_actual
		var/atom/movable/AM = speaker.GetSource()
		if(AM)
			return AM.say_quote(raw_message, spans, message_mode)
		else
			return speaker.say_quote(raw_message, spans, message_mode)
	//else if(language)
	//	var/atom/movable/AM = speaker.GetSource()
	//	var/datum/language/D = GLOB.language_datum_instances[language]
	//	raw_message = D.scramble(raw_message)
	//	if(AM)
	//		return AM.say_quote(raw_message, spans, message_mode)
	//	else
	//		return speaker.say_quote(raw_message, spans, message_mode)
	else
		return "makes a strange sound."

/proc/get_radio_span(freq)
	var/returntext = GLOB.freqtospan["[freq]"]
	if(returntext)
		return returntext
	return "radio"

/proc/get_radio_name(freq)
	var/returntext = GLOB.reverseradiochannels["[freq]"]
	if(returntext)
		return returntext
	return "[copytext("[freq]", 1, 4)].[copytext("[freq]", 4, 5)]"

/proc/attach_spans(input, list/spans)
	return "[message_spans_start(spans)][input]</span>"

/proc/message_spans_start(list/spans)
	var/output = "<span class='"
	for(var/S in spans)
		output = "[output][S] "
	output = "[output]'>"
	return output

/atom/movable/proc/GetVoice()
	return "[src]"

/atom/movable/proc/IsVocal()
	return 1

/atom/movable/proc/get_alt_name()

/atom/movable/proc/GetJob()

/atom/movable/proc/GetSource()

/atom/movable/proc/GetRadio()

/atom/movable/virtualspeaker
	var/job
	var/atom/movable/source
	var/obj/item/radio/radio

INITIALIZE_IMMEDIATE(/atom/movable/virtualspeaker)
/atom/movable/virtualspeaker/Initialize(mapload, atom/movable/M, radio)
	. = ..()
	radio = radio
	source = M
	if (istype(M))
		name = M.GetVoice()
		verb_say = M.verb_say
		verb_ask = M.verb_ask
		verb_exclaim = M.verb_exclaim
		verb_yell = M.verb_yell

	if(ishuman(M))
		//var/datum/data/record/findjob = find_record("name", name, GLOB.data_core.general)
		//if(findjob)
		if(FALSE)//not_actual
			//job = findjob.fields["rank"]
		else
			job = "Unknown"
	else if(iscarbon(M))
		job = "No ID"
	else if(isAI(M))
		job = "AI"
	else if(iscyborg(M))
		//var/mob/living/silicon/robot/B = M
		//job = "[B.designation] Cyborg"
	//else if(istype(M, /mob/living/silicon/pai))
	//	job = "Personal AI"
	else if(isobj(M))
		job = "Machine"
	else
		job = "Unknown"

/atom/movable/virtualspeaker/GetJob()
	return job

/atom/movable/virtualspeaker/GetSource()
	return source

/atom/movable/virtualspeaker/GetRadio()
	return radio