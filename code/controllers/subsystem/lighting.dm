GLOBAL_LIST_EMPTY(lighting_update_lights)
GLOBAL_LIST_EMPTY(lighting_update_corners)
GLOBAL_LIST_EMPTY(lighting_update_objects)

SUBSYSTEM_DEF(lighting)
	name = "Lighting"
	wait = 2
	init_order = INIT_ORDER_LIGHTING
	flags = SS_TICKER

/datum/controller/subsystem/lighting/stat_entry()
	..("L:[GLOB.lighting_update_lights.len]|C:[GLOB.lighting_update_corners.len]|O:[GLOB.lighting_update_objects.len]")

/datum/controller/subsystem/lighting/Initialize(timeofday)
	if(!initialized)
		//if (CONFIG_GET(flag/starlight))
		//	for(var/I in GLOB.sortedAreas)
		//		var/area/A = I
		//		if (A.dynamic_lighting == DYNAMIC_LIGHTING_IFSTARLIGHT)
		//			A.luminosity = 0

		create_all_lighting_objects()
		initialized = TRUE

	fire(FALSE, TRUE)

	return ..()

/datum/controller/subsystem/lighting/fire(resumed, init_tick_checks)
	MC_SPLIT_TICK_INIT(3)
	if(!init_tick_checks)
		MC_SPLIT_TICK
	var/i = 0
	if (GLOB.lighting_update_lights.len)//not_actual
		for (i in 1 to GLOB.lighting_update_lights.len)
			var/datum/light_source/L = GLOB.lighting_update_lights[i]

			L.update_corners()

			L.needs_update = LIGHTING_NO_UPDATE

			if(init_tick_checks)
				CHECK_TICK
			else if (MC_TICK_CHECK)
				break
	if (i)
		GLOB.lighting_update_lights.Cut(1, i+1)
		i = 0

	if(!init_tick_checks)
		MC_SPLIT_TICK

	if (GLOB.lighting_update_corners.len)//not_actual
		for (i in 1 to GLOB.lighting_update_corners.len)
			var/datum/lighting_corner/C = GLOB.lighting_update_corners[i]

			C.update_objects()
			C.needs_update = FALSE
			if(init_tick_checks)
				CHECK_TICK
			else if (MC_TICK_CHECK)
				break
	if (i)
		GLOB.lighting_update_corners.Cut(1, i+1)
		i = 0


	if(!init_tick_checks)
		MC_SPLIT_TICK

	if (GLOB.lighting_update_objects.len)//not_actual
		for (i in 1 to GLOB.lighting_update_objects.len)
			var/atom/movable/lighting_object/O = GLOB.lighting_update_objects[i]

			if (QDELETED(O))
				continue

			O.update()
			O.needs_update = FALSE
			if(init_tick_checks)
				CHECK_TICK
			else if (MC_TICK_CHECK)
				break
	if (i)
		GLOB.lighting_update_objects.Cut(1, i+1)