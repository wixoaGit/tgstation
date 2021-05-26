#define MAX_DENT_DECALS 15

/turf/closed/wall
	name = "wall"
	desc = "A huge chunk of metal used to separate rooms."
	icon = 'icons/turf/walls/wall.dmi'
	icon_state = "wall"
	explosion_block = 1

	//thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	//heat_capacity = 312500

	baseturfs = /turf/open/floor/plating
	
	var/hardness = 40
	var/slicing_duration = 100
	var/sheet_type = /obj/item/stack/sheet/metal
	var/sheet_amount = 2
	var/girder_type = /obj/structure/girder

	//canSmoothWith = list(
	///turf/closed/wall,
	///turf/closed/wall/r_wall,
	///obj/structure/falsewall,
	///obj/structure/falsewall/brass,
	///obj/structure/falsewall/reinforced,
	///turf/closed/wall/rust,
	///turf/closed/wall/r_wall/rust,
	///turf/closed/wall/clockwork)
	//not_actual
	canSmoothWith = list(
	/turf/closed/wall,
	/turf/closed/wall/r_wall,
	/turf/closed/wall/rust,
	/turf/closed/wall/r_wall/rust)
	smooth = SMOOTH_TRUE

	var/list/dent_decals

/turf/closed/wall/examine(mob/user)
	..()
	deconstruction_hints(user)

/turf/closed/wall/proc/deconstruction_hints(mob/user)
	to_chat(user, "<span class='notice'>The outer plating is <b>welded</b> firmly in place.</span>")

/turf/closed/wall/handle_ricochet(obj/item/projectile/P)
	var/turf/p_turf = get_turf(P)
	var/face_direction = get_dir(src, p_turf)
	var/face_angle = dir2angle(face_direction)
	var/incidence_s = GET_ANGLE_OF_INCIDENCE(face_angle, (P.Angle + 180))
	if(abs(incidence_s) > 90 && abs(incidence_s) < 270)
		return FALSE
	var/new_angle_s = SIMPLIFY_DEGREES(face_angle + incidence_s)
	P.setAngle(new_angle_s)
	return TRUE

/turf/closed/wall/proc/dismantle_wall(devastated=0, explode=0)
	if(devastated)
		devastate_wall()
	else
		playsound(src, 'sound/items/welder.ogg', 100, 1)
		var/newgirder = break_wall()
		if(newgirder)
			transfer_fingerprints_to(newgirder)

	//for(var/obj/O in src.contents)
	//	if(istype(O, /obj/structure/sign/poster))
	//		var/obj/structure/sign/poster/P = O
	//		P.roll_and_drop(src)

	ScrapeAway()

/turf/closed/wall/proc/break_wall()
	new sheet_type(src, sheet_amount)
	return new girder_type(src)

/turf/closed/wall/proc/devastate_wall()
	new sheet_type(src, sheet_amount)
	if(girder_type)
		new /obj/item/stack/sheet/metal(src)

/turf/closed/wall/ex_act(severity, target)
	if(target == src)
		dismantle_wall(1,1)
		return
	switch(severity)
		if(1)
			var/turf/NT = ScrapeAway()
			NT.contents_explosion(severity, target)
			return
		if(2)
			if (prob(50))
				dismantle_wall(0,1)
			else
				dismantle_wall(1,1)
		if(3)
			if (prob(hardness))
				dismantle_wall(0,1)
	if(!density)
		..()

/turf/closed/wall/attack_paw(mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	return attack_hand(user)

/turf/closed/wall/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	to_chat(user, "<span class='notice'>You push the wall but nothing happens!</span>")
	playsound(src, 'sound/weapons/genhit.ogg', 25, 1)
	add_fingerprint(user)

/turf/closed/wall/attackby(obj/item/W, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	if (!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	if(!isturf(user.loc))
		return

	add_fingerprint(user)

	var/turf/T = user.loc

	//if(try_clean(W, user, T) || try_wallmount(W, user, T) || try_decon(W, user, T) || try_destroy(W, user, T))
	if (try_wallmount(W, user, T) || try_decon(W, user, T))//not_actual
		return

	return ..()

/turf/closed/wall/proc/try_wallmount(obj/item/W, mob/user, turf/T)
	if(istype(W, /obj/item/wallframe))
		var/obj/item/wallframe/F = W
		if(F.try_build(src, user))
			F.attach(src, user)
		return TRUE
	//else if(istype(W, /obj/item/poster))
	//	place_poster(W,user)
	//	return TRUE

	return FALSE

/turf/closed/wall/proc/try_decon(obj/item/I, mob/user, turf/T)
	if(I.tool_behaviour == TOOL_WELDER)
		if(!I.tool_start_check(user, amount=0))
			return FALSE

		to_chat(user, "<span class='notice'>You begin slicing through the outer plating...</span>")
		if(I.use_tool(src, user, slicing_duration, volume=100))
			if(iswallturf(src))
				to_chat(user, "<span class='notice'>You remove the outer plating.</span>")
				dismantle_wall()
			return TRUE
	return FALSE

/turf/closed/wall/get_dumping_location(obj/item/storage/source, mob/user)
	return null

/turf/closed/wall/proc/add_dent(denttype, x=rand(-8, 8), y=rand(-8, 8))
	if(LAZYLEN(dent_decals) >= MAX_DENT_DECALS)
		return

	var/mutable_appearance/decal = mutable_appearance('icons/effects/effects.dmi', "", BULLET_HOLE_LAYER)
	switch(denttype)
		if(WALL_DENT_SHOT)
			decal.icon_state = "bullet_hole"
		if(WALL_DENT_HIT)
			decal.icon_state = "impact[rand(1, 3)]"

	decal.pixel_x = x
	decal.pixel_y = y

	if(LAZYLEN(dent_decals))
		cut_overlay(dent_decals)
		dent_decals += decal
	else
		dent_decals = list(decal)

	add_overlay(dent_decals)

#undef MAX_DENT_DECALS