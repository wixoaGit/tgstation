/obj/item/assembly/control
	name = "blast door controller"
	desc = "A small electronic device able to control a blast door remotely."
	icon_state = "control"
	attachable = TRUE
	var/id = null
	var/can_change_id = 0
	var/cooldown = FALSE
	var/sync_doors = TRUE

/obj/item/assembly/control/examine(mob/user)
	..()
	if(id)
		to_chat(user, "<span class='notice'>Its channel ID is '[id]'.</span>")

/obj/item/assembly/control/activate()
	cooldown = TRUE
	var/openclose
	for(var/obj/machinery/door/poddoor/M in GLOB.machines)
		if(M.id == src.id)
			if(openclose == null || !sync_doors)
				openclose = M.density
			//INVOKE_ASYNC(M, openclose ? /obj/machinery/door/poddoor.proc/open : /obj/machinery/door/poddoor.proc/close)
			openclose ? M.open() : M.close()//not_actual
	//addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 10)
	addtimer(CALLBACK(src, .proc/varset_callback_cooldown, FALSE), 10)//not_actual

//not_actual
/obj/item/assembly/control/proc/varset_callback_cooldown(value)
	cooldown = value

/obj/item/assembly/control/airlock
	name = "airlock controller"
	desc = "A small electronic device able to control an airlock remotely."
	id = "badmin"
	var/specialfunctions = OPEN

/obj/item/assembly/control/airlock/activate()
	cooldown = TRUE
	var/doors_need_closing = FALSE
	var/list/obj/machinery/door/airlock/open_or_close = list()
	for(var/obj/machinery/door/airlock/D in GLOB.airlocks)
		if(D.id_tag == src.id)
			if(specialfunctions & OPEN)
				open_or_close += D
				if(!D.density)
					doors_need_closing = TRUE
			//if(specialfunctions & IDSCAN)
			//	D.aiDisabledIdScanner = !D.aiDisabledIdScanner
			if(specialfunctions & BOLTS)
				if(!D.wires.is_cut(WIRE_BOLTS) && D.hasPower())
					D.locked = !D.locked
					D.update_icon()
			//if(specialfunctions & SHOCK)
			//	if(D.secondsElectrified)
			//		D.set_electrified(MACHINE_ELECTRIFIED_PERMANENT, usr)
			//	else
			//		D.set_electrified(MACHINE_NOT_ELECTRIFIED, usr)
			if(specialfunctions & SAFE)
				D.safe = !D.safe

	//for(var/D in open_or_close)
	for(var/obj/machinery/door/airlock/D in open_or_close)//not_actual
		//INVOKE_ASYNC(D, doors_need_closing ? /obj/machinery/door/airlock.proc/close : /obj/machinery/door/airlock.proc/open)
		doors_need_closing ? D.close() : D.open()//not_actual

	//addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 10)
	addtimer(CALLBACK(src, .proc/varset_callback_cooldown, FALSE), 10)//not_actual