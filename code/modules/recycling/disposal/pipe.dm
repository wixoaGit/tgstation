/obj/structure/disposalpipe
	name = "disposal pipe"
	desc = "An underfloor disposal pipe."
	icon = 'icons/obj/atmospherics/pipes/disposal.dmi'
	anchored = TRUE
	density = FALSE
	obj_flags = CAN_BE_HIT | ON_BLUEPRINTS
	level = 1
	dir = NONE
	max_integrity = 200
	armor = list("melee" = 25, "bullet" = 10, "laser" = 10, "energy" = 100, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 30)
	layer = DISPOSAL_PIPE_LAYER
	//rad_flags = RAD_PROTECT_CONTENTS | RAD_NO_CONTAMINATE
	var/dpdir = NONE
	var/initialize_dirs = NONE
	var/flip_type
	var/obj/structure/disposalconstruct/stored

/obj/structure/disposalpipe/Initialize(mapload, obj/structure/disposalconstruct/make_from)
	. = ..()

	if(!QDELETED(make_from))
		setDir(make_from.dir)
		make_from.forceMove(src)
		stored = make_from
	else
		stored = new /obj/structure/disposalconstruct(src, null , SOUTH , FALSE , src)

	if(dir in GLOB.diagonals)
		initialize_dirs = NONE

	if(initialize_dirs != DISP_DIR_NONE)
		dpdir = dir

		if(initialize_dirs & DISP_DIR_LEFT)
			dpdir |= turn(dir, 90)
		if(initialize_dirs & DISP_DIR_RIGHT)
			dpdir |= turn(dir, -90)
		if(initialize_dirs & DISP_DIR_FLIP)
			dpdir |= turn(dir, 180)
	update()

/obj/structure/disposalpipe/Destroy()
	var/obj/structure/disposalholder/H = locate() in src
	if(H)
		H.active = FALSE
		expel(H, get_turf(src), 0)
	QDEL_NULL(stored)
	return ..()

/obj/structure/disposalpipe/proc/update()
	var/turf/T = get_turf(src)
	hide(T.intact && !isspaceturf(T))

/obj/structure/disposalpipe/hide(var/intact)
	invisibility = intact ? INVISIBILITY_MAXIMUM: 0

/obj/structure/disposalpipe/proc/expel(obj/structure/disposalholder/H, turf/T, direction)
	var/turf/target
	var/eject_range = 5
	var/turf/open/floor/floorturf

	if(isfloorturf(T))
		floorturf = T
		if(floorturf.floor_tile)
			new floorturf.floor_tile(T)
		floorturf.make_plating()

	if(direction)
		if(isspaceturf(T))
			target = get_edge_target_turf(T, direction)
		else
			target = get_ranged_target_turf(T, direction, 10)

		eject_range = 10

	else if(floorturf)
		target = get_offset_target_turf(T, rand(5)-rand(5), rand(5)-rand(5))

	playsound(src, 'sound/machines/hiss.ogg', 50, 0, 0)
	for(var/A in H)
		var/atom/movable/AM = A
		AM.forceMove(get_turf(src))
		AM.pipe_eject(direction)
		if(target)
			AM.throw_at(target, eject_range, 1)
	H.vent_gas(T)
	qdel(H)

/obj/structure/disposalpipe/contents_explosion(severity, target)
	var/obj/structure/disposalholder/H = locate() in src
	if(H)
		H.contents_explosion(severity, target)

/obj/structure/disposalpipe/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == "melee" && damage_amount < 10)
		return 0
	return ..()

/obj/structure/disposalpipe/welder_act(mob/living/user, obj/item/I)
	if(!can_be_deconstructed(user))
		return TRUE

	if(!I.tool_start_check(user, amount=0))
		return TRUE

	to_chat(user, "<span class='notice'>You start slicing [src]...</span>")
	if(I.use_tool(src, user, 30, volume=50))
		deconstruct()
		to_chat(user, "<span class='notice'>You slice [src].</span>")
	return TRUE

/obj/structure/disposalpipe/proc/can_be_deconstructed()
	return TRUE

/obj/structure/disposalpipe/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(disassembled)
			if(stored)
				stored.forceMove(loc)
				transfer_fingerprints_to(stored)
				stored.setDir(dir)
				stored = null
		else
			var/turf/T = get_turf(src)
			for(var/D in GLOB.cardinals)
				if(D & dpdir)
					var/obj/structure/disposalpipe/broken/P = new(T)
					P.setDir(D)
	qdel(src)

/obj/structure/disposalpipe/segment
	icon_state = "pipe"
	initialize_dirs = DISP_DIR_FLIP

/obj/structure/disposalpipe/junction
	icon_state = "pipe-j1"
	initialize_dirs = DISP_DIR_RIGHT | DISP_DIR_FLIP
	flip_type = /obj/structure/disposalpipe/junction/flip

/obj/structure/disposalpipe/junction/flip
	icon_state = "pipe-j2"
	initialize_dirs = DISP_DIR_LEFT | DISP_DIR_FLIP
	flip_type = /obj/structure/disposalpipe/junction

/obj/structure/disposalpipe/junction/yjunction
	icon_state = "pipe-y"
	initialize_dirs = DISP_DIR_LEFT | DISP_DIR_RIGHT
	flip_type = null

/obj/structure/disposalpipe/trunk
	icon_state = "pipe-t"
	var/obj/linked

/obj/structure/disposalpipe/broken
	desc = "A broken piece of disposal pipe."
	icon_state = "pipe-b"
	initialize_dirs = DISP_DIR_NONE

/obj/structure/disposalpipe/broken/deconstruct()
	qdel(src)