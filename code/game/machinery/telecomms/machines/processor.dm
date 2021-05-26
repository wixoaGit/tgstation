/obj/machinery/telecomms/processor
	name = "processor unit"
	icon_state = "processor"
	desc = "This machine is used to process large quantities of information."
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 30
	circuit = /obj/item/circuitboard/machine/telecomms/processor
	var/process_mode = 1

/obj/machinery/telecomms/processor/receive_information(datum/signal/subspace/signal, obj/machinery/telecomms/machine_from)
	if(!is_freq_listening(signal))
		return

	if (!process_mode)
		signal.data["compression"] = 100
	else if (signal.data["compression"])
		signal.data["compression"] = 0

	if(istype(machine_from, /obj/machinery/telecomms/bus))
		relay_direct_information(signal, machine_from)
	else
		signal.data["slow"] += rand(5, 10)
		relay_information(signal, signal.server_type)

/obj/machinery/telecomms/processor/preset_one
	id = "Processor 1"
	network = "tcommsat"
	autolinkers = list("processor1")

/obj/machinery/telecomms/processor/preset_two
	id = "Processor 2"
	network = "tcommsat"
	autolinkers = list("processor2")

/obj/machinery/telecomms/processor/preset_three
	id = "Processor 3"
	network = "tcommsat"
	autolinkers = list("processor3")

/obj/machinery/telecomms/processor/preset_four
	id = "Processor 4"
	network = "tcommsat"
	autolinkers = list("processor4")

/obj/machinery/telecomms/processor/preset_one/birdstation
	name = "Processor"
