/turf
	var/thermal_conductivity = 0.05
	var/temperature_archived

	var/list/atmos_adjacent_turfs
	var/atmos_supeconductivity = NONE

	var/archived_cycle = 0
	var/current_cycle = 0

	var/initial_gas_mix = OPENTURF_DEFAULT_ATMOS

/turf/open
	var/pressure_difference = 0
	var/pressure_direction = 0

	var/datum/excited_group/excited_group
	var/excited = FALSE
	var/datum/gas_mixture/turf/air

	var/obj/effect/hotspot/active_hotspot
	var/atmos_cooldown  = 0
	var/planetary_atmos = FALSE

	var/list/atmos_overlay_types

/turf/open/Initialize()
	if(!blocks_air)
		air = new
		air.copy_from_turf(src)
	. = ..()

/turf/open/Destroy()
	if(active_hotspot)
		QDEL_NULL(active_hotspot)
	for(var/T in atmos_adjacent_turfs)
		SSair.add_to_active(T)
	return ..()

/turf/open/assume_air(datum/gas_mixture/giver)
	if(!giver)
		return FALSE
	air.merge(giver)
	update_visuals()
	return TRUE

/turf/open/remove_air(amount)
	var/datum/gas_mixture/ours = return_air()
	var/datum/gas_mixture/removed = ours.remove(amount)
	update_visuals()
	return removed

/turf/open/proc/copy_air_with_tile(turf/open/T)
	if(istype(T))
		air.copy_from(T.air)

/turf/return_air()
	var/datum/gas_mixture/GM = new
	GM.copy_from_turf(src)
	return GM

/turf/open/return_air()
	return air

/turf/proc/archive()
	temperature_archived = temperature

/turf/open/archive()
	air.archive()
	archived_cycle = SSair.times_fired
	temperature_archived = temperature

/turf/open/proc/update_visuals()
	//var/list/new_overlay_types = tile_graphic()
	//var/list/atmos_overlay_types = src.atmos_overlay_types

	//if (atmos_overlay_types)
	//	for(var/overlay in atmos_overlay_types-new_overlay_types)
	//		vis_contents -= overlay

	//if (length(new_overlay_types))
	//	if (atmos_overlay_types)
	//		vis_contents += new_overlay_types - atmos_overlay_types
	//	else
	//		vis_contents += new_overlay_types

	//UNSETEMPTY(new_overlay_types)
	//src.atmos_overlay_types = new_overlay_types

#define LAST_SHARE_CHECK \
	var/last_share = our_air.last_share;\
	if(last_share > MINIMUM_AIR_TO_SUSPEND){\
		our_excited_group.reset_cooldowns();\
		cached_atmos_cooldown = 0;\
	} else if(last_share > MINIMUM_MOLES_DELTA_TO_MOVE) {\
		our_excited_group.dismantle_cooldown = 0;\
		cached_atmos_cooldown = 0;\
	}

/turf/proc/process_cell(fire_count)
	SSair.remove_from_active(src)

/turf/open/process_cell(fire_count)
	if(archived_cycle < fire_count)
		archive()

	current_cycle = fire_count

	var/list/adjacent_turfs = atmos_adjacent_turfs
	var/datum/excited_group/our_excited_group = excited_group
	var/adjacent_turfs_length = LAZYLEN(adjacent_turfs)
	var/cached_atmos_cooldown = atmos_cooldown + 1

	//var/planet_atmos = planetary_atmos
	//if (planet_atmos)
	//	adjacent_turfs_length++

	var/datum/gas_mixture/our_air = air

	for(var/t in adjacent_turfs)
		var/turf/open/enemy_tile = t

		if(fire_count <= enemy_tile.current_cycle)
			continue
		enemy_tile.archive()

		var/should_share_air = FALSE
		var/datum/gas_mixture/enemy_air = enemy_tile.air

		var/datum/excited_group/enemy_excited_group = enemy_tile.excited_group

		if(our_excited_group && enemy_excited_group)
			if(our_excited_group != enemy_excited_group)
				our_excited_group.merge_groups(enemy_excited_group)
				our_excited_group = excited_group
			should_share_air = TRUE

		else if(our_air.compare(enemy_air))
			if(!enemy_tile.excited)
				SSair.add_to_active(enemy_tile)
			var/datum/excited_group/EG = our_excited_group || enemy_excited_group || new
			if(!our_excited_group)
				EG.add_turf(src)
			if(!enemy_excited_group)
				EG.add_turf(enemy_tile)
			our_excited_group = excited_group
			should_share_air = TRUE

		if(should_share_air)
			var/difference = our_air.share(enemy_air, adjacent_turfs_length)
			if(difference)
				if(difference > 0)
					consider_pressure_difference(enemy_tile, difference)
				else
					enemy_tile.consider_pressure_difference(src, -difference)
			LAST_SHARE_CHECK

	//if (planet_atmos)
	//	var/datum/gas_mixture/G = new
	//	G.copy_from_turf(src)
	//	G.archive()
	//	if(our_air.compare(G))
	//		if(!our_excited_group)
	//			var/datum/excited_group/EG = new
	//			EG.add_turf(src)
	//			our_excited_group = excited_group
	//		our_air.share(G, adjacent_turfs_length)
	//		LAST_SHARE_CHECK

	our_air.react(src)

	update_visuals()

	if((!our_excited_group && !(our_air.temperature > MINIMUM_TEMPERATURE_START_SUPERCONDUCTION && consider_superconductivity(starting = TRUE))) \
	|| (cached_atmos_cooldown > (EXCITED_GROUP_DISMANTLE_CYCLES * 2)))
		SSair.remove_from_active(src)

	atmos_cooldown = cached_atmos_cooldown

/turf/open/proc/consider_pressure_difference(turf/T, difference)
	SSair.high_pressure_delta |= src
	if(difference > pressure_difference)
		pressure_direction = get_dir(src, T)
		pressure_difference = difference

/turf/open/proc/high_pressure_movements()
	var/atom/movable/M
	for(var/thing in src)
		M = thing
		if (!M.anchored && !M.pulledby && M.last_high_pressure_movement_air_cycle < SSair.times_fired)
			M.experience_pressure_difference(pressure_difference, pressure_direction)

/atom/movable/var/pressure_resistance = 10
/atom/movable/var/last_high_pressure_movement_air_cycle = 0

/atom/movable/proc/experience_pressure_difference(pressure_difference, direction, pressure_resistance_prob_delta = 0)
	var/const/PROBABILITY_OFFSET = 25
	var/const/PROBABILITY_BASE_PRECENT = 75
	var/max_force = sqrt(pressure_difference)*(MOVE_FORCE_DEFAULT / 5)
	set waitfor = 0
	var/move_prob = 100
	if (pressure_resistance > 0)
		move_prob = (pressure_difference/pressure_resistance*PROBABILITY_BASE_PRECENT)-PROBABILITY_OFFSET
	move_prob += pressure_resistance_prob_delta
	if (move_prob > PROBABILITY_OFFSET && prob(move_prob) && (move_resist != INFINITY) && (!anchored && (max_force >= (move_resist * MOVE_FORCE_PUSH_RATIO))) || (anchored && (max_force >= (move_resist * MOVE_FORCE_FORCEPUSH_RATIO))))
		step(src, direction)
		last_high_pressure_movement_air_cycle = SSair.times_fired

/datum/excited_group
	var/list/turf_list = list()
	var/breakdown_cooldown = 0
	var/dismantle_cooldown = 0

/datum/excited_group/New()
	SSair.excited_groups += src

/datum/excited_group/proc/add_turf(turf/open/T)
	turf_list += T
	T.excited_group = src
	reset_cooldowns()

/datum/excited_group/proc/merge_groups(datum/excited_group/E)
	if(turf_list.len > E.turf_list.len)
		SSair.excited_groups -= E
		for(var/t in E.turf_list)
			var/turf/open/T = t
			T.excited_group = src
			turf_list += T
		reset_cooldowns()
	else
		SSair.excited_groups -= src
		for(var/t in turf_list)
			var/turf/open/T = t
			T.excited_group = E
			E.turf_list += T
		E.reset_cooldowns()

/datum/excited_group/proc/reset_cooldowns()
	breakdown_cooldown = 0
	dismantle_cooldown = 0

/datum/excited_group/proc/self_breakdown(space_is_all_consuming = FALSE)
	var/datum/gas_mixture/A = new

	var/list/A_gases = A.gases
	var/list/turf_list = src.turf_list
	var/turflen = turf_list.len
	var/space_in_group = FALSE

	for(var/t in turf_list)
		var/turf/open/T = t
		if (space_is_all_consuming && !space_in_group && istype(T.air, /datum/gas_mixture/immutable/space))
			space_in_group = TRUE
			qdel(A)
			A = new /datum/gas_mixture/immutable/space()
			A_gases = A.gases
			break
		A.merge(T.air)

	for(var/id in A_gases)
		A_gases[id][MOLES] /= turflen

	for(var/t in turf_list)
		var/turf/open/T = t
		T.air.copy_from(A)
		T.atmos_cooldown = 0
		T.update_visuals()

	breakdown_cooldown = 0

/datum/excited_group/proc/dismantle()
	for(var/t in turf_list)
		var/turf/open/T = t
		T.excited = FALSE
		T.excited_group = null
		SSair.active_turfs -= T
	garbage_collect()

/datum/excited_group/proc/garbage_collect()
	for(var/t in turf_list)
		var/turf/open/T = t
		T.excited_group = null
	turf_list.Cut()
	SSair.excited_groups -= src

/turf/proc/consider_superconductivity()
	if(!thermal_conductivity)
		return FALSE

	SSair.active_super_conductivity |= src
	return TRUE

/turf/open/consider_superconductivity(starting)
	if(air.temperature < (starting?MINIMUM_TEMPERATURE_START_SUPERCONDUCTION:MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION))
		return FALSE
	if(air.heat_capacity() < M_CELL_WITH_RATIO)
		return FALSE
	return ..()

/turf/closed/consider_superconductivity(starting)
	if(temperature < (starting?MINIMUM_TEMPERATURE_START_SUPERCONDUCTION:MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION))
		return FALSE
	return ..()