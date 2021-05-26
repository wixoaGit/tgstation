GLOBAL_LIST_EMPTY(telecomms_list)

/obj/machinery/telecomms
	icon = 'icons/obj/machines/telecomms.dmi'
	critical_machine = TRUE
	var/list/links = list()
	var/traffic = 0
	var/netspeed = 5
	var/list/autolinkers = list()
	var/id = "NULL"
	var/network = "NULL"

	var/list/freq_listening = list()

	var/on = TRUE
	var/toggled = TRUE
	var/long_range_link = FALSE
	var/hide = FALSE

/obj/machinery/telecomms/proc/relay_information(datum/signal/subspace/signal, filter, copysig, amount = 20)
	if(!on)
		return
	var/send_count = 0

	var/netlag = round(traffic / 50)
	if(netlag > signal.data["slow"])
		signal.data["slow"] = netlag

	for(var/obj/machinery/telecomms/machine in links)
		if(filter && !istype( machine, filter ))
			continue
		if(!machine.on)
			continue
		if(amount && send_count >= amount)
			break
		if(z != machine.loc.z && !long_range_link && !machine.long_range_link)
			continue

		send_count++
		if(machine.is_freq_listening(signal))
			machine.traffic++

		if(copysig)
			machine.receive_information(signal.copy(), src)
		else
			machine.receive_information(signal, src)

	if(send_count > 0 && is_freq_listening(signal))
		traffic++

	return send_count

/obj/machinery/telecomms/proc/relay_direct_information(datum/signal/signal, obj/machinery/telecomms/machine)
	machine.receive_information(signal, src)

/obj/machinery/telecomms/proc/receive_information(datum/signal/signal, obj/machinery/telecomms/machine_from)

/obj/machinery/telecomms/proc/is_freq_listening(datum/signal/signal)
	return signal && (!freq_listening.len || (signal.frequency in freq_listening))

/obj/machinery/telecomms/Initialize(mapload)
	. = ..()
	GLOB.telecomms_list += src
	if(mapload && autolinkers.len)
		return INITIALIZE_HINT_LATELOAD

/obj/machinery/telecomms/LateInitialize()
	..()
	for(var/obj/machinery/telecomms/T in (long_range_link ? GLOB.telecomms_list : urange(20, src, 1)))
		add_link(T)

/obj/machinery/telecomms/Destroy()
	GLOB.telecomms_list -= src
	for(var/obj/machinery/telecomms/comm in GLOB.telecomms_list)
		comm.links -= src
	links = list()
	return ..()

/obj/machinery/telecomms/proc/add_link(obj/machinery/telecomms/T)
	var/turf/position = get_turf(src)
	var/turf/T_position = get_turf(T)
	if((position.z == T_position.z) || (long_range_link && T.long_range_link))
		if(src != T)
			for(var/x in autolinkers)
				if(x in T.autolinkers)
					links |= T

/obj/machinery/telecomms/update_icon()
	if(on)
		if(panel_open)
			icon_state = "[initial(icon_state)]_o"
		else
			icon_state = initial(icon_state)
	else
		if(panel_open)
			icon_state = "[initial(icon_state)]_o_off"
		else
			icon_state = "[initial(icon_state)]_off"

/obj/machinery/telecomms/proc/update_power()

	if(toggled)
		if(stat & (BROKEN|NOPOWER|EMPED))
			on = FALSE
		else
			on = TRUE
	else
		on = FALSE

/obj/machinery/telecomms/process()
	update_power()

	update_icon()

	if(traffic > 0)
		traffic -= netspeed

/obj/machinery/telecomms/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(prob(100/severity))
		if(!(stat & EMPED))
			stat |= EMPED
			var/duration = (300 * 10)/severity
			spawn(rand(duration - 20, duration + 20))
				stat &= ~EMPED