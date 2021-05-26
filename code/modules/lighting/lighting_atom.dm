
/atom
	var/light_power = 1
	var/light_range = 0
	var/light_color

	//var/tmp/datum/light_source/light
	var/datum/light_source/light //not_actual
	//var/tmp/list/light_sources
	var/list/light_sources //not_actual

#define NONSENSICAL_VALUE -99999
/atom/proc/set_light(var/l_range, var/l_power, var/l_color = NONSENSICAL_VALUE)
	if(l_range > 0 && l_range < MINIMUM_USEFUL_LIGHT_RANGE)
		l_range = MINIMUM_USEFUL_LIGHT_RANGE
	if (l_power != null)
		light_power = l_power

	if (l_range != null)
		light_range = l_range

	if (l_color != NONSENSICAL_VALUE)
		light_color = l_color

	SEND_SIGNAL(src, COMSIG_ATOM_SET_LIGHT, l_range, l_power, l_color)

	update_light()

#undef NONSENSICAL_VALUE

/atom/proc/update_light()
	set waitfor = FALSE
	if (QDELETED(src))
		return

	if (!light_power || !light_range)
		QDEL_NULL(light)
	else
		if (!ismovableatom(loc))
			. = src
		else
			. = loc

		if (light)
			light.update(.)
		else
			light = new/datum/light_source(src, .)

/atom/movable/Destroy()
	var/turf/T = loc
	. = ..()
	if (opacity && istype(T))
		var/old_has_opaque_atom = T.has_opaque_atom
		T.recalc_atom_opacity()
		if (old_has_opaque_atom != T.has_opaque_atom)
			T.reconsider_lights()

/atom/movable/Moved(atom/OldLoc, Dir)
	. = ..()
	var/datum/light_source/L
	var/thing
	for (thing in light_sources)
		L = thing
		L.source_atom.update_light()