GLOBAL_LIST_INIT(blacklisted_automated_baseturfs, typecacheof(list(
	/turf/open/space,
	/turf/baseturf_bottom,
	)))

/turf/proc/empty(turf_type=/turf/open/space, baseturf_type, list/ignore_typecache, flags)
	//var/static/list/ignored_atoms = typecacheof(list(/mob/dead, /obj/effect/landmark, /obj/docking_port, /atom/movable/lighting_object))
	var/list/ignored_atoms = typecacheof(list(/mob/dead, /obj/effect/landmark, /obj/docking_port, /atom/movable/lighting_object))//not_actual
	var/list/allowed_contents = typecache_filter_list_reverse(GetAllContentsIgnoring(ignore_typecache), ignored_atoms)
	allowed_contents -= src
	for(var/i in 1 to allowed_contents.len)
		var/thing = allowed_contents[i]
		qdel(thing, force=TRUE)

	if(turf_type)
		var/turf/newT = ChangeTurf(turf_type, baseturf_type, flags)
		SSair.remove_from_active(newT)
		newT.CalculateAdjacentTurfs()
		SSair.add_to_active(newT,1)

/turf/proc/copyTurf(turf/T)
	if(T.type != type)
		var/obj/O
		if(underlays.len)
			O = new()
			O.underlays.Add(T)
		T.ChangeTurf(type)
		if(underlays.len)
			T.underlays = O.underlays
	if(T.icon_state != icon_state)
		T.icon_state = icon_state
	if(T.icon != icon)
		T.icon = icon
	if(color)
		//T.atom_colours = atom_colours.Copy()
		T.update_atom_colour()
	if(T.dir != dir)
		T.setDir(dir)
	return T

/turf/open/copyTurf(turf/T, copy_air = FALSE)
	. = ..()
	if (isopenturf(T))
		//GET_COMPONENT(slip, /datum/component/wet_floor)
		//if(slip)
		//	var/datum/component/wet_floor/WF = T.AddComponent(/datum/component/wet_floor)
		//	WF.InheritComponent(slip)
		if (copy_air)
			var/turf/open/openTurf = T
			openTurf.air.copy_from(air)

/turf/proc/ChangeTurf(path, list/new_baseturfs, flags)
	switch(path)
		if(null)
			return
		if(/turf/baseturf_bottom)
			//path = SSmapping.level_trait(z, ZTRAIT_BASETURF) || /turf/open/space
			path = /turf/open/space//not_actual
			//if (!ispath(path))
			//	path = text2path(path)
			//	if (!ispath(path))
			//		warning("Z-level [z] has invalid baseturf '[SSmapping.level_trait(z, ZTRAIT_BASETURF)]'")
			//		path = /turf/open/space
		if(/turf/open/space/basic)
			path = /turf/open/space

	if(!GLOB.use_preloader && path == type && !(flags & CHANGETURF_FORCEOP))
		return src
	if(flags & CHANGETURF_SKIP)
		return new path(src)

	//var/old_opacity = opacity
	//var/old_dynamic_lighting = dynamic_lighting
	//var/old_affecting_lights = affecting_lights
	//var/old_lighting_object = lighting_object
	//var/old_corners = corners

	var/old_exl = explosion_level
	var/old_exi = explosion_id
	//var/old_bp = blueprint_data
	//blueprint_data = null

	var/list/old_baseturfs = baseturfs

	var/list/transferring_comps = list()
	SEND_SIGNAL(src, COMSIG_TURF_CHANGE, path, new_baseturfs, flags, transferring_comps)
	//for(var/i in transferring_comps)
	//	var/datum/component/comp = i
	//	comp.RemoveComponent()

	changing_turf = TRUE
	qdel(src)
	var/turf/W = new path(src)

	//for(var/i in transferring_comps)
	//	W.TakeComponent(i)

	if(new_baseturfs)
		W.baseturfs = new_baseturfs
	else
		W.baseturfs = old_baseturfs

	W.explosion_id = old_exi
	W.explosion_level = old_exl

	if(!(flags & CHANGETURF_DEFER_CHANGE))
		W.AfterChange(flags)

	//W.blueprint_data = old_bp

	//if(SSlighting.initialized)
	//	recalc_atom_opacity()
	//	lighting_object = old_lighting_object
	//	affecting_lights = old_affecting_lights
	//	corners = old_corners
	//	if (old_opacity != opacity || dynamic_lighting != old_dynamic_lighting)
	//		reconsider_lights()

	//	if (dynamic_lighting != old_dynamic_lighting)
	//		if (IS_DYNAMIC_LIGHTING(src))
	//			lighting_build_overlay()
	//		else
	//			lighting_clear_overlay()

	//	for(var/turf/open/space/S in RANGE_TURFS(1, src))
	//		S.update_starlight()

	return W

/turf/proc/ScrapeAway(amount=1, flags)
	if(!amount)
		return
	if(length(baseturfs))
		var/list/new_baseturfs = baseturfs.Copy()
		var/turf_type = new_baseturfs[max(1, new_baseturfs.len - amount + 1)]
		while(ispath(turf_type, /turf/baseturf_skipover))
			amount++
			if(amount > new_baseturfs.len)
				CRASH("The bottomost baseturf of a turf is a skipover [src]([type])")
			turf_type = new_baseturfs[max(1, new_baseturfs.len - amount + 1)]
		new_baseturfs.len -= min(amount, new_baseturfs.len - 1)
		if(new_baseturfs.len == 1)
			new_baseturfs = new_baseturfs[1]
		return ChangeTurf(turf_type, new_baseturfs, flags)

	if(baseturfs == type)
		return src

	return ChangeTurf(baseturfs, baseturfs, flags)

/turf/proc/PlaceOnTop(list/new_baseturfs, turf/fake_turf_type, flags)
	var/area/turf_area = loc
	if(new_baseturfs && !length(new_baseturfs))
		new_baseturfs = list(new_baseturfs)
	flags = turf_area.PlaceOnTopReact(new_baseturfs, fake_turf_type, flags)

	var/turf/newT
	if(flags & CHANGETURF_SKIP)
		if(flags_1 & INITIALIZED_1)
			stack_trace("CHANGETURF_SKIP was used in a PlaceOnTop call for a turf that's initialized. This is a mistake. [src]([type])")
		assemble_baseturfs()
	if(fake_turf_type)
		if(!new_baseturfs)
			if(!length(baseturfs))
				baseturfs = list(baseturfs)
			var/list/old_baseturfs = baseturfs.Copy()
			if(!istype(src, /turf/closed))
				old_baseturfs += type
			newT = ChangeTurf(fake_turf_type, null, flags)
			newT.assemble_baseturfs(initial(fake_turf_type.baseturfs))
			if(!length(newT.baseturfs))
				newT.baseturfs = list(baseturfs)
			newT.baseturfs -= GLOB.blacklisted_automated_baseturfs
			newT.baseturfs.Insert(1, old_baseturfs)
			return newT
		if(!length(baseturfs))
			baseturfs = list(baseturfs)
		if(!istype(src, /turf/closed))
			baseturfs += type
		baseturfs += new_baseturfs
		return ChangeTurf(fake_turf_type, null, flags)
	if(!length(baseturfs))
		baseturfs = list(baseturfs)
	if(!istype(src, /turf/closed))
		baseturfs += type
	var/turf/change_type
	if(length(new_baseturfs))
		change_type = new_baseturfs[new_baseturfs.len]
		new_baseturfs.len--
		if(new_baseturfs.len)
			baseturfs += new_baseturfs
	else
		change_type = new_baseturfs
	return ChangeTurf(change_type, null, flags)

/turf/proc/CopyOnTop(turf/copytarget, ignore_bottom=1, depth=INFINITY, copy_air = FALSE)
	var/list/new_baseturfs = list()
	new_baseturfs += baseturfs
	new_baseturfs += type

	if(depth)
		var/list/target_baseturfs
		if(length(copytarget.baseturfs))
			target_baseturfs = copytarget.baseturfs.Copy(CLAMP(1 + ignore_bottom, 1 + copytarget.baseturfs.len - depth, copytarget.baseturfs.len))
		else if(!ignore_bottom)
			target_baseturfs = list(copytarget.baseturfs)
		if(target_baseturfs)
			target_baseturfs -= new_baseturfs & GLOB.blacklisted_automated_baseturfs
			new_baseturfs += target_baseturfs

	
	var/turf/newT = copytarget.copyTurf(src, copy_air)
	newT.baseturfs = new_baseturfs
	return newT

/turf/proc/AfterChange(flags)
	levelupdate()
	CalculateAdjacentTurfs()

	//var/list/turfs_to_check = get_adjacent_open_turfs(src) | src
	//for(var/I in turfs_to_check)
	//	var/turf/T = I
	//	for(var/obj/machinery/door/firedoor/FD in T)
	//		FD.CalculateAffectingAreas()

	queue_smooth_neighbors(src)

	//HandleTurfChange(src)

/turf/open/AfterChange(flags)
	..()
	RemoveLattice()
	//if(!(flags & (CHANGETURF_IGNORE_AIR | CHANGETURF_INHERIT_AIR)))
	//	Assimilate_Air()

/turf/proc/ReplaceWithLattice()
	ScrapeAway()
	new /obj/structure/lattice(locate(x, y, z))