/turf/proc/fromShuttleMove(turf/newT, move_mode)
	if(!(move_mode & MOVE_AREA) || !isshuttleturf(src))
		return move_mode

	return move_mode | MOVE_TURF | MOVE_CONTENTS

/turf/proc/toShuttleMove(turf/oldT, move_mode, obj/docking_port/mobile/shuttle)
	. = move_mode
	if(!(. & MOVE_TURF))
		return

	var/shuttle_dir = shuttle.dir
	for(var/i in contents)
		var/atom/movable/thing = i
		if(ismob(thing))
			if(isliving(thing))
				var/mob/living/M = thing
				//if(M.buckled)
				//	M.buckled.unbuckle_mob(M, 1)
				if(M.pulledby)
					M.pulledby.stop_pulling()
				M.stop_pulling()
				M.visible_message("<span class='warning'>[shuttle] slams into [M]!</span>")
				//SSblackbox.record_feedback("tally", "shuttle_gib", 1, M.type)
				M.gib()

		else
			//if(istype(thing, /obj/singularity) && !istype(thing, /obj/singularity/narsie))
			//	continue
			if(!thing.anchored)
				step(thing, shuttle_dir)
			else
				qdel(thing)

/turf/proc/onShuttleMove(turf/newT, list/movement_force, move_dir)
	if(newT == src)
		return
	var/shuttle_boundary = baseturfs.Find(/turf/baseturf_skipover/shuttle)
	if(!shuttle_boundary)
		CRASH("A turf queued to move via shuttle somehow had no skipover in baseturfs. [src]([type]):[loc]")
	var/depth = baseturfs.len - shuttle_boundary + 1
	newT.CopyOnTop(src, 1, depth, TRUE)

	newT.blocks_air = TRUE
	newT.air_update_turf(TRUE)
	blocks_air = TRUE
	air_update_turf(TRUE)
	if(isopenturf(newT))
		var/turf/open/new_open = newT
		new_open.copy_air_with_tile(src)

	return TRUE

/turf/proc/afterShuttleMove(turf/oldT, rotation)
	oldT.TransferComponents(src)
	var/shuttle_boundary = baseturfs.Find(/turf/baseturf_skipover/shuttle)
	if(shuttle_boundary)
		oldT.ScrapeAway(baseturfs.len - shuttle_boundary + 1)

	if(rotation)
		shuttleRotate(rotation)

	return TRUE

/turf/proc/lateShuttleMove(turf/oldT)
	blocks_air = initial(blocks_air)
	air_update_turf(TRUE)
	oldT.blocks_air = initial(oldT.blocks_air)
	oldT.air_update_turf(TRUE)

/atom/movable/proc/beforeShuttleMove(turf/newT, rotation, move_mode, obj/docking_port/mobile/moving_dock)
	return move_mode

/atom/movable/proc/onShuttleMove(turf/newT, turf/oldT, list/movement_force, move_dir, obj/docking_port/stationary/old_dock, obj/docking_port/mobile/moving_dock)
	if(newT == oldT)
		return

	if(loc != oldT)
		return

	loc = newT

	return TRUE

/atom/movable/proc/afterShuttleMove(turf/oldT, list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir, rotation)

	var/turf/newT = get_turf(src)
	if (newT.z != oldT.z)
		onTransitZ(oldT.z, newT.z)

	if(light)
		update_light()
	if(rotation)
		shuttleRotate(rotation)

	//update_parallax_contents()

	return TRUE

/atom/movable/proc/lateShuttleMove(turf/oldT, list/movement_force, move_dir)
	if(!movement_force || anchored)
		return
	var/throw_force = movement_force["THROW"]
	if(!throw_force)
		return
	var/turf/target = get_edge_target_turf(src, move_dir)
	var/range = throw_force * 10
	range = CEILING(rand(range-(range*0.1), range+(range*0.1)), 10)/10
	var/speed = range/5
	safe_throw_at(target, range, speed, force = MOVE_FORCE_EXTREMELY_STRONG)

/area/proc/beforeShuttleMove(list/shuttle_areas)
	if(!shuttle_areas[src])
		return NONE
	return MOVE_AREA

/area/proc/onShuttleMove(turf/oldT, turf/newT, area/underlying_old_area)
	if(newT == oldT)
		return TRUE

	contents -= oldT
	underlying_old_area.contents += oldT
	oldT.change_area(src, underlying_old_area)

	var/area/old_dest_area = newT.loc
	//parallax_movedir = old_dest_area.parallax_movedir

	old_dest_area.contents -= newT
	contents += newT
	newT.change_area(old_dest_area, src)
	return TRUE

/area/proc/afterShuttleMove(new_parallax_dir)
	//parallax_movedir = new_parallax_dir
	return TRUE

/area/proc/lateShuttleMove()
	return

/obj/docking_port/mobile/beforeShuttleMove(turf/newT, rotation, move_mode, obj/docking_port/mobile/moving_dock)
	. = ..()
	if(moving_dock == src)
		. |= MOVE_CONTENTS

/obj/docking_port/stationary/onShuttleMove(turf/newT, turf/oldT, list/movement_force, move_dir, obj/docking_port/stationary/old_dock, obj/docking_port/mobile/moving_dock)
	if(!moving_dock.can_move_docking_ports || old_dock == src)
		return FALSE
	. = ..()