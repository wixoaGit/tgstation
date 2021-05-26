/obj/machinery/telecomms/allinone
	name = "telecommunications mainframe"
	icon_state = "comm_server"
	desc = "A compact machine used for portable subspace telecommunications processing."
	density = TRUE
	use_power = NO_POWER_USE
	idle_power_usage = 0
	var/intercept = FALSE

/obj/machinery/telecomms/allinone/indestructable
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	flags_1 = NODECONSTRUCT_1

/obj/machinery/telecomms/allinone/Initialize()
	. = ..()
	if (intercept)
		freq_listening = list(FREQ_SYNDICATE)

/obj/machinery/telecomms/allinone/receive_signal(datum/signal/subspace/signal)
	if(!istype(signal) || signal.transmission_method != TRANSMISSION_SUBSPACE)
		return
	if(!on || !is_freq_listening(signal))
		return
	if (!intercept && !(z in signal.levels) && !(0 in signal.levels))
		return

	if (intercept)
		signal.levels += 0

	signal.data["compression"] = 0
	signal.mark_done()
	if(signal.data["slow"] > 0)
		sleep(signal.data["slow"])
	signal.broadcast()

/obj/machinery/telecomms/allinone/attackby(obj/item/P, mob/user, params)
	if(P.tool_behaviour == TOOL_MULTITOOL)
		return attack_hand(user)