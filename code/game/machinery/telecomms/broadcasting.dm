/datum/signal/subspace
	transmission_method = TRANSMISSION_SUBSPACE
	var/server_type = /obj/machinery/telecomms/server
	var/datum/signal/subspace/original
	var/list/levels

/datum/signal/subspace/New(data)
	src.data = data || list()

/datum/signal/subspace/proc/copy()
	var/datum/signal/subspace/copy = new
	copy.original = src
	copy.source = source
	copy.levels = levels
	copy.frequency = frequency
	copy.server_type = server_type
	copy.transmission_method = transmission_method
	copy.data = data.Copy()
	return copy

/datum/signal/subspace/proc/mark_done()
	var/datum/signal/subspace/current = src
	while (current)
		current.data["done"] = TRUE
		current = current.original

/datum/signal/subspace/proc/send_to_receivers()
	for(var/obj/machinery/telecomms/receiver/R in GLOB.telecomms_list)
		R.receive_signal(src)
	for(var/obj/machinery/telecomms/allinone/R in GLOB.telecomms_list)
		R.receive_signal(src)

/datum/signal/subspace/proc/broadcast()
	set waitfor = FALSE

/datum/signal/subspace/vocal
	var/atom/movable/virtualspeaker/virt
	var/datum/language/language

/datum/signal/subspace/vocal/New(
	obj/source,
	frequency,
	atom/movable/virtualspeaker/speaker,
	datum/language/language,
	message,
	spans
)
	src.source = source
	src.frequency = frequency
	src.language = language
	virt = speaker
	var/datum/language/lang_instance = GLOB.language_datum_instances[language]
	data = list(
		"name" = speaker.name,
		"job" = speaker.job,
		"message" = message,
		"compression" = rand(35, 65),
		"language" = lang_instance.name,
		"spans" = spans
	)
	var/turf/T = get_turf(source)
	levels = list(T.z)

/datum/signal/subspace/vocal/copy()
	var/datum/signal/subspace/vocal/copy = new(source, frequency, virt, language)
	copy.original = src
	copy.data = data.Copy()
	copy.levels = levels
	return copy

/datum/signal/subspace/vocal/broadcast()
	set waitfor = FALSE

	var/message = copytext(data["message"], 1, MAX_BROADCAST_LEN)
	if(!message)
		return
	var/compression = data["compression"]
	//if(compression > 0)
	//	message = Gibberish(message, compression + 40)

	var/list/radios = list()
	switch (transmission_method)
		if (TRANSMISSION_SUBSPACE)
			for(var/obj/item/radio/R in GLOB.all_radios["[frequency]"])
				if(R.can_receive(frequency, levels))
					radios += R

			if (num2text(frequency) in GLOB.reverseradiochannels)
				for(var/obj/item/radio/R in GLOB.all_radios["[FREQ_SYNDICATE]"])
					if(R.can_receive(FREQ_SYNDICATE, list(R.z)))
						radios |= R

		if (TRANSMISSION_RADIO)
			for(var/obj/item/radio/R in GLOB.all_radios["[frequency]"])
				if(!R.subspace_transmission && R.can_receive(frequency, levels))
					radios += R

		if (TRANSMISSION_SUPERSPACE)
			for(var/obj/item/radio/R in GLOB.all_radios["[frequency]"])
				if(R.independent && R.can_receive(frequency, levels))
					radios += R

	var/list/receive = get_mobs_in_radio_ranges(radios)

	//for(var/mob/R in receive)
	//	if (R.client && R.client.holder && !(R.client.prefs.chat_toggles & CHAT_RADIO))
	//		receive -= R

	//for(var/mob/dead/observer/M in GLOB.player_list)
	//	if(M.client && (M.client.prefs.chat_toggles & CHAT_GHOSTRADIO))
	//		receive |= M

	var/spans = data["spans"]
	var/rendered = virt.compose_message(virt, language, message, frequency, spans)
	for(var/atom/movable/hearer in receive)
		hearer.Hear(rendered, virt, language, message, frequency, spans)

	//if(length(receive))
	//	SSblackbox.LogBroadcast(frequency)

	var/spans_part = ""
	if(length(spans))
		spans_part = "(spans:"
		for(var/S in spans)
			spans_part = "[spans_part] [S]"
		spans_part = "[spans_part] ) "

	var/lang_name = data["language"]
	var/log_text = "\[[get_radio_name(frequency)]\] [spans_part]\"[message]\" (language: [lang_name])"

	var/mob/source_mob = virt.source
	if(istype(source_mob))
		//source_mob.log_message(log_text, LOG_TELECOMMS)
	else
		log_telecomms("[virt.source] [log_text] [loc_name(get_turf(virt.source))]")

	QDEL_IN(virt, 50)