/area/shuttle/auxillary_base
	name = "Auxillary Base"
	luminosity = 0

/obj/docking_port/mobile/auxillary_base
	name = "auxillary base"
	id = "colony_drop"
	dheight = 4
	dwidth = 4
	width = 9
	height = 9

/obj/docking_port/mobile/auxillary_base/takeoff(list/old_turfs, list/new_turfs, list/moved_atoms, rotation, movement_direction, old_dock, area/underlying_old_area)
	for(var/i in new_turfs)
		var/turf/place = i
		if(istype(place, /turf/closed/mineral))
			place.ScrapeAway()
	return ..()

/obj/docking_port/stationary/public_mining_dock
	name = "public mining base dock"
	id = "disabled"
	dwidth = 3
	width = 7
	height = 5
	area_type = /area/construction/mining/aux_base