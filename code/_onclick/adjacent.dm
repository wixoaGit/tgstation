/atom/proc/Adjacent(atom/neighbor)
	return 0

/turf/Adjacent(atom/neighbor, atom/target = null, atom/movable/mover = null)
	var/turf/T0 = get_turf(neighbor)

	if(T0 == src)
		return TRUE

	if(get_dist(src, T0) > 1 || z != T0.z)
		return FALSE

	if(T0.x == x || T0.y == y)
		return T0.ClickCross(get_dir(T0,src), border_only = 1, target_atom = target, mover = mover) && src.ClickCross(get_dir(src,T0), border_only = 1, target_atom = target, mover = mover)

	var/in_dir = get_dir(T0,src)
	var/d1 = in_dir&3
	var/d2 = in_dir&12

	for(var/d in list(d1,d2))
		if(!T0.ClickCross(d, border_only = 1, target_atom = target, mover = mover))
			continue

		var/turf/T1 = get_step(T0,d)
		if(!T1 || T1.density)
			continue
		if(!T1.ClickCross(get_dir(T1,src), border_only = 0, target_atom = target, mover = mover) || !T1.ClickCross(get_dir(T1,T0), border_only = 0, target_atom = target, mover = mover))
			continue

		if(!src.ClickCross(get_dir(src,T1), border_only = 1, target_atom = target, mover = mover))
			continue

		return 1

	return 0

/atom/movable/Adjacent(var/atom/neighbor)
	if(neighbor == loc)
		return TRUE
	if(!isturf(loc))
		return FALSE
	if(loc.Adjacent(neighbor,target = neighbor, mover = src))
		return TRUE
	return FALSE

/turf/proc/ClickCross(target_dir, border_only, target_atom = null, atom/movable/mover = null)
	for(var/obj/O in src)
		if((mover && O.CanPass(mover,get_step(src,target_dir))) || (!mover && !O.density))
			continue
		if(O == target_atom || O == mover || (O.pass_flags & LETPASSTHROW))
			continue

		if( O.flags_1&ON_BORDER_1) 
			if( O.dir & target_dir || O.dir & (O.dir-1) )
				return 0
		else if( !border_only )
			return 0
	return 1