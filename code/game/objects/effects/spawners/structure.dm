/obj/effect/spawner/structure
	name = "map structure spawner"
	var/list/spawn_list

/obj/effect/spawner/structure/Initialize()
	. = ..()
	if(spawn_list && spawn_list.len)
		for(var/I in spawn_list)
			new I(get_turf(src))
	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/structure/window
	icon = 'icons/obj/structures_spawners.dmi'
	icon_state = "window_spawner"
	name = "window spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/fulltile)
	dir = SOUTH

/obj/effect/spawner/structure/window/reinforced
	name = "reinforced window spawner"
	icon_state = "rwindow_spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/fulltile)

/obj/effect/spawner/structure/window/shuttle
	name = "shuttle window spawner"
	icon_state = "swindow_spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/shuttle)

/obj/effect/spawner/structure/window/plasma
	name = "plasma window spawner"
	icon_state = "pwindow_spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma/fulltile)

/obj/effect/spawner/structure/window/plasma/reinforced
	name = "reinforced plasma window spawner"
	icon_state = "prwindow_spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma/reinforced/fulltile)