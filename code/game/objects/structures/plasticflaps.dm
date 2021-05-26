/obj/structure/plasticflaps
	name = "airtight plastic flaps"
	desc = "Heavy duty, airtight, plastic flaps. Definitely can't get past those. No way."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "plasticflaps"
	density = FALSE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER

/obj/structure/plasticflaps/opaque
	opacity = TRUE

/obj/structure/plasticflaps/Initialize()
	. = ..()
	//alpha = 0
	//SSvis_overlays.add_vis_overlay(src, icon, icon_state, ABOVE_MOB_LAYER, plane, dir, add_appearance_flags = RESET_ALPHA)

/obj/structure/plasticflaps/examine(mob/user)
	. = ..()
	if(anchored)
		to_chat(user, "<span class='notice'>[src] are <b>screwed</b> to the floor.</span>")
	else
		to_chat(user, "<span class='notice'>[src] are no longer <i>screwed</i> to the floor, and the flaps can be <b>cut</b> apart.</span>")

/obj/structure/plasticflaps/screwdriver_act(mob/living/user, obj/item/W)
	if(..())
		return TRUE
	add_fingerprint(user)
	var/action = anchored ? "unscrews [src] from" : "screws [src] to"
	var/uraction = anchored ? "unscrew [src] from " : "screw [src] to"
	user.visible_message("<span class='warning'>[user] [action] the floor.</span>", "<span class='notice'>You start to [uraction] the floor...</span>", "You hear rustling noises.")
	if(W.use_tool(src, user, 100, volume=100, extra_checks = CALLBACK(src, .proc/check_anchored_state, anchored)))
		setAnchored(!anchored)
		to_chat(user, "<span class='notice'> You [anchored ? "unscrew" : "screw"] [src] from the floor.</span>")
		return TRUE
	else
		return TRUE

/obj/structure/plasticflaps/wirecutter_act(mob/living/user, obj/item/W)
	if(!anchored)
		user.visible_message("<span class='warning'>[user] cuts apart [src].</span>", "<span class='notice'>You start to cut apart [src].</span>", "You hear cutting.")
		if(W.use_tool(src, user, 50, volume=100))
			if(anchored)
				return TRUE
			to_chat(user, "<span class='notice'>You cut apart [src].</span>")
			//var/obj/item/stack/sheet/plastic/five/P = new(loc)
			//P.add_fingerprint(user)
			qdel(src)
			return TRUE
		else
			return TRUE

/obj/structure/plasticflaps/proc/check_anchored_state(check_anchored)
	if(anchored != check_anchored)
		return FALSE
	return TRUE

/obj/structure/plasticflaps/CanPass(atom/movable/A, turf/T)
	if(istype(A) && (A.pass_flags & PASSGLASS))
		return prob(60)

	var/obj/structure/bed/B = A
	if(istype(A, /obj/structure/bed) && (B.has_buckled_mobs() || B.density))
		return FALSE
	
	//if(istype(A, /obj/structure/closet/cardboard))
	//	var/obj/structure/closet/cardboard/C = A
	//	if(C.move_delay)
	//		return FALSE

	if(ismecha(A))
		return FALSE

	else if(isliving(A))
		var/mob/living/M = A
		if(isbot(A))
			return TRUE
		//if(M.buckled && istype(M.buckled, /mob/living/simple_animal/bot/mulebot))
		//	return TRUE
		//if((M.mobility_flags & MOBILITY_STAND) && !M.ventcrawler && M.mob_size != MOB_SIZE_TINY)
		if((M.mobility_flags & MOBILITY_STAND) && M.mob_size != MOB_SIZE_TINY)//not_actual
			return FALSE
	return ..()

/obj/structure/plasticflaps/deconstruct(disassembled = TRUE)
	//if(!(flags_1 & NODECONSTRUCT_1))
	//	new /obj/item/stack/sheet/plastic/five(loc)
	qdel(src)

/obj/structure/plasticflaps/Initialize()
	. = ..()
	air_update_turf(TRUE)

/obj/structure/plasticflaps/Destroy()
	var/atom/oldloc = loc
	. = ..()
	if (oldloc)
		oldloc.air_update_turf(1)