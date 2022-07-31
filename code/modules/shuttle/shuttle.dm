#ifdef TESTING
#define DOCKING_PORT_HIGHLIGHT
#endif

/obj/docking_port
	invisibility = INVISIBILITY_ABSTRACT
	icon = 'icons/obj/device.dmi'
	icon_state = "pinonfar"

	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	anchored = TRUE

	var/id
	dir = NORTH
	var/width = 0
	var/height = 0
	var/dwidth = 0
	var/dheight = 0

	var/area_type
	var/hidden = FALSE

/obj/docking_port/Destroy(force)
	if(force)
		..()
		. = QDEL_HINT_QUEUE
	else
		return QDEL_HINT_LETMELIVE

/obj/docking_port/has_gravity(turf/T)
	return FALSE

/obj/docking_port/take_damage()
	return

///obj/docking_port/singularity_pull()
//	return
///obj/docking_port/singularity_act()
//	return 0
/obj/docking_port/shuttleRotate()
	return

/obj/docking_port/proc/return_coords(_x, _y, _dir)
	if(_dir == null)
		_dir = dir
	if(_x == null)
		_x = x
	if(_y == null)
		_y = y

	var/cos = 1
	var/sin = 0
	switch(_dir)
		if(WEST)
			cos = 0
			sin = 1
		if(SOUTH)
			cos = -1
			sin = 0
		if(EAST)
			cos = 0
			sin = -1

	return list(
		_x + (-dwidth*cos) - (-dheight*sin),
		_y + (-dwidth*sin) + (-dheight*cos),
		_x + (-dwidth+width-1)*cos - (-dheight+height-1)*sin,
		_y + (-dwidth+width-1)*sin + (-dheight+height-1)*cos
		)

/obj/docking_port/proc/return_turfs()
	var/list/L = return_coords()
	var/turf/T0 = locate(L[1],L[2],z)
	var/turf/T1 = locate(L[3],L[4],z)
	return block(T0,T1)

/obj/docking_port/proc/return_ordered_turfs(_x, _y, _z, _dir)
	var/cos = 1
	var/sin = 0
	switch(_dir)
		if(WEST)
			cos = 0
			sin = 1
		if(SOUTH)
			cos = -1
			sin = 0
		if(EAST)
			cos = 0
			sin = -1

	. = list()

	for(var/dx in 0 to width-1)
		var/compX = dx-dwidth
		for(var/dy in 0 to height-1)
			var/compY = dy-dheight
			var/turf/T = locate(_x + compX*cos - compY*sin, _y + compY*cos + compX*sin, _z)
			.[T] = NONE

#ifdef DOCKING_PORT_HIGHLIGHT
/obj/docking_port/proc/highlight(_color)
	var/list/L = return_coords()
	var/turf/T0 = locate(L[1],L[2],z)
	var/turf/T1 = locate(L[3],L[4],z)
	for(var/turf/T in block(T0,T1))
		T.color = _color
		LAZYINITLIST(T.atom_colours)
		T.maptext = null
	if(_color)
		var/turf/T = locate(L[1], L[2], z)
		T.color = "#0f0"
		T = locate(L[3], L[4], z)
		T.color = "#00f"
#endif

/obj/docking_port/proc/get_docked()
	return locate(/obj/docking_port/stationary) in loc

/obj/docking_port/proc/getDockedId()
	var/obj/docking_port/P = get_docked()
	if(P)
		return P.id

/obj/docking_port/stationary
	name = "dock"

	area_type = SHUTTLE_DEFAULT_UNDERLYING_AREA

	var/last_dock_time

	var/datum/map_template/shuttle/roundstart_template
	var/json_key

/obj/docking_port/stationary/Initialize(mapload)
	. = ..()
	SSshuttle.stationary += src
	if(!id)
		id = "[SSshuttle.stationary.len]"
	if(name == "dock")
		name = "dock[SSshuttle.stationary.len]"

	if(mapload)
		for(var/turf/T in return_turfs())
			T.flags_1 |= NO_RUINS_1

	#ifdef DOCKING_PORT_HIGHLIGHT
	highlight("#f00")
	#endif

/obj/docking_port/stationary/Destroy(force)
	if(force)
		SSshuttle.stationary -= src
	. = ..()

/obj/docking_port/stationary/proc/load_roundstart()
	if(json_key)
		var/sid = SSmapping.config.shuttles[json_key]
		roundstart_template = SSmapping.shuttle_templates[sid]
		if(!roundstart_template)
			CRASH("json_key:[json_key] value \[[sid]\] resulted in a null shuttle template for [src]")
	else if(roundstart_template)
		var/sid = "[initial(roundstart_template.port_id)]_[initial(roundstart_template.suffix)]"

		roundstart_template = SSmapping.shuttle_templates[sid]
		if(!roundstart_template)
			CRASH("Invalid path ([roundstart_template]) passed to docking port.")

	if(roundstart_template)
		SSshuttle.manipulator.action_load(roundstart_template, src)

/obj/docking_port/stationary/get_docked()
	. = locate(/obj/docking_port/mobile) in loc

/obj/docking_port/stationary/transit
	name = "In Transit"
	var/datum/turf_reservation/reserved_area
	var/area/shuttle/transit/assigned_area
	var/obj/docking_port/mobile/owner

/obj/docking_port/stationary/transit/Initialize()
	. = ..()
	SSshuttle.transit += src

/obj/docking_port/stationary/transit/Destroy(force=FALSE)
	if(force)
		if(get_docked())
			log_world("A transit dock was destroyed while something was docked to it.")
		SSshuttle.transit -= src
		if(owner)
			if(owner.assigned_transit == src)
				owner.assigned_transit = null
			owner = null
		if(!QDELETED(reserved_area))
			qdel(reserved_area)
		reserved_area = null
	return ..()

/obj/docking_port/mobile
	name = "shuttle"
	icon_state = "pinonclose"

	area_type = SHUTTLE_DEFAULT_SHUTTLE_AREA_TYPE

	var/list/shuttle_areas

	var/timer
	var/last_timer_length

	var/mode = SHUTTLE_IDLE
	var/callTime = 100
	var/ignitionTime = 55

	var/preferred_direction = NORTH
	var/port_direction = NORTH

	var/obj/docking_port/stationary/destination
	var/obj/docking_port/stationary/previous

	var/obj/docking_port/stationary/transit/assigned_transit

	var/launch_status = NOLAUNCH

	var/list/movement_force = list("KNOCKDOWN" = 3, "THROW" = 0)

	var/list/ripples = list()
	var/engine_coeff = 1
	var/current_engines = 0
	var/initial_engines = 0
	var/can_move_docking_ports = FALSE
	var/list/hidden_turfs = list()

/obj/docking_port/mobile/proc/register()
	SSshuttle.mobile += src

/obj/docking_port/mobile/Destroy(force)
	if(force)
		SSshuttle.mobile -= src
		destination = null
		previous = null
		QDEL_NULL(assigned_transit)
		shuttle_areas = null
		remove_ripples()
	. = ..()

/obj/docking_port/mobile/Initialize(mapload)
	. = ..()

	if(!id)
		id = "[SSshuttle.mobile.len]"
	if(name == "shuttle")
		name = "shuttle[SSshuttle.mobile.len]"

	shuttle_areas = list()
	var/list/all_turfs = return_ordered_turfs(x, y, z, dir)
	for(var/i in 1 to all_turfs.len)
		var/turf/curT = all_turfs[i]
		var/area/cur_area = curT.loc
		if(istype(cur_area, area_type))
			shuttle_areas[cur_area] = TRUE

	initial_engines = count_engines()
	current_engines = initial_engines

	#ifdef DOCKING_PORT_HIGHLIGHT
	highlight("#0f0")
	#endif

/obj/docking_port/mobile/proc/linkup(datum/map_template/shuttle/template, obj/docking_port/stationary/dock)
	//var/list/static/shuttle_id = list()
	var/list/shuttle_id = list()//not_actual
	var/idnum = ++shuttle_id[template]
	if(idnum > 1)
		if(id == initial(id))
			id = "[id][idnum]"
		if(name == initial(name))
			name = "[name] [idnum]"
	for(var/place in shuttle_areas)
		var/area/area = place
		area.connect_to_shuttle(src, dock, idnum, FALSE)
		for(var/each in place)
			var/atom/atom = each
			atom.connect_to_shuttle(src, dock, idnum, FALSE)

/obj/docking_port/mobile/proc/canMove()
	return TRUE

/obj/docking_port/mobile/proc/canDock(obj/docking_port/stationary/S)
	if(!istype(S))
		return SHUTTLE_NOT_A_DOCKING_PORT

	if(istype(S, /obj/docking_port/stationary/transit))
		return SHUTTLE_CAN_DOCK

	if(dwidth > S.dwidth)
		return SHUTTLE_DWIDTH_TOO_LARGE

	if(width-dwidth > S.width-S.dwidth)
		return SHUTTLE_WIDTH_TOO_LARGE

	if(dheight > S.dheight)
		return SHUTTLE_DHEIGHT_TOO_LARGE

	if(height-dheight > S.height-S.dheight)
		return SHUTTLE_HEIGHT_TOO_LARGE

	var/currently_docked = S.get_docked()
	if(currently_docked)
		if(currently_docked != src)
			return SHUTTLE_SOMEONE_ELSE_DOCKED
		else
			return SHUTTLE_ALREADY_DOCKED

	return SHUTTLE_CAN_DOCK

/obj/docking_port/mobile/proc/check_dock(obj/docking_port/stationary/S, silent=FALSE)
	var/status = canDock(S)
	if(status == SHUTTLE_CAN_DOCK)
		return TRUE
	else
		if(status != SHUTTLE_ALREADY_DOCKED && !silent)
			var/msg = "Shuttle [src] cannot dock at [S], error: [status]"
			message_admins(msg)
		return FALSE

/obj/docking_port/mobile/proc/transit_failure()
	message_admins("Shuttle [src] repeatedly failed to create transit zone.")

/obj/docking_port/mobile/proc/request(obj/docking_port/stationary/S)
	if(!check_dock(S))
		testing("check_dock failed on request for [src]")
		return

	if(mode == SHUTTLE_IGNITING && destination == S)
		return

	switch(mode)
		if(SHUTTLE_CALL)
			if(S == destination)
				if(timeLeft(1) < callTime * engine_coeff)
					setTimer(callTime * engine_coeff)
			else
				destination = S
				setTimer(callTime * engine_coeff)
		if(SHUTTLE_RECALL)
			if(S == destination)
				setTimer(callTime * engine_coeff - timeLeft(1))
			else
				destination = S
				setTimer(callTime * engine_coeff)
			mode = SHUTTLE_CALL
		if(SHUTTLE_IDLE, SHUTTLE_IGNITING)
			destination = S
			mode = SHUTTLE_IGNITING
			setTimer(ignitionTime)

/obj/docking_port/mobile/proc/enterTransit()
	if((SSshuttle.lockdown && is_station_level(z)) || !canMove())
		mode = SHUTTLE_IDLE
		return
	previous = null
	if(!destination)
		timer = INFINITY
	var/obj/docking_port/stationary/S0 = get_docked()
	var/obj/docking_port/stationary/S1 = assigned_transit
	if(S1)
		if(initiate_docking(S1) != DOCKING_SUCCESS)
			WARNING("shuttle \"[id]\" could not enter transit space. Docked at [S0 ? S0.id : "null"]. Transit dock [S1 ? S1.id : "null"].")
		else
			previous = S0
	else
		WARNING("shuttle \"[id]\" could not enter transit space. S0=[S0 ? S0.id : "null"] S1=[S1 ? S1.id : "null"]")

/obj/docking_port/mobile/proc/jumpToNullSpace()
	var/obj/docking_port/stationary/current_dock = get_docked()

	var/underlying_area_type = SHUTTLE_DEFAULT_UNDERLYING_AREA
	if(current_dock && current_dock.area_type)
		underlying_area_type = current_dock.area_type

	var/list/old_turfs = return_ordered_turfs(x, y, z, dir)

	var/area/underlying_area = GLOB.areas_by_type[underlying_area_type]
	if(!underlying_area)
		underlying_area = new underlying_area_type(null)

	for(var/i in 1 to old_turfs.len)
		var/turf/oldT = old_turfs[i]
		if(!oldT || !istype(oldT.loc, area_type))
			continue
		var/area/old_area = oldT.loc
		underlying_area.contents += oldT
		oldT.change_area(old_area, underlying_area)
		oldT.empty(FALSE)

		var/list/baseturf_cache = oldT.baseturfs
		for(var/k in 1 to length(baseturf_cache))
			if(ispath(baseturf_cache[k], /turf/baseturf_skipover/shuttle))
				oldT.ScrapeAway(baseturf_cache.len - k + 1)
				break

	qdel(src, force=TRUE)

/obj/docking_port/mobile/proc/create_ripples(obj/docking_port/stationary/S1, animate_time)
	var/list/turfs = ripple_area(S1)
	for(var/t in turfs)
		ripples += new /obj/effect/abstract/ripple(t, animate_time)

/obj/docking_port/mobile/proc/remove_ripples()
	QDEL_LIST(ripples)

/obj/docking_port/mobile/proc/ripple_area(obj/docking_port/stationary/S1)
	var/list/L0 = return_ordered_turfs(x, y, z, dir)
	var/list/L1 = return_ordered_turfs(S1.x, S1.y, S1.z, S1.dir)

	var/list/ripple_turfs = list()

	for(var/i in 1 to L0.len)
		var/turf/T0 = L0[i]
		var/turf/T1 = L1[i]
		if(!T0 || !T1)
			continue
		if(T0.type == T0.baseturfs)
			continue
		if(!istype(T0.loc, area_type) || istype(T0.loc, /area/shuttle/transit))
			continue
		ripple_turfs += T1

	return ripple_turfs

/obj/docking_port/mobile/proc/check_poddoors()
	for(var/obj/machinery/door/poddoor/shuttledock/pod in GLOB.airlocks)
		pod.check()

/obj/docking_port/mobile/proc/dock_id(id)
	var/port = SSshuttle.getDock(id)
	if(port)
		. = initiate_docking(port)
	else
		. = null

/obj/effect/landmark/shuttle_import
	name = "Shuttle Import"

/obj/effect/landmark/shuttle_import/onShuttleMove()
	return FALSE

/obj/docking_port/mobile/proc/check()
	check_effects()

	if(mode == SHUTTLE_IGNITING)
		check_transit_zone()

	if(timeLeft(1) > 0)
		return
	switch(mode)
		if(SHUTTLE_CALL)
			var/error = initiate_docking(destination, preferred_direction)
			if(error && error & (DOCKING_NULL_DESTINATION | DOCKING_NULL_SOURCE))
				var/msg = "A mobile dock in transit exited initiate_docking() with an error. This is most likely a mapping problem: Error: [error],  ([src]) ([previous][ADMIN_JMP(previous)] -> [destination][ADMIN_JMP(destination)])"
				WARNING(msg)
				message_admins(msg)
				mode = SHUTTLE_IDLE
				return
			else if(error)
				setTimer(20)
				return
		if(SHUTTLE_RECALL)
			if(initiate_docking(previous) != DOCKING_SUCCESS)
				setTimer(20)
				return
		if(SHUTTLE_IGNITING)
			if(check_transit_zone() != TRANSIT_READY)
				setTimer(20)
				return
			else
				mode = SHUTTLE_CALL
				setTimer(callTime * engine_coeff)
				enterTransit()
				return

	mode = SHUTTLE_IDLE
	timer = 0
	destination = null

/obj/docking_port/mobile/proc/check_effects()
	if(!ripples.len)
		if((mode == SHUTTLE_CALL) || (mode == SHUTTLE_RECALL))
			var/tl = timeLeft(1)
			if(tl <= SHUTTLE_RIPPLE_TIME)
				create_ripples(destination, tl)

	var/obj/docking_port/stationary/S0 = get_docked()
	if(istype(S0, /obj/docking_port/stationary/transit) && timeLeft(1) <= PARALLAX_LOOP_TIME)
		for(var/place in shuttle_areas)
			var/area/shuttle/shuttle_area = place
			//if(shuttle_area.parallax_movedir)
			//	parallax_slowdown()

/obj/docking_port/mobile/proc/check_transit_zone()
	if(assigned_transit)
		return TRANSIT_READY
	else
		SSshuttle.request_transit_dock(src)

/obj/docking_port/mobile/proc/setTimer(wait)
	timer = world.time + wait
	last_timer_length = wait

/obj/docking_port/mobile/proc/timeLeft(divisor)
	if(divisor <= 0)
		divisor = 10

	var/ds_remaining
	if(!timer)
		ds_remaining = callTime * engine_coeff
	else
		ds_remaining = max(0, timer - world.time)

	. = round(ds_remaining / divisor, 1)

/obj/docking_port/mobile/proc/getModeStr()
	switch(mode)
		if(SHUTTLE_IGNITING)
			return "IGN"
		if(SHUTTLE_RECALL)
			return "RCL"
		if(SHUTTLE_CALL)
			return "ETA"
		if(SHUTTLE_DOCKED)
			return "ETD"
		if(SHUTTLE_ESCAPE)
			return "ESC"
		if(SHUTTLE_STRANDED)
			return "ERR"
	return ""

/obj/docking_port/mobile/proc/getTimerStr()
	if(mode == SHUTTLE_STRANDED)
		return "--:--"

	var/timeleft = timeLeft()
	if(timeleft > 1 HOURS)
		return "--:--"
	else if(timeleft > 0)
		return "[add_zero(num2text((timeleft / 60) % 60),2)]:[add_zero(num2text(timeleft % 60), 2)]"
	else
		return "00:00"

/obj/docking_port/mobile/proc/getStatusText()
	var/obj/docking_port/stationary/dockedAt = get_docked()

	if(istype(dockedAt, /obj/docking_port/stationary/transit))
		if (timeLeft() > 1 HOURS)
			return "hyperspace"
		else
			var/obj/docking_port/stationary/dst
			if(mode == SHUTTLE_RECALL)
				dst = previous
			else
				dst = destination
			. = "transit towards [dst?.name || "unknown location"] ([getTimerStr()])"
	else
		return dockedAt?.name || "unknown"

/obj/docking_port/mobile/proc/getDbgStatusText()
	var/obj/docking_port/stationary/dockedAt = get_docked()
	. = (dockedAt && dockedAt.name) ? dockedAt.name : "unknown"
	if(istype(dockedAt, /obj/docking_port/stationary/transit))
		var/obj/docking_port/stationary/dst
		if(mode == SHUTTLE_RECALL)
			dst = previous
		else
			dst = destination
		if(dst)
			. = "(transit to) [dst.name || dst.id]"
		else
			. = "(transit to) nowhere"
	else if(dockedAt)
		. = dockedAt.name || dockedAt.id
	else
		. = "unknown"

/obj/docking_port/mobile/proc/hyperspace_sound(phase, list/areas)
	var/s
	switch(phase)
		if(HYPERSPACE_WARMUP)
			s = 'sound/effects/hyperspace_begin.ogg'
		if(HYPERSPACE_LAUNCH)
			s = 'sound/effects/hyperspace_progress.ogg'
		if(HYPERSPACE_END)
			s = 'sound/effects/hyperspace_end.ogg'
		else
			CRASH("Invalid hyperspace sound phase: [phase]")
	for(var/A in areas)
		//for(var/obj/machinery/door/E in A)
		//	playsound(E, s, 100, FALSE, max(width, height) - world.view)
		playsound(src, s, 100, FALSE, max(width, height) - 5)//not_actual

/obj/docking_port/mobile/proc/count_engines()
	. = 0
	for(var/thing in shuttle_areas)
		var/area/shuttle/areaInstance = thing
		//for(var/obj/structure/shuttle/engine/E in areaInstance.contents)
		//	if(!QDELETED(E))
		//		. += E.engine_power

/obj/docking_port/mobile/proc/on_emergency_launch()
	if(launch_status == UNLAUNCHED)
		launch_status = ENDGAME_LAUNCHED
		enterTransit()

/obj/docking_port/mobile/emergency/on_emergency_launch()
	return

/obj/docking_port/mobile/proc/on_emergency_dock()
	if(launch_status == ENDGAME_LAUNCHED)
		launch_status = ENDGAME_TRANSIT

/obj/docking_port/mobile/pod/on_emergency_dock()
	if(launch_status == ENDGAME_LAUNCHED)
		initiate_docking(SSshuttle.getDock("[id]_away"))
		mode = SHUTTLE_ENDGAME

/obj/docking_port/mobile/emergency/on_emergency_dock()
	return
