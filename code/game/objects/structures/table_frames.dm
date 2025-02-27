/obj/structure/table_frame
	name = "table frame"
	desc = "Four metal legs with four framing rods for a table. You could easily pass through this."
	icon = 'icons/obj/structures.dmi'
	icon_state = "table_frame"
	density = FALSE
	anchored = FALSE
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	max_integrity = 100
	var/framestack = /obj/item/stack/rods
	var/framestackamount = 2

/obj/structure/table_frame/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WRENCH)
		to_chat(user, "<span class='notice'>You start disassembling [src]...</span>")
		I.play_tool_sound(src)
		if(I.use_tool(src, user, 30))
			playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
			deconstruct(TRUE)
	else if(istype(I, /obj/item/stack/sheet/plasteel))
		var/obj/item/stack/sheet/plasteel/P = I
		if(P.get_amount() < 1)
			to_chat(user, "<span class='warning'>You need one plasteel sheet to do this!</span>")
			return
		to_chat(user, "<span class='notice'>You start adding [P] to [src]...</span>")
		if(do_after(user, 50, target = src) && P.use(1))
			make_new_table(/obj/structure/table/reinforced)
	else if(istype(I, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = I
		if(M.get_amount() < 1)
			to_chat(user, "<span class='warning'>You need one metal sheet to do this!</span>")
			return
		to_chat(user, "<span class='notice'>You start adding [M] to [src]...</span>")
		if(do_after(user, 20, target = src) && M.use(1))
			make_new_table(/obj/structure/table)
	else if(istype(I, /obj/item/stack/sheet/glass))
		var/obj/item/stack/sheet/glass/G = I
		if(G.get_amount() < 1)
			to_chat(user, "<span class='warning'>You need one glass sheet to do this!</span>")
			return
		to_chat(user, "<span class='notice'>You start adding [G] to [src]...</span>")
		if(do_after(user, 20, target = src) && G.use(1))
			make_new_table(/obj/structure/table/glass)
	//else if(istype(I, /obj/item/stack/sheet/mineral/silver))
	//	var/obj/item/stack/sheet/mineral/silver/S = I
	//	if(S.get_amount() < 1)
	//		to_chat(user, "<span class='warning'>You need one silver sheet to do this!</span>")
	//		return
	//	to_chat(user, "<span class='notice'>You start adding [S] to [src]...</span>")
	//	if(do_after(user, 20, target = src) && S.use(1))
	//		make_new_table(/obj/structure/table/optable)
	//else if(istype(I, /obj/item/stack/tile/carpet/black))
	//	var/obj/item/stack/tile/carpet/black/C = I
	//	if(C.get_amount() < 1)
	//		to_chat(user, "<span class='warning'>You need one  black carpet sheet to do this!</span>")
	//		return
	//	to_chat(user, "<span class='notice'>You start adding [C] to [src]...</span>")
	//	if(do_after(user, 20, target = src) && C.use(1))
	//		make_new_table(/obj/structure/table/wood/fancy/black)
	//else if(istype(I, /obj/item/stack/tile/carpet))
	//	var/obj/item/stack/tile/carpet/C = I
	//	if(C.get_amount() < 1)
	//		to_chat(user, "<span class='warning'>You need one carpet sheet to do this!</span>")
	//		return
	//	to_chat(user, "<span class='notice'>You start adding [C] to [src]...</span>")
	//	if(do_after(user, 20, target = src) && C.use(1))
	//		make_new_table(/obj/structure/table/wood/fancy)
	//else if(istype(I, /obj/item/stack/tile/bronze))
	//	var/obj/item/stack/tile/bronze/B = I
	//	if(B.get_amount() < 1)
	//		to_chat(user, "<span class='warning'>You need one bronze sheet to do this!</span>")
	//		return
	//	to_chat(user, "<span class='notice'>You start adding [B] to [src]...</span>")
	//	if(do_after(user, 20, target = src) && B.use(1))
	//		make_new_table(/obj/structure/table/bronze)
	else
		return ..()
	
/obj/structure/table_frame/proc/make_new_table(table_type)
	var/obj/structure/table/T = new table_type(loc)
	T.frame = type
	T.framestack = framestack
	T.framestackamount = framestackamount
	qdel(src)

/obj/structure/table_frame/deconstruct(disassembled = TRUE)
	new framestack(get_turf(src), framestackamount)
	qdel(src)

/obj/structure/table_frame/wood
	name = "wooden table frame"
	desc = "Four wooden legs with four framing wooden rods for a wooden table. You could easily pass through this."
	icon_state = "wood_frame"
	framestack = /obj/item/stack/sheet/mineral/wood
	framestackamount = 2
	resistance_flags = FLAMMABLE

/obj/structure/table_frame/wood/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/sheet/mineral/wood))
		var/obj/item/stack/sheet/mineral/wood/W = I
		if(W.get_amount() < 1)
			to_chat(user, "<span class='warning'>You need one wood sheet to do this!</span>")
			return
		to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
		if(do_after(user, 20, target = src) && W.use(1))
			make_new_table(/obj/structure/table/wood)
		return
	else if(istype(I, /obj/item/stack/tile/carpet))
		var/obj/item/stack/tile/carpet/C = I
		if(C.get_amount() < 1)
			to_chat(user, "<span class='warning'>You need one carpet sheet to do this!</span>")
			return
		to_chat(user, "<span class='notice'>You start adding [C] to [src]...</span>")
		if(do_after(user, 20, target = src) && C.use(1))
			make_new_table(/obj/structure/table/wood/poker)
	else
		return ..()