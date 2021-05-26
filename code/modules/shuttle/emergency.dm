#define ENGINES_START_TIME 100

/obj/docking_port/mobile/emergency
	name = "emergency shuttle"
	id = "emergency"

	dwidth = 9
	width = 22
	height = 11
	dir = EAST
	port_direction = WEST
	var/sound_played = 0

/obj/docking_port/mobile/emergency/canDock(obj/docking_port/stationary/S)
	return SHUTTLE_CAN_DOCK

/obj/docking_port/mobile/emergency/register()
	. = ..()
	SSshuttle.emergency = src

/obj/docking_port/mobile/emergency/Destroy(force)
	if(force)
		if(src == SSshuttle.emergency)
			SSshuttle.emergencyDeregister()

	. = ..()

/obj/docking_port/mobile/emergency/request(obj/docking_port/stationary/S, area/signalOrigin, reason, redAlert, set_coefficient=null)
	if(!isnum(set_coefficient))
		var/security_num = seclevel2num(get_security_level())
		switch(security_num)
			if(SEC_LEVEL_GREEN)
				set_coefficient = 2
			if(SEC_LEVEL_BLUE)
				set_coefficient = 1
			else
				set_coefficient = 0.5
	var/call_time = SSshuttle.emergencyCallTime * set_coefficient * engine_coeff
	switch(mode)
		if(SHUTTLE_RECALL, SHUTTLE_IDLE, SHUTTLE_CALL)
			mode = SHUTTLE_CALL
			setTimer(call_time)
		else
			return

	SSshuttle.emergencyCallAmount++

	if(prob(70))
		SSshuttle.emergencyLastCallLoc = signalOrigin
	else
		SSshuttle.emergencyLastCallLoc = null

	priority_announce("The emergency shuttle has been called. [redAlert ? "Red Alert state confirmed: Dispatching priority shuttle. " : "" ]It will arrive in [timeLeft(600)] minutes.[reason][SSshuttle.emergencyLastCallLoc ? "\n\nCall signal traced. Results can be viewed on any communications console." : "" ]", null, 'sound/ai/shuttlecalled.ogg', "Priority")

///obj/docking_port/mobile/emergency/cancel(area/signalOrigin)
//	if(mode != SHUTTLE_CALL)
//		return
//	if(SSshuttle.emergencyNoRecall)
//		return
//
//	invertTimer()
//	mode = SHUTTLE_RECALL
//
//	if(prob(70))
//		SSshuttle.emergencyLastCallLoc = signalOrigin
//	else
//		SSshuttle.emergencyLastCallLoc = null
//	priority_announce("The emergency shuttle has been recalled.[SSshuttle.emergencyLastCallLoc ? " Recall signal traced. Results can be viewed on any communications console." : "" ]", null, 'sound/ai/shuttlerecalled.ogg', "Priority")

/obj/docking_port/mobile/emergency/proc/ShuttleDBStuff()
	set waitfor = FALSE
	//if(!SSdbcore.Connect())
	//	return
	//var/datum/DBQuery/query_round_shuttle_name = SSdbcore.NewQuery("UPDATE [format_table_name("round")] SET shuttle_name = '[name]' WHERE id = [GLOB.round_id]")
	//query_round_shuttle_name.Execute()
	//qdel(query_round_shuttle_name)

/obj/docking_port/mobile/emergency/check()
	if(!timer)
		return
	var/time_left = timeLeft(1)

	if(!ripples.len && (time_left <= SHUTTLE_RIPPLE_TIME) && ((mode == SHUTTLE_CALL) || (mode == SHUTTLE_ESCAPE)))
		var/destination
		if(mode == SHUTTLE_CALL)
			destination = SSshuttle.getDock("emergency_home")
		else if(mode == SHUTTLE_ESCAPE)
			destination = SSshuttle.getDock("emergency_away")
		create_ripples(destination)

	switch(mode)
		if(SHUTTLE_RECALL)
			if(time_left <= 0)
				mode = SHUTTLE_IDLE
				timer = 0
		if(SHUTTLE_CALL)
			if(time_left <= 0)
				if(initiate_docking(SSshuttle.getDock("emergency_home")) != DOCKING_SUCCESS)
					setTimer(20)
					return
				mode = SHUTTLE_DOCKED
				setTimer(SSshuttle.emergencyDockTime)
				//send2irc("Server", "The Emergency Shuttle has docked with the station.")
				priority_announce("The Emergency Shuttle has docked with the station. You have [timeLeft(600)] minutes to board the Emergency Shuttle.", null, 'sound/ai/shuttledock.ogg', "Priority")
				ShuttleDBStuff()


		if(SHUTTLE_DOCKED)
			if(time_left <= ENGINES_START_TIME)
				mode = SHUTTLE_IGNITING
				SSshuttle.checkHostileEnvironment()
				if(mode == SHUTTLE_STRANDED)
					return
				for(var/A in SSshuttle.mobile)
					var/obj/docking_port/mobile/M = A
					if(M.launch_status == UNLAUNCHED)
						M.check_transit_zone()

		if(SHUTTLE_IGNITING)
			var/success = TRUE
			SSshuttle.checkHostileEnvironment()
			if(mode == SHUTTLE_STRANDED)
				return

			success &= (check_transit_zone() == TRANSIT_READY)
			for(var/A in SSshuttle.mobile)
				var/obj/docking_port/mobile/M = A
				if(M.launch_status == UNLAUNCHED)
					success &= (M.check_transit_zone() == TRANSIT_READY)
			if(!success)
				setTimer(ENGINES_START_TIME)

			if(time_left <= 50 && !sound_played)
				sound_played = 1
				var/list/areas = list()
				for(var/area/shuttle/escape/E in GLOB.sortedAreas)
					areas += E
				hyperspace_sound(HYPERSPACE_WARMUP, areas)

			if(time_left <= 0 && !SSshuttle.emergencyNoEscape)
				for(var/A in SSshuttle.mobile)
					var/obj/docking_port/mobile/M = A
					M.on_emergency_launch()

				var/list/areas = list()
				for(var/area/shuttle/escape/E in GLOB.sortedAreas)
					areas += E
				hyperspace_sound(HYPERSPACE_LAUNCH, areas)
				enterTransit()
				mode = SHUTTLE_ESCAPE
				launch_status = ENDGAME_LAUNCHED
				setTimer(SSshuttle.emergencyEscapeTime * engine_coeff)
				priority_announce("The Emergency Shuttle has left the station. Estimate [timeLeft(600)] minutes until the shuttle docks at Central Command.", null, null, "Priority")

		if(SHUTTLE_STRANDED)
			SSshuttle.checkHostileEnvironment()

		if(SHUTTLE_ESCAPE)
			if(sound_played && time_left <= HYPERSPACE_END_TIME)
				var/list/areas = list()
				for(var/area/shuttle/escape/E in GLOB.sortedAreas)
					areas += E
				hyperspace_sound(HYPERSPACE_END, areas)
			if(time_left <= PARALLAX_LOOP_TIME)
				var/area_parallax = FALSE
				//for(var/place in shuttle_areas)
				//	var/area/shuttle/shuttle_area = place
				//	if(shuttle_area.parallax_movedir)
				//		area_parallax = TRUE
				//		break
				//if(area_parallax)
				//	parallax_slowdown()
				//	for(var/A in SSshuttle.mobile)
				//		var/obj/docking_port/mobile/M = A
				//		if(M.launch_status == ENDGAME_LAUNCHED)
				//			if(istype(M, /obj/docking_port/mobile/pod))
				//				M.parallax_slowdown()

			if(time_left <= 0)
				for(var/A in SSshuttle.mobile)
					var/obj/docking_port/mobile/M = A
					M.on_emergency_dock()

				var/destination_dock = "emergency_away"
				//if(is_hijacked())
				//	destination_dock = "emergency_syndicate"
				//	minor_announce("Corruption detected in \
				//		shuttle navigation protocols. Please contact your \
				//		supervisor.", "SYSTEM ERROR:", alert=TRUE)

				dock_id(destination_dock)
				mode = SHUTTLE_ENDGAME
				timer = 0

/obj/docking_port/mobile/emergency/transit_failure()
	..()
	message_admins("Moving emergency shuttle directly to centcom dock to prevent deadlock.")

	mode = SHUTTLE_ESCAPE
	launch_status = ENDGAME_LAUNCHED
	setTimer(SSshuttle.emergencyEscapeTime)
	priority_announce("The Emergency Shuttle preparing for direct jump. Estimate [timeLeft(600)] minutes until the shuttle docks at Central Command.", null, null, "Priority")

/obj/docking_port/mobile/pod
	name = "escape pod"
	id = "pod"
	dwidth = 1
	width = 3
	height = 4
	launch_status = UNLAUNCHED

///obj/docking_port/mobile/pod/request(obj/docking_port/stationary/S)
//	var/obj/machinery/computer/shuttle/C = getControlConsole()
//	if(!istype(C, /obj/machinery/computer/shuttle/pod))
//		return ..()
//	if(GLOB.security_level >= SEC_LEVEL_RED || (C && (C.obj_flags & EMAGGED)))
//		if(launch_status == UNLAUNCHED)
//			launch_status = EARLY_LAUNCHED
//			return ..()
//	else
//		to_chat(usr, "<span class='warning'>Escape pods will only launch during \"Code Red\" security alert.</span>")
//		return TRUE

///obj/docking_port/mobile/pod/cancel()
//	return

/obj/docking_port/stationary/random
	name = "escape pod"
	id = "pod"
	dwidth = 1
	width = 3
	height = 4
	//var/target_area = /area/lavaland/surface/outdoors
	var/edge_distance = 16

/obj/docking_port/stationary/random/Initialize(mapload)
	. = ..()
	if(!mapload)
		return

	//var/list/turfs = get_area_turfs(target_area)
	//var/turf/T = pick(turfs)

	//while(turfs.len)
	//	if(T.x<edge_distance || T.y<edge_distance || (world.maxx+1-T.x)<edge_distance || (world.maxy+1-T.y)<edge_distance)
	//		turfs -= T
	//		T = pick(turfs)
	//	else
	//		forceMove(T)
	//		break

/obj/docking_port/mobile/emergency/backup
	name = "backup shuttle"
	id = "backup"
	dwidth = 2
	width = 8
	height = 8
	dir = EAST

/obj/docking_port/mobile/emergency/backup/Initialize()
	var/current_emergency = SSshuttle.emergency
	. = ..()
	SSshuttle.emergency = current_emergency
	SSshuttle.backup_shuttle = src

/obj/docking_port/mobile/emergency/shuttle_build/register()
	. = ..()
	initiate_docking(SSshuttle.getDock("emergency_home"))