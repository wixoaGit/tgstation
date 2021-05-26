#define RANGE_TURFS(RADIUS, CENTER) \
  block( \
    locate(max(CENTER.x-(RADIUS),1),          max(CENTER.y-(RADIUS),1),          CENTER.z), \
    locate(min(CENTER.x+(RADIUS),world.maxx), min(CENTER.y+(RADIUS),world.maxy), CENTER.z) \
  )

/proc/get_area(atom/A)
	if(isarea(A))
		return A
	var/turf/T = get_turf(A)
	return T ? T.loc : null

/proc/get_area_name(atom/X, format_text = FALSE)
	var/area/A = isarea(X) ? X : get_area(X)
	if(!A)
		return null
	return format_text ? format_text(A.name) : A.name

/proc/cheap_hypotenuse(Ax,Ay,Bx,By)
	return sqrt(abs(Ax - Bx)**2 + abs(Ay - By)**2)

/proc/get_dist_euclidian(atom/Loc1 as turf|mob|obj,atom/Loc2 as turf|mob|obj)
	var/dx = Loc1.x - Loc2.x
	var/dy = Loc1.y - Loc2.y

	var/dist = sqrt(dx**2 + dy**2)

	return dist

/proc/get_hearers_in_view(R, atom/source)
	var/turf/T = get_turf(source)
	. = list()

	if(!T)
		return

	var/list/processing_list = list()
	if (R == 0)
		processing_list += T.contents
	else
		//var/lum = T.luminosity
		//T.luminosity = 6
		for(var/mob/M in view(R, T))
			processing_list += M
		for(var/obj/O in view(R, T))
			processing_list += O
		//T.luminosity = lum

	while(processing_list.len)
		var/atom/A = processing_list[1]
		if(A.flags_1 & HEAR_1)
			. += A
		processing_list.Cut(1, 2)
		processing_list += A.contents

/proc/get_mobs_in_radio_ranges(list/obj/item/radio/radios)
	. = list()
	for(var/obj/item/radio/R in radios)
		if(R)
			. |= get_hearers_in_view(R.canhear_range, R)

/proc/considered_alive(datum/mind/M, enforce_human = TRUE)
	if(M && M.current)
		if(enforce_human)
			var/mob/living/carbon/human/H
			if(ishuman(M.current))
				H = M.current
			return M.current.stat != DEAD && !issilicon(M.current) && !isbrain(M.current) && (!H || H.dna.species.id != "memezombies")
		else if(isliving(M.current))
			return M.current.stat != DEAD
	return FALSE

/proc/considered_afk(datum/mind/M)
	//return !M || !M.current || !M.current.client || M.current.client.is_afk()
	return !M || !M.current || !M.current.client//not_actual

/proc/remove_images_from_clients(image/I, list/show_to)
	for(var/client/C in show_to)
		C.images -= I

/proc/flick_overlay(image/I, list/show_to, duration)
	for(var/client/C in show_to)
		C.images += I
	addtimer(CALLBACK(GLOBAL_PROC, /proc/remove_images_from_clients, I, show_to), duration, TIMER_CLIENT_TIME)

/proc/AnnounceArrival(var/mob/living/carbon/human/character, var/rank)
	if(!SSticker.IsRoundInProgress() || QDELETED(character))
		return
	var/area/A = get_area(character)
	var/message = "<span class='game deadsay'><span class='name'>\
		[character.real_name]</span> ([rank]) has arrived at the station at \
		<span class='name'>[A.name]</span>.</span>"
	deadchat_broadcast(message, follow_target = character, message_type=DEADCHAT_ARRIVALRATTLE)
	if((!GLOB.announcement_systems.len) || (!character.mind))
		return
	if((character.mind.assigned_role == "Cyborg") || (character.mind.assigned_role == character.mind.special_role))
		return

	var/obj/machinery/announcement_system/announcer = pick(GLOB.announcement_systems)
	announcer.announce("ARRIVAL", character.real_name, rank, list())

///proc/GetRedPart(const/hexa)
/proc/GetRedPart(var/hexa)//not_actual
	return hex2num(copytext(hexa, 2, 4))

///proc/GetGreenPart(const/hexa)
/proc/GetGreenPart(var/hexa)//not_actual
	return hex2num(copytext(hexa, 4, 6))

///proc/GetBluePart(const/hexa)
/proc/GetBluePart(var/hexa)//not_actual
	return hex2num(copytext(hexa, 6, 8))