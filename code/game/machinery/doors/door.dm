/obj/machinery/door
	name = "door"
	desc = "It opens and closes."
	icon = 'icons/obj/doors/Doorint.dmi'
	icon_state = "door1"
	opacity = 1
	density = TRUE
	move_resist = MOVE_FORCE_VERY_STRONG
	layer = OPEN_DOOR_LAYER
	power_channel = ENVIRON
	max_integrity = 350
	armor = list("melee" = 30, "bullet" = 30, "laser" = 20, "energy" = 20, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 80, "acid" = 70)
	CanAtmosPass = ATMOS_PASS_DENSITY
	flags_1 = PREVENT_CLICK_UNDER_1
	damage_deflection = 10

	interaction_flags_atom = INTERACT_ATOM_UI_INTERACT

	var/secondsElectrified = MACHINE_NOT_ELECTRIFIED
	var/shockedby
	var/visible = TRUE
	var/operating = FALSE
	var/glass = FALSE
	var/welded = FALSE
	var/normalspeed = 1
	var/heat_proof = FALSE
	var/emergency = FALSE
	var/sub_door = FALSE
	var/closingLayer = CLOSED_DOOR_LAYER
	var/autoclose = FALSE
	var/safe = TRUE
	var/locked = FALSE
	var/assemblytype
	var/datum/effect_system/spark_spread/spark_system
	var/real_explosion_block
	var/red_alert_access = FALSE
	var/poddoor = FALSE
	var/unres_sides = 0

/obj/machinery/door/examine(mob/user)
	..()
	if(red_alert_access)
		if(GLOB.security_level >= SEC_LEVEL_RED)
			to_chat(user, "<span class='notice'>Due to a security threat, its access requirements have been lifted!</span>")
		else
			to_chat(user, "<span class='notice'>In the event of a red alert, its access requirements will automatically lift.</span>")
	if(!poddoor)
		to_chat(user, "<span class='notice'>Its maintenance panel is <b>screwed</b> in place.</span>")

/obj/machinery/door/check_access_list(list/access_list)
	if(red_alert_access && GLOB.security_level >= SEC_LEVEL_RED)
		return TRUE
	return ..()

/obj/machinery/door/Initialize()
	. = ..()
	set_init_door_layer()
	update_freelook_sight()
	air_update_turf(1)
	GLOB.airlocks += src
	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(2, 1, src)

	real_explosion_block = explosion_block
	explosion_block = EXPLOSION_BLOCK_PROC

/obj/machinery/door/proc/set_init_door_layer()
	if(density)
		layer = closingLayer
	else
		layer = initial(layer)

/obj/machinery/door/power_change()
	..()
	update_icon()

/obj/machinery/door/Destroy()
	update_freelook_sight()
	GLOB.airlocks -= src
	if(spark_system)
		qdel(spark_system)
		spark_system = null
	return ..()

/obj/machinery/door/Bumped(atom/movable/AM)
	if(operating || (obj_flags & EMAGGED))
		return
	if(ismob(AM))
		var/mob/B = AM
		if((isdrone(B) || iscyborg(B)) && B.stat)
			return
		if(isliving(AM))
			var/mob/living/M = AM
			if(world.time - M.last_bumped <= 10)
				return
			M.last_bumped = world.time
			if(M.restrained() && !check_access(null))
				return
			bumpopen(M)
			return

	if(ismecha(AM))
		//var/obj/mecha/mecha = AM
		//if(density)
		//	if(mecha.occupant)
		//		if(world.time - mecha.occupant.last_bumped <= 10)
		//			return
		//		mecha.occupant.last_bumped = world.time
		//	if(mecha.occupant && (src.allowed(mecha.occupant) || src.check_access_list(mecha.operation_req_access)))
		//		open()
		//	else
		//		do_animate("deny")
		return
	return

/obj/machinery/door/Move()
	var/turf/T = loc
	. = ..()
	move_update_air(T)

/obj/machinery/door/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && (mover.pass_flags & PASSGLASS))
		return !opacity
	return !density

/obj/machinery/door/proc/bumpopen(mob/user)
	if(operating)
		return
	src.add_fingerprint(user)
	if(!src.requiresID())
		user = null

	if(density && !(obj_flags & EMAGGED))
		if(allowed(user))
			open()
		else
			do_animate("deny")
	return

/obj/machinery/door/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	return try_to_activate_door(user)

/obj/machinery/door/proc/try_to_activate_door(mob/user)
	add_fingerprint(user)
	if(operating || (obj_flags & EMAGGED))
		return
	if(!requiresID())
		user = null
	if(allowed(user))
		if(density)
			open()
		else
			close()
		return
	if(density)
		do_animate("deny")

/obj/machinery/door/allowed(mob/M)
	if(emergency)
		return TRUE
	if(unrestricted_side(M))
		return TRUE
	return ..()

/obj/machinery/door/proc/unrestricted_side(mob/M)
	return get_dir(src, M) & unres_sides

/obj/machinery/door/proc/try_to_weld(obj/item/weldingtool/W, mob/user)
	return

/obj/machinery/door/proc/try_to_crowbar(obj/item/I, mob/user)
	return

/obj/machinery/door/attackby(obj/item/I, mob/user, params)
	//if(user.a_intent != INTENT_HARM && (I.tool_behaviour == TOOL_CROWBAR || istype(I, /obj/item/twohanded/fireaxe)))
	if(user.a_intent != INTENT_HARM && I.tool_behaviour == TOOL_CROWBAR)//not_actual
		try_to_crowbar(I, user)
		return 1
	else if(I.tool_behaviour == TOOL_WELDER)
		try_to_weld(I, user)
		return 1
	else if(!(I.item_flags & NOBLUDGEON) && user.a_intent != INTENT_HARM)
		try_to_activate_door(user)
		return 1
	return ..()

/obj/machinery/door/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(. && obj_integrity > 0)
		if(damage_amount >= 10 && prob(30))
			spark_system.start()

/obj/machinery/door/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(glass)
				playsound(loc, 'sound/effects/glasshit.ogg', 90, 1)
			else if(damage_amount)
				playsound(loc, 'sound/weapons/smash.ogg', 50, 1)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, 1)

/obj/machinery/door/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	//if(prob(20/severity) && (istype(src, /obj/machinery/door/airlock) || istype(src, /obj/machinery/door/window)) )
	//	INVOKE_ASYNC(src, .proc/open)
	//if(prob(severity*10 - 20))
	//	if(secondsElectrified == MACHINE_NOT_ELECTRIFIED)
	//		secondsElectrified = MACHINE_ELECTRIFIED_PERMANENT
	//		LAZYADD(shockedby, "\[[time_stamp()]\]EM Pulse")
	//		addtimer(CALLBACK(src, .proc/unelectrify), 300)

/obj/machinery/door/update_icon()
	if(density)
		icon_state = "door1"
	else
		icon_state = "door0"

/obj/machinery/door/proc/do_animate(animation)
	//switch(animation)
	//	if("opening")
	//		if(panel_open)
	//			flick("o_doorc0", src)
	//		else
	//			flick("doorc0", src)
	//	if("closing")
	//		if(panel_open)
	//			flick("o_doorc1", src)
	//		else
	//			flick("doorc1", src)
	//	if("deny")
	//		if(!stat)
	//			flick("door_deny", src)

/obj/machinery/door/proc/open()
	if(!density)
		return 1
	if(operating)
		return
	operating = TRUE
	do_animate("opening")
	set_opacity(0)
	sleep(5)
	density = FALSE
	sleep(5)
	layer = initial(layer)
	update_icon()
	set_opacity(0)
	operating = FALSE
	air_update_turf(1)
	update_freelook_sight()
	if(autoclose)
		spawn(autoclose)
			close()
	return 1

/obj/machinery/door/proc/close()
	if(density)
		return TRUE
	if(operating || welded)
		return
	if(safe)
		for(var/atom/movable/M in get_turf(src))
			if(M.density && M != src)
				if(autoclose)
					autoclose_in(60)
				return

	operating = TRUE

	do_animate("closing")
	layer = closingLayer
	sleep(5)
	density = TRUE
	sleep(5)
	update_icon()
	//if(visible && !glass)
	//	set_opacity(1)
	operating = FALSE
	air_update_turf(1)
	update_freelook_sight()
	//if(safe)
	//	CheckForMobs()
	//else
	//	crush()
	return 1

/obj/machinery/door/proc/autoclose()
	if(!QDELETED(src) && !density && !operating && !locked && !welded && autoclose)
		close()

/obj/machinery/door/proc/autoclose_in(wait)
	addtimer(CALLBACK(src, .proc/autoclose), wait, TIMER_UNIQUE | TIMER_NO_HASH_WAIT | TIMER_OVERRIDE)

/obj/machinery/door/proc/requiresID()
	return 1

/obj/machinery/door/proc/hasPower()
	return !(stat & NOPOWER)

/obj/machinery/door/proc/update_freelook_sight()
	//if(!glass && GLOB.cameranet)
	//	GLOB.cameranet.updateVisibility(src, 0)

/obj/machinery/door/get_dumping_location(obj/item/storage/source,mob/user)
	return null

/obj/machinery/door/ex_act(severity, target)
	..(severity ? max(1, severity - 1) : 0, target)

/obj/machinery/door/GetExplosionBlock()
	return density ? real_explosion_block : 0