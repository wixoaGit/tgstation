#define CONSTRUCTION_COMPLETE 0
#define CONSTRUCTION_PANEL_OPEN 1
#define CONSTRUCTION_WIRES_EXPOSED 2
#define CONSTRUCTION_GUTTED 3
#define CONSTRUCTION_NOCIRCUIT 4

/obj/machinery/door/firedoor
	name = "firelock"
	desc = "Apply crowbar."
	icon = 'icons/obj/doors/Doorfireglass.dmi'
	icon_state = "door_open"
	opacity = FALSE
	density = FALSE
	max_integrity = 300
	resistance_flags = FIRE_PROOF
	heat_proof = TRUE
	glass = TRUE
	sub_door = TRUE
	explosion_block = 1
	safe = FALSE
	layer = BELOW_OPEN_DOOR_LAYER
	closingLayer = CLOSED_FIREDOOR_LAYER
	//assemblytype = /obj/structure/firelock_frame
	armor = list("melee" = 30, "bullet" = 30, "laser" = 20, "energy" = 20, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 95, "acid" = 70)
	interaction_flags_machine = INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON | INTERACT_MACHINE_REQUIRES_SILICON | INTERACT_MACHINE_OPEN
	var/nextstate = null
	var/boltslocked = TRUE
	var/list/affecting_areas

/obj/machinery/door/firedoor/Initialize()
	. = ..()
	CalculateAffectingAreas()

/obj/machinery/door/firedoor/examine(mob/user)
	..()
	if(!density)
		to_chat(user, "<span class='notice'>It is open, but could be <b>pried</b> closed.</span>")
	else if(!welded)
		to_chat(user, "<span class='notice'>It is closed, but could be <i>pried</i> open. Deconstruction would require it to be <b>welded</b> shut.</span>")
	else if(boltslocked)
		to_chat(user, "<span class='notice'>It is <i>welded</i> shut. The floor bolts have been locked by <b>screws</b>.</span>")
	else
		to_chat(user, "<span class='notice'>The bolt locks have been <i>unscrewed</i>, but the bolts themselves are still <b>wrenched</b> to the floor.</span>")

/obj/machinery/door/firedoor/proc/CalculateAffectingAreas()
	remove_from_areas()
	//affecting_areas = get_adjacent_open_areas(src) | get_area(src)
	//for(var/I in affecting_areas)
	//	var/area/A = I
	//	LAZYADD(A.firedoors, src)

/obj/machinery/door/firedoor/closed
	icon_state = "door_closed"
	opacity = TRUE
	density = TRUE

/obj/machinery/door/firedoor/proc/remove_from_areas()
	//if(affecting_areas)
	//	for(var/I in affecting_areas)
	//		var/area/A = I
	//		LAZYREMOVE(A.firedoors, src)

/obj/machinery/door/firedoor/Destroy()
	remove_from_areas()
	//affecting_areas.Cut()
	return ..()

/obj/machinery/door/firedoor/Bumped(atom/movable/AM)
	if(panel_open || operating)
		return
	if(!density)
		return ..()
	return FALSE

/obj/machinery/door/firedoor/power_change()
	if(powered(power_channel))
		stat &= ~NOPOWER
		latetoggle()
	else
		stat |= NOPOWER

/obj/machinery/door/firedoor/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(operating || !density)
		return
	user.changeNext_move(CLICK_CD_MELEE)

	user.visible_message("[user] bangs on \the [src].",
						 "You bang on \the [src].")
	playsound(loc, 'sound/effects/glassknock.ogg', 10, FALSE, frequency = 32000)

/obj/machinery/door/firedoor/try_to_activate_door(mob/user)
	return

/obj/machinery/door/firedoor/try_to_weld(obj/item/weldingtool/W, mob/user)
	if(!W.tool_start_check(user, amount=0))
		return
	user.visible_message("<span class='notice'>[user] starts [welded ? "unwelding" : "welding"] [src].</span>", "<span class='notice'>You start welding [src].</span>")
	if(W.use_tool(src, user, 40, volume=50))
		welded = !welded
		to_chat(user, "<span class='danger'>[user] [welded?"welds":"unwelds"] [src].</span>", "<span class='notice'>You [welded ? "weld" : "unweld"] [src].</span>")
		update_icon()

/obj/machinery/door/firedoor/try_to_crowbar(obj/item/I, mob/user)
	if(welded || operating)
		return

	if(density)
		open()
	else
		close()

/obj/machinery/door/firedoor/attack_ai(mob/user)
	add_fingerprint(user)
	if(welded || operating || stat & NOPOWER)
		return TRUE
	if(density)
		open()
	else
		close()
	return TRUE

/obj/machinery/door/firedoor/do_animate(animation)
	//switch(animation)
	//	if("opening")
	//		flick("door_opening", src)
	//	if("closing")
	//		flick("door_closing", src)

/obj/machinery/door/firedoor/update_icon()
	cut_overlays()
	if(density)
		icon_state = "door_closed"
		if(welded)
			add_overlay("welded")
	else
		icon_state = "door_open"
		if(welded)
			add_overlay("welded_open")

/obj/machinery/door/firedoor/open()
	. = ..()
	latetoggle()

/obj/machinery/door/firedoor/close()
	. = ..()
	latetoggle()

/obj/machinery/door/firedoor/deconstruct(disassembled = TRUE)
	//if(!(flags_1 & NODECONSTRUCT_1))
	//	var/obj/structure/firelock_frame/F = new assemblytype(get_turf(src))
	//	if(disassembled)
	//		F.constructionStep = CONSTRUCTION_PANEL_OPEN
	//	else
	//		F.constructionStep = CONSTRUCTION_WIRES_EXPOSED
	//		F.obj_integrity = F.max_integrity * 0.5
	//	F.update_icon()
	qdel(src)

/obj/machinery/door/firedoor/proc/latetoggle()
	if(operating || stat & NOPOWER || !nextstate)
		return
	switch(nextstate)
		if(FIREDOOR_OPEN)
			nextstate = null
			open()
		if(FIREDOOR_CLOSED)
			nextstate = null
			close()

/obj/machinery/door/firedoor/heavy
	name = "heavy firelock"
	icon = 'icons/obj/doors/Doorfire.dmi'
	glass = FALSE
	explosion_block = 2
	//assemblytype = /obj/structure/firelock_frame/heavy
	max_integrity = 550

#undef CONSTRUCTION_COMPLETE
#undef CONSTRUCTION_PANEL_OPEN
#undef CONSTRUCTION_WIRES_EXPOSED
#undef CONSTRUCTION_GUTTED
#undef CONSTRUCTION_NOCIRCUIT