/////////////////////////////////////////////
//// SMOKE SYSTEMS
/////////////////////////////////////////////

/obj/effect/particle_effect/smoke
	name = "smoke"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "smoke"
	pixel_x = -32
	pixel_y = -32
	opacity = 0
	layer = FLY_LAYER
	anchored = TRUE
	//mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	//animate_movement = 0
	var/amount = 4
	var/lifetime = 5
	var/opaque = 1


/obj/effect/particle_effect/smoke/proc/fade_out(frames = 16)
	if(alpha == 0)
		return
	if(frames == 0)
		frames = 1
	var/step = alpha / frames
	for(var/i = 0, i < frames, i++)
		alpha -= step
		if(alpha < 160)
			set_opacity(0)
		stoplag()

/obj/effect/particle_effect/smoke/Initialize()
	. = ..()
	create_reagents(500)
	START_PROCESSING(SSobj, src)


/obj/effect/particle_effect/smoke/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/particle_effect/smoke/proc/kill_smoke()
	STOP_PROCESSING(SSobj, src)
	INVOKE_ASYNC(src, .proc/fade_out)
	QDEL_IN(src, 10)

/obj/effect/particle_effect/smoke/process()
	lifetime--
	if(lifetime < 1)
		kill_smoke()
		return 0
	for(var/mob/living/L in range(0,src))
		smoke_mob(L)
	return 1

/obj/effect/particle_effect/smoke/proc/smoke_mob(mob/living/carbon/C)
	if(!istype(C))
		return 0
	if(lifetime<1)
		return 0
	//if(C.internal != null || C.has_smoke_protection())
	//	return 0
	if(C.smoke_delay)
		return 0
	C.smoke_delay++
	addtimer(CALLBACK(src, .proc/remove_smoke_delay, C), 10)
	return 1

/obj/effect/particle_effect/smoke/proc/remove_smoke_delay(mob/living/carbon/C)
	if(C)
		C.smoke_delay = 0

/obj/effect/particle_effect/smoke/proc/spread_smoke()
	var/turf/t_loc = get_turf(src)
	if(!t_loc)
		return
	var/list/newsmokes = list()
	for(var/turf/T in t_loc.GetAtmosAdjacentTurfs())
		var/obj/effect/particle_effect/smoke/foundsmoke = locate() in T
		if(foundsmoke)
			continue
		//for(var/mob/living/L in T)
		//	smoke_mob(L)
		var/obj/effect/particle_effect/smoke/S = new type(T)
		reagents.copy_to(S, reagents.total_volume)
		S.setDir(pick(GLOB.cardinals))
		S.amount = amount-1
		S.add_atom_colour(color, FIXED_COLOUR_PRIORITY)
		S.lifetime = lifetime
		if(S.amount>0)
			if(opaque)
				S.set_opacity(TRUE)
			newsmokes.Add(S)

	if(newsmokes.len)
		spawn(1)
			for(var/obj/effect/particle_effect/smoke/SM in newsmokes)
				SM.spread_smoke()


/datum/effect_system/smoke_spread
	var/amount = 10
	effect_type = /obj/effect/particle_effect/smoke

/datum/effect_system/smoke_spread/set_up(radius = 5, loca)
	if(isturf(loca))
		location = loca
	else
		location = get_turf(loca)
	amount = radius

/datum/effect_system/smoke_spread/start()
	if(holder)
		location = get_turf(holder)
	var/obj/effect/particle_effect/smoke/S = new effect_type(location)
	S.amount = amount
	if(S.amount)
		S.spread_smoke()

/obj/effect/particle_effect/smoke/bad
	lifetime = 8

/obj/effect/particle_effect/smoke/bad/smoke_mob(mob/living/carbon/M)
	if(..())
		M.drop_all_held_items()
		M.adjustOxyLoss(1)
		M.emote("cough")
		return 1

/obj/effect/particle_effect/smoke/bad/CanPass(atom/movable/mover, turf/target)
	//if(istype(mover, /obj/item/projectile/beam))
	//	var/obj/item/projectile/beam/B = mover
	//	B.damage = (B.damage/2)
	return 1

/datum/effect_system/smoke_spread/bad
	effect_type = /obj/effect/particle_effect/smoke/bad


/datum/effect_system/smoke_spread/transparent
	effect_type = /obj/effect/particle_effect/smoke/transparent

/obj/effect/particle_effect/smoke/transparent
	opaque = FALSE

/proc/do_smoke(range=0, location=null, smoke_type=/obj/effect/particle_effect/smoke)
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.effect_type = smoke_type
	smoke.set_up(range, location)
	smoke.start()
