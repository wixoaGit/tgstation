/turf/closed/mineral
	name = "rock"
	icon = 'icons/turf/mining.dmi'
	icon_state = "rock"
	var/smooth_icon = 'icons/turf/smoothrocks.dmi'
	smooth = SMOOTH_MORE|SMOOTH_BORDER
	canSmoothWith = null
	baseturfs = /turf/open/floor/plating/asteroid/airless
	initial_gas_mix = AIRLESS_ATMOS
	opacity = 1
	density = TRUE
	layer = EDGED_TURF_LAYER
	temperature = TCMB
	var/environment_type = "asteroid"
	var/turf/open/floor/plating/turf_type = /turf/open/floor/plating/asteroid/airless
	var/mineralType = null
	var/mineralAmt = 3
	var/spread = 0
	var/spreadChance = 0
	var/last_act = 0
	var/scan_state = ""
	var/defer_change = 0

/turf/closed/mineral/Initialize()
	if (!canSmoothWith)
		canSmoothWith = list(/turf/closed/mineral, /turf/closed/indestructible)
	var/matrix/M = new
	M.Translate(-4, -4)
	transform = M
	icon = smooth_icon
	. = ..()
	//if (mineralType && mineralAmt && spread && spreadChance)
	//	for(var/dir in GLOB.cardinals)
	//		if(prob(spreadChance))
	//			var/turf/T = get_step(src, dir)
	//			if(istype(T, /turf/closed/mineral/random))
	//				Spread(T)

/turf/closed/mineral/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	if(turf_type)
		underlay_appearance.icon = initial(turf_type.icon)
		underlay_appearance.icon_state = initial(turf_type.icon_state)
		return TRUE
	return ..()

/turf/closed/mineral/attackby(obj/item/I, mob/user, params)
	if (!user.IsAdvancedToolUser())
		to_chat(usr, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	if(I.tool_behaviour == TOOL_MINING)
		var/turf/T = user.loc
		if (!isturf(T))
			return

		if(last_act + (40 * I.toolspeed) > world.time)
			return
		last_act = world.time
		to_chat(user, "<span class='notice'>You start picking...</span>")

		if(I.use_tool(src, user, 40, volume=50))
			if(ismineralturf(src))
				to_chat(user, "<span class='notice'>You finish cutting into the rock.</span>")
				gets_drilled(user)
				//SSblackbox.record_feedback("tally", "pick_used_mining", 1, I.type)
	else
		return attack_hand(user)

/turf/closed/mineral/proc/gets_drilled()
	if (mineralType && (mineralAmt > 0))
		new mineralType(src, mineralAmt)
		//SSblackbox.record_feedback("tally", "ore_mined", mineralAmt, mineralType)
	//for(var/obj/effect/temp_visual/mining_overlay/M in src)
	//	qdel(M)
	var/flags = NONE
	if(defer_change)
		flags = CHANGETURF_DEFER_CHANGE
	ScrapeAway(null, flags)
	addtimer(CALLBACK(src, .proc/AfterChange), 1, TIMER_UNIQUE)
	playsound(src, 'sound/effects/break_stone.ogg', 50, 1)

/turf/closed/mineral/ex_act(severity, target)
	..()
	switch(severity)
		if(3)
			if (prob(75))
				gets_drilled(null, 1)
		if(2)
			if (prob(90))
				gets_drilled(null, 1)
		if(1)
			gets_drilled(null, 1)
	return

/turf/closed/mineral/titanium
	//mineralType = /obj/item/stack/ore/titanium
	spreadChance = 5
	spread = 1
	scan_state = "rock_Titanium"

/turf/closed/mineral/ash_rock
	name = "rock"
	icon = 'icons/turf/mining.dmi'
	smooth_icon = 'icons/turf/walls/rock_wall.dmi'
	icon_state = "rock2"
	smooth = SMOOTH_MORE|SMOOTH_BORDER
	canSmoothWith = list (/turf/closed)
	baseturfs = /turf/open/floor/plating/ashplanet/wateryrock
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	environment_type = "waste"
	turf_type = /turf/open/floor/plating/ashplanet/rocky
	defer_change = 1