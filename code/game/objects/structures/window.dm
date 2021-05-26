/obj/structure/window
	name = "window"
	desc = "A window."
	icon_state = "window"
	density = TRUE
	layer = ABOVE_OBJ_LAYER
	pressure_resistance = 4*ONE_ATMOSPHERE
	anchored = TRUE
	flags_1 = ON_BORDER_1
	max_integrity = 25
	can_be_unanchored = TRUE
	resistance_flags = ACID_PROOF
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 100)
	CanAtmosPass = ATMOS_PASS_PROC
	//rad_insulation = RAD_VERY_LIGHT_INSULATION
	//rad_flags = RAD_PROTECT_CONTENTS
	var/ini_dir = null
	var/state = WINDOW_OUT_OF_FRAME
	var/reinf = FALSE
	var/heat_resistance = 800
	var/decon_speed = 30
	var/wtype = "glass"
	var/fulltile = FALSE
	var/glass_type = /obj/item/stack/sheet/glass
	var/glass_amount = 1
	var/mutable_appearance/crack_overlay
	var/real_explosion_block
	var/breaksound = "shatter"
	var/hitsound = 'sound/effects/Glasshit.ogg'

/obj/structure/window/examine(mob/user)
	..()
	if(reinf)
		if(anchored && state == WINDOW_SCREWED_TO_FRAME)
			to_chat(user, "<span class='notice'>The window is <b>screwed</b> to the frame.</span>")
		else if(anchored && state == WINDOW_IN_FRAME)
			to_chat(user, "<span class='notice'>The window is <i>unscrewed</i> but <b>pried</b> into the frame.</span>")
		else if(anchored && state == WINDOW_OUT_OF_FRAME)
			to_chat(user, "<span class='notice'>The window is out of the frame, but could be <i>pried</i> in. It is <b>screwed</b> to the floor.</span>")
		else if(!anchored)
			to_chat(user, "<span class='notice'>The window is <i>unscrewed</i> from the floor, and could be deconstructed by <b>wrenching</b>.</span>")
	else
		if(anchored)
			to_chat(user, "<span class='notice'>The window is <b>screwed</b> to the floor.</span>")
		else
			to_chat(user, "<span class='notice'>The window is <i>unscrewed</i> from the floor, and could be deconstructed by <b>wrenching</b>.</span>")

/obj/structure/window/Initialize(mapload, direct)
	. = ..()
	if(direct)
		setDir(direct)
	if(reinf && anchored)
		state = WINDOW_SCREWED_TO_FRAME

	ini_dir = dir
	air_update_turf(1)

	if(fulltile)
		setDir()

	real_explosion_block = explosion_block
	explosion_block = EXPLOSION_BLOCK_PROC

/obj/structure/window/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/simple_rotation,ROTATION_ALTCLICK | ROTATION_CLOCKWISE | ROTATION_COUNTERCLOCKWISE | ROTATION_VERBS ,null,CALLBACK(src, .proc/can_be_rotated),CALLBACK(src,.proc/after_rotation))

/obj/structure/window/setDir(direct)
	if(!fulltile)
		..()
	else
		..(FULLTILE_WINDOW_DIR)

/obj/structure/window/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && (mover.pass_flags & PASSGLASS))
		return 1
	if(dir == FULLTILE_WINDOW_DIR)
		return 0
	if(get_dir(loc, target) == dir)
		return !density
	if(istype(mover, /obj/structure/window))
		var/obj/structure/window/W = mover
		if(!valid_window_location(loc, W.ini_dir))
			return FALSE
	//else if(istype(mover, /obj/structure/windoor_assembly))
	//	var/obj/structure/windoor_assembly/W = mover
	//	if(!valid_window_location(loc, W.ini_dir))
	//		return FALSE
	//else if(istype(mover, /obj/machinery/door/window) && !valid_window_location(loc, mover.dir))
	//	return FALSE
	return 1

/obj/structure/window/CheckExit(atom/movable/O, turf/target)
	if(istype(O) && (O.pass_flags & PASSGLASS))
		return 1
	if(get_dir(O.loc, target) == dir)
		return 0
	return 1

/obj/structure/window/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(!can_be_reached(user))
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message("[user] knocks on [src].")
	add_fingerprint(user)
	playsound(src, 'sound/effects/Glassknock.ogg', 50, 1)

/obj/structure/window/attackby(obj/item/I, mob/living/user, params)
	if(!can_be_reached(user))
		return 1

	add_fingerprint(user)

	if(I.tool_behaviour == TOOL_WELDER && user.a_intent == INTENT_HELP)
		if(obj_integrity < max_integrity)
			if(!I.tool_start_check(user, amount=0))
				return

			to_chat(user, "<span class='notice'>You begin repairing [src]...</span>")
			if(I.use_tool(src, user, 40, volume=50))
				obj_integrity = max_integrity
				update_nearby_icons()
				to_chat(user, "<span class='notice'>You repair [src].</span>")
		else
			to_chat(user, "<span class='warning'>[src] is already in good condition!</span>")
		return

	if(!(flags_1&NODECONSTRUCT_1))
		if(I.tool_behaviour == TOOL_SCREWDRIVER)
			I.play_tool_sound(src, 75)
			if(reinf)
				if(state == WINDOW_SCREWED_TO_FRAME || state == WINDOW_IN_FRAME)
					to_chat(user, "<span class='notice'>You begin to [state == WINDOW_SCREWED_TO_FRAME ? "unscrew the window from":"screw the window to"] the frame...</span>")
					if(I.use_tool(src, user, decon_speed, extra_checks = CALLBACK(src, .proc/check_state_and_anchored, state, anchored)))
						state = (state == WINDOW_IN_FRAME ? WINDOW_SCREWED_TO_FRAME : WINDOW_IN_FRAME)
						to_chat(user, "<span class='notice'>You [state == WINDOW_IN_FRAME ? "unfasten the window from":"fasten the window to"] the frame.</span>")
				else if(state == WINDOW_OUT_OF_FRAME)
					to_chat(user, "<span class='notice'>You begin to [anchored ? "unscrew the frame from":"screw the frame to"] the floor...</span>")
					if(I.use_tool(src, user, decon_speed, extra_checks = CALLBACK(src, .proc/check_state_and_anchored, state, anchored)))
						setAnchored(!anchored)
						to_chat(user, "<span class='notice'>You [anchored ? "fasten the frame to":"unfasten the frame from"] the floor.</span>")
			else
				to_chat(user, "<span class='notice'>You begin to [anchored ? "unscrew the window from":"screw the window to"] the floor...</span>")
				if(I.use_tool(src, user, decon_speed, extra_checks = CALLBACK(src, .proc/check_anchored, anchored)))
					setAnchored(!anchored)
					to_chat(user, "<span class='notice'>You [anchored ? "fasten the window to":"unfasten the window from"] the floor.</span>")
			return


		else if(I.tool_behaviour == TOOL_CROWBAR && reinf && (state == WINDOW_OUT_OF_FRAME || state == WINDOW_IN_FRAME))
			to_chat(user, "<span class='notice'>You begin to lever the window [state == WINDOW_OUT_OF_FRAME ? "into":"out of"] the frame...</span>")
			I.play_tool_sound(src, 75)
			if(I.use_tool(src, user, decon_speed, extra_checks = CALLBACK(src, .proc/check_state_and_anchored, state, anchored)))
				state = (state == WINDOW_OUT_OF_FRAME ? WINDOW_IN_FRAME : WINDOW_OUT_OF_FRAME)
				to_chat(user, "<span class='notice'>You pry the window [state == WINDOW_IN_FRAME ? "into":"out of"] the frame.</span>")
			return

		else if(I.tool_behaviour == TOOL_WRENCH && !anchored)
			I.play_tool_sound(src, 75)
			to_chat(user, "<span class='notice'> You begin to disassemble [src]...</span>")
			if(I.use_tool(src, user, decon_speed, extra_checks = CALLBACK(src, .proc/check_state_and_anchored, state, anchored)))
				var/obj/item/stack/sheet/G = new glass_type(user.loc, glass_amount)
				G.add_fingerprint(user)
				playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
				to_chat(user, "<span class='notice'>You successfully disassemble [src].</span>")
				qdel(src)
			return
	return ..()

/obj/structure/window/setAnchored(anchorvalue)
	..()
	air_update_turf(TRUE)
	update_nearby_icons()

/obj/structure/window/proc/check_state(checked_state)
	if(state == checked_state)
		return TRUE

/obj/structure/window/proc/check_anchored(checked_anchored)
	if(anchored == checked_anchored)
		return TRUE

/obj/structure/window/proc/check_state_and_anchored(checked_state, checked_anchored)
	return check_state(checked_state) && check_anchored(checked_anchored)

/obj/structure/window/proc/can_be_reached(mob/user)
	if(!fulltile)
		if(get_dir(user,src) & dir)
			for(var/obj/O in loc)
				if(!O.CanPass(user, user.loc, 1))
					return 0
	return 1

/obj/structure/window/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	. = ..()
	if(.)
		update_nearby_icons()

/obj/structure/window/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, hitsound, 75, 1)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			playsound(src, 'sound/items/Welder.ogg', 100, 1)

/obj/structure/window/deconstruct(disassembled = TRUE)
	if(QDELETED(src))
		return
	if(!disassembled)
		playsound(src, breaksound, 70, 1)
		if(!(flags_1 & NODECONSTRUCT_1))
			for(var/obj/item/shard/debris in spawnDebris(drop_location()))
				transfer_fingerprints_to(debris)
	qdel(src)
	update_nearby_icons()

/obj/structure/window/proc/spawnDebris(location)
	. = list()
	. += new /obj/item/shard(location)
	. += new /obj/effect/decal/cleanable/glass(location)
	if (reinf)
		. += new /obj/item/stack/rods(location, (fulltile ? 2 : 1))
	if (fulltile)
		. += new /obj/item/shard(location)

/obj/structure/window/proc/can_be_rotated(mob/user,rotation_type)
	if(anchored)
		to_chat(user, "<span class='warning'>[src] cannot be rotated while it is fastened to the floor!</span>")
		return FALSE

	var/target_dir = turn(dir, rotation_type == ROTATION_CLOCKWISE ? -90 : 90)

	if(!valid_window_location(loc, target_dir))
		to_chat(user, "<span class='warning'>[src] cannot be rotated in that direction!</span>")
		return FALSE
	return TRUE

/obj/structure/window/proc/after_rotation(mob/user,rotation_type)
	air_update_turf(1)
	ini_dir = dir
	add_fingerprint(user)

/obj/structure/window/Destroy()
	density = FALSE
	air_update_turf(1)
	update_nearby_icons()
	return ..()

/obj/structure/window/Move()
	var/turf/T = loc
	. = ..()
	setDir(ini_dir)
	move_update_air(T)

/obj/structure/window/CanAtmosPass(turf/T)
	if(!anchored || !density)
		return TRUE
	return !(FULLTILE_WINDOW_DIR == dir || dir == get_dir(loc, T))

/obj/structure/window/proc/update_nearby_icons()
	update_icon()
	if(smooth)
		queue_smooth_neighbors(src)

/obj/structure/window/update_icon()
	if(!QDELETED(src))
		if(!fulltile)
			return

		var/ratio = obj_integrity / max_integrity
		ratio = CEILING(ratio*4, 1) * 25

		if(smooth)
			queue_smooth(src)

		cut_overlay(crack_overlay)
		if(ratio > 75)
			return
		crack_overlay = mutable_appearance('icons/obj/structures.dmi', "damage[ratio]", -(layer+0.1))
		add_overlay(crack_overlay)

/obj/structure/window/get_dumping_location(obj/item/storage/source,mob/user)
	return null

/obj/structure/window/GetExplosionBlock()
	return reinf && fulltile ? real_explosion_block : 0

/obj/structure/window/unanchored
	anchored = FALSE

/obj/structure/window/reinforced
	name = "reinforced window"
	desc = "A window that is reinforced with metal rods."
	icon_state = "rwindow"
	reinf = TRUE
	heat_resistance = 1600
	armor = list("melee" = 50, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 25, "bio" = 100, "rad" = 100, "fire" = 80, "acid" = 100)
	max_integrity = 50
	explosion_block = 1
	glass_type = /obj/item/stack/sheet/rglass
	//rad_insulation = RAD_HEAVY_INSULATION

/obj/structure/window/reinforced/spawner/east
	dir = EAST

/obj/structure/window/reinforced/spawner/west
	dir = WEST

/obj/structure/window/reinforced/spawner/north
	dir = NORTH

/obj/structure/window/reinforced/unanchored
	anchored = FALSE

/obj/structure/window/plasma
	name = "plasma window"
	desc = "A window made out of a plasma-silicate alloy. It looks insanely tough to break and burn through."
	icon_state = "plasmawindow"
	reinf = FALSE
	heat_resistance = 25000
	armor = list("melee" = 75, "bullet" = 5, "laser" = 0, "energy" = 0, "bomb" = 45, "bio" = 100, "rad" = 100, "fire" = 99, "acid" = 100)
	max_integrity = 150
	explosion_block = 1
	glass_type = /obj/item/stack/sheet/plasmaglass
	//rad_insulation = RAD_NO_INSULATION

/obj/structure/window/plasma/spawnDebris(location)
	. = list()
	. += new /obj/item/shard/plasma(location)
	. += new /obj/effect/decal/cleanable/glass/plasma(location)
	if (reinf)
		. += new /obj/item/stack/rods(location, (fulltile ? 2 : 1))
	if (fulltile)
		. += new /obj/item/shard/plasma(location)

/obj/structure/window/plasma/spawner/east
	dir = EAST

/obj/structure/window/plasma/spawner/west
	dir = WEST

/obj/structure/window/plasma/spawner/north
	dir = NORTH

/obj/structure/window/plasma/unanchored
	anchored = FALSE

/obj/structure/window/plasma/reinforced
	name = "reinforced plasma window"
	desc = "A window made out of a plasma-silicate alloy and a rod matrix. It looks hopelessly tough to break and is most likely nigh fireproof."
	icon_state = "plasmarwindow"
	reinf = TRUE
	heat_resistance = 50000
	armor = list("melee" = 85, "bullet" = 20, "laser" = 0, "energy" = 0, "bomb" = 60, "bio" = 100, "rad" = 100, "fire" = 99, "acid" = 100)
	max_integrity = 500
	explosion_block = 2
	glass_type = /obj/item/stack/sheet/plasmarglass

/obj/structure/window/plasma/reinforced/spawner/east
	dir = EAST

/obj/structure/window/plasma/reinforced/spawner/west
	dir = WEST

/obj/structure/window/plasma/reinforced/spawner/north
	dir = NORTH

/obj/structure/window/plasma/reinforced/unanchored
	anchored = FALSE

/obj/structure/window/fulltile
	icon = 'icons/obj/smooth_structures/window.dmi'
	icon_state = "window"
	dir = FULLTILE_WINDOW_DIR
	max_integrity = 50
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	smooth = SMOOTH_TRUE
	//canSmoothWith = list(/obj/structure/window/fulltile, /obj/structure/window/reinforced/fulltile, /obj/structure/window/reinforced/tinted/fulltile, /obj/structure/window/plasma/fulltile, /obj/structure/window/plasma/reinforced/fulltile)
	glass_amount = 2

/obj/structure/window/fulltile/unanchored
	anchored = FALSE

/obj/structure/window/plasma/fulltile
	icon = 'icons/obj/smooth_structures/plasma_window.dmi'
	icon_state = "plasmawindow"
	dir = FULLTILE_WINDOW_DIR
	max_integrity = 300
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	smooth = SMOOTH_TRUE
	//canSmoothWith = list(/obj/structure/window/fulltile, /obj/structure/window/reinforced/fulltile, /obj/structure/window/reinforced/tinted/fulltile, /obj/structure/window/plasma/fulltile, /obj/structure/window/plasma/reinforced/fulltile)
	glass_amount = 2

/obj/structure/window/plasma/fulltile/unanchored
	anchored = FALSE

/obj/structure/window/plasma/reinforced/fulltile
	icon = 'icons/obj/smooth_structures/rplasma_window.dmi'
	icon_state = "rplasmawindow"
	dir = FULLTILE_WINDOW_DIR
	max_integrity = 1000
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	smooth = SMOOTH_TRUE
	glass_amount = 2

/obj/structure/window/plasma/reinforced/fulltile/unanchored
	anchored = FALSE

/obj/structure/window/reinforced/fulltile
	icon = 'icons/obj/smooth_structures/reinforced_window.dmi'
	icon_state = "r_window"
	dir = FULLTILE_WINDOW_DIR
	max_integrity = 100
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	smooth = SMOOTH_TRUE
	//canSmoothWith = list(/obj/structure/window/fulltile, /obj/structure/window/reinforced/fulltile, /obj/structure/window/reinforced/tinted/fulltile, /obj/structure/window/plasma/fulltile, /obj/structure/window/plasma/reinforced/fulltile)
	level = 3
	glass_amount = 2

/obj/structure/window/reinforced/fulltile/unanchored
	anchored = FALSE

/obj/structure/window/shuttle
	name = "shuttle window"
	desc = "A reinforced, air-locked pod window."
	icon = 'icons/obj/smooth_structures/shuttle_window.dmi'
	icon_state = "shuttle_window"
	dir = FULLTILE_WINDOW_DIR
	max_integrity = 100
	wtype = "shuttle"
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	reinf = TRUE
	heat_resistance = 1600
	armor = list("melee" = 50, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 80, "acid" = 100)
	smooth = SMOOTH_TRUE
	canSmoothWith = null
	explosion_block = 3
	level = 3
	glass_type = /obj/item/stack/sheet/titaniumglass
	glass_amount = 2

///obj/structure/window/shuttle/narsie_act()
//	add_atom_colour("#3C3434", FIXED_COLOUR_PRIORITY)

/obj/structure/window/shuttle/tinted
	opacity = TRUE

/obj/structure/window/shuttle/unanchored
	anchored = FALSE

/obj/structure/window/plastitanium
	name = "plastitanium window"
	desc = "A durable looking window made of an alloy of of plasma and titanium."
	icon = 'icons/obj/smooth_structures/plastitanium_window.dmi'
	icon_state = "plastitanium_window"
	dir = FULLTILE_WINDOW_DIR
	max_integrity = 100
	wtype = "shuttle"
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	reinf = TRUE
	heat_resistance = 1600
	armor = list("melee" = 50, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 80, "acid" = 100)
	smooth = SMOOTH_TRUE
	canSmoothWith = null
	explosion_block = 3
	level = 3
	//glass_type = /obj/item/stack/sheet/plastitaniumglass
	glass_amount = 2

/obj/structure/window/plastitanium/unanchored
	anchored = FALSE