/proc/create_all_lighting_objects()
	//for(var/area/A in world)
	//	if(!IS_DYNAMIC_LIGHTING(A))
	//		continue

	//	for(var/turf/T in A)

	//		if(!IS_DYNAMIC_LIGHTING(T))
	//			continue

	//		new/atom/movable/lighting_object(T)
	//		CHECK_TICK
	//	CHECK_TICK
	//not_actual
	for(var/turf/T in world)
		var/area/a = T.loc
		if(!IS_DYNAMIC_LIGHTING(T) || !IS_DYNAMIC_LIGHTING(a))
			continue
		
		new/atom/movable/lighting_object(T)
		CHECK_TICK