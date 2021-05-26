GLOBAL_LIST_EMPTY(recentmessages)
GLOBAL_VAR_INIT(message_delay, 0)

/obj/machinery/telecomms/broadcaster
	name = "subspace broadcaster"
	icon_state = "broadcaster"
	desc = "A dish-shaped machine used to broadcast processed subspace signals."
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 25
	circuit = /obj/item/circuitboard/machine/telecomms/broadcaster

/obj/machinery/telecomms/broadcaster/receive_information(datum/signal/subspace/signal, obj/machinery/telecomms/machine_from)
	if(!istype(signal))
		return
	if(signal.data["reject"])
		return
	if(!signal.data["message"])
		return

	signal.mark_done()
	var/datum/signal/subspace/original = signal.original
	if(original && ("compression" in signal.data))
		original.data["compression"] = signal.data["compression"]

	var/turf/T = get_turf(src)
	if (T)
		signal.levels |= T.z

	var/signal_message = "[signal.frequency]:[signal.data["message"]]:[signal.data["name"]]"
	if(signal_message in GLOB.recentmessages)
		return
	GLOB.recentmessages.Add(signal_message)

	if(signal.data["slow"] > 0)
		sleep(signal.data["slow"])

	signal.broadcast()

	//if(!GLOB.message_delay)
	//	GLOB.message_delay = 1
	//	spawn(10)
	//		GLOB.message_delay = 0
	//		GLOB.recentmessages = list()

	//flick("broadcaster_send", src)

/obj/machinery/telecomms/broadcaster/Destroy()
	if(GLOB.message_delay)
		GLOB.message_delay = 0
	return ..()

/obj/machinery/telecomms/broadcaster/preset_left
	id = "Broadcaster A"
	network = "tcommsat"
	autolinkers = list("broadcasterA")

/obj/machinery/telecomms/broadcaster/preset_right
	id = "Broadcaster B"
	network = "tcommsat"
	autolinkers = list("broadcasterB")

/obj/machinery/telecomms/broadcaster/preset_left/birdstation
	name = "Broadcaster"
