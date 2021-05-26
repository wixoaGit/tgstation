/turf
	icon = 'icons/turf/floors.dmi'
	level = 1

	var/intact = 1

	var/list/baseturfs = /turf/baseturf_bottom

	var/temperature = T20C

	var/blocks_air = FALSE

	flags_1 = CAN_BE_DIRTY_1

	var/explosion_level = 0
	var/explosion_id = 0

	var/requires_activation
	var/changing_turf = FALSE

	var/bullet_bounce_sound = 'sound/weapons/bulletremove.ogg'
	var/bullet_sizzle = FALSE

	var/tiled_dirt = FALSE

/turf/Initialize(mapload)
	if(flags_1 & INITIALIZED_1)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	flags_1 |= INITIALIZED_1

	//vis_contents.Cut()

	assemble_baseturfs()

	levelupdate()
	if(smooth)
		queue_smooth(src)
	//visibilityChanged()

	for(var/atom/movable/AM in src)
		Entered(AM)

	//var/area/A = loc
	//if(!IS_DYNAMIC_LIGHTING(src) && IS_DYNAMIC_LIGHTING(A))
	//	add_overlay(/obj/effect/fullbright)

	if(requires_activation)
		CalculateAdjacentTurfs()
		SSair.add_to_active(src)

	if (light_power && light_range)
		update_light()

	//var/turf/T = SSmapping.get_turf_above(src)
	//if(T)
	//	T.multiz_turf_new(src, DOWN)
	//	SEND_SIGNAL(T, COMSIG_TURF_MULTIZ_NEW, src, DOWN)
	//T = SSmapping.get_turf_below(src)
	//if(T)
	//	T.multiz_turf_new(src, UP)
	//	SEND_SIGNAL(T, COMSIG_TURF_MULTIZ_NEW, src, UP)

	if (opacity)
		has_opaque_atom = TRUE

	ComponentInitialize()

	return INITIALIZE_HINT_NORMAL

/turf/proc/Initalize_Atmos(times_fired)
	CalculateAdjacentTurfs()

/turf/Destroy(force)
	. = QDEL_HINT_IWILLGC
	if(!changing_turf)
		stack_trace("Incorrect turf deletion")
	changing_turf = FALSE
	//var/turf/T = SSmapping.get_turf_above(src)
	//if(T)
	//	T.multiz_turf_del(src, DOWN)
	//T = SSmapping.get_turf_below(src)
	//if(T)
	//	T.multiz_turf_del(src, UP)
	if(force)
		..()
		var/turf/B = new world.turf(src)
		for(var/A in B.contents)
			qdel(A)
		for(var/I in B.vars)
			B.vars[I] = null
		return
	SSair.remove_from_active(src)
	visibilityChanged()
	//QDEL_LIST(blueprint_data)
	flags_1 &= ~INITIALIZED_1
	requires_activation = FALSE
	..()

/turf/proc/zPassIn(atom/movable/A, direction, turf/source)
	return FALSE

/turf/proc/zPassOut(atom/movable/A, direction, turf/destination)
	return FALSE

/turf/proc/zAirIn(direction, turf/source)
	return FALSE

/turf/proc/zAirOut(direction, turf/source)
	return FALSE

/turf/attackby(obj/item/C, mob/user, params)
	if(..())
		return TRUE
	if(can_lay_cable() && istype(C, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/coil = C
		for(var/obj/structure/cable/LC in src)
			if(!LC.d1 || !LC.d2)
				LC.attackby(C,user)
				return
		coil.place_turf(src, user)
		return TRUE

	//else if(istype(C, /obj/item/twohanded/rcl))
	//	handleRCL(C, user)

	return FALSE

/turf/CanPass(atom/movable/mover, turf/target)
	if(!target)
		return FALSE

	if(istype(mover))
		return !density

	stack_trace("Non movable passed to turf CanPass : [mover]")
	return FALSE

/turf/Enter(atom/movable/mover, atom/oldloc)
	var/atom/firstbump
	if(!CanPass(mover, src))
		firstbump = src
	else
		for(var/i in contents)
			if(i == mover || i == mover.loc)
				continue
			if(QDELETED(mover))
				break
			var/atom/movable/thing = i
			if(!thing.Cross(mover))
				if(CHECK_BITFIELD(mover.movement_type, UNSTOPPABLE))
					mover.Bump(thing)
					continue
				else
					if(!firstbump || ((thing.layer > firstbump.layer || thing.flags_1 & ON_BORDER_1) && !(firstbump.flags_1 & ON_BORDER_1)))
						firstbump = thing
	if(firstbump)
		if(!QDELETED(mover))
			mover.Bump(firstbump)
		return CHECK_BITFIELD(mover.movement_type, UNSTOPPABLE)
	return TRUE

/turf/Exit(atom/movable/mover, atom/newloc)
	. = ..()
	if(!.)
		return FALSE
	for(var/i in contents)
		if(QDELETED(mover))
			break
		if(i == mover)
			continue
		var/atom/movable/thing = i
		if(!thing.Uncross(mover, newloc))
			if(thing.flags_1 & ON_BORDER_1)
				mover.Bump(thing)
			if(!CHECK_BITFIELD(mover.movement_type, UNSTOPPABLE))
				return FALSE

/turf/proc/assemble_baseturfs(turf/fake_baseturf_type)
	//var/static/list/created_baseturf_lists = list()
	var/turf/current_target
	if(fake_baseturf_type)
		if(length(fake_baseturf_type))
			baseturfs = fake_baseturf_type
			return
		current_target = fake_baseturf_type
	else
		if(length(baseturfs))
			return
		if(!baseturfs)
			current_target = initial(baseturfs) || type
			stack_trace("baseturfs var was null for [type]. Failsafe activated and it has been given a new baseturfs value of [current_target].")
		else
			current_target = baseturfs

	//if(created_baseturf_lists[current_target])
	//	var/list/premade_baseturfs = created_baseturf_lists[current_target]
	//	if(length(premade_baseturfs))
	//		baseturfs = premade_baseturfs.Copy()
	//	else
	//		baseturfs = premade_baseturfs
	//	return baseturfs

	var/turf/next_target = initial(current_target.baseturfs)
	if(current_target == next_target)
		baseturfs = current_target
		//created_baseturf_lists[current_target] = current_target
		return current_target
	var/list/new_baseturfs = list(current_target)
	for(var/i=0;current_target != next_target;i++)
		if(i > 100)
			stack_trace("A turf <[type]> created a baseturfs list over 100 members long. This is most likely an infinite loop.")
			message_admins("A turf <[type]> created a baseturfs list over 100 members long. This is most likely an infinite loop.")
			break
		new_baseturfs.Insert(1, next_target)
		current_target = next_target
		next_target = initial(current_target.baseturfs)

	baseturfs = new_baseturfs
	//created_baseturf_lists[new_baseturfs[new_baseturfs.len]] = new_baseturfs.Copy()
	return new_baseturfs

/turf/proc/levelupdate()
	for(var/obj/O in src)
		if(O.level == 1 && (O.flags_1 & INITIALIZED_1))
			O.hide(src.intact)

/turf/open/space/levelupdate()
	for(var/obj/O in src)
		if(O.level == 1 && (O.flags_1 & INITIALIZED_1))
			O.hide(0)

/turf/proc/RemoveLattice()
	var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
	if(L && (L.flags_1 & INITIALIZED_1))
		qdel(L)

/turf/proc/can_have_cabling()
	return TRUE

/turf/proc/can_lay_cable()
	return can_have_cabling() & !intact

/turf/proc/visibilityChanged()
	//GLOB.cameranet.updateVisibility(src)
	//var/datum/camerachunk/C = GLOB.cameranet.chunkGenerated(x, y, z)
	//if(C)
	//	if(C.obscuredTurfs[src])
	//		vis_contents += GLOB.cameranet.vis_contents_objects
	//	else
	//		vis_contents -= GLOB.cameranet.vis_contents_objects

/turf/proc/burn_tile()

/turf/proc/is_shielded()

/turf/contents_explosion(severity, target)
	var/affecting_level
	if(severity == 1)
		affecting_level = 1
	else if(is_shielded())
		affecting_level = 3
	else if(intact)
		affecting_level = 2
	else
		affecting_level = 1

	for(var/V in contents)
		var/atom/A = V
		if(!QDELETED(A) && A.level >= affecting_level)
			if(ismovableatom(A))
				var/atom/movable/AM = A
				if(!AM.ex_check(explosion_id))
					continue
			A.ex_act(severity, target)
			CHECK_TICK

/turf/proc/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = icon
	underlay_appearance.icon_state = icon_state
	underlay_appearance.dir = adjacency_dir
	return TRUE

/turf/AllowDrop()
	return TRUE