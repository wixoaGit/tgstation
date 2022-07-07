/proc/Get_Angle(atom/movable/start,atom/movable/end)
	if(!start || !end)
		return 0
	var/dy
	var/dx
	dy=(32*end.y+end.pixel_y)-(32*start.y+start.pixel_y)
	dx=(32*end.x+end.pixel_x)-(32*start.x+start.pixel_x)
	if(!dy)
		return (dx>=0)?90:270
	.=arctan(dx/dy)
	if(dy<0)
		.+=180
	else if(dx<0)
		.+=360

/proc/IsGuestKey(key)
	if (findtext(key, "Guest-", 1, 7) != 1)
		return 0

	var/i, ch, len = length(key)

	for (i = 7, i <= len, ++i)
		ch = text2ascii(key, i)
		if (ch < 48 || ch > 57)
			return 0
	return 1

/proc/DisplayPower(powerused)
	if(powerused < 1000)
		return "[powerused] W"
	else if(powerused < 1000000) 
		return "[round((powerused * 0.001),0.01)] kW"
	else if(powerused < 1000000000)
		return "[round((powerused * 0.000001),0.001)] MW"
	return "[round((powerused * 0.000000001),0.0001)] GW"

/proc/DisplayEnergy(units)
	units *= SSmachines.wait * 0.1 / GLOB.CELLRATE
	if (units < 1000)
		return "[round(units, 0.1)] J"
	else if (units < 1000000)
		return "[round(units * 0.001, 0.01)] kJ"
	else if (units < 1000000000)
		return "[round(units * 0.000001, 0.001)] MJ"
	return "[round(units * 0.000000001, 0.0001)] GJ"

/proc/get_edge_target_turf(atom/A, direction)
	var/turf/target = locate(A.x, A.y, A.z)
	if(!A || !target)
		return 0

	var/x = A.x
	var/y = A.y
	if(direction & NORTH)
		y = world.maxy
	else if(direction & SOUTH)
		y = 1
	if(direction & EAST)
		x = world.maxx
	else if(direction & WEST)
		x = 1
	if(direction in GLOB.diagonals)
		var/lowest_distance_to_map_edge = min(abs(x - A.x), abs(y - A.y))
		return get_ranged_target_turf(A, direction, lowest_distance_to_map_edge)
	return locate(x,y,A.z)

/proc/get_ranged_target_turf(atom/A, direction, range)

	var/x = A.x
	var/y = A.y
	if(direction & NORTH)
		y = min(world.maxy, y + range)
	else if(direction & SOUTH)
		y = max(1, y - range)
	if(direction & EAST)
		x = min(world.maxx, x + range)
	else if(direction & WEST)
		x = max(1, x - range)

	return locate(x,y,A.z)

/proc/get_offset_target_turf(atom/A, dx, dy)
	var/x = min(world.maxx, max(1, A.x + dx))
	var/y = min(world.maxy, max(1, A.y + dy))
	return locate(x,y,A.z)

/atom/proc/GetAllContents(var/T)
	var/list/processing_list = list(src)
	var/list/assembled = list()
	if(T)
		while(processing_list.len)
			var/atom/A = processing_list[1]
			processing_list.Cut(1, 2)
			processing_list += A.contents
			if(istype(A,T))
				assembled += A
	else
		while(processing_list.len)
			var/atom/A = processing_list[1]
			processing_list.Cut(1, 2)
			processing_list += A.contents
			assembled += A
	return assembled

/atom/proc/GetAllContentsIgnoring(list/ignore_typecache)
	if(!length(ignore_typecache))
		return GetAllContents()
	var/list/processing = list(src)
	var/list/assembled = list()
	while(processing.len)
		var/atom/A = processing[1]
		processing.Cut(1,2)
		if(!ignore_typecache[A.type])
			processing += A.contents
			assembled += A
	return assembled

/proc/is_blocked_turf(turf/T, exclude_mobs)
	if(T.density)
		return 1
	for(var/i in T)
		var/atom/A = i
		if(A.density && (!exclude_mobs || !ismob(A)))
			return 1
	return 0

/proc/repopulate_sorted_areas()
	GLOB.sortedAreas = list()

	for(var/area/A in world)
		GLOB.sortedAreas.Add(A)

	//sortTim(GLOB.sortedAreas, /proc/cmp_name_asc)

/proc/get_area_instance_from_text(areatext)
	if(istext(areatext))
		areatext = text2path(areatext)
	return GLOB.areas_by_type[areatext]

/proc/parse_zone(zone)
	if(zone == BODY_ZONE_PRECISE_R_HAND)
		return "right hand"
	else if (zone == BODY_ZONE_PRECISE_L_HAND)
		return "left hand"
	else if (zone == BODY_ZONE_L_ARM)
		return "left arm"
	else if (zone == BODY_ZONE_R_ARM)
		return "right arm"
	else if (zone == BODY_ZONE_L_LEG)
		return "left leg"
	else if (zone == BODY_ZONE_R_LEG)
		return "right leg"
	else if (zone == BODY_ZONE_PRECISE_L_FOOT)
		return "left foot"
	else if (zone == BODY_ZONE_PRECISE_R_FOOT)
		return "right foot"
	else
		return zone

/proc/get_turf_pixel(atom/AM)
	if(!istype(AM))
		return

	var/matrix/M = matrix(AM.transform)

	var/pixel_x_offset = AM.pixel_x + M.get_x_shift()
	var/pixel_y_offset = AM.pixel_y + M.get_y_shift()

	//var/icon/AMicon = icon(AM.icon, AM.icon_state)
	//var/AMiconheight = AMicon.Height()
	//var/AMiconwidth = AMicon.Width()
	//if(AMiconheight != world.icon_size || AMiconwidth != world.icon_size)
	//	pixel_x_offset += ((AMiconwidth/world.icon_size)-1)*(world.icon_size*0.5)
	//	pixel_y_offset += ((AMiconheight/world.icon_size)-1)*(world.icon_size*0.5)

	var/rough_x = round(round(pixel_x_offset,world.icon_size)/world.icon_size)
	var/rough_y = round(round(pixel_y_offset,world.icon_size)/world.icon_size)

	var/turf/T = get_turf(AM)
	if(!T)
		return null
	var/final_x = T.x + rough_x
	var/final_y = T.y + rough_y

	if(final_x || final_y)
		return locate(final_x, final_y, T.z)

/proc/gotwallitem(loc, dir, var/check_external = 0)
	//var/locdir = get_step(loc, dir)
	//for(var/obj/O in loc)
	//	if(is_type_in_typecache(O, GLOB.WALLITEMS) && check_external != 2)
	//		if(is_type_in_typecache(O, GLOB.WALLITEMS_INVERSE))
	//			if(O.dir == turn(dir, 180))
	//				return 1
	//		else if(O.dir == dir)
	//			return 1

	//		if(get_turf_pixel(O) == locdir)
	//			return 1

	//	if(is_type_in_typecache(O, GLOB.WALLITEMS_EXTERNAL) && check_external)
	//		if(is_type_in_typecache(O, GLOB.WALLITEMS_INVERSE))
	//			if(O.dir == turn(dir, 180))
	//				return 1
	//		else if(O.dir == dir)
	//			return 1

	//for(var/obj/O in locdir)
	//	if(is_type_in_typecache(O, GLOB.WALLITEMS) && check_external != 2)
	//		if(O.pixel_x == 0 && O.pixel_y == 0)
	//			return 1
	return 0

/proc/format_text(text)
	return replacetext(replacetext(text,"\proper ",""),"\improper ","")

/proc/urange(dist=0, atom/center=usr, orange=0, areas=0)
	if(!dist)
		if(!orange)
			return list(center)
		else
			return list()

	var/list/turfs = RANGE_TURFS(dist, center)
	if(orange)
		turfs -= get_turf(center)
	. = list()
	for(var/V in turfs)
		var/turf/T = V
		. += T
		. += T.contents
		if(areas)
			. |= T.loc

/proc/spiral_range_turfs(dist=0, center=usr, orange=0, list/outlist = list(), tick_checked)
	outlist.Cut()
	if(!dist)
		outlist += center
		return outlist

	var/turf/t_center = get_turf(center)
	if(!t_center)
		return outlist

	var/list/L = outlist
	var/turf/T
	var/y
	var/x
	var/c_dist = 1

	if(!orange)
		L += t_center

	while( c_dist <= dist )
		y = t_center.y + c_dist
		x = t_center.x - c_dist + 1
		for(x in x to t_center.x+c_dist)
			T = locate(x,y,t_center.z)
			if(T)
				L += T

		y = t_center.y + c_dist - 1
		x = t_center.x + c_dist
		for(y in t_center.y-c_dist to y)
			T = locate(x,y,t_center.z)
			if(T)
				L += T

		y = t_center.y - c_dist
		x = t_center.x + c_dist - 1
		for(x in t_center.x-c_dist to x)
			T = locate(x,y,t_center.z)
			if(T)
				L += T

		y = t_center.y - c_dist + 1
		x = t_center.x - c_dist
		for(y in y to t_center.y+c_dist)
			T = locate(x,y,t_center.z)
			if(T)
				L += T
		c_dist++
		if(tick_checked)
			CHECK_TICK

	return L

/atom/proc/contains(var/atom/A)
	if(!A)
		return 0
	for(var/atom/location = A.loc, location, location = location.loc)
		if(location == src)
			return 1

/proc/stack_trace(msg)
	CRASH(msg)

#define DELTA_CALC max(((max(TICK_USAGE, world.cpu) / 100) * max(Master.sleep_delta-1,1)), 1)

/proc/stoplag(initial_delay)
	if (!Master || !(Master.current_runlevel & RUNLEVELS_DEFAULT))
		sleep(world.tick_lag)
		return 1
	if (!initial_delay)
		initial_delay = world.tick_lag
	. = 0
	var/i = DS2TICKS(initial_delay)
	do
		. += CEILING(i*DELTA_CALC, 1)
		sleep(i*world.tick_lag*DELTA_CALC)
		i *= 2
	while (TICK_USAGE > min(TICK_LIMIT_TO_RUN, Master.current_ticklimit))

#undef DELTA_CALC

#define RANDOM_COLOUR (rgb(rand(0,255),rand(0,255),rand(0,255)))

/proc/weightclass2text(var/w_class)
	switch(w_class)
		if(WEIGHT_CLASS_TINY)
			. = "tiny"
		if(WEIGHT_CLASS_SMALL)
			. = "small"
		if(WEIGHT_CLASS_NORMAL)
			. = "normal-sized"
		if(WEIGHT_CLASS_BULKY)
			. = "bulky"
		if(WEIGHT_CLASS_HUGE)
			. = "huge"
		if(WEIGHT_CLASS_GIGANTIC)
			. = "gigantic"
		else
			. = ""

/proc/valid_window_location(turf/T, dir_to_check)
	if(!T)
		return FALSE
	for(var/obj/O in T)
		if(istype(O, /obj/machinery/door/window) && (O.dir == dir_to_check || dir_to_check == FULLTILE_WINDOW_DIR))
			return FALSE
		//if(istype(O, /obj/structure/windoor_assembly))
		//	var/obj/structure/windoor_assembly/W = O
		//	if(W.ini_dir == dir_to_check || dir_to_check == FULLTILE_WINDOW_DIR)
		//		return FALSE
		if(istype(O, /obj/structure/window))
			var/obj/structure/window/W = O
			if(W.ini_dir == dir_to_check || W.ini_dir == FULLTILE_WINDOW_DIR || dir_to_check == FULLTILE_WINDOW_DIR)
				return FALSE
	return TRUE

#define UNTIL(X) while(!(X)) stoplag()

/proc/pass()
	return

/proc/get_mob_or_brainmob(occupant)
	var/mob/living/mob_occupant

	if(isliving(occupant))
		mob_occupant = occupant

	//else if(isbodypart(occupant))
	//	var/obj/item/bodypart/head/head = occupant

	//	mob_occupant = head.brainmob

	//else if(isorgan(occupant))
	//	var/obj/item/organ/brain/brain = occupant
	//	mob_occupant = brain.brainmob

	return mob_occupant

/proc/REF(input)
	//if(istype(input, /datum))
	//	var/datum/thing = input
	//	if(thing.datum_flags & DF_USE_TAG)
	//		if(!thing.tag)
	//			stack_trace("A ref was requested of an object with DF_USE_TAG set but no tag: [thing]")
	//			thing.datum_flags &= ~DF_USE_TAG
	//		else
	//			return "\[[url_encode(thing.tag)]\]"
	return "\ref[input]"

/proc/generate_items_inside(list/items_list,var/where_to)
	for(var/each_item in items_list)
		for(var/i in 1 to items_list[each_item])
			new each_item(where_to)