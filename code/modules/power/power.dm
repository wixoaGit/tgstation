/obj/machinery/power
	name = null
	icon = 'icons/obj/power.dmi'
	anchored = TRUE
	obj_flags = CAN_BE_HIT | ON_BLUEPRINTS
	var/datum/powernet/powernet = null
	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0

/obj/machinery/power/Destroy()
	disconnect_from_network()
	return ..()

/obj/machinery/power/proc/add_avail(amount)
	if(powernet)
		powernet.newavail += amount
		return TRUE
	else
		return FALSE

/obj/machinery/power/proc/add_load(amount)
	if(powernet)
		powernet.load += amount

/obj/machinery/power/proc/surplus()
	if(powernet)
		return CLAMP(powernet.avail-powernet.load, 0, powernet.avail)
	else
		return 0

/obj/machinery/power/proc/avail()
	if(powernet)
		return powernet.avail
	else
		return 0

/obj/machinery/power/proc/disconnect_terminal()
	return

/obj/machinery/proc/powered(var/chan = -1)
	if(!loc)
		return FALSE
	if(!use_power)
		return TRUE

	var/area/A = get_area(src)
	if(!A)
		return FALSE
	if(chan == -1)
		chan = power_channel
	return A.powered(chan)

/obj/machinery/proc/use_power(amount, chan = -1)
	var/area/A = get_area(src)
	if(!A)
		return
	if(chan == -1)
		chan = power_channel
	A.use_power(amount, chan)

/obj/machinery/proc/addStaticPower(value, powerchannel)
	var/area/A = get_area(src)
	if(!A)
		return
	A.addStaticPower(value, powerchannel)

/obj/machinery/proc/removeStaticPower(value, powerchannel)
	addStaticPower(-value, powerchannel)

/obj/machinery/proc/power_change()
	if(powered(power_channel))
		stat &= ~NOPOWER
	else
	
		stat |= NOPOWER
	return

/obj/machinery/power/proc/connect_to_network()
	var/turf/T = src.loc
	if(!T || !istype(T))
		return FALSE

	var/obj/structure/cable/C = T.get_cable_node()
	if(!C || !C.powernet)
		return FALSE

	C.powernet.add_machine(src)
	return TRUE

/obj/machinery/power/proc/disconnect_from_network()
	if(!powernet)
		return FALSE
	powernet.remove_machine(src)
	return TRUE

/proc/power_list(turf/T, source, d, unmarked=0, cable_only = 0)
	. = list()

	for(var/AM in T)
		if(AM == source)
			continue

		if(!cable_only && istype(AM, /obj/machinery/power))
			var/obj/machinery/power/P = AM
			if(P.powernet == 0)
				continue

			if(!unmarked || !P.powernet)
				if(d == 0)
					. += P

		else if(istype(AM, /obj/structure/cable))
			var/obj/structure/cable/C = AM

			if(!unmarked || !C.powernet)
				if(C.d1 == d || C.d2 == d)
					. += C
	return .

/proc/propagate_network(obj/O, datum/powernet/PN)
	var/list/worklist = list()
	var/list/found_machines = list()
	var/index = 1
	var/obj/P = null

	worklist+=O

	while(index<=worklist.len)
		P = worklist[index]
		index++

		if( istype(P, /obj/structure/cable))
			var/obj/structure/cable/C = P
			if(C.powernet != PN)
				PN.add_cable(C)
			worklist |= C.get_connections()

		else if(P.anchored && istype(P, /obj/machinery/power))
			var/obj/machinery/power/M = P
			found_machines |= M

		else
			continue

	for(var/obj/machinery/power/PM in found_machines)
		if(!PM.connect_to_network())
			PM.disconnect_from_network()

/proc/merge_powernets(datum/powernet/net1, datum/powernet/net2)
	if(!net1 || !net2)
		return

	if(net1 == net2)
		return

	if(net1.cables.len < net2.cables.len)
		var/temp = net1
		net1 = net2
		net2 = temp

	for(var/obj/structure/cable/Cable in net2.cables)
		net1.add_cable(Cable)

	for(var/obj/machinery/power/Node in net2.nodes)
		if(!Node.connect_to_network())
			Node.disconnect_from_network()

	return net1

/proc/electrocute_mob(mob/living/carbon/M, power_source, obj/source, siemens_coeff = 1, dist_check = FALSE)
	return 0//not_actual
	//if(!M || ismecha(M.loc))
	//	return 0
	//if(dist_check)
	//	if(!in_range(source,M))
	//		return 0
	//if(ishuman(M))
	//	var/mob/living/carbon/human/H = M
	//	if(H.gloves)
	//		var/obj/item/clothing/gloves/G = H.gloves
	//		if(G.siemens_coefficient == 0)
	//			return 0

	//var/area/source_area
	//if(istype(power_source, /area))
	//	source_area = power_source
	//	power_source = source_area.get_apc()
	//if(istype(power_source, /obj/structure/cable))
	//	var/obj/structure/cable/Cable = power_source
	//	power_source = Cable.powernet

	//var/datum/powernet/PN
	//var/obj/item/stock_parts/cell/cell

	//if(istype(power_source, /datum/powernet))
	//	PN = power_source
	//else if(istype(power_source, /obj/item/stock_parts/cell))
	//	cell = power_source
	//else if(istype(power_source, /obj/machinery/power/apc))
	//	var/obj/machinery/power/apc/apc = power_source
	//	cell = apc.cell
	//	if (apc.terminal)
	//		PN = apc.terminal.powernet
	//else if (!power_source)
	//	return 0
	//else
	//	log_admin("ERROR: /proc/electrocute_mob([M], [power_source], [source]): wrong power_source")
	//	return 0
	//if (!cell && !PN)
	//	return 0
	//var/PN_damage = 0
	//var/cell_damage = 0
	//if (PN)
	//	PN_damage = PN.get_electrocute_damage()
	//if (cell)
	//	cell_damage = cell.get_electrocute_damage()
	//var/shock_damage = 0
	//if (PN_damage>=cell_damage)
	//	power_source = PN
	//	shock_damage = PN_damage
	//else
	//	power_source = cell
	//	shock_damage = cell_damage
	//var/drained_hp = M.electrocute_act(shock_damage, source, siemens_coeff)
	//log_combat(source, M, "electrocuted")

	//var/drained_energy = drained_hp*20

	//if (source_area)
	//	source_area.use_power(drained_energy/GLOB.CELLRATE)
	//else if (istype(power_source, /datum/powernet))
	//	var/drained_power = drained_energy/GLOB.CELLRATE
	//	PN.delayedload += (min(drained_power, max(PN.newavail - PN.delayedload, 0)))
	//else if (istype(power_source, /obj/item/stock_parts/cell))
	//	cell.use(drained_energy)
	//return drained_energy

/turf/proc/get_cable_node()
	if(!can_have_cabling())
		return null
	for(var/obj/structure/cable/C in src)
		if(C.d1 == 0)
			return C
	return null

/area/proc/get_apc()
	for(var/obj/machinery/power/apc/APC in GLOB.apcs_list)
		if(APC.area == src)
			return APC