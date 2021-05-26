/turf/open/floor/plating/asteroid
	gender = PLURAL
	name = "asteroid sand"
	baseturfs = /turf/open/floor/plating/asteroid
	icon = 'icons/turf/floors.dmi'
	icon_state = "asteroid"
	icon_plating = "asteroid"
	postdig_icon_change = TRUE
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	var/environment_type = "asteroid"
	var/turf_type = /turf/open/floor/plating/asteroid
	var/floor_variance = 20
	attachment_holes = FALSE
	//var/obj/item/stack/digResult = /obj/item/stack/ore/glass/basalt
	var/dug

/turf/open/floor/plating/asteroid/Initialize()
	var/proper_name = name
	. = ..()
	name = proper_name
	if(prob(floor_variance))
		icon_state = "[environment_type][rand(0,12)]"

/turf/open/floor/plating/asteroid/proc/getDug()
	//new digResult(src, 5)
	if(postdig_icon_change)
		if(!postdig_icon)
			icon_plating = "[environment_type]_dug"
			icon_state = "[environment_type]_dug"
	dug = TRUE

/turf/open/floor/plating/asteroid/proc/can_dig(mob/user)
	if(!dug)
		return TRUE
	if(user)
		to_chat(user, "<span class='notice'>Looks like someone has dug here already.</span>")

/turf/open/floor/plating/asteroid/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/plating/asteroid/burn_tile()
	return

/turf/open/floor/plating/asteroid/MakeSlippery(wet_setting, min_wet_time, wet_time_to_add, max_wet_time, permanent)
	return

///turf/open/floor/plating/asteroid/MakeDry()
//	return

/turf/open/floor/plating/asteroid/attackby(obj/item/W, mob/user, params)
	. = ..()
	if(!.)
		if(W.tool_behaviour == TOOL_SHOVEL || W.tool_behaviour == TOOL_MINING)
			if(!can_dig(user))
				return TRUE

			if(!isturf(user.loc))
				return

			to_chat(user, "<span class='notice'>You start digging...</span>")

			if(W.use_tool(src, user, 40, volume=50))
				if(!can_dig(user))
					return TRUE
				to_chat(user, "<span class='notice'>You dig a hole.</span>")
				getDug()
				//SSblackbox.record_feedback("tally", "pick_used_mining", 1, W.type)
				return TRUE
		//else if(istype(W, /obj/item/storage/bag/ore))
		//	for(var/obj/item/stack/ore/O in src)
		//		SEND_SIGNAL(W, COMSIG_PARENT_ATTACKBY, O)

/turf/open/floor/plating/asteroid/ex_act(severity, target)
	. = SEND_SIGNAL(src, COMSIG_ATOM_EX_ACT, severity, target)
	contents_explosion(severity, target)

/turf/open/floor/plating/asteroid/getDug()
	set_light(0)
	return ..()

/proc/set_basalt_light(turf/open/floor/B)
	//switch(B.icon_state)
	//	if("basalt1", "basalt2", "basalt3")
	//		B.set_light(2, 0.6, LIGHT_COLOR_LAVA)
	//	if("basalt5", "basalt9")
	//		B.set_light(1.4, 0.6, LIGHT_COLOR_LAVA)

/turf/open/floor/plating/asteroid/airless
	initial_gas_mix = AIRLESS_ATMOS
	baseturfs = /turf/open/floor/plating/asteroid/airless
	turf_type = /turf/open/floor/plating/asteroid/airless

/turf/open/floor/plating/asteroid/snow
	gender = PLURAL
	name = "snow"
	desc = "Looks cold."
	icon = 'icons/turf/snow.dmi'
	baseturfs = /turf/open/floor/plating/asteroid/snow
	icon_state = "snow"
	icon_plating = "snow"
	initial_gas_mix = FROZEN_ATMOS
	slowdown = 2
	environment_type = "snow"
	flags_1 = NONE
	planetary_atmos = TRUE
	burnt_states = list("snow_dug")
	bullet_sizzle = TRUE
	bullet_bounce_sound = null
	//digResult = /obj/item/stack/sheet/mineral/snow

/turf/open/floor/plating/asteroid/snow/burn_tile()
	if(!burnt)
		visible_message("<span class='danger'>[src] melts away!.</span>")
		slowdown = 0
		burnt = TRUE
		icon_state = "snow_dug"
		return TRUE
	return FALSE

/turf/open/floor/plating/asteroid/snow/airless
	initial_gas_mix = AIRLESS_ATMOS