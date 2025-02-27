/turf/open/floor
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	baseturfs = /turf/open/floor/plating

	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	
	var/icon_regular_floor = "floor"
	var/icon_plating = "plating"
	//thermal_conductivity = 0.040
	//heat_capacity = 10000
	intact = 1
	var/broken = 0
	var/burnt = 0
	var/floor_tile = null
	var/list/broken_states
	var/list/burnt_states

	tiled_dirt = TRUE

/turf/open/floor/Initialize(mapload)

	if (!broken_states)
		broken_states = typelist("broken_states", list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5"))
	else
		broken_states = typelist("broken_states", broken_states)
	burnt_states = typelist("burnt_states", burnt_states)
	if(!broken && broken_states && (icon_state in broken_states))
		broken = TRUE
	if(!burnt && burnt_states && (icon_state in burnt_states))
		burnt = TRUE
	. = ..()
	//var/static/list/icons_to_ignore_at_floor_init = list("foam_plating", "plating","light_on","light_on_flicker1","light_on_flicker2",
	//				"light_on_clicker3","light_on_clicker4","light_on_clicker5",
	//				"light_on_broken","light_off","wall_thermite","grass", "sand",
	//				"asteroid","asteroid_dug",
	//				"asteroid0","asteroid1","asteroid2","asteroid3","asteroid4",
	//				"asteroid5","asteroid6","asteroid7","asteroid8","asteroid9","asteroid10","asteroid11","asteroid12",
	//				"basalt","basalt_dug",
	//				"basalt0","basalt1","basalt2","basalt3","basalt4",
	//				"basalt5","basalt6","basalt7","basalt8","basalt9","basalt10","basalt11","basalt12",
	//				"oldburning","light-on-r","light-on-y","light-on-g","light-on-b", "wood", "carpetsymbol", "carpetstar",
	//				"carpetcorner", "carpetside", "carpet", "ironsand1", "ironsand2", "ironsand3", "ironsand4", "ironsand5",
	//				"ironsand6", "ironsand7", "ironsand8", "ironsand9", "ironsand10", "ironsand11",
	//				"ironsand12", "ironsand13", "ironsand14", "ironsand15")
	//if(broken || burnt || (icon_state in icons_to_ignore_at_floor_init))
	//	icon_regular_floor = "floor"
	//else
	//	icon_regular_floor = icon_state
	//if(mapload && prob(33))
	//	MakeDirty()

/turf/open/floor/ex_act(severity, target)
	var/shielded = is_shielded()
	..()
	if(severity != 1 && shielded && target != src)
		return
	if(target == src)
		ScrapeAway()
		return
	if(target != null)
		severity = 3

	switch(severity)
		if(1)
			ScrapeAway(2)
		if(2)
			switch(pick(1,2;75,3))
				if(1)
					if(!length(baseturfs) || !ispath(baseturfs[baseturfs.len-1], /turf/open/floor))
						ScrapeAway()
						ReplaceWithLattice()
					else
						ScrapeAway(2)
					if(prob(33))
						new /obj/item/stack/sheet/metal(src)
				if(2)
					ScrapeAway(2)
				if(3)
					if(prob(80))
						ScrapeAway()
					else
						break_tile()
					hotspot_expose(1000,CELL_VOLUME)
					if(prob(33))
						new /obj/item/stack/sheet/metal(src)
		if(3)
			if (prob(50))
				src.break_tile()
				src.hotspot_expose(1000,CELL_VOLUME)

/turf/open/floor/is_shielded()
	for(var/obj/structure/A in contents)
		if(A.level == 3)
			return 1

/turf/open/floor/proc/update_icon()
	update_visuals()
	return 1

/turf/open/floor/attack_paw(mob/user)
	return attack_hand(user)

/turf/open/floor/proc/break_tile()
	if(broken)
		return
	icon_state = pick(broken_states)
	broken = 1

/turf/open/floor/burn_tile()
	if(broken || burnt)
		return
	if(burnt_states.len)
		icon_state = pick(burnt_states)
	else
		icon_state = pick(broken_states)
	burnt = 1

/turf/open/floor/proc/make_plating()
	return ScrapeAway()

/turf/open/floor/ChangeTurf(path, new_baseturf, flags)
	if(!isfloorturf(src))
		return ..()
	if(!ispath(path, /turf/open/floor))
		return ..()
	var/old_icon = icon_regular_floor
	var/old_dir = dir
	var/turf/open/floor/W = ..()
	W.icon_regular_floor = old_icon
	W.setDir(old_dir)
	W.update_icon()
	return W

/turf/open/floor/attackby(obj/item/C, mob/user, params)
	if(!C || !user)
		return 1
	if(..())
		return 1
	if(intact && istype(C, /obj/item/stack/tile))
		try_replace_tile(C, user, params)
	return 0

/turf/open/floor/crowbar_act(mob/living/user, obj/item/I)
	return intact ? pry_tile(I, user) : FALSE

/turf/open/floor/proc/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	if(T.turf_type == type)
		return
	var/obj/item/crowbar/CB = user.is_holding_item_of_type(/obj/item/crowbar)
	if(!CB)
		return
	var/turf/open/floor/plating/P = pry_tile(CB, user, TRUE)
	if (!istype(P, /turf/open/floor/plating))
		return
	P.attackby(T, user, params)

/turf/open/floor/proc/pry_tile(obj/item/I, mob/user, silent = FALSE)
	I.play_tool_sound(src, 80)
	return remove_tile(user, silent)

/turf/open/floor/proc/remove_tile(mob/user, silent = FALSE, make_tile = TRUE)
	if(broken || burnt)
		broken = 0
		burnt = 0
		if(user && !silent)
			to_chat(user, "<span class='notice'>You remove the broken plating.</span>")
	else
		if(user && !silent)
			to_chat(user, "<span class='notice'>You remove the floor tile.</span>")
		if(floor_tile && make_tile)
			new floor_tile(src)
	return make_plating()