/obj/docking_port/mobile/assault_pod
	name = "assault pod"
	id = "steel_rain"
	dwidth = 3
	width = 7
	height = 7

///obj/docking_port/mobile/assault_pod/request(obj/docking_port/stationary/S)
//	if(!(z in SSmapping.levels_by_trait(ZTRAIT_STATION)))
//		return ..()


/obj/docking_port/mobile/assault_pod/initiate_docking(obj/docking_port/stationary/S1)
	. = ..()
	if(!istype(S1, /obj/docking_port/stationary/transit))
		playsound(get_turf(src.loc), 'sound/effects/explosion1.ogg',50,1)