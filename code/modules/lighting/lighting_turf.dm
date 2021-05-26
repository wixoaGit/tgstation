/turf
	var/dynamic_lighting = TRUE
	luminosity           = 1

	var/tmp/lighting_corners_initialised = FALSE

	//var/tmp/list/datum/light_source/affecting_lights
	var/list/datum/light_source/affecting_lights //not_actual
	//var/tmp/atom/movable/lighting_object/lighting_object
	var/atom/movable/lighting_object/lighting_object //not_actual
	//var/tmp/list/datum/lighting_corner/corners
	var/list/datum/lighting_corner/corners //not_actual
	var/tmp/has_opaque_atom = FALSE

/turf/proc/reconsider_lights()
	var/datum/light_source/L
	var/thing
	for (thing in affecting_lights)
		L = thing
		L.vis_update()

/turf/proc/recalc_atom_opacity()
	has_opaque_atom = opacity
	if (!has_opaque_atom)
		for (var/atom/A in src.contents)
			if (A.opacity)
				has_opaque_atom = TRUE
				break

/turf/Exited(atom/movable/Obj, atom/newloc)
	. = ..()

	if (Obj && Obj.opacity)
		recalc_atom_opacity()
		reconsider_lights()

/turf/proc/change_area(var/area/old_area, var/area/new_area)
	//if(SSlighting.initialized)
	//	if (new_area.dynamic_lighting != old_area.dynamic_lighting)
	//		if (new_area.dynamic_lighting)
	//			lighting_build_overlay()
	//		else
	//			lighting_clear_overlay()

/turf/proc/get_corners()
	if (!IS_DYNAMIC_LIGHTING(src) && !light_sources)
		return null
	if (!lighting_corners_initialised)
		generate_missing_corners()
	if (has_opaque_atom)
		return null

	return corners

/turf/proc/generate_missing_corners()
	if (!IS_DYNAMIC_LIGHTING(src) && !light_sources)
		return
	lighting_corners_initialised = TRUE
	if (!corners)
		corners = list(null, null, null, null)

	//for (var/i = 1 to 4)
	for (var/i = 1, i<=4, i++)//not_actual
		if (corners[i])
			continue

		corners[i] = new/datum/lighting_corner(src, GLOB.LIGHTING_CORNER_DIAGONAL[i])