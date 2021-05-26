GLOBAL_LIST_EMPTY(conveyors_by_id)

/obj/machinery/conveyor
	icon = 'icons/obj/recycling.dmi'
	icon_state = "conveyor_map"
	name = "conveyor belt"
	desc = "A conveyor belt."
	layer = BELOW_OPEN_DOOR_LAYER
	var/operating = 0
	var/operable = 1
	var/forwards
	var/backwards
	var/movedir
	
	var/list/affecting
	var/id = ""
	var/verted = 1

/obj/machinery/conveyor/New()
	..()

/obj/machinery/conveyor/Initialize(mapload, newdir, newid)
	. = ..()
	if(newdir)
		setDir(newdir)
	if(newid)
		id = newid
	update_move_direction()
	LAZYADD(GLOB.conveyors_by_id[id], src)

/obj/machinery/conveyor/Destroy()
	LAZYREMOVE(GLOB.conveyors_by_id[id], src)
	. = ..()

/obj/machinery/conveyor/setDir(newdir)
	. = ..()
	update_move_direction()

/obj/machinery/conveyor/proc/update_move_direction()
	switch(dir)
		if(NORTH)
			forwards = NORTH
			backwards = SOUTH
		if(SOUTH)
			forwards = SOUTH
			backwards = NORTH
		if(EAST)
			forwards = EAST
			backwards = WEST
		if(WEST)
			forwards = WEST
			backwards = EAST
		if(NORTHEAST)
			forwards = EAST
			backwards = SOUTH
		if(NORTHWEST)
			forwards = NORTH
			backwards = EAST
		if(SOUTHEAST)
			forwards = SOUTH
			backwards = WEST
		if(SOUTHWEST)
			forwards = WEST
			backwards = NORTH
	if(verted == -1)
		var/temp = forwards
		forwards = backwards
		backwards = temp
	if(operating == 1)
		movedir = forwards
	else
		movedir = backwards
	update()

/obj/machinery/conveyor/proc/update()
	if(stat & BROKEN)
		icon_state = "conveyor-broken"
		operating = FALSE
		return
	if(!operable)
		operating = FALSE
	if(stat & NOPOWER)
		operating = FALSE
	icon_state = "conveyor[operating * verted]"

obj/machinery/conveyor/process()
	if(stat & (BROKEN | NOPOWER))
		return
	if(!operating)
		return
	use_power(6)
	affecting = loc.contents - src
	//addtimer(CALLBACK(src, .proc/convey, affecting), 1)
	addtimer(CALLBACK(src, .proc/convey), 1)//not_actual

///obj/machinery/conveyor/proc/convey(list/affecting)
/obj/machinery/conveyor/proc/convey()//not_actual
	for(var/atom/movable/A in affecting)
		if((A.loc == loc) && A.has_gravity())
			A.ConveyorMove(movedir)

/obj/machinery/conveyor_switch
	name = "conveyor switch"
	desc = "A conveyor control switch."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "switch-off"
	
	var/position = 0
	var/last_pos = -1
	var/operated = 1
	var/oneway = FALSE
	var/invert_icon = FALSE
	
	var/id = ""

/obj/machinery/conveyor_switch/Initialize(mapload, newid)
	. = ..()
	if (newid)
		id = newid
	update_icon()
	LAZYADD(GLOB.conveyors_by_id[id], src)

/obj/machinery/conveyor_switch/Destroy()
	LAZYREMOVE(GLOB.conveyors_by_id[id], src)
	. = ..()

/obj/machinery/conveyor_switch/update_icon()
	if(position<0)
		if(invert_icon)
			icon_state = "switch-fwd"
		else
			icon_state = "switch-rev"
	else if(position>0)
		if(invert_icon)
			icon_state = "switch-rev"
		else
			icon_state = "switch-fwd"
	else
		icon_state = "switch-off"

/obj/machinery/conveyor_switch/process()
	if(!operated)
		return
	operated = 0

	for(var/obj/machinery/conveyor/C in GLOB.conveyors_by_id[id])
		C.operating = position
		C.update_move_direction()
		CHECK_TICK

/obj/machinery/conveyor_switch/interact(mob/user)
	add_fingerprint(user)
	if(position == 0)
		if(oneway)
			position = oneway
		else
			if(last_pos < 0)
				position = 1
				last_pos = 0
			else
				position = -1
				last_pos = 0
	else
		last_pos = position
		position = 0

	operated = 1
	update_icon()

	for(var/obj/machinery/conveyor_switch/S in GLOB.conveyors_by_id[id])
		S.invert_icon = invert_icon
		S.position = position
		S.update_icon()

/obj/machinery/conveyor_switch/oneway
	icon_state = "conveyor_switch_oneway"
	desc = "A conveyor control switch. It appears to only go in one direction."
	oneway = TRUE