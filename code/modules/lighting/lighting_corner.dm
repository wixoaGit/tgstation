GLOBAL_LIST_INIT(LIGHTING_CORNER_DIAGONAL, list(NORTHEAST, SOUTHEAST, SOUTHWEST, NORTHWEST))

/datum/lighting_corner
	var/list/turf/masters
	var/list/datum/light_source/affecting
	var/active                            = FALSE

	var/x     = 0
	var/y     = 0
	var/z     = 0

	var/lum_r = 0
	var/lum_g = 0
	var/lum_b = 0

	var/needs_update = FALSE

	var/cache_r  = LIGHTING_SOFT_THRESHOLD
	var/cache_g  = LIGHTING_SOFT_THRESHOLD
	var/cache_b  = LIGHTING_SOFT_THRESHOLD
	var/cache_mx = 0

/datum/lighting_corner/New(var/turf/new_turf, var/diagonal)
	. = ..()
	masters = list()
	masters[new_turf] = turn(diagonal, 180)
	z = new_turf.z

	var/vertical   = diagonal & ~(diagonal - 1)
	var/horizontal = diagonal & ~vertical

	x = new_turf.x + (horizontal == EAST  ? 0.5 : -0.5)
	y = new_turf.y + (vertical   == NORTH ? 0.5 : -0.5)

	var/turf/T
	var/i

	T = get_step(new_turf, diagonal)
	if (T)
		if (!T.corners)
			T.corners = list(null, null, null, null)

		masters[T]   = diagonal
		i            = GLOB.LIGHTING_CORNER_DIAGONAL.Find(turn(diagonal, 180))
		T.corners[i] = src

	T = get_step(new_turf, horizontal)
	if (T)
		if (!T.corners)
			T.corners = list(null, null, null, null)

		masters[T]   = ((T.x > x) ? EAST : WEST) | ((T.y > y) ? NORTH : SOUTH)
		i            = GLOB.LIGHTING_CORNER_DIAGONAL.Find(turn(masters[T], 180))
		T.corners[i] = src

	T = get_step(new_turf, vertical)
	if (T)
		if (!T.corners)
			T.corners = list(null, null, null, null)

		masters[T]   = ((T.x > x) ? EAST : WEST) | ((T.y > y) ? NORTH : SOUTH)
		i            = GLOB.LIGHTING_CORNER_DIAGONAL.Find(turn(masters[T], 180))
		T.corners[i] = src

	update_active()

/datum/lighting_corner/proc/update_active()
	active = FALSE
	var/turf/T
	var/thing
	for (thing in masters)
		T = thing
		if (T.lighting_object)
			active = TRUE

/datum/lighting_corner/proc/update_lumcount(var/delta_r, var/delta_g, var/delta_b)
	if ((abs(delta_r)+abs(delta_g)+abs(delta_b)) == 0)
		return

	lum_r += delta_r
	lum_g += delta_g
	lum_b += delta_b

	if (!needs_update)
		needs_update = TRUE
		GLOB.lighting_update_corners += src

/datum/lighting_corner/proc/update_objects()
	var/lum_r = src.lum_r
	var/lum_g = src.lum_g
	var/lum_b = src.lum_b
	var/mx = max(lum_r, lum_g, lum_b)
	. = 1
	if (mx > 1)
		. = 1 / mx

	//#if LIGHTING_SOFT_THRESHOLD != 0
	//else if (mx < LIGHTING_SOFT_THRESHOLD)
	//	. = 0

	//cache_r  = round(lum_r * ., LIGHTING_ROUND_VALUE) || LIGHTING_SOFT_THRESHOLD
	//cache_g  = round(lum_g * ., LIGHTING_ROUND_VALUE) || LIGHTING_SOFT_THRESHOLD
	//cache_b  = round(lum_b * ., LIGHTING_ROUND_VALUE) || LIGHTING_SOFT_THRESHOLD
	//#else
	cache_r  = round(lum_r * ., LIGHTING_ROUND_VALUE)
	cache_g  = round(lum_g * ., LIGHTING_ROUND_VALUE)
	cache_b  = round(lum_b * ., LIGHTING_ROUND_VALUE)
	//#endif
	cache_mx = round(mx, LIGHTING_ROUND_VALUE)

	for (var/TT in masters)
		var/turf/T = TT
		if (T.lighting_object)
			if (!T.lighting_object.needs_update)
				T.lighting_object.needs_update = TRUE
				GLOB.lighting_update_objects += T.lighting_object

/datum/lighting_corner/dummy/New()
	return


/datum/lighting_corner/Destroy(var/force)
	if (!force)
		return QDEL_HINT_LETMELIVE

	stack_trace("Ok, Look, /tg/, I need you to find whatever fucker decided to call qdel on a fucking lighting corner, then tell him very nicely and politely that he is 100% retarded and needs his head checked. Thanks. Send them my regards by the way.")

	return ..()