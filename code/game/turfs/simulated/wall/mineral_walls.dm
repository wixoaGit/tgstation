/turf/closed/wall/mineral
	name = "mineral wall"
	desc = "This shouldn't exist"
	icon_state = ""
	var/last_event = 0
	var/active = null
	canSmoothWith = null
	smooth = SMOOTH_TRUE

/turf/closed/wall/mineral/titanium
	name = "wall"
	desc = "A light-weight titanium wall used in shuttles."
	icon = 'icons/turf/walls/shuttle_wall.dmi'
	icon_state = "map-shuttle"
	explosion_block = 3
	flags_1 = CAN_BE_DIRTY_1 | CHECK_RICOCHET_1
	//sheet_type = /obj/item/stack/sheet/mineral/titanium
	smooth = SMOOTH_MORE|SMOOTH_DIAGONAL
	//canSmoothWith = list(/turf/closed/wall/mineral/titanium, /obj/machinery/door/airlock/shuttle, /obj/machinery/door/airlock, /obj/structure/window/shuttle, /obj/structure/shuttle/engine/heater, /obj/structure/falsewall/titanium)
	canSmoothWith = list(/turf/closed/wall/mineral/titanium, /obj/machinery/door/airlock, /obj/structure/window/shuttle)//not_actual

/turf/closed/wall/mineral/titanium/nodiagonal
	smooth = SMOOTH_MORE
	icon_state = "map-shuttle_nd"

/turf/closed/wall/mineral/titanium/nosmooth
	icon = 'icons/turf/shuttle.dmi'
	icon_state = "wall"
	smooth = SMOOTH_FALSE

/turf/closed/wall/mineral/titanium/overspace
	icon_state = "map-overspace"
	fixed_underlay = list("space"=1)

/turf/closed/wall/mineral/titanium/interior/copyTurf(turf/T)
	if(T.type != type)
		T.ChangeTurf(type)
		if(underlays.len)
			T.underlays = underlays
	if(T.icon_state != icon_state)
		T.icon_state = icon_state
	if(T.icon != icon)
		T.icon = icon
	if(color)
		//T.atom_colours = atom_colours.Copy()
		T.update_atom_colour()
	if(T.dir != dir)
		T.setDir(dir)
	T.transform = transform
	return T

/turf/closed/wall/mineral/titanium/copyTurf(turf/T)
	. = ..()
	T.transform = transform

/turf/closed/wall/mineral/titanium/survival
	name = "pod wall"
	desc = "An easily-compressable wall used for temporary shelter."
	icon = 'icons/turf/walls/survival_pod_walls.dmi'
	icon_state = "smooth"
	smooth = SMOOTH_MORE|SMOOTH_DIAGONAL
	//canSmoothWith = list(/turf/closed/wall/mineral/titanium/survival, /obj/machinery/door/airlock, /obj/structure/window/fulltile, /obj/structure/window/reinforced/fulltile, /obj/structure/window/reinforced/tinted/fulltile, /obj/structure/window/shuttle, /obj/structure/shuttle/engine)
	canSmoothWith = list(/turf/closed/wall/mineral/titanium/survival, /obj/machinery/door/airlock, /obj/structure/window/fulltile, /obj/structure/window/reinforced/fulltile, /obj/structure/window/shuttle)//not_actual

/turf/closed/wall/mineral/titanium/survival/nodiagonal
	smooth = SMOOTH_MORE

/turf/closed/wall/mineral/titanium/survival/pod
	//canSmoothWith = list(/turf/closed/wall/mineral/titanium/survival, /obj/machinery/door/airlock/survival_pod, /obj/structure/window/shuttle/survival_pod)
	canSmoothWith = list(/turf/closed/wall/mineral/titanium/survival)//not_actual

/turf/closed/wall/mineral/plastitanium
	name = "wall"
	desc = "A durable wall made of an alloy of plasma and titanium."
	icon = 'icons/turf/walls/plastitanium_wall.dmi'
	icon_state = "map-shuttle"
	explosion_block = 4
	sheet_type = /obj/item/stack/sheet/mineral/plastitanium
	smooth = SMOOTH_MORE|SMOOTH_DIAGONAL
	//canSmoothWith = list(/turf/closed/wall/mineral/plastitanium, /obj/machinery/door/airlock/shuttle, /obj/machinery/door/airlock, /obj/structure/window/plastitanium, /obj/structure/shuttle/engine, /obj/structure/falsewall/plastitanium)
	canSmoothWith = list(/turf/closed/wall/mineral/plastitanium, /obj/machinery/door/airlock, /obj/structure/window/plastitanium)//not_actual

/turf/closed/wall/mineral/plastitanium/nodiagonal
	smooth = SMOOTH_MORE
	icon_state = "map-shuttle_nd"

/turf/closed/wall/mineral/plastitanium/nosmooth
	icon = 'icons/turf/shuttle.dmi'
	icon_state = "wall"
	smooth = SMOOTH_FALSE

/turf/closed/wall/mineral/plastitanium/overspace
	icon_state = "map-overspace"
	fixed_underlay = list("space"=1)