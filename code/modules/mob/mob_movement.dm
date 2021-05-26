/mob/CanPass(atom/movable/mover, turf/target)
	return TRUE

/mob/living/CanPass(atom/movable/mover, turf/target)
	if((mover.pass_flags & PASSMOB))
		return TRUE
	if(istype(mover, /obj/item/projectile) || mover.throwing)
		return (!density || !(mobility_flags & MOBILITY_STAND))
	if(buckled == mover)
		return TRUE
	if(ismob(mover))
		if (mover in buckled_mobs)
			return TRUE
	return (!mover.density || !density || !(mobility_flags & MOBILITY_STAND))

/mob/proc/movement_delay()
	return cached_multiplicative_slowdown

#define MOVEMENT_DELAY_BUFFER 0.75
#define MOVEMENT_DELAY_BUFFER_DELTA 1.25

/client/Move(n, direct)
	if(world.time < move_delay)
		return FALSE
	//else
	//	next_move_dir_add = 0
	//	next_move_dir_sub = 0
	var/old_move_delay = move_delay
	move_delay = world.time + world.tick_lag
	if(!mob || !mob.loc)
		return FALSE
	if(!n || !direct)
		return FALSE
	if(mob.notransform)
		return FALSE
	//if(mob.control_object)
	//	return Move_object(direct)
	if(!isliving(mob))
		return mob.Move(n, direct)
	if(mob.stat == DEAD)
		mob.ghostize()
		return FALSE
	//if(mob.force_moving)
	//	return FALSE

	var/mob/living/L = mob
	//if(L.incorporeal_move)
	//	Process_Incorpmove(direct)
	//	return FALSE

	//if(mob.remote_control)
	//	return mob.remote_control.relaymove(mob, direct)

	//if(isAI(mob))
	//	return AIMove(n,direct,mob)

	//if(Process_Grab())
	//	return

	//if(mob.buckled)
	//	return mob.buckled.relaymove(mob, direct)

	if(!(L.mobility_flags & MOBILITY_MOVE))
		return FALSE

	if(isobj(mob.loc) || ismob(mob.loc))
		var/atom/O = mob.loc
		return O.relaymove(mob, direct)

	if(!mob.Process_Spacemove(direct))
		return FALSE
	var/add_delay = mob.movement_delay()
	if(old_move_delay + (add_delay*MOVEMENT_DELAY_BUFFER_DELTA) + MOVEMENT_DELAY_BUFFER > world.time)
		move_delay = old_move_delay
	else
		move_delay = world.time

	//if(L.confused)
	//	var/newdir = 0
	//	if(L.confused > 40)
	//		newdir = pick(GLOB.alldirs)
	//	else if(prob(L.confused * 1.5))
	//		newdir = angle2dir(dir2angle(direct) + pick(90, -90))
	//	else if(prob(L.confused * 3))
	//		newdir = angle2dir(dir2angle(direct) + pick(45, -45))
	//	if(newdir)
	//		direct = newdir
	//		n = get_step(L, direct)

	. = ..()

	if((direct & (direct - 1)) && mob.loc == n)
		add_delay *= 2
	move_delay += add_delay
	if(.)
		if(mob.throwing)
			mob.throwing.finalize(FALSE)

	var/atom/movable/P = mob.pulling
	if(P && !ismob(P) && P.density)
		mob.setDir(turn(mob.dir, 180))

/mob/Process_Spacemove(movement_dir = 0)
	if(spacewalk || ..())
		return TRUE
	var/atom/movable/backup = get_spacemove_backup()
	if(backup)
		if(istype(backup) && movement_dir && !backup.anchored)
			if(backup.newtonian_move(turn(movement_dir, 180)))
				to_chat(src, "<span class='info'>You push off of [backup] to propel yourself.</span>")
		return TRUE
	return FALSE

/mob/get_spacemove_backup()
	for(var/A in orange(1, get_turf(src)))
		if(isarea(A))
			continue
		else if(isturf(A))
			var/turf/turf = A
			if(isspaceturf(turf))
				continue
			if(!turf.density && !mob_negates_gravity())
				continue
			return A
		else
			var/atom/movable/AM = A
			if(AM == buckled)
				continue
			if(ismob(AM))
				var/mob/M = AM
				if(M.buckled)
					continue
			if(!AM.CanPass(src) || AM.density)
				if(AM.anchored)
					return AM
				if(pulling == AM)
					continue
				. = AM

/mob/proc/mob_has_gravity()
	return has_gravity()

/mob/proc/mob_negates_gravity()
	return FALSE

/mob/proc/update_gravity()
	return