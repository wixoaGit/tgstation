/obj/machinery/camera/autoname
	var/number = 0

/obj/machinery/camera/autoname/Initialize()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/camera/autoname/LateInitialize()
	. = ..()
	number = 1
	//var/area/A = get_area(src)
	//if(A)
	//	for(var/obj/machinery/camera/autoname/C in GLOB.machines)
	//		if(C == src)
	//			continue
	//		var/area/CA = get_area(C)
	//		if(CA.type == A.type)
	//			if(C.number)
	//				number = max(number, C.number+1)
	//	c_tag = "[A.name] #[number]"