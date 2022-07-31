SUBSYSTEM_DEF(mapping)
	name = "Mapping"
	init_order = INIT_ORDER_MAPPING
	flags = SS_NO_FIRE

	var/list/nuke_tiles = list()
	var/list/nuke_threats = list()

	var/datum/map_config/config
	var/datum/map_config/next_map_config

	var/list/map_templates = list()

	var/list/ruins_templates = list()
	var/list/space_ruins_templates = list()
	var/list/lava_ruins_templates = list()

	var/list/shuttle_templates = list()
	var/list/shelter_templates = list()

	var/list/areas_in_z = list()

	var/loading_ruins = FALSE
	var/list/turf/unused_turfs = list()
	var/list/datum/turf_reservations
	var/list/used_turfs = list()

	var/clearing_reserved_turfs = FALSE

	var/station_start
	var/space_levels_so_far = 0
	var/list/z_list
	var/datum/space_level/transit
	var/datum/space_level/empty_space
	var/num_of_res_levels = 1

/datum/controller/subsystem/mapping/proc/HACK_LoadMapConfig()
	if(!config)
#ifdef FORCE_MAP
		config = load_map_config(FORCE_MAP)
#else
		config = load_map_config(error_if_missing = FALSE)
#endif

/datum/controller/subsystem/mapping/Initialize(timeofday)
	HACK_LoadMapConfig()
	if(initialized)
		return
	if(config.defaulted)
		var/old_config = config
		config = global.config.defaultmap
		if(!config || config.defaulted)
			to_chat(world, "<span class='boldannounce'>Unable to load next or default map config, defaulting to Box Station</span>")
			config = old_config
	loadWorld()
	repopulate_sorted_areas()
	//process_teleport_locs()
	preloadTemplates()
#ifndef LOWMEMORYMODE
	//while (space_levels_so_far < config.space_ruin_levels)
	//	++space_levels_so_far
	//	add_new_zlevel("Empty Area [space_levels_so_far]", ZTRAITS_SPACE)
	//for (var/i in 1 to config.space_empty_levels)
	//	++space_levels_so_far
	//	empty_space = add_new_zlevel("Empty Area [space_levels_so_far]", list(ZTRAIT_LINKAGE = CROSSLINKED))
	transit = add_new_zlevel("Transit/Reserved", list(ZTRAIT_RESERVED = TRUE))

	//if(CONFIG_GET(flag/roundstart_away))
	//	createRandomZlevel()


	//loading_ruins = TRUE
	//var/list/lava_ruins = levels_by_trait(ZTRAIT_LAVA_RUINS)
	//if (lava_ruins.len)
	//	seedRuins(lava_ruins, CONFIG_GET(number/lavaland_budget), /area/lavaland/surface/outdoors/unexplored, lava_ruins_templates)
	//	for (var/lava_z in lava_ruins)
	//		spawn_rivers(lava_z)

	//var/list/space_ruins = levels_by_trait(ZTRAIT_SPACE_RUINS)
	//if (space_ruins.len)
	//	seedRuins(space_ruins, CONFIG_GET(number/space_budget), /area/space, space_ruins_templates)
	//loading_ruins = FALSE
#endif
	repopulate_sorted_areas()
	setup_map_transitions()
	//generate_station_area_list()
	initialize_reserved_level()
	return ..()

#define INIT_ANNOUNCE(X) to_chat(world, "<span class='boldannounce'>[X]</span>"); log_world(X)
/datum/controller/subsystem/mapping/proc/LoadGroup(list/errorList, name, path, files, list/traits, list/default_traits, silent = FALSE)
	. = list()
	var/start_time = REALTIMEOFDAY

	if (!islist(files))
		files = list(files)

	var/total_z = 0
	var/list/parsed_maps = list()
	for (var/file in files)
		var/full_path = "_maps/[path]/[file]"
		var/datum/parsed_map/pm = new(file(full_path))
		var/bounds = pm?.bounds
		if (!bounds)
			errorList |= full_path
			continue
		parsed_maps[pm] = total_z
		total_z += bounds[MAP_MAXZ] - bounds[MAP_MINZ] + 1

	if (!length(traits))
		for (var/i in 1 to total_z)
			traits += list(default_traits)
	else if (total_z != traits.len)
		INIT_ANNOUNCE("WARNING: [traits.len] trait sets specified for [total_z] z-levels in [path]!")
		if (total_z < traits.len)
			traits.Cut(total_z + 1)
		while (total_z > traits.len)
			traits += list(default_traits)

	var/start_z = world.maxz + 1
	var/i = 0
	for (var/level in traits)
		add_new_zlevel("[name][i ? " [i + 1]" : ""]", level)
		++i

	for (var/P in parsed_maps)
		var/datum/parsed_map/pm = P
		if (!pm.load(1, 1, start_z + parsed_maps[P], no_changeturf = TRUE))
			errorList |= pm.original_path
	if(!silent)
		INIT_ANNOUNCE("Loaded [name] in [(REALTIMEOFDAY - start_time)/10]s!")
	return parsed_maps

/datum/controller/subsystem/mapping/proc/loadWorld()
	var/list/FailedZs = list()

	InitializeDefaultZLevels()

	station_start = world.maxz + 1
	INIT_ANNOUNCE("Loading [config.map_name]...")
	LoadGroup(FailedZs, "Station", config.map_path, config.map_file, config.traits, ZTRAITS_STATION)

	//if(SSdbcore.Connect())
	//	var/datum/DBQuery/query_round_map_name = SSdbcore.NewQuery("UPDATE [format_table_name("round")] SET map_name = '[config.map_name]' WHERE id = [GLOB.round_id]")
	//	query_round_map_name.Execute()
	//	qdel(query_round_map_name)

/datum/controller/subsystem/mapping/proc/preloadTemplates(path = "_maps/templates/")
	var/list/filelist = flist(path)
	for(var/map in filelist)
		var/datum/map_template/T = new(path = "[path][map]", rename = "[map]")
		map_templates[T.name] = T

	//preloadRuinTemplates()
	preloadShuttleTemplates()
	//preloadShelterTemplates()

/datum/controller/subsystem/mapping/proc/preloadShuttleTemplates()
	var/list/unbuyable = generateMapList("[global.config.directory]/unbuyableshuttles.txt")

	for(var/item in subtypesof(/datum/map_template/shuttle))
		var/datum/map_template/shuttle/shuttle_type = item
		if(!(initial(shuttle_type.suffix)))
			continue

		var/datum/map_template/shuttle/S = new shuttle_type()
		if(unbuyable.Find(S.mappath))
			S.can_be_bought = FALSE

		shuttle_templates[S.shuttle_id] = S
		map_templates[S.shuttle_id] = S

/datum/controller/subsystem/mapping/proc/RequestBlockReservation(width, height, z, type = /datum/turf_reservation, turf_type_override)
	UNTIL(initialized && !clearing_reserved_turfs)
	var/datum/turf_reservation/reserve = new type
	if(turf_type_override)
		reserve.turf_type = turf_type_override
	if(!z)
		for(var/i in levels_by_trait(ZTRAIT_RESERVED))
			if(reserve.Reserve(width, height, i))
				return reserve
		num_of_res_levels += 1
		var/newReserved = add_new_zlevel("Transit/Reserved [num_of_res_levels]", list(ZTRAIT_RESERVED = TRUE))
		if(reserve.Reserve(width, height, newReserved))
			return reserve
	else
		if(!level_trait(z, ZTRAIT_RESERVED))
			qdel(reserve)
			return
		else
			if(reserve.Reserve(width, height, z))
				return reserve
	QDEL_NULL(reserve)

/datum/controller/subsystem/mapping/proc/initialize_reserved_level()
	UNTIL(!clearing_reserved_turfs)
	clearing_reserved_turfs = TRUE
	for(var/i in levels_by_trait(ZTRAIT_RESERVED))
		var/turf/A = get_turf(locate(SHUTTLE_TRANSIT_BORDER,SHUTTLE_TRANSIT_BORDER,i))
		var/turf/B = get_turf(locate(world.maxx - SHUTTLE_TRANSIT_BORDER,world.maxy - SHUTTLE_TRANSIT_BORDER,i))
		var/block = block(A, B)
		for(var/t in block)
			var/turf/T = t
			T.flags_1 |= UNUSED_RESERVATION_TURF_1
		unused_turfs["[i]"] = block
	clearing_reserved_turfs = FALSE

/datum/controller/subsystem/mapping/proc/reserve_turfs(list/turfs)
	for(var/i in turfs)
		var/turf/T = i
		T.empty(RESERVED_TURF_TYPE, RESERVED_TURF_TYPE, null, TRUE)
		LAZYINITLIST(unused_turfs["[T.z]"])
		unused_turfs["[T.z]"] |= T
		T.flags_1 |= UNUSED_RESERVATION_TURF_1
		GLOB.areas_by_type[world.area].contents += T
		CHECK_TICK

/datum/controller/subsystem/mapping/proc/reg_in_areas_in_z(list/areas)
	for(var/B in areas)
		var/area/A = B
		A.reg_in_areas_in_z()