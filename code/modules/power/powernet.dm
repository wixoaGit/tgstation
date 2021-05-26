/datum/powernet
	var/number
	var/list/cables = list()
	var/list/nodes = list()

	var/load = 0
	var/newavail = 0
	var/avail = 0
	var/viewavail = 0
	var/viewload = 0
	var/netexcess = 0
	var/delayedload = 0

/datum/powernet/New()
	SSmachines.powernets += src

/datum/powernet/Destroy()
	for(var/obj/structure/cable/C in cables)
		cables -= C
		C.powernet = null
	for(var/obj/machinery/power/M in nodes)
		nodes -= M
		M.powernet = null

	SSmachines.powernets -= src
	return ..()

/datum/powernet/proc/is_empty()
	return !cables.len && !nodes.len

/datum/powernet/proc/remove_cable(obj/structure/cable/C)
	cables -= C
	C.powernet = null
	if(is_empty())
		qdel(src)

/datum/powernet/proc/add_cable(obj/structure/cable/C)
	if(C.powernet)
		if(C.powernet == src)
			return
		else
			C.powernet.remove_cable(C)
	C.powernet = src
	cables +=C

/datum/powernet/proc/remove_machine(obj/machinery/power/M)
	nodes -=M
	M.powernet = null
	if(is_empty())
		qdel(src)

/datum/powernet/proc/add_machine(obj/machinery/power/M)
	if(M.powernet)
		if(M.powernet == src)
			return
		else
			M.disconnect_from_network()
	M.powernet = src
	nodes[M] = M

/datum/powernet/proc/reset()
	netexcess = avail - load

	if(netexcess > 100 && nodes && nodes.len)
		for(var/obj/machinery/power/smes/S in nodes)
			S.restore()

	viewavail = round(0.8 * viewavail + 0.2 * avail)
	viewload = round(0.8 * viewload + 0.2 * load)

	load = delayedload
	delayedload = 0
	avail = newavail
	newavail = 0