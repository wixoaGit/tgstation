/obj/effect/decal
	name = "decal"
	plane = FLOOR_PLANE
	anchored = TRUE
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/turf_loc_check = TRUE

/obj/effect/decal/Initialize()
	. = ..()
	if(turf_loc_check && (!isturf(loc) || NeverShouldHaveComeHere(loc)))
		return INITIALIZE_HINT_QDEL

/obj/effect/decal/proc/NeverShouldHaveComeHere(turf/T)
	//return isclosedturf(T) || isgroundlessturf(T)
	return isclosedturf(T)//not_actual

/obj/effect/turf_decal
	icon = 'icons/turf/decals.dmi'
	icon_state = "warningline"
	layer = TURF_DECAL_LAYER

/obj/effect/turf_decal/Initialize()
	..()
	//not_actual
	var/turf/T = get_turf(src)
	var/image/_image = image(icon, null, icon_state, layer, dir)
	_image.color = color
	_image.alpha = alpha
	T.add_overlay(_image)
	return INITIALIZE_HINT_QDEL