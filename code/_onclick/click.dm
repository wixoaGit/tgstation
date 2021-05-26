/mob/var/next_click	= 0

/mob/var/next_move_adjust = 0
/mob/var/next_move_modifier = 1

/mob/proc/changeNext_move(num)
	next_move = world.time + ((num+next_move_adjust)*next_move_modifier)

/mob/living/changeNext_move(num)
	var/mod = next_move_modifier
	var/adj = next_move_adjust
	for(var/i in status_effects)
		var/datum/status_effect/S = i
		mod *= S.nextmove_modifier()
		adj += S.nextmove_adjust()
	next_move = world.time + ((num + adj)*mod)

/atom/Click(location,control,params)
	if(flags_1 & INITIALIZED_1)
		SEND_SIGNAL(src, COMSIG_CLICK, location, control, params, usr)
		usr.ClickOn(src, params)

/mob/proc/ClickOn( atom/A, params )
	if(world.time <= next_click)
		return
	next_click = world.time + 1

	if(notransform)
		return

	var/list/modifiers = params2list(params)
	if (modifiers["shift"])
		ShiftClickOn(A)
		return
	if(modifiers["alt"])
		AltClickOn(A)
		return
	if(modifiers["ctrl"])
		CtrlClickOn(A)
		return
	
	face_atom(A)

	if(next_move > world.time)
		return
	
	if(in_throw_mode)
		throw_item(A)
		return
	
	var/obj/item/W = get_active_held_item()
	
	if (W == A)
		W.attack_self(src)
		update_inv_hands()
		return
	
	if(A in DirectAccess())
		if(W)
			W.melee_attack_chain(src, A, params)
		else
			if(ismob(A))
				changeNext_move(CLICK_CD_MELEE)
			UnarmedAttack(A)
		return
	
	if(!loc.AllowClick())
		return
	
	if(CanReach(A,W))
		if(W)
			W.melee_attack_chain(src, A, params)
		else
			if(ismob(A))
				changeNext_move(CLICK_CD_MELEE)
			UnarmedAttack(A,1)
	else
		if(W)
			W.afterattack(A,src,0,params)
		//else
		//	RangedAttack(A,params)

/atom/movable/proc/CanReach(atom/ultimate_target, obj/item/tool, view_only = FALSE)
	var/list/direct_access = DirectAccess()
	var/depth = 1 + (view_only ? STORAGE_VIEW_DEPTH : INVENTORY_DEPTH)

	var/list/closed = list()
	var/list/checking = list(ultimate_target)
	while (checking.len && depth > 0)
		var/list/next = list()
		--depth

		for(var/atom/target in checking)
			if(closed[target] || isarea(target))
				continue
			closed[target] = TRUE
			if(isturf(target) || isturf(target.loc) || (target in direct_access))
				//if(Adjacent(target) || (tool && CheckToolReach(src, target, tool.reach)))
				if(Adjacent(target))//not_actual
					return TRUE

			if (!target.loc)
				continue

			if(!(SEND_SIGNAL(target.loc, COMSIG_ATOM_CANREACH, next) & COMPONENT_BLOCK_REACH))
				next += target.loc

		checking = next
	return FALSE

/atom/movable/proc/DirectAccess()
	return list(src, loc)

/mob/DirectAccess(atom/target)
	return ..() + contents

/mob/living/DirectAccess(atom/target)
	return ..() + GetAllContents()

/atom/proc/AllowClick()
	return FALSE

/turf/AllowClick()
	return TRUE

/mob/proc/UnarmedAttack(atom/A, proximity_flag)
	if(ismob(A))
		changeNext_move(CLICK_CD_MELEE)
	return

/mob/proc/ShiftClickOn(atom/A)
	A.ShiftClick(src)
	return
/atom/proc/ShiftClick(mob/user)
	SEND_SIGNAL(src, COMSIG_CLICK_SHIFT, user)
	if(user.client && user.client.eye == user || user.client.eye == user.loc)
		user.examinate(src)
	return


/mob/proc/CtrlClickOn(atom/A)
	A.CtrlClick(src)
	return

/atom/proc/CtrlClick(mob/user)
	SEND_SIGNAL(src, COMSIG_CLICK_CTRL, user)
	var/mob/living/ML = user
	if(istype(ML))
		ML.pulled(src)

/mob/proc/AltClickOn(atom/A)
	A.AltClick(src)
	return

/mob/living/carbon/AltClickOn(atom/A)
	//if(!stat && mind && iscarbon(A) && A != src)
	//	var/datum/antagonist/changeling/C = mind.has_antag_datum(/datum/antagonist/changeling)
	//	if(C && C.chosen_sting)
	//		C.chosen_sting.try_to_sting(src,A)
	//		next_click = world.time + 5
	//		return
	..()

/atom/proc/AltClick(mob/user)
	SEND_SIGNAL(src, COMSIG_CLICK_ALT, user)
	var/turf/T = get_turf(src)
	if(T && user.TurfAdjacent(T))
		user.listed_turf = T
		//user.client.statpanel = T.name

/mob/proc/TurfAdjacent(turf/T)
	return T.Adjacent(src)

/mob/proc/face_atom(atom/A)
	if( buckled || stat != CONSCIOUS || !A || !x || !y || !A.x || !A.y )
		return
	var/dx = A.x - x
	var/dy = A.y - y
	if(!dx && !dy)
		if(A.pixel_y > 16)
			setDir(NORTH)
		else if(A.pixel_y < -16)
			setDir(SOUTH)
		else if(A.pixel_x > 16)
			setDir(EAST)
		else if(A.pixel_x < -16)
			setDir(WEST)
		return
	
	if(abs(dx) < abs(dy))
		if(dy > 0)
			setDir(NORTH)
		else
			setDir(SOUTH)
	else
		if(dx > 0)
			setDir(EAST)
		else
			setDir(WEST)