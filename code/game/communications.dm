GLOBAL_LIST_EMPTY(all_radios)
/proc/add_radio(obj/item/radio, freq)
	if(!freq || !radio)
		return
	if(!GLOB.all_radios["[freq]"])
		GLOB.all_radios["[freq]"] = list(radio)
		return freq

	GLOB.all_radios["[freq]"] |= radio
	return freq

/proc/remove_radio(obj/item/radio, freq)
	if(!freq || !radio)
		return
	if(!GLOB.all_radios["[freq]"])
		return

	GLOB.all_radios["[freq]"] -= radio

/proc/remove_radio_all(obj/item/radio)
	for(var/freq in GLOB.all_radios)
		GLOB.all_radios["[freq]"] -= radio

GLOBAL_LIST_INIT(radiochannels, list(
	RADIO_CHANNEL_COMMON = FREQ_COMMON,
	RADIO_CHANNEL_SCIENCE = FREQ_SCIENCE,
	RADIO_CHANNEL_COMMAND = FREQ_COMMAND,
	RADIO_CHANNEL_MEDICAL = FREQ_MEDICAL,
	RADIO_CHANNEL_ENGINEERING = FREQ_ENGINEERING,
	RADIO_CHANNEL_SECURITY = FREQ_SECURITY,
	RADIO_CHANNEL_CENTCOM = FREQ_CENTCOM,
	RADIO_CHANNEL_SYNDICATE = FREQ_SYNDICATE,
	RADIO_CHANNEL_SUPPLY = FREQ_SUPPLY,
	RADIO_CHANNEL_SERVICE = FREQ_SERVICE,
	RADIO_CHANNEL_AI_PRIVATE = FREQ_AI_PRIVATE,
	RADIO_CHANNEL_CTF_RED = FREQ_CTF_RED,
	RADIO_CHANNEL_CTF_BLUE = FREQ_CTF_BLUE
))

GLOBAL_LIST_INIT(reverseradiochannels, list(
	"[FREQ_COMMON]" = RADIO_CHANNEL_COMMON,
	"[FREQ_SCIENCE]" = RADIO_CHANNEL_SCIENCE,
	"[FREQ_COMMAND]" = RADIO_CHANNEL_COMMAND,
	"[FREQ_MEDICAL]" = RADIO_CHANNEL_MEDICAL,
	"[FREQ_ENGINEERING]" = RADIO_CHANNEL_ENGINEERING,
	"[FREQ_SECURITY]" = RADIO_CHANNEL_SECURITY,
	"[FREQ_CENTCOM]" = RADIO_CHANNEL_CENTCOM,
	"[FREQ_SYNDICATE]" = RADIO_CHANNEL_SYNDICATE,
	"[FREQ_SUPPLY]" = RADIO_CHANNEL_SUPPLY,
	"[FREQ_SERVICE]" = RADIO_CHANNEL_SERVICE,
	"[FREQ_AI_PRIVATE]" = RADIO_CHANNEL_AI_PRIVATE,
	"[FREQ_CTF_RED]" = RADIO_CHANNEL_CTF_RED,
	"[FREQ_CTF_BLUE]" = RADIO_CHANNEL_CTF_BLUE
))

/datum/radio_frequency
	//var/frequency as num
	var/frequency//not_actual
	//var/list/list/obj/devices = list()
	var/list/devices = list()//not_actual

/datum/radio_frequency/New(freq)
	frequency = freq

/datum/radio_frequency/proc/post_signal(obj/source as obj|null, datum/signal/signal, filter = null as text|null, range = null as num|null)
	signal.source = source
	signal.frequency = frequency

	var/list/filter_list

	if(filter)
		filter_list = list(filter,"_default")
	else
		filter_list = devices

	var/turf/start_point
	if(range)
		start_point = get_turf(source)
		if(!start_point)
			return 0

	for(var/current_filter in filter_list)
		for(var/obj/device in devices[current_filter])
			if(device == source)
				continue
			if(range)
				var/turf/end_point = get_turf(device)
				if(!end_point)
					continue
				if(start_point.z != end_point.z || (range > 0 && get_dist(start_point, end_point) > range))
					continue
			device.receive_signal(signal)

/datum/radio_frequency/proc/add_listener(obj/device, filter as text|null)
	if (!filter)
		filter = "_default"

	var/list/devices_line = devices[filter]
	if(!devices_line)
		devices[filter] = devices_line = list()
	devices_line += device


/datum/radio_frequency/proc/remove_listener(obj/device)
	for(var/devices_filter in devices)
		var/list/devices_line = devices[devices_filter]
		if(!devices_line)
			devices -= devices_filter
		devices_line -= device
		if(!devices_line.len)
			devices -= devices_filter

/obj/proc/receive_signal(datum/signal/signal)
	return

/datum/signal
	var/obj/source
	var/frequency = 0
	var/transmission_method
	var/list/data

/datum/signal/New(data, transmission_method = TRANSMISSION_RADIO)
	src.data = data || list()
	src.transmission_method = transmission_method