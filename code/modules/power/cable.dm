GLOBAL_LIST_INIT(cable_colors, list(
	"yellow" = "#ffff00",
	"green" = "#00aa00",
	"blue" = "#1919c8",
	"pink" = "#ff3cc8",
	"orange" = "#ff8000",
	"cyan" = "#00ffff",
	"white" = "#ffffff",
	"red" = "#ff0000"
	))

/obj/structure/cable
	name = "power cable"
	desc = "A flexible, superconducting insulated cable for heavy-duty power transfer."
	icon = 'icons/obj/power_cond/cables.dmi'
	icon_state = "0-1"
	level = 1
	layer = WIRE_LAYER
	anchored = TRUE
	obj_flags = CAN_BE_HIT | ON_BLUEPRINTS
	var/d1 = 0
	var/d2 = 1
	var/datum/powernet/powernet
	var/obj/item/stack/cable_coil/stored

	var/cable_color = "red"
	color = "#ff0000"

/obj/structure/cable/yellow
	cable_color = "yellow"
	color = "#ffff00"

/obj/structure/cable/green
	cable_color = "green"
	color = "#00aa00"

/obj/structure/cable/blue
	cable_color = "blue"
	color = "#1919c8"

/obj/structure/cable/pink
	cable_color = "pink"
	color = "#ff3cc8"

/obj/structure/cable/orange
	cable_color = "orange"
	color = "#ff8000"

/obj/structure/cable/cyan
	cable_color = "cyan"
	color = "#00ffff"

/obj/structure/cable/white
	cable_color = "white"
	color = "#ffffff"

/obj/structure/cable/Initialize(mapload, param_color)
	. = ..()

	var/dash = findtext(icon_state, "-")
	d1 = text2num( copytext( icon_state, 1, dash ) )
	d2 = text2num( copytext( icon_state, dash+1 ) )

	var/turf/T = get_turf(src)
	if(level==1)
		hide(T.intact)
	GLOB.cable_list += src

	if(d1)
		stored = new/obj/item/stack/cable_coil(null,2,cable_color)
	else
		stored = new/obj/item/stack/cable_coil(null,1,cable_color)

	var/list/cable_colors = GLOB.cable_colors
	cable_color = param_color || cable_color || pick(cable_colors)
	if(cable_colors[cable_color])
		cable_color = cable_colors[cable_color]
	update_icon()

/obj/structure/cable/Destroy()
	if(powernet)
		cut_cable_from_powernet()
	GLOB.cable_list -= src
	return ..()

/obj/structure/cable/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/turf/T = loc
		stored.forceMove(T)
	qdel(src)

/obj/structure/cable/hide(i)
	if(level == 1 && isturf(loc))
		invisibility = i ? INVISIBILITY_MAXIMUM : 0
	update_icon()

/obj/structure/cable/update_icon()
	icon_state = "[d1]-[d2]"
	color = null
	add_atom_colour(cable_color, FIXED_COLOUR_PRIORITY)

/obj/structure/cable/proc/handlecable(obj/item/W, mob/user, params)
	var/turf/T = get_turf(src)
	if(T.intact)
		return
	if(W.tool_behaviour == TOOL_WIRECUTTER)
		//if (shock(user, 50))
		//	return
		user.visible_message("[user] cuts the cable.", "<span class='notice'>You cut the cable.</span>")
		stored.add_fingerprint(user)
		//investigate_log("was cut by [key_name(usr)] in [AREACOORD(src)]", INVESTIGATE_WIRES)
		deconstruct()
		return

	else if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/coil = W
		if (coil.get_amount() < 1)
			to_chat(user, "<span class='warning'>Not enough cable!</span>")
			return
		coil.cable_join(src, user)

	//else if(istype(W, /obj/item/twohanded/rcl))
	//	var/obj/item/twohanded/rcl/R = W
	//	if(R.loaded)
	//		R.loaded.cable_join(src, user)
	//		R.is_empty(user)

	else if(W.tool_behaviour == TOOL_MULTITOOL)
		if(powernet && (powernet.avail > 0))
			to_chat(user, "<span class='danger'>Total power: [DisplayPower(powernet.avail)]\nLoad: [DisplayPower(powernet.load)]\nExcess power: [DisplayPower(surplus())]</span>")
		else
			to_chat(user, "<span class='danger'>The cable is not powered.</span>")
		//shock(user, 5, 0.2)

	add_fingerprint(user)

/obj/structure/cable/attackby(obj/item/W, mob/user, params)
	handlecable(W, user, params)

/obj/structure/cable/proc/update_stored(length = 1, colorC = "red")
	stored.amount = length
	stored.item_color = colorC
	stored.update_icon()

/obj/structure/cable/proc/surplus()
	if(powernet)
		return CLAMP(powernet.avail-powernet.load, 0, powernet.avail)
	else
		return 0

/obj/structure/cable/proc/mergeDiagonalsNetworks(direction)
	var/turf/T  = get_step(src, direction&3)

	for(var/obj/structure/cable/C in T)

		if(!C)
			continue

		if(src == C)
			continue

		if(C.d1 == (direction^3) || C.d2 == (direction^3))
			if(!C.powernet)
				var/datum/powernet/newPN = new()
				newPN.add_cable(C)

			if(powernet)
				merge_powernets(powernet,C.powernet)
			else
				C.powernet.add_cable(src)

	T  = get_step(src, direction&12)

	for(var/obj/structure/cable/C in T)

		if(!C)
			continue

		if(src == C)
			continue
		if(C.d1 == (direction^12) || C.d2 == (direction^12)) 
			if(!C.powernet)
				var/datum/powernet/newPN = new()
				newPN.add_cable(C)

			if(powernet)
				merge_powernets(powernet,C.powernet)
			else
				C.powernet.add_cable(src)

// merge with the powernets of power objects in the given direction
/obj/structure/cable/proc/mergeConnectedNetworks(direction)

	var/fdir = (!direction)? 0 : turn(direction, 180)

	if(!(d1 == direction || d2 == direction))
		return

	var/turf/TB  = get_step(src, direction)

	for(var/obj/structure/cable/C in TB)

		if(!C)
			continue

		if(src == C)
			continue

		if(C.d1 == fdir || C.d2 == fdir)
			if(!C.powernet)
				var/datum/powernet/newPN = new()
				newPN.add_cable(C)

			if(powernet)
				merge_powernets(powernet,C.powernet)
			else
				C.powernet.add_cable(src)

/obj/structure/cable/proc/mergeConnectedNetworksOnTurf()
	var/list/to_connect = list()

	if(!powernet)
		var/datum/powernet/newPN = new()
		newPN.add_cable(src)

	for(var/AM in loc)
		if(istype(AM, /obj/structure/cable))
			var/obj/structure/cable/C = AM
			if(C.d1 == d1 || C.d2 == d1 || C.d1 == d2 || C.d2 == d2)
				if(C.powernet == powernet)
					continue
				if(C.powernet)
					merge_powernets(powernet, C.powernet)
				else
					powernet.add_cable(C)

		else if(istype(AM, /obj/machinery/power/apc))
			var/obj/machinery/power/apc/N = AM
			if(!N.terminal)
				continue

			if(N.terminal.powernet == powernet)
				continue

			to_connect += N.terminal

		else if(istype(AM, /obj/machinery/power))
			var/obj/machinery/power/M = AM

			if(M.powernet == powernet)
				continue

			to_connect += M

	for(var/obj/machinery/power/PM in to_connect)
		if(!PM.connect_to_network())
			PM.disconnect_from_network()

/obj/structure/cable/proc/get_connections(powernetless_only = 0)
	. = list()
	var/turf/T

	if(d1)
		T = get_step(src, d1)
		if(T)
			. += power_list(T, src, turn(d1, 180), powernetless_only)

	if(d1&(d1-1))
		T = get_step(src,d1&3)
		if(T)
			. += power_list(T, src, d1 ^ 3, powernetless_only)
		T = get_step(src,d1&12)
		if(T)
			. += power_list(T, src, d1 ^ 12, powernetless_only)

	. += power_list(loc, src, d1, powernetless_only)

	T = get_step(src, d2)
	if(T)
		. += power_list(T, src, turn(d2, 180), powernetless_only)

	if(d2&(d2-1))
		T = get_step(src,d2&3)
		if(T)
			. += power_list(T, src, d2 ^ 3, powernetless_only)
		T = get_step(src,d2&12)
		if(T)
			. += power_list(T, src, d2 ^ 12, powernetless_only)
	. += power_list(loc, src, d2, powernetless_only)

	return .

/obj/structure/cable/proc/denode()
	var/turf/T1 = loc
	if(!T1)
		return

	var/list/powerlist = power_list(T1,src,0,0)
	if(powerlist.len>0)
		var/datum/powernet/PN = new()
		propagate_network(powerlist[1],PN)

		if(PN.is_empty())
			qdel(PN)

/obj/structure/cable/proc/auto_propogate_cut_cable(obj/O)
	if(O && !QDELETED(O))
		var/datum/powernet/newPN = new()
		propagate_network(O, newPN)

/obj/structure/cable/proc/cut_cable_from_powernet(remove=TRUE)
	var/turf/T1 = loc
	var/list/P_list
	if(!T1)
		return
	if(d1)
		T1 = get_step(T1, d1)
		P_list = power_list(T1, src, turn(d1,180),0,cable_only = 1)

	P_list += power_list(loc, src, d1, 0, cable_only = 1)


	if(P_list.len == 0)
		powernet.remove_cable(src)

		for(var/obj/machinery/power/P in T1)
			if(!P.connect_to_network())
				P.disconnect_from_network()
		return

	var/obj/O = P_list[1]
	if(remove)
		moveToNullspace()
	powernet.remove_cable(src)

	addtimer(CALLBACK(O, .proc/auto_propogate_cut_cable, O), 0)

	if(d1 == 0)
		for(var/obj/machinery/power/P in T1)
			if(!P.connect_to_network())
				P.disconnect_from_network()

//GLOBAL_LIST_INIT(cable_coil_recipes, list (new/datum/stack_recipe("cable restraints", /obj/item/restraints/handcuffs/cable, 15)))
GLOBAL_LIST_INIT(cable_coil_recipes, list ())//not_actual

/obj/item/stack/cable_coil
	name = "cable coil"
	custom_price = 15
	gender = NEUTER
	icon = 'icons/obj/power.dmi'
	icon_state = "coil"
	item_state = "coil"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	max_amount = MAXCOIL
	amount = MAXCOIL
	merge_type = /obj/item/stack/cable_coil
	item_color = "red"
	desc = "A coil of insulated power cable."
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	materials = list(MAT_METAL=10, MAT_GLASS=5)
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	attack_verb = list("whipped", "lashed", "disciplined", "flogged")
	singular_name = "cable piece"
	full_w_class = WEIGHT_CLASS_SMALL
	grind_results = list("copper" = 2)
	usesound = 'sound/items/deconstruct.ogg'

/obj/item/stack/cable_coil/suicide_act(mob/user)
	if(locate(/obj/structure/chair/stool) in get_turf(user))
		user.visible_message("<span class='suicide'>[user] is making a noose with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	else
		user.visible_message("<span class='suicide'>[user] is strangling [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return(OXYLOSS)

/obj/item/stack/cable_coil/Initialize(mapload, new_amount = null, param_color = null)
	. = ..()

	var/list/cable_colors = GLOB.cable_colors
	item_color = param_color || item_color || pick(cable_colors)
	if(cable_colors[item_color])
		item_color = cable_colors[item_color]

	pixel_x = rand(-2,2)
	pixel_y = rand(-2,2)
	update_icon()
	recipes = GLOB.cable_coil_recipes

/obj/item/stack/cable_coil/attack(mob/living/carbon/human/H, mob/user)
	if(!istype(H))
		return ..()

	var/obj/item/bodypart/affecting = H.get_bodypart(check_zone(user.zone_selected))
	if(affecting && affecting.status == BODYPART_ROBOTIC)
		if(user == H)
			user.visible_message("<span class='notice'>[user] starts to fix some of the wires in [H]'s [affecting.name].</span>", "<span class='notice'>You start fixing some of the wires in [H]'s [affecting.name].</span>")
			if(!do_mob(user, H, 50))
				return
		//if(item_heal_robotic(H, user, 0, 15))
		//	use(1)
		return
	else
		return ..()

/obj/item/stack/cable_coil/update_icon()
	icon_state = "[initial(item_state)][amount < 3 ? amount : ""]"
	name = "cable [amount < 3 ? "piece" : "coil"]"
	color = null
	add_atom_colour(item_color, FIXED_COLOUR_PRIORITY)

/obj/item/stack/cable_coil/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	var/obj/item/stack/cable_coil/new_cable = ..()
	if(istype(new_cable))
		new_cable.item_color = item_color
		new_cable.update_icon()

/obj/item/stack/cable_coil/update_icon()
	icon_state = "[initial(item_state)][amount < 3 ? amount : ""]"
	name = "cable [amount < 3 ? "piece" : "coil"]"
	color = null
	add_atom_colour(item_color, FIXED_COLOUR_PRIORITY)

/obj/item/stack/cable_coil/proc/get_new_cable(location)
	var/path = /obj/structure/cable
	return new path(location, item_color)

/obj/item/stack/cable_coil/proc/place_turf(turf/T, mob/user, dirnew)
	if(!isturf(user.loc))
		return

	if(!isturf(T) || T.intact || !T.can_have_cabling())
		to_chat(user, "<span class='warning'>You can only lay cables on catwalks and plating!</span>")
		return

	if(get_amount() < 1)
		to_chat(user, "<span class='warning'>There is no cable left!</span>")
		return

	if(get_dist(T,user) > 1)
		to_chat(user, "<span class='warning'>You can't lay cable at a place that far away!</span>")
		return

	var/dirn
	if(!dirnew)
		if(user.loc == T)
			dirn = user.dir
		else
			dirn = get_dir(T, user)
	else
		dirn = dirnew

	for(var/obj/structure/cable/LC in T)
		if(LC.d2 == dirn && LC.d1 == 0)
			to_chat(user, "<span class='warning'>There's already a cable at that position!</span>")
			return

	var/obj/structure/cable/C = get_new_cable(T)

	C.d1 = 0
	C.d2 = dirn
	C.add_fingerprint(user)
	C.update_icon()

	var/datum/powernet/PN = new()
	PN.add_cable(C)

	C.mergeConnectedNetworks(C.d2)
	C.mergeConnectedNetworksOnTurf()

	if(C.d2 & (C.d2 - 1))
		C.mergeDiagonalsNetworks(C.d2)

	use(1)

	//if(C.shock(user, 50))
	//	if(prob(50))
	//		new /obj/item/stack/cable_coil(get_turf(C), 1, C.color)
	//		C.deconstruct()

	return C

/obj/item/stack/cable_coil/proc/cable_join(obj/structure/cable/C, mob/user, var/showerror = TRUE)
	var/turf/U = user.loc
	if(!isturf(U))
		return

	var/turf/T = C.loc

	if(!isturf(T) || T.intact)
		return

	if(get_dist(C, user) > 1)
		to_chat(user, "<span class='warning'>You can't lay cable at a place that far away!</span>")
		return


	if(U == T)
		place_turf(T,user)
		return

	var/dirn = get_dir(C, user)

	if(C.d1 == dirn || C.d2 == dirn)
		if(!U.can_have_cabling())
			if (showerror)
				to_chat(user, "<span class='warning'>You can only lay cables on catwalks and plating!</span>")
			return
		if(U.intact)
			to_chat(user, "<span class='warning'>You can't lay cable there unless the floor tiles are removed!</span>")
			return
		else
			var/fdirn = turn(dirn, 180)

			for(var/obj/structure/cable/LC in U)
				if(LC.d1 == fdirn || LC.d2 == fdirn)
					if (showerror)
						to_chat(user, "<span class='warning'>There's already a cable at that position!</span>")
					return

			var/obj/structure/cable/NC = get_new_cable (U)

			NC.d1 = 0
			NC.d2 = fdirn
			NC.add_fingerprint(user)
			NC.update_icon()

			var/datum/powernet/newPN = new()
			newPN.add_cable(NC)

			NC.mergeConnectedNetworks(NC.d2)
			NC.mergeConnectedNetworksOnTurf()

			if(NC.d2 & (NC.d2 - 1))
				NC.mergeDiagonalsNetworks(NC.d2)

			use(1)

			//if (NC.shock(user, 50))
			//	if (prob(50))
			//		NC.deconstruct()

			return
	else if(C.d1 == 0)
		var/nd1 = C.d2
		var/nd2 = dirn


		if(nd1 > nd2)
			nd1 = dirn
			nd2 = C.d2


		for(var/obj/structure/cable/LC in T)
			if(LC == C)	
				continue
			if((LC.d1 == nd1 && LC.d2 == nd2) || (LC.d1 == nd2 && LC.d2 == nd1) )
				if (showerror)
					to_chat(user, "<span class='warning'>There's already a cable at that position!</span>")

				return


		C.update_icon()

		C.d1 = nd1
		C.d2 = nd2

		C.update_stored(2, item_color)

		C.add_fingerprint(user)
		C.update_icon()


		C.mergeConnectedNetworks(C.d1)
		C.mergeConnectedNetworks(C.d2)
		C.mergeConnectedNetworksOnTurf()

		if(C.d1 & (C.d1 - 1))
			C.mergeDiagonalsNetworks(C.d1)

		if(C.d2 & (C.d2 - 1))
			C.mergeDiagonalsNetworks(C.d2)

		use(1)

		//if (C.shock(user, 50))
		//	if (prob(50))
		//		C.deconstruct()
		//		return

		C.denode()
		return

/obj/item/stack/cable_coil/red
	item_color = "red"
	color = "#ff0000"

/obj/item/stack/cable_coil/yellow
	item_color = "yellow"
	color = "#ffff00"

/obj/item/stack/cable_coil/blue
	item_color = "blue"
	color = "#1919c8"

/obj/item/stack/cable_coil/green
	item_color = "green"
	color = "#00aa00"

/obj/item/stack/cable_coil/pink
	item_color = "pink"
	color = "#ff3ccd"

/obj/item/stack/cable_coil/orange
	item_color = "orange"
	color = "#ff8000"

/obj/item/stack/cable_coil/cyan
	item_color = "cyan"
	color = "#00ffff"

/obj/item/stack/cable_coil/white
	item_color = "white"

/obj/item/stack/cable_coil/random
	item_color = null
	color = "#ffffff"


/obj/item/stack/cable_coil/random/five
	amount = 5

/obj/item/stack/cable_coil/cut
	amount = null
	icon_state = "coil2"

/obj/item/stack/cable_coil/cut/Initialize(mapload)
	. = ..()
	if(!amount)
		amount = rand(1,2)
	pixel_x = rand(-2,2)
	pixel_y = rand(-2,2)
	update_icon()

/obj/item/stack/cable_coil/cut/red
	item_color = "red"
	color = "#ff0000"

/obj/item/stack/cable_coil/cut/yellow
	item_color = "yellow"
	color = "#ffff00"

/obj/item/stack/cable_coil/cut/blue
	item_color = "blue"
	color = "#1919c8"

/obj/item/stack/cable_coil/cut/green
	item_color = "green"
	color = "#00aa00"

/obj/item/stack/cable_coil/cut/pink
	item_color = "pink"
	color = "#ff3ccd"

/obj/item/stack/cable_coil/cut/orange
	item_color = "orange"
	color = "#ff8000"

/obj/item/stack/cable_coil/cut/cyan
	item_color = "cyan"
	color = "#00ffff"

/obj/item/stack/cable_coil/cut/white
	item_color = "white"

/obj/item/stack/cable_coil/cut/random
	item_color = null
	color = "#ffffff"