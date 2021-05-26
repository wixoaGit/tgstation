/obj/docking_port/mobile/proc/initiate_docking(obj/docking_port/stationary/new_dock, movement_direction, force=FALSE)
	if(new_dock.get_docked() == src)
		remove_ripples()
		return DOCKING_SUCCESS

	if(!force)
		if(!check_dock(new_dock))
			remove_ripples()
			return DOCKING_BLOCKED
		if(!canMove())
			remove_ripples()
			return DOCKING_IMMOBILIZED

	var/obj/docking_port/stationary/old_dock = get_docked()

	var/underlying_area_type = SHUTTLE_DEFAULT_UNDERLYING_AREA

	if(old_dock)
		underlying_area_type = old_dock.area_type

	var/list/old_turfs = return_ordered_turfs(x, y, z, dir)
	var/list/new_turfs = return_ordered_turfs(new_dock.x, new_dock.y, new_dock.z, new_dock.dir)
	CHECK_TICK
	
	var/area/underlying_old_area = GLOB.areas_by_type[underlying_area_type]
	if(!underlying_old_area)
		underlying_old_area = new underlying_area_type(null)

	var/rotation = 0
	if(new_dock.dir != dir)
		rotation = dir2angle(new_dock.dir)-dir2angle(dir)
		if ((rotation % 90) != 0)
			rotation += (rotation % 90)
		rotation = SIMPLIFY_DEGREES(rotation)

	if(!movement_direction)
		movement_direction = turn(preferred_direction, 180)

	var/list/moved_atoms = list()
	var/list/areas_to_move = list()

	. = preflight_check(old_turfs, new_turfs, areas_to_move, rotation)
	if(.)
		remove_ripples()
		return

	var/list/new_hidden_turfs
	if(hidden)
		new_hidden_turfs = list()
		for(var/i in 1 to old_turfs.len)
			CHECK_TICK
			var/turf/oldT = old_turfs[i]
			if(old_turfs[oldT] & MOVE_TURF)
				new_hidden_turfs += new_turfs[i]
		SSshuttle.update_hidden_docking_ports(null, new_hidden_turfs)

	if(!force)
		if(!check_dock(new_dock))
			remove_ripples()
			return DOCKING_BLOCKED
		if(!canMove())
			remove_ripples()
			return DOCKING_IMMOBILIZED

	takeoff(old_turfs, new_turfs, moved_atoms, rotation, movement_direction, old_dock, underlying_old_area)

	CHECK_TICK

	cleanup_runway(new_dock, old_turfs, new_turfs, areas_to_move, moved_atoms, rotation, movement_direction, underlying_old_area)

	CHECK_TICK

	if(new_hidden_turfs)
		SSshuttle.update_hidden_docking_ports(hidden_turfs, null)
		hidden_turfs = new_hidden_turfs

	check_poddoors()
	new_dock.last_dock_time = world.time
	setDir(new_dock.dir)

	remove_ripples()
	return DOCKING_SUCCESS

/obj/docking_port/mobile/proc/preflight_check(list/old_turfs, list/new_turfs, list/areas_to_move, rotation)
	for(var/i in 1 to old_turfs.len)
		CHECK_TICK
		var/turf/oldT = old_turfs[i]
		var/turf/newT = new_turfs[i]
		if(!newT)
			return DOCKING_NULL_DESTINATION
		if(!oldT)
			return DOCKING_NULL_SOURCE

		var/area/old_area = oldT.loc
		var/move_mode = old_area.beforeShuttleMove(shuttle_areas)

		var/list/old_contents = oldT.contents
		for(var/k in 1 to old_contents.len)
			CHECK_TICK
			var/atom/movable/moving_atom = old_contents[k]
			if(moving_atom.loc != oldT)
				continue
			move_mode = moving_atom.beforeShuttleMove(newT, rotation, move_mode, src)

		move_mode = oldT.fromShuttleMove(newT, move_mode)
		move_mode = newT.toShuttleMove(oldT, move_mode, src)

		if(move_mode & MOVE_AREA)
			areas_to_move[old_area] = TRUE

		old_turfs[oldT] = move_mode

/obj/docking_port/mobile/proc/takeoff(list/old_turfs, list/new_turfs, list/moved_atoms, rotation, movement_direction, old_dock, area/underlying_old_area)
	for(var/i in 1 to old_turfs.len)
		var/turf/oldT = old_turfs[i]
		var/turf/newT = new_turfs[i]
		var/move_mode = old_turfs[oldT]
		if(move_mode & MOVE_CONTENTS)
			for(var/k in oldT)
				var/atom/movable/moving_atom = k
				if(moving_atom.loc != oldT)
					continue
				moving_atom.onShuttleMove(newT, oldT, movement_force, movement_direction, old_dock, src)
				moved_atoms[moving_atom] = oldT

		if(move_mode & MOVE_TURF)
			oldT.onShuttleMove(newT, movement_force, movement_direction)

		if(move_mode & MOVE_AREA)
			var/area/shuttle_area = oldT.loc
			shuttle_area.onShuttleMove(oldT, newT, underlying_old_area)

/obj/docking_port/mobile/proc/cleanup_runway(obj/docking_port/stationary/new_dock, list/old_turfs, list/new_turfs, list/areas_to_move, list/moved_atoms, rotation, movement_direction, area/underlying_old_area)
	underlying_old_area.afterShuttleMove()

	var/new_parallax_dir = FALSE
	if(istype(new_dock, /obj/docking_port/stationary/transit))
		new_parallax_dir = preferred_direction
	for(var/i in 1 to areas_to_move.len)
		CHECK_TICK
		var/area/internal_area = areas_to_move[i]
		internal_area.afterShuttleMove(new_parallax_dir)

	for(var/i in 1 to old_turfs.len)
		CHECK_TICK
		if(!(old_turfs[old_turfs[i]] & MOVE_TURF))
			continue
		var/turf/oldT = old_turfs[i]
		var/turf/newT = new_turfs[i]
		newT.afterShuttleMove(oldT, rotation)

	for(var/i in 1 to moved_atoms.len)
		CHECK_TICK
		var/atom/movable/moved_object = moved_atoms[i]
		if(QDELETED(moved_object))
			continue
		var/turf/oldT = moved_atoms[moved_object]
		moved_object.afterShuttleMove(oldT, movement_force, dir, preferred_direction, movement_direction, rotation)

	underlying_old_area.lateShuttleMove()

	for(var/i in 1 to areas_to_move.len)
		CHECK_TICK
		var/area/internal_area = areas_to_move[i]
		internal_area.lateShuttleMove()

	for(var/i in 1 to old_turfs.len)
		CHECK_TICK
		if(!(old_turfs[old_turfs[i]] & MOVE_CONTENTS | MOVE_TURF))
			continue
		var/turf/oldT = old_turfs[i]
		var/turf/newT = new_turfs[i]
		newT.lateShuttleMove(oldT)

	for(var/i in 1 to moved_atoms.len)
		CHECK_TICK
		var/atom/movable/moved_object = moved_atoms[i]
		if(QDELETED(moved_object))
			continue
		var/turf/oldT = moved_atoms[moved_object]
		moved_object.lateShuttleMove(oldT, movement_force, movement_direction)