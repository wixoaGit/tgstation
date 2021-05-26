/obj/item/radio
	icon = 'icons/obj/radio.dmi'
	name = "station bounced radio"
	icon_state = "walkietalkie"
	item_state = "walkietalkie"
	desc = "A basic handheld radio that communicates with local telecommunication networks."
	//dog_fashion = /datum/dog_fashion/back

	flags_1 = CONDUCT_1 | HEAR_1
	slot_flags = ITEM_SLOT_BELT
	throw_speed = 3
	throw_range = 7
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=75, MAT_GLASS=25)
	obj_flags = USES_TGUI

	var/on = TRUE
	var/frequency = FREQ_COMMON
	var/canhear_range = 3
	var/emped = 0

	var/broadcasting = FALSE
	var/listening = TRUE
	var/prison_radio = FALSE
	var/unscrewed = FALSE
	var/freerange = FALSE
	var/subspace_transmission = FALSE
	var/subspace_switchable = FALSE
	var/freqlock = FALSE
	var/use_command = FALSE
	var/command = FALSE

	var/obj/item/encryptionkey/keyslot
	var/translate_binary = FALSE
	var/independent = FALSE
	var/syndie = FALSE
	var/list/channels = list()
	var/list/secure_radio_connections

	//var/const/FREQ_LISTENING = 1
	var/FREQ_LISTENING = 1//not_actual

/obj/item/radio/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] starts bouncing [src] off [user.p_their()] head! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS

/obj/item/radio/proc/set_frequency(new_frequency)
	SEND_SIGNAL(src, COMSIG_RADIO_NEW_FREQUENCY, args)
	remove_radio(src, frequency)
	frequency = add_radio(src, new_frequency)

/obj/item/radio/proc/recalculateChannels()
	channels = list()
	translate_binary = FALSE
	syndie = FALSE
	independent = FALSE

	if(keyslot)
		for(var/ch_name in keyslot.channels)
			if(!(ch_name in channels))
				channels[ch_name] = keyslot.channels[ch_name]

		if(keyslot.translate_binary)
			translate_binary = TRUE
		if(keyslot.syndie)
			syndie = TRUE
		if(keyslot.independent)
			independent = TRUE

	for(var/ch_name in channels)
		secure_radio_connections[ch_name] = add_radio(src, GLOB.radiochannels[ch_name])

/obj/item/radio/Destroy()
	remove_radio_all(src)
	//QDEL_NULL(wires)
	QDEL_NULL(keyslot)
	return ..()

/obj/item/radio/Initialize()
	//wires = new /datum/wires/radio(src)
	//if(prison_radio)
	//	wires.cut(WIRE_TX)
	//secure_radio_connections = new
	secure_radio_connections = new /list()//not_actual
	. = ..()
	frequency = sanitize_frequency(frequency, freerange)
	set_frequency(frequency)

	for(var/ch_name in channels)
		secure_radio_connections[ch_name] = add_radio(src, GLOB.radiochannels[ch_name])

/obj/item/radio/ComponentInitialize()
	. = ..()
	//AddComponent(/datum/component/empprotection, EMP_PROTECT_WIRES)

/obj/item/radio/interact(mob/user)
	if(unscrewed && !isAI(user))
		//wires.interact(user)
		add_fingerprint(user)
	else
		..()

/obj/item/radio/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
										datum/tgui/master_ui = null, datum/ui_state/state = GLOB.inventory_state)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "radio", name, 370, 220 + channels.len * 22, master_ui, state)
		ui.open()

/obj/item/radio/ui_data(mob/user)
	var/list/data = list()

	data["broadcasting"] = broadcasting
	data["listening"] = listening
	data["frequency"] = frequency
	data["minFrequency"] = freerange ? MIN_FREE_FREQ : MIN_FREQ
	data["maxFrequency"] = freerange ? MAX_FREE_FREQ : MAX_FREQ
	data["freqlock"] = freqlock
	data["channels"] = list()
	for(var/channel in channels)
		data["channels"][channel] = channels[channel] & FREQ_LISTENING
	data["command"] = command
	data["useCommand"] = use_command
	data["subspace"] = subspace_transmission
	data["subspaceSwitchable"] = subspace_switchable
	data["headset"] = istype(src, /obj/item/radio/headset)

	return data

/obj/item/radio/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	switch(action)
		if("frequency")
			if(freqlock)
				return
			var/tune = params["tune"]
			var/adjust = text2num(params["adjust"])
			if(tune == "input")
				var/min = format_frequency(freerange ? MIN_FREE_FREQ : MIN_FREQ)
				var/max = format_frequency(freerange ? MAX_FREE_FREQ : MAX_FREQ)
				tune = input("Tune frequency ([min]-[max]):", name, format_frequency(frequency)) as null|num
				if(!isnull(tune) && !..())
					if (tune < MIN_FREE_FREQ && tune <= MAX_FREE_FREQ / 10)
						tune *= 10
					. = TRUE
			else if(adjust)
				tune = frequency + adjust * 10
				. = TRUE
			else if(text2num(tune) != null)
				tune = tune * 10
				. = TRUE
			if(.)
				set_frequency(sanitize_frequency(tune, freerange))
		if("listen")
			listening = !listening
			. = TRUE
		if("broadcast")
			broadcasting = !broadcasting
			. = TRUE
		if("channel")
			var/channel = params["channel"]
			if(!(channel in channels))
				return
			if(channels[channel] & FREQ_LISTENING)
				channels[channel] &= ~FREQ_LISTENING
			else
				channels[channel] |= FREQ_LISTENING
			. = TRUE
		if("command")
			use_command = !use_command
			. = TRUE
		if("subspace")
			if(subspace_switchable)
				subspace_transmission = !subspace_transmission
				if(!subspace_transmission)
					channels = list()
				else
					recalculateChannels()
				. = TRUE

/obj/item/radio/talk_into(atom/movable/M, message, channel, list/spans, datum/language/language)
	if(!spans)
		spans = M.get_spans()
	if(!language)
		language = M.get_default_language()
	INVOKE_ASYNC(src, .proc/talk_into_impl, M, message, channel, spans.Copy(), language)
	return ITALICS | REDUCE_RANGE

/obj/item/radio/proc/talk_into_impl(atom/movable/M, message, channel, list/spans, datum/language/language)
	if(!on)
		return
	if(!M || !message)
		return
	//if(wires.is_cut(WIRE_TX))
	//	return
	if(!M.IsVocal())
		return

	if(use_command)
		spans |= SPAN_COMMAND

	var/freq
	if(channel && channels && channels.len > 0)
		if(channel == MODE_DEPARTMENT)
			channel = channels[1]
		freq = secure_radio_connections[channel]
		if (!channels[channel])
			return
	else
		freq = frequency
		channel = null

	//var/turf/position = get_turf(src)
	//for(var/obj/item/jammer/jammer in GLOB.active_jammers)
	//	var/turf/jammer_turf = get_turf(jammer)
	//	if(position.z == jammer_turf.z && (get_dist(position, jammer_turf) < jammer.range))
	//		message = Gibberish(message,100)
	//		break

	var/atom/movable/virtualspeaker/speaker = new(null, M, src)

	var/datum/signal/subspace/vocal/signal = new(src, freq, speaker, language, message, spans)

	if (independent && (freq == FREQ_CENTCOM || freq == FREQ_CTF_RED || freq == FREQ_CTF_BLUE))
		signal.data["compression"] = 0
		signal.transmission_method = TRANSMISSION_SUPERSPACE
		signal.levels = list(0)
		signal.broadcast()
		return

	signal.send_to_receivers()

	if (subspace_transmission)
		return

	addtimer(CALLBACK(src, .proc/backup_transmission, signal), 20)

/obj/item/radio/proc/backup_transmission(datum/signal/subspace/vocal/signal)
	var/turf/T = get_turf(src)
	if (signal.data["done"] && (T.z in signal.levels))
		return

	signal.data["compression"] = 0
	signal.transmission_method = TRANSMISSION_RADIO
	signal.levels = list(T.z)
	signal.broadcast()

/obj/item/radio/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	. = ..()
	if(radio_freq || !broadcasting || get_dist(src, speaker) > canhear_range)
		return

	if(message_mode == MODE_WHISPER || message_mode == MODE_WHISPER_CRIT)
		raw_message = stars(raw_message)
	else if(message_mode == MODE_L_HAND || message_mode == MODE_R_HAND)
		if (loc == speaker && ismob(speaker))
			var/mob/M = speaker
			var/idx = M.get_held_index_of_item(src)
			if (idx && (idx % 2) == (message_mode == MODE_L_HAND))
				return

	talk_into(speaker, raw_message, , spans, language=message_language)

/obj/item/radio/proc/can_receive(freq, level)
	//if (!on || !listening || wires.is_cut(WIRE_RX))
	if (!on || !listening)//not_actual
		return FALSE
	if (freq == FREQ_SYNDICATE && !syndie)
		return FALSE
	if (freq == FREQ_CENTCOM)
		return independent
	if (!(0 in level))
		var/turf/position = get_turf(src)
		if(!position || !(position.z in level))
			return FALSE

	if (freq == frequency)
		return TRUE
	for(var/ch_name in channels)
		if(channels[ch_name] & FREQ_LISTENING)
			if(GLOB.radiochannels[ch_name] == text2num(freq) || syndie)
				return TRUE
	return FALSE

/obj/item/radio/examine(mob/user)
	..()
	if (unscrewed)
		to_chat(user, "<span class='notice'>It can be attached and modified.</span>")
	else
		to_chat(user, "<span class='notice'>It cannot be modified or attached.</span>")

/obj/item/radio/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(W.tool_behaviour == TOOL_SCREWDRIVER)
		unscrewed = !unscrewed
		if(unscrewed)
			to_chat(user, "<span class='notice'>The radio can now be attached and modified!</span>")
		else
			to_chat(user, "<span class='notice'>The radio can no longer be modified or attached!</span>")
	else
		return ..()

/obj/item/radio/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	emped++
	var/curremp = emped
	if (listening && ismob(loc))
		to_chat(loc, "<span class='warning'>\The [src] overloads.</span>")
	broadcasting = FALSE
	listening = FALSE
	for (var/ch_name in channels)
		channels[ch_name] = 0
	on = FALSE
	spawn(200)
		if(emped == curremp)
			emped = 0
			if (!istype(src, /obj/item/radio/intercom))
				on = TRUE

/obj/item/radio/off
	listening = 0
	//dog_fashion = /datum/dog_fashion/back