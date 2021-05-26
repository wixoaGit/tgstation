/obj/machinery/telecomms/hub
	name = "telecommunication hub"
	icon_state = "hub"
	desc = "A mighty piece of hardware used to send/receive massive amounts of data."
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 80
	long_range_link = TRUE
	netspeed = 40
	circuit = /obj/item/circuitboard/machine/telecomms/hub

/obj/machinery/telecomms/hub/receive_information(datum/signal/signal, obj/machinery/telecomms/machine_from)
	if(!is_freq_listening(signal))
		return

	if(istype(machine_from, /obj/machinery/telecomms/receiver))
		relay_information(signal, /obj/machinery/telecomms/bus, TRUE)
	else
		relay_information(signal, /obj/machinery/telecomms/relay)
		relay_information(signal, /obj/machinery/telecomms/broadcaster)

/obj/machinery/telecomms/hub/preset
	id = "Hub"
	network = "tcommsat"
	autolinkers = list("hub", "relay", "s_relay", "m_relay", "r_relay", "h_relay", "science", "medical",
	"supply", "service", "common", "command", "engineering", "security",
	"receiverA", "receiverB", "broadcasterA", "broadcasterB")

