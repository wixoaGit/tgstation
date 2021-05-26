/turf/open
	//plane = FLOOR_PLANE
	var/slowdown = 0

	var/postdig_icon_change = FALSE
	var/postdig_icon
	var/wet

	var/footstep = null
	var/barefootstep = null
	var/clawfootstep = null
	var/heavyfootstep = null

/turf/open/zPassIn(atom/movable/A, direction, turf/source)
	return (direction == DOWN)

/turf/open/zPassOut(atom/movable/A, direction, turf/destination)
	return (direction == UP)

/turf/open/zAirIn(direction, turf/source)
	return (direction == DOWN)

/turf/open/zAirOut(direction, turf/source)
	return (direction == UP)

/turf/open/indestructible
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = TRUE

/turf/open/indestructible/binary
	name = "tear in the fabric of reality"
	CanAtmosPass = ATMOS_PASS_NO
	baseturfs = /turf/open/indestructible/binary
	icon_state = "binary"
	footstep = null
	barefootstep = null
	clawfootstep = null
	heavyfootstep = null

/turf/open/indestructible/airblock
	icon_state = "bluespace"
	blocks_air = TRUE
	baseturfs = /turf/open/indestructible/airblock

/turf/open/Initalize_Atmos(times_fired)
	excited = 0
	update_visuals()

	current_cycle = times_fired
	CalculateAdjacentTurfs()
	for(var/i in atmos_adjacent_turfs)
		var/turf/open/enemy_tile = i
		var/datum/gas_mixture/enemy_air = enemy_tile.return_air()
		if(!excited && air.compare(enemy_air))
			excited = TRUE
			SSair.active_turfs |= src

/turf/open/proc/MakeSlippery(wet_setting = TURF_WET_WATER, min_wet_time = 0, wet_time_to_add = 0, max_wet_time = MAXIMUM_WET_TIME, permanent)
	//AddComponent(/datum/component/wet_floor, wet_setting, min_wet_time, wet_time_to_add, max_wet_time, permanent)

/turf/open/get_dumping_location()
	return src