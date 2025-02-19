/turf/open/floor/engine
	name = "reinforced floor"
	desc = "Extremely sturdy."
	icon_state = "engine"
	//thermal_conductivity = 0.025
	//heat_capacity = INFINITY
	floor_tile = /obj/item/stack/rods
	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE

/turf/open/floor/engine/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>The reinforcement rods are <b>wrenched</b> firmly in place.</span>")

/turf/open/floor/engine/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/engine/break_tile()
	return

/turf/open/floor/engine/burn_tile()
	return

/turf/open/floor/engine/make_plating(force = 0)
	if(force)
		..()
	return

/turf/open/floor/engine/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/engine/crowbar_act(mob/living/user, obj/item/I)
	return

/turf/open/floor/engine/wrench_act(mob/living/user, obj/item/I)
	to_chat(user, "<span class='notice'>You begin removing rods...</span>")
	if(I.use_tool(src, user, 30, volume=80))
		if(!istype(src, /turf/open/floor/engine))
			return TRUE
		if(floor_tile)
			new floor_tile(src, 2)
		ScrapeAway()
	return TRUE

///turf/open/floor/engine/ex_act(severity,target)
//	var/shielded = is_shielded()
//	contents_explosion(severity, target)
//	if(severity != 1 && shielded && target != src)
//		return
//	if(target == src)
//		ScrapeAway()
//		return
//	switch(severity)
//		if(1)
//			if(prob(80))
//				if(!length(baseturfs) || !ispath(baseturfs[baseturfs.len-1], /turf/open/floor))
//					ScrapeAway()
//					ReplaceWithLattice()
//				else
//					ScrapeAway(2)
//			else if(prob(50))
//				ScrapeAway(2)
//			else
//				ScrapeAway()
//		if(2)
//			if(prob(50))
//				ScrapeAway()

///turf/open/floor/engine/singularity_pull(S, current_size)
//	..()
//	if(current_size >= STAGE_FIVE)
//		if(floor_tile)
//			if(prob(30))
//				new floor_tile(src)
//				make_plating()
//		else if(prob(30))
//			ReplaceWithLattice()

/turf/open/floor/engine/attack_paw(mob/user)
	return attack_hand(user)

/turf/open/floor/engine/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	user.Move_Pulled(src)

/turf/open/floor/engine/n2o
	article = "an"
	name = "\improper N2O floor"
	initial_gas_mix = ATMOS_TANK_N2O

/turf/open/floor/engine/co2
	name = "\improper CO2 floor"
	initial_gas_mix = ATMOS_TANK_CO2

/turf/open/floor/engine/plasma
	name = "plasma floor"
	initial_gas_mix = ATMOS_TANK_PLASMA

/turf/open/floor/engine/o2
	name = "\improper O2 floor"
	initial_gas_mix = ATMOS_TANK_O2

/turf/open/floor/engine/n2
	article = "an"
	name = "\improper N2 floor"
	initial_gas_mix = ATMOS_TANK_N2

/turf/open/floor/engine/air
	name = "air floor"
	initial_gas_mix = ATMOS_TANK_AIRMIX

/turf/open/floor/engine/cult
	name = "engraved floor"
	desc = "The air smells strangely over this sinister flooring."
	icon_state = "plating"
	floor_tile = null
	//var/obj/effect/clockwork/overlay/floor/bloodcult/realappearance


/turf/open/floor/engine/cult/Initialize()
	. = ..()
	new /obj/effect/temp_visual/cult/turf/floor(src)
	//realappearance = new /obj/effect/clockwork/overlay/floor/bloodcult(src)
	//realappearance.linked = src

/turf/open/floor/engine/cult/Destroy()
	be_removed()
	return ..()

/turf/open/floor/engine/cult/ChangeTurf(path, new_baseturf, flags)
	if(path != type)
		be_removed()
	return ..()

/turf/open/floor/engine/cult/proc/be_removed()
	//qdel(realappearance)
	//realappearance = null

///turf/open/floor/engine/cult/ratvar_act()
//	. = ..()
//	if(istype(src, /turf/open/floor/engine/cult))
//		var/previouscolor = color
//		color = "#FAE48C"
//		animate(src, color = previouscolor, time = 8)
//		addtimer(CALLBACK(src, /atom/proc/update_atom_colour), 8)

/turf/open/floor/engine/cult/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/engine/vacuum
	name = "vacuum floor"
	initial_gas_mix = AIRLESS_ATMOS