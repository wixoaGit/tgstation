/atom/movable/lighting_object
	name          = ""

	anchored      = TRUE

	icon             = LIGHTING_ICON
	icon_state       = "transparent"
	//color            = LIGHTING_BASE_MATRIX
	plane            = LIGHTING_PLANE
	//mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer            = LIGHTING_LAYER
	//invisibility     = INVISIBILITY_LIGHTING

	var/needs_update = FALSE
	var/turf/myturf

/atom/movable/lighting_object/Initialize(mapload)
	. = ..()
	verbs.Cut()


	myturf = loc
	if (myturf.lighting_object)
		qdel(myturf.lighting_object, force = TRUE)
	myturf.lighting_object = src
	myturf.luminosity = 0

	for(var/turf/open/space/S in RANGE_TURFS(1, src))
		S.update_starlight()

	needs_update = TRUE
	GLOB.lighting_update_objects += src

/atom/movable/lighting_object/Destroy(var/force)
	if (force)
		GLOB.lighting_update_objects     -= src
		if (loc != myturf)
			var/turf/oldturf = get_turf(myturf)
			var/turf/newturf = get_turf(loc)
			stack_trace("A lighting object was qdeleted with a different loc then it is suppose to have ([COORD(oldturf)] -> [COORD(newturf)])")
		if (isturf(myturf))
			myturf.lighting_object = null
			myturf.luminosity = 1
		myturf = null

		return ..()

	else
		return QDEL_HINT_LETMELIVE

/atom/movable/lighting_object/proc/update()
	if (loc != myturf)
		if (loc)
			var/turf/oldturf = get_turf(myturf)
			var/turf/newturf = get_turf(loc)
			//warning("A lighting object realised it's loc had changed in update() ([myturf]\[[myturf ? myturf.type : "null"]]([COORD(oldturf)]) -> [loc]\[[ loc ? loc.type : "null"]]([COORD(newturf)]))!")

		qdel(src, TRUE)
		return

	//var/static/datum/lighting_corner/dummy/dummy_lighting_corner = new
	var/datum/lighting_corner/dummy/dummy_lighting_corner = new//not_actual

	var/list/corners = myturf.corners
	var/datum/lighting_corner/cr = dummy_lighting_corner
	var/datum/lighting_corner/cg = dummy_lighting_corner
	var/datum/lighting_corner/cb = dummy_lighting_corner
	var/datum/lighting_corner/ca = dummy_lighting_corner
	if (corners)
		cr = corners[3] || dummy_lighting_corner
		cg = corners[2] || dummy_lighting_corner
		cb = corners[4] || dummy_lighting_corner
		ca = corners[1] || dummy_lighting_corner

	var/max = max(cr.cache_mx, cg.cache_mx, cb.cache_mx, ca.cache_mx)

	var/rr = cr.cache_r
	var/rg = cr.cache_g
	var/rb = cr.cache_b

	var/gr = cg.cache_r
	var/gg = cg.cache_g
	var/gb = cg.cache_b

	var/br = cb.cache_r
	var/bg = cb.cache_g
	var/bb = cb.cache_b

	var/ar = ca.cache_r
	var/ag = ca.cache_g
	var/ab = ca.cache_b

	//#if LIGHTING_SOFT_THRESHOLD != 0
	//var/set_luminosity = max > LIGHTING_SOFT_THRESHOLD
	//#else
	var/set_luminosity = max > 1e-6
	//#endif

	if((rr & gr & br & ar) && (rg + gg + bg + ag + rb + gb + bb + ab == 8))
		icon_state = "transparent"
		color = null
	else if(!set_luminosity)
		icon_state = "dark"
		color = null
	else
		icon_state = null
		//color = list(
		//	rr, rg, rb, 00,
		//	gr, gg, gb, 00,
		//	br, bg, bb, 00,
		//	ar, ag, ab, 00,
		//	00, 00, 00, 01
		//)

	luminosity = set_luminosity

/atom/movable/lighting_object/ex_act(severity)
	return 0

///atom/movable/lighting_object/singularity_act()
//	return

///atom/movable/lighting_object/singularity_pull()
//	return

///atom/movable/lighting_object/blob_act()
//	return

/atom/movable/lighting_object/onTransitZ()
	return

/atom/movable/lighting_object/forceMove(atom/destination, var/no_tp=FALSE, var/harderforce = FALSE)
	if(harderforce)
		. = ..()