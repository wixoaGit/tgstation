#define SEND_PRESSURE (0.05*ONE_ATMOSPHERE)

/obj/machinery/disposal
	icon = 'icons/obj/atmospherics/pipes/disposal.dmi'
	density = TRUE
	armor = list("melee" = 25, "bullet" = 10, "laser" = 10, "energy" = 100, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 30)
	max_integrity = 200
	resistance_flags = FIRE_PROOF
	interaction_flags_machine = INTERACT_MACHINE_OPEN | INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON
	obj_flags = CAN_BE_HIT | USES_TGUI
	//rad_flags = RAD_PROTECT_CONTENTS | RAD_NO_CONTAMINATE
	var/datum/gas_mixture/air_contents
	var/full_pressure = FALSE
	var/pressure_charging = TRUE
	var/flush = 0
	var/obj/structure/disposalpipe/trunk/trunk = null
	var/flushing = 0
	var/flush_every_ticks = 30
	var/flush_count = 0
	var/last_sound = 0
	var/obj/structure/disposalconstruct/stored

/obj/machinery/disposal/Initialize(mapload, obj/structure/disposalconstruct/make_from)
	. = ..()

	if(make_from)
		setDir(make_from.dir)
		make_from.moveToNullspace()
		stored = make_from
		pressure_charging = FALSE
	else
		stored = new /obj/structure/disposalconstruct(null, null , SOUTH , FALSE , src)

	trunk_check()

	air_contents = new /datum/gas_mixture()
	update_icon()

	return INITIALIZE_HINT_LATELOAD

/obj/machinery/disposal/proc/trunk_check()
	trunk = locate() in loc
	if(!trunk)
		pressure_charging = FALSE
		flush = FALSE
	else
		if(initial(pressure_charging))
			pressure_charging = TRUE
		flush = initial(flush)
		trunk.linked = src

/obj/machinery/disposal/Destroy()
	eject()
	if(trunk)
		trunk.linked = null
	return ..()

///obj/machinery/disposal/singularity_pull(S, current_size)
//	..()
//	if(current_size >= STAGE_FIVE)
//		deconstruct()

/obj/machinery/disposal/LateInitialize()
	var/atom/L = loc
	var/datum/gas_mixture/env = new
	env.copy_from(L.return_air())
	var/datum/gas_mixture/removed = env.remove(SEND_PRESSURE + 1)
	air_contents.merge(removed)
	trunk_check()

/obj/machinery/disposal/attackby(obj/item/I, mob/user, params)
	add_fingerprint(user)
	if(!pressure_charging && !full_pressure && !flush)
		if(I.tool_behaviour == TOOL_SCREWDRIVER)
			panel_open = !panel_open
			I.play_tool_sound(src)
			to_chat(user, "<span class='notice'>You [panel_open ? "remove":"attach"] the screws around the power connection.</span>")
			return
		else if(I.tool_behaviour == TOOL_WELDER && panel_open)
			if(!I.tool_start_check(user, amount=0))
				return

			to_chat(user, "<span class='notice'>You start slicing the floorweld off \the [src]...</span>")
			if(I.use_tool(src, user, 20, volume=100) && panel_open)
				to_chat(user, "<span class='notice'>You slice the floorweld off \the [src].</span>")
				deconstruct()
			return

	if(user.a_intent != INTENT_HARM)
		if((I.item_flags & ABSTRACT) || !user.temporarilyRemoveItemFromInventory(I))
			return
		place_item_in_disposal(I, user)
		update_icon()
		return 1
	else
		return ..()

/obj/machinery/disposal/proc/place_item_in_disposal(obj/item/I, mob/user)
	I.forceMove(src)
	user.visible_message("[user.name] places \the [I] into \the [src].", "<span class='notice'>You place \the [I] into \the [src].</span>")

///obj/machinery/disposal/MouseDrop_T(mob/living/target, mob/living/user)
//	if(istype(target))
//		stuff_mob_in(target, user)

/obj/machinery/disposal/relaymove(mob/user)
	attempt_escape(user)

/obj/machinery/disposal/container_resist(mob/living/user)
	attempt_escape(user)

/obj/machinery/disposal/proc/attempt_escape(mob/user)
	if(flushing)
		return
	go_out(user)

/obj/machinery/disposal/attack_paw(mob/user)
	if(stat & BROKEN)
		return
	flush = !flush
	update_icon()


/obj/machinery/disposal/proc/eject()
	var/turf/T = get_turf(src)
	for(var/atom/movable/AM in src)
		AM.forceMove(T)
		AM.pipe_eject(0)
	update_icon()

/obj/machinery/disposal/update_icon()
	return

/obj/machinery/disposal/proc/go_out(mob/user)
	user.forceMove(loc)
	update_icon()

/obj/machinery/disposal/proc/flush()
	flushing = TRUE
	flushAnimation()
	sleep(10)
	if(last_sound < world.time + 1)
		playsound(src, 'sound/machines/disposalflush.ogg', 50, 0, 0)
		last_sound = world.time
	sleep(5)
	if(QDELETED(src))
		return
	var/obj/structure/disposalholder/H = new(src)
	newHolderDestination(H)
	H.init(src)
	//air_contents = new()
	air_contents = new /datum/gas_mixture()//not_actual
	H.start(src)
	flushing = FALSE
	flush = FALSE

/obj/machinery/disposal/proc/newHolderDestination(obj/structure/disposalholder/H)
	//for(var/obj/item/smallDelivery/O in src)
	//	H.tomail = TRUE
	//	return

/obj/machinery/disposal/proc/flushAnimation()
	//flick("[icon_state]-flush", src)

/obj/machinery/disposal/power_change()
	..()
	update_icon()

/obj/machinery/disposal/proc/expel(obj/structure/disposalholder/H)
	H.active = FALSE

	var/turf/T = get_turf(src)
	var/turf/target
	playsound(src, 'sound/machines/hiss.ogg', 50, 0, 0)

	for(var/A in H)
		var/atom/movable/AM = A

		target = get_offset_target_turf(loc, rand(5)-rand(5), rand(5)-rand(5))

		AM.forceMove(T)
		AM.pipe_eject(0)
		AM.throw_at(target, 5, 1)

	H.vent_gas(loc)
	qdel(H)

/obj/machinery/disposal/deconstruct(disassembled = TRUE)
	var/turf/T = loc
	if(!(flags_1 & NODECONSTRUCT_1))
		if(stored)
			stored.forceMove(T)
			src.transfer_fingerprints_to(stored)
			stored.anchored = FALSE
			stored.density = TRUE
			stored.update_icon()
	for(var/atom/movable/AM in src)
		AM.forceMove(T)
	..()

/obj/machinery/disposal/get_dumping_location(obj/item/storage/source,mob/user)
	return src

/obj/machinery/disposal/bin
	name = "disposal unit"
	desc = "A pneumatic waste disposal unit."
	icon_state = "disposal"

/obj/machinery/disposal/bin/attackby(obj/item/I, mob/user, params)
	//if(istype(I, /obj/item/storage/bag/trash))
	if(FALSE)//not_actual
		//var/obj/item/storage/bag/trash/T = I
		//GET_COMPONENT_FROM(STR, /datum/component/storage, T)
		//to_chat(user, "<span class='warning'>You empty the bag.</span>")
		//for(var/obj/item/O in T.contents)
		//	STR.remove_from_storage(O,src)
		//T.update_icon()
		//update_icon()
	else
		return ..()

/obj/machinery/disposal/bin/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
									datum/tgui/master_ui = null, datum/ui_state/state = GLOB.notcontained_state)
	if(stat & BROKEN)
		return
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "disposal_unit", name, 300, 200, master_ui, state)
		ui.open()

/obj/machinery/disposal/bin/ui_data(mob/user)
	var/list/data = list()
	data["flush"] = flush
	data["full_pressure"] = full_pressure
	data["pressure_charging"] = pressure_charging
	data["panel_open"] = panel_open
	var/per = CLAMP(100* air_contents.return_pressure() / (SEND_PRESSURE), 0, 100)
	data["per"] = round(per, 1)
	data["isai"] = isAI(user)
	return data

/obj/machinery/disposal/bin/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("handle-0")
			flush = FALSE
			update_icon()
			. = TRUE
		if("handle-1")
			if(!panel_open)
				flush = TRUE
				update_icon()
			. = TRUE
		if("pump-0")
			if(pressure_charging)
				pressure_charging = FALSE
				update_icon()
			. = TRUE
		if("pump-1")
			if(!pressure_charging)
				pressure_charging = TRUE
				update_icon()
			. = TRUE
		if("eject")
			eject()
			. = TRUE


/obj/machinery/disposal/bin/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(isitem(AM) && AM.CanEnterDisposals())
		if(prob(75))
			AM.forceMove(src)
			visible_message("<span class='notice'>[AM] lands in [src].</span>")
			update_icon()
		else
			visible_message("<span class='notice'>[AM] bounces off of [src]'s rim!</span>")
			return ..()
	else
		return ..()

/obj/machinery/disposal/bin/flush()
	..()
	full_pressure = FALSE
	pressure_charging = TRUE
	update_icon()

/obj/machinery/disposal/bin/update_icon()
	cut_overlays()
	if(stat & BROKEN)
		pressure_charging = FALSE
		flush = FALSE
		return

	if(flush)
		add_overlay("dispover-handle")

	if(stat & NOPOWER || panel_open)
		return

	if(contents.len > 0)
		add_overlay("dispover-full")

	if(pressure_charging)
		add_overlay("dispover-charge")
	else if(full_pressure)
		add_overlay("dispover-ready")

/obj/machinery/disposal/bin/proc/do_flush()
	set waitfor = FALSE
	flush()

/obj/machinery/disposal/bin/process()
	if(stat & BROKEN)
		return

	flush_count++
	if(flush_count >= flush_every_ticks)
		if(contents.len)
			if(full_pressure)
				do_flush()
		flush_count = 0

	updateDialog()

	if(flush && air_contents.return_pressure() >= SEND_PRESSURE)
		do_flush()

	if(stat & NOPOWER)
		return

	use_power(100)

	if(!pressure_charging)
		return

	use_power(500)

	var/atom/L = loc

	var/datum/gas_mixture/env = L.return_air()
	var/pressure_delta = (SEND_PRESSURE*1.01) - air_contents.return_pressure()

	if(env.temperature > 0)
		var/transfer_moles = 0.1 * pressure_delta*air_contents.volume/(env.temperature * R_IDEAL_GAS_EQUATION)

		var/datum/gas_mixture/removed = env.remove(transfer_moles)
		air_contents.merge(removed)
		air_update_turf()


	if(air_contents.return_pressure() >= SEND_PRESSURE)
		full_pressure = TRUE
		pressure_charging = FALSE
		update_icon()
	return

///obj/machinery/disposal/bin/get_remote_view_fullscreens(mob/user)
//	if(user.stat == DEAD || !(user.sight & (SEEOBJS|SEEMOBS)))
//		user.overlay_fullscreen("remote_view", /obj/screen/fullscreen/impaired, 2)

/atom/movable/proc/CanEnterDisposals()
	return TRUE

/obj/item/projectile/CanEnterDisposals()
	return

/obj/effect/CanEnterDisposals()
	return

///obj/mecha/CanEnterDisposals()
//	return