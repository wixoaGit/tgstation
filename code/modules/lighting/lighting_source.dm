/datum/light_source
	var/atom/top_atom
	var/atom/source_atom

	var/turf/source_turf
	var/turf/pixel_turf
	var/light_power
	var/light_range
	var/light_color

	var/lum_r
	var/lum_g
	var/lum_b

	//var/tmp/applied_lum_r
	var/applied_lum_r //not_actual
	//var/tmp/applied_lum_g
	var/applied_lum_g //not_actual
	//var/tmp/applied_lum_b
	var/applied_lum_b //not_actual

	var/list/datum/lighting_corner/effect_str
	var/list/turf/affecting_turfs

	var/applied = FALSE

	var/needs_update = LIGHTING_NO_UPDATE

/datum/light_source/New(var/atom/owner, var/atom/top)
	source_atom = owner
	LAZYADD(source_atom.light_sources, src)
	top_atom = top
	if (top_atom != source_atom)
		LAZYADD(top_atom.light_sources, src)

	source_turf = top_atom
	pixel_turf = get_turf_pixel(top_atom) || source_turf

	light_power = source_atom.light_power
	light_range = source_atom.light_range
	light_color = source_atom.light_color

	parse_light_color()

	update()

	return ..()

/datum/light_source/Destroy(force)
	remove_lum()
	if (source_atom)
		LAZYREMOVE(source_atom.light_sources, src)

	if (top_atom)
		LAZYREMOVE(top_atom.light_sources, src)

	if (needs_update)
		GLOB.lighting_update_lights -= src

	. = ..()

#define EFFECT_UPDATE(level)                \
	if (needs_update == LIGHTING_NO_UPDATE) \
		GLOB.lighting_update_lights += src; \
	if (needs_update < level)               \
		needs_update            = level;    \

//not_actual (this comment itself, necessary due to the last backslash in the above define)
/datum/light_source/proc/update(var/atom/new_top_atom)
	if (new_top_atom && new_top_atom != top_atom)
		if(top_atom != source_atom && top_atom.light_sources)
			LAZYREMOVE(top_atom.light_sources, src)

		top_atom = new_top_atom

		if (top_atom != source_atom)
			LAZYADD(top_atom.light_sources, src)

	EFFECT_UPDATE(LIGHTING_CHECK_UPDATE)

/datum/light_source/proc/vis_update()
	EFFECT_UPDATE(LIGHTING_VIS_UPDATE)

/datum/light_source/proc/parse_light_color()
	if (light_color)
		lum_r = GetRedPart   (light_color) / 255
		lum_g = GetGreenPart (light_color) / 255
		lum_b = GetBluePart  (light_color) / 255
	else
		lum_r = 1
		lum_g = 1
		lum_b = 1

#define LUM_FALLOFF(C, T) (1 - CLAMP01(sqrt((C.x - T.x) ** 2 + (C.y - T.y) ** 2 + LIGHTING_HEIGHT) / max(1, light_range)))

#define APPLY_CORNER(C)                      \
	. = LUM_FALLOFF(C, pixel_turf);          \
	. *= light_power;                        \
	var/OLD = effect_str[C];                 \
	effect_str[C] = .;                       \
                                             \
	C.update_lumcount                        \
	(                                        \
		(. * lum_r) - (OLD * applied_lum_r), \
		(. * lum_g) - (OLD * applied_lum_g), \
		(. * lum_b) - (OLD * applied_lum_b)  \
	);

#define REMOVE_CORNER(C)                     \
	. = -effect_str[C];                      \
	C.update_lumcount                        \
	(                                        \
		. * applied_lum_r,                   \
		. * applied_lum_g,                   \
		. * applied_lum_b                    \
	);

/datum/light_source/proc/remove_lum()
	applied = FALSE
	var/thing
	for (thing in affecting_turfs)
		var/turf/T = thing
		LAZYREMOVE(T.affecting_lights, src)

	affecting_turfs = null

	var/datum/lighting_corner/C
	for (thing in effect_str)
		C = thing
		REMOVE_CORNER(C)

		LAZYREMOVE(C.affecting, src)

	effect_str = null

/datum/light_source/proc/update_corners()
	var/update = FALSE
	var/atom/source_atom = src.source_atom

	if (QDELETED(source_atom))
		qdel(src)
		return

	if (source_atom.light_power != light_power)
		light_power = source_atom.light_power
		update = TRUE

	if (source_atom.light_range != light_range)
		light_range = source_atom.light_range
		update = TRUE

	if (!top_atom)
		top_atom = source_atom
		update = TRUE

	if (!light_range || !light_power)
		qdel(src)
		return

	if (isturf(top_atom))
		if (source_turf != top_atom)
			source_turf = top_atom
			pixel_turf = source_turf
			update = TRUE
	else if (top_atom.loc != source_turf)
		source_turf = top_atom.loc
		pixel_turf = get_turf_pixel(top_atom)
		update = TRUE
	else
		var/P = get_turf_pixel(top_atom)
		if (P != pixel_turf)
			pixel_turf = P
			update = TRUE

	if (!isturf(source_turf))
		if (applied)
			remove_lum()
		return

	if (light_range && light_power && !applied)
		update = TRUE

	if (source_atom.light_color != light_color)
		light_color = source_atom.light_color
		parse_light_color()
		update = TRUE

	else if (applied_lum_r != lum_r || applied_lum_g != lum_g || applied_lum_b != lum_b)
		update = TRUE

	if (update)
		needs_update = LIGHTING_CHECK_UPDATE
		applied = TRUE
	else if (needs_update == LIGHTING_CHECK_UPDATE)
		return

	var/list/datum/lighting_corner/corners = list()
	var/list/turf/turfs                    = list()
	var/thing
	var/datum/lighting_corner/C
	var/turf/T
	if (source_turf)
		var/oldlum = source_turf.luminosity
		source_turf.luminosity = CEILING(light_range, 1)
		for(T in view(CEILING(light_range, 1), source_turf))
			if (!isturf(T)) continue//not_actual
			for (thing in T.get_corners(source_turf))
				C = thing
				corners[C] = 0
			turfs += T
		source_turf.luminosity = oldlum

	LAZYINITLIST(affecting_turfs)
	var/list/L = turfs - affecting_turfs
	affecting_turfs += L
	for (thing in L)
		T = thing
		LAZYADD(T.affecting_lights, src)

	L = affecting_turfs - turfs
	affecting_turfs -= L
	for (thing in L)
		T = thing
		LAZYREMOVE(T.affecting_lights, src)

	LAZYINITLIST(effect_str)
	if (needs_update == LIGHTING_VIS_UPDATE)
		for (thing in  corners - effect_str)
			C = thing
			LAZYADD(C.affecting, src)
			if (!C.active)
				effect_str[C] = 0
				continue
			APPLY_CORNER(C)
	else
		L = corners - effect_str

		for (thing in L)
			C = thing
			LAZYADD(C.affecting, src)
			if (!C.active)
				effect_str[C] = 0
				continue
			APPLY_CORNER(C)

		for (thing in corners - L)
			C = thing
			if (!C.active)
				effect_str[C] = 0
				continue
			APPLY_CORNER(C)

	L = effect_str - corners
	for (thing in L)
		C = thing
		REMOVE_CORNER(C)
		LAZYREMOVE(C.affecting, src)
	effect_str -= L

	applied_lum_r = lum_r
	applied_lum_g = lum_g
	applied_lum_b = lum_b

	UNSETEMPTY(effect_str)
	UNSETEMPTY(affecting_turfs)

#undef EFFECT_UPDATE
#undef LUM_FALLOFF
#undef REMOVE_CORNER
#undef APPLY_CORNER