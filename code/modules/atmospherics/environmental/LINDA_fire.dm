/turf/proc/hotspot_expose(exposed_temperature, exposed_volume, soh = 0)
	return

/obj/effect/hotspot
	anchored = TRUE
	//mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'icons/effects/fire.dmi'
	icon_state = "1"
	layer = GASFIRE_LAYER
	light_range = LIGHT_RANGE_FIRE
	light_color = LIGHT_COLOR_FIRE
	//blend_mode = BLEND_ADD

	var/volume = 125
	var/temperature = FIRE_MINIMUM_TEMPERATURE_TO_EXIST
	var/just_spawned = TRUE
	var/bypassing = FALSE
	var/visual_update_tick = 0

/obj/effect/hotspot/Initialize(mapload, starting_volume, starting_temperature)
	. = ..()
	SSair.hotspots += src
	if(!isnull(starting_volume))
		volume = starting_volume
	if(!isnull(starting_temperature))
		temperature = starting_temperature
	perform_exposure()
	setDir(pick(GLOB.cardinals))
	air_update_turf()

/obj/effect/hotspot/proc/perform_exposure()
	var/turf/open/location = loc
	if(!istype(location) || !(location.air))
		return

	location.active_hotspot = src

	bypassing = !just_spawned && (volume > CELL_VOLUME*0.95)

	//if(bypassing)
	//	volume = location.air.reaction_results["fire"]*FIRE_GROWTH_RATE
	//	temperature = location.air.temperature
	//else
	//	var/datum/gas_mixture/affected = location.air.remove_ratio(volume/location.air.volume)
	//	if(affected)
	//		affected.temperature = temperature
	//		affected.react(src)
	//		temperature = affected.temperature
	//		volume = affected.reaction_results["fire"]*FIRE_GROWTH_RATE
	//		location.assume_air(affected)

	//for(var/A in location)
	//	var/atom/AT = A
	//	if(!QDELETED(AT) && AT != src)
	//		AT.fire_act(temperature, volume)
	return

#define INSUFFICIENT(path) (!location.air.gases[path] || location.air.gases[path][MOLES] < 0.5)
/obj/effect/hotspot/process()
	if(just_spawned)
		just_spawned = FALSE
		return

	var/turf/open/location = loc
	if(!istype(location))
		qdel(src)
		return

	if(location.excited_group)
		location.excited_group.reset_cooldowns()

	if((temperature < FIRE_MINIMUM_TEMPERATURE_TO_EXIST) || (volume <= 1))
		qdel(src)
		return
	if(!location.air || (INSUFFICIENT(/datum/gas/plasma) && INSUFFICIENT(/datum/gas/tritium)) || INSUFFICIENT(/datum/gas/oxygen))
		qdel(src)
		return

	if(((!location.air.gases[/datum/gas/plasma] || location.air.gases[/datum/gas/plasma][MOLES] < 0.5) && (!location.air.gases[/datum/gas/tritium] || location.air.gases[/datum/gas/tritium][MOLES] < 0.5)) || location.air.gases[/datum/gas/oxygen][MOLES] < 0.5)
		qdel(src)
		return

	perform_exposure()

	if(bypassing)
		icon_state = "3"
		location.burn_tile()

		if(location.air.temperature > FIRE_MINIMUM_TEMPERATURE_TO_SPREAD)
			var/radiated_temperature = location.air.temperature*FIRE_SPREAD_RADIOSITY_SCALE
			for(var/t in location.atmos_adjacent_turfs)
				var/turf/open/T = t
				if(T.active_hotspot)
					T.hotspot_expose(radiated_temperature, CELL_VOLUME/4)

	else
		if(volume > CELL_VOLUME*0.4)
			icon_state = "2"
		else
			icon_state = "1"

	//if((visual_update_tick++ % 7) == 0)
	//	update_color()

	//if(temperature > location.max_fire_temperature_sustained)
	//	location.max_fire_temperature_sustained = temperature

	//if(location.heat_capacity && temperature > location.heat_capacity)
	//	location.to_be_destroyed = TRUE
	return TRUE

/obj/effect/hotspot/Destroy()
	set_light(0)
	SSair.hotspots -= src
	var/turf/open/T = loc
	if(istype(T) && T.active_hotspot == src)
		T.active_hotspot = null
	DestroyTurf()
	return ..()

/obj/effect/hotspot/proc/DestroyTurf()
	//if(isturf(loc))
	//	var/turf/T = loc
	//	if(T.to_be_destroyed && !T.changing_turf)
	//		var/chance_of_deletion
	//		if (T.heat_capacity)
	//			chance_of_deletion = T.max_fire_temperature_sustained / T.heat_capacity * 8
	//		else
	//			chance_of_deletion = 100
	//		if(prob(chance_of_deletion))
	//			T.Melt()
	//		else
	//			T.to_be_destroyed = FALSE
	//			T.max_fire_temperature_sustained = 0