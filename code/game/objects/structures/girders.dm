/obj/structure/girder
	name = "girder"
	icon_state = "girder"
	desc = "A large structural assembly made out of metal; It requires a layer of metal before it can be considered a wall."
	anchored = TRUE
	density = TRUE
	layer = BELOW_OBJ_LAYER
	var/state = GIRDER_NORMAL
	var/girderpasschance = 20
	var/can_displace = TRUE
	max_integrity = 200
	//rad_flags = RAD_PROTECT_CONTENTS | RAD_NO_CONTAMINATE
	//rad_insulation = RAD_VERY_LIGHT_INSULATION

/obj/structure/girder/examine(mob/user)
	. = ..()
	switch(state)
		if(GIRDER_REINF)
			to_chat(user, "<span class='notice'>The support struts are <b>screwed</b> in place.</span>")
		if(GIRDER_REINF_STRUTS)
			to_chat(user, "<span class='notice'>The support struts are <i>unscrewed</i> and the inner <b>grille</b> is intact.</span>")
		if(GIRDER_NORMAL)
			if(can_displace)
				to_chat(user, "<span class='notice'>The bolts are <b>wrenched</b> in place.</span>")
		if(GIRDER_DISPLACED)
			to_chat(user, "<span class='notice'>The bolts are <i>loosened</i>, but the <b>screws</b> are holding [src] together.</span>")
		if(GIRDER_DISASSEMBLED)
			to_chat(user, "<span class='notice'>[src] is disassembled! You probably shouldn't be able to see this examine message.</span>")

/obj/structure/girder/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)

	//if(istype(W, /obj/item/gun/energy/plasmacutter))
	if(FALSE)//not_actual
	//	to_chat(user, "<span class='notice'>You start slicing apart the girder...</span>")
	//	if(W.use_tool(src, user, 40, volume=100))
	//		to_chat(user, "<span class='notice'>You slice apart the girder.</span>")
	//		var/obj/item/stack/sheet/metal/M = new (loc, 2)
	//		M.add_fingerprint(user)
	//		qdel(src)

	//else if(istype(W, /obj/item/pickaxe/drill/jackhammer))
	//	to_chat(user, "<span class='notice'>You smash through the girder!</span>")
	//	new /obj/item/stack/sheet/metal(get_turf(src))
	//	W.play_tool_sound(src)
	//	qdel(src)


	else if(istype(W, /obj/item/stack))
		if(iswallturf(loc))
			to_chat(user, "<span class='warning'>There is already a wall present!</span>")
			return
		if(!isfloorturf(src.loc))
			to_chat(user, "<span class='warning'>A floor must be present to build a false wall!</span>")
			return
		//if (locate(/obj/structure/falsewall) in src.loc.contents)
		//	to_chat(user, "<span class='warning'>There is already a false wall present!</span>")
		//	return

		if(istype(W, /obj/item/stack/rods))
			var/obj/item/stack/rods/S = W
			if(state == GIRDER_DISPLACED)
				if(S.get_amount() < 2)
					to_chat(user, "<span class='warning'>You need at least two rods to create a false wall!</span>")
					return
				to_chat(user, "<span class='notice'>You start building a reinforced false wall...</span>")
				if(do_after(user, 20, target = src))
					if(S.get_amount() < 2)
						return
					S.use(2)
					to_chat(user, "<span class='notice'>You create a false wall. Push on it to open or close the passage.</span>")
					//var/obj/structure/falsewall/iron/FW = new (loc)
					//transfer_fingerprints_to(FW)
					qdel(src)
			else
				if(S.get_amount() < 5)
					to_chat(user, "<span class='warning'>You need at least five rods to add plating!</span>")
					return
				to_chat(user, "<span class='notice'>You start adding plating...</span>")
				if(do_after(user, 40, target = src))
					if(S.get_amount() < 5)
						return
					S.use(5)
					to_chat(user, "<span class='notice'>You add the plating.</span>")
					var/turf/T = get_turf(src)
					//T.PlaceOnTop(/turf/closed/wall/mineral/iron)
					transfer_fingerprints_to(T)
					qdel(src)
				return

		if(!istype(W, /obj/item/stack/sheet))
			return

		var/obj/item/stack/sheet/S = W
		if(istype(S, /obj/item/stack/sheet/metal))
			if(state == GIRDER_DISPLACED)
				if(S.get_amount() < 2)
					to_chat(user, "<span class='warning'>You need two sheets of metal to create a false wall!</span>")
					return
				to_chat(user, "<span class='notice'>You start building a false wall...</span>")
				if(do_after(user, 20, target = src))
					if(S.get_amount() < 2)
						return
					S.use(2)
					to_chat(user, "<span class='notice'>You create a false wall. Push on it to open or close the passage.</span>")
					//var/obj/structure/falsewall/F = new (loc)
					//transfer_fingerprints_to(F)
					qdel(src)
			else
				if(S.get_amount() < 2)
					to_chat(user, "<span class='warning'>You need two sheets of metal to finish a wall!</span>")
					return
				to_chat(user, "<span class='notice'>You start adding plating...</span>")
				if (do_after(user, 40, target = src))
					if(S.get_amount() < 2)
						return
					S.use(2)
					to_chat(user, "<span class='notice'>You add the plating.</span>")
					var/turf/T = get_turf(src)
					T.PlaceOnTop(/turf/closed/wall)
					transfer_fingerprints_to(T)
					qdel(src)
				return

		if(istype(S, /obj/item/stack/sheet/plasteel))
			if(state == GIRDER_DISPLACED)
				if(S.get_amount() < 2)
					to_chat(user, "<span class='warning'>You need at least two sheets to create a false wall!</span>")
					return
				to_chat(user, "<span class='notice'>You start building a reinforced false wall...</span>")
				if(do_after(user, 20, target = src))
					if(S.get_amount() < 2)
						return
					S.use(2)
					to_chat(user, "<span class='notice'>You create a reinforced false wall. Push on it to open or close the passage.</span>")
					//var/obj/structure/falsewall/reinforced/FW = new (loc)
					//transfer_fingerprints_to(FW)
					qdel(src)
			else
				if(state == GIRDER_REINF)
					if(S.get_amount() < 1)
						return
					to_chat(user, "<span class='notice'>You start finalizing the reinforced wall...</span>")
					if(do_after(user, 50, target = src))
						if(S.get_amount() < 1)
							return
						S.use(1)
						to_chat(user, "<span class='notice'>You fully reinforce the wall.</span>")
						var/turf/T = get_turf(src)
						T.PlaceOnTop(/turf/closed/wall/r_wall)
						transfer_fingerprints_to(T)
						qdel(src)
					return
				else
					if(S.get_amount() < 1)
						return
					to_chat(user, "<span class='notice'>You start reinforcing the girder...</span>")
					if(do_after(user, 60, target = src))
						if(S.get_amount() < 1)
							return
						S.use(1)
						to_chat(user, "<span class='notice'>You reinforce the girder.</span>")
						var/obj/structure/girder/reinforced/R = new (loc)
						transfer_fingerprints_to(R)
						qdel(src)
					return

		//if(S.sheettype && S.sheettype != "runed")
		//	var/M = S.sheettype
		//	if(state == GIRDER_DISPLACED)
		//		if(S.get_amount() < 2)
		//			to_chat(user, "<span class='warning'>You need at least two sheets to create a false wall!</span>")
		//			return
		//		if(do_after(user, 20, target = src))
		//			if(S.get_amount() < 2)
		//				return
		//			S.use(2)
		//			to_chat(user, "<span class='notice'>You create a false wall. Push on it to open or close the passage.</span>")
		//			var/F = text2path("/obj/structure/falsewall/[M]")
		//			var/obj/structure/FW = new F (loc)
		//			transfer_fingerprints_to(FW)
		//			qdel(src)
		//	else
		//		if(S.get_amount() < 2)
		//			to_chat(user, "<span class='warning'>You need at least two sheets to add plating!</span>")
		//			return
		//		to_chat(user, "<span class='notice'>You start adding plating...</span>")
		//		if (do_after(user, 40, target = src))
		//			if(S.get_amount() < 2)
		//				return
		//			S.use(2)
		//			to_chat(user, "<span class='notice'>You add the plating.</span>")
		//			var/turf/T = get_turf(src)
		//			T.PlaceOnTop(text2path("/turf/closed/wall/mineral/[M]"))
		//			transfer_fingerprints_to(T)
		//			qdel(src)
		//		return

		add_hiddenprint(user)

	//else if(istype(W, /obj/item/pipe))
	//	var/obj/item/pipe/P = W
	//	if (P.pipe_type in list(0, 1, 5))
	//		if(!user.transferItemToLoc(P, drop_location()))
	//			return
	//		to_chat(user, "<span class='notice'>You fit the pipe into \the [src].</span>")
	else
		return ..()

/obj/structure/girder/screwdriver_act(mob/user, obj/item/tool)
	if(..())
		return TRUE

	. = FALSE
	if(state == GIRDER_DISPLACED)
		user.visible_message("<span class='warning'>[user] disassembles the girder.</span>",
							 "<span class='notice'>You start to disassemble the girder...</span>",
							 "You hear clanking and banging noises.")
		if(tool.use_tool(src, user, 40, volume=100))
			if(state != GIRDER_DISPLACED)
				return
			state = GIRDER_DISASSEMBLED
			to_chat(user, "<span class='notice'>You disassemble the girder.</span>")
			var/obj/item/stack/sheet/metal/M = new (loc, 2)
			M.add_fingerprint(user)
			qdel(src)
		return TRUE

	else if(state == GIRDER_REINF)
		to_chat(user, "<span class='notice'>You start unsecuring support struts...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			if(state != GIRDER_REINF)
				return
			to_chat(user, "<span class='notice'>You unsecure the support struts.</span>")
			state = GIRDER_REINF_STRUTS
		return TRUE

	else if(state == GIRDER_REINF_STRUTS)
		to_chat(user, "<span class='notice'>You start securing support struts...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			if(state != GIRDER_REINF_STRUTS)
				return
			to_chat(user, "<span class='notice'>You secure the support struts.</span>")
			state = GIRDER_REINF
		return TRUE

/obj/structure/girder/wirecutter_act(mob/user, obj/item/tool)
	. = FALSE
	if(state == GIRDER_REINF_STRUTS)
		to_chat(user, "<span class='notice'>You start removing the inner grille...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You remove the inner grille.</span>")
			new /obj/item/stack/sheet/plasteel(get_turf(src))
			var/obj/structure/girder/G = new (loc)
			transfer_fingerprints_to(G)
			qdel(src)
		return TRUE

/obj/structure/girder/wrench_act(mob/user, obj/item/tool)
	. = FALSE
	if(state == GIRDER_DISPLACED)
		if(!isfloorturf(loc))
			to_chat(user, "<span class='warning'>A floor must be present to secure the girder!</span>")

		to_chat(user, "<span class='notice'>You start securing the girder...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You secure the girder.</span>")
			var/obj/structure/girder/G = new (loc)
			transfer_fingerprints_to(G)
			qdel(src)
		return TRUE
	else if(state == GIRDER_NORMAL && can_displace)
		to_chat(user, "<span class='notice'>You start unsecuring the girder...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You unsecure the girder.</span>")
			var/obj/structure/girder/displaced/D = new (loc)
			transfer_fingerprints_to(D)
			qdel(src)
		return TRUE

/obj/structure/girder/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/remains = pick(/obj/item/stack/rods, /obj/item/stack/sheet/metal)
		new remains(loc)
	qdel(src)

/obj/structure/girder/displaced
	name = "displaced girder"
	icon_state = "displaced"
	anchored = FALSE
	state = GIRDER_DISPLACED
	girderpasschance = 25
	max_integrity = 120

/obj/structure/girder/reinforced
	name = "reinforced girder"
	icon_state = "reinforced"
	state = GIRDER_REINF
	girderpasschance = 0
	max_integrity = 350