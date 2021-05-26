/obj/effect/decal/cleanable
	gender = PLURAL
	layer = ABOVE_NORMAL_TURF_LAYER
	var/list/random_icon_states = null
	var/blood_state = ""
	var/bloodiness = 0
	var/mergeable_decal = TRUE

/obj/effect/decal/cleanable/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	if (random_icon_states && (icon_state == initial(icon_state)) && length(random_icon_states) > 0)
		icon_state = pick(random_icon_states)
	create_reagents(300)
	if(loc && isturf(loc))
		for(var/obj/effect/decal/cleanable/C in loc)
			if(C != src && C.type == type && !QDELETED(C))
				if (replace_decal(C))
					return INITIALIZE_HINT_QDEL

	//if(LAZYLEN(diseases))
	//	var/list/datum/disease/diseases_to_add = list()
	//	for(var/datum/disease/D in diseases)
	//		if(D.spread_flags & DISEASE_SPREAD_CONTACT_FLUIDS)
	//			diseases_to_add += D
	//	if(LAZYLEN(diseases_to_add))
	//		AddComponent(/datum/component/infective, diseases_to_add)

/obj/effect/decal/cleanable/proc/replace_decal(obj/effect/decal/cleanable/C)
	if(mergeable_decal)
		return TRUE