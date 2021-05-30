/area
	level = null
	name = "Space"
	icon = 'icons/turf/areas.dmi'
	icon_state = "unknown"
	layer = AREA_LAYER
	plane = BLACKNESS_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = INVISIBILITY_LIGHTING

	var/map_name

	var/valid_territory = TRUE
	var/blob_allowed = TRUE
	var/clockwork_warp_allowed = TRUE
	var/clockwork_warp_fail = "The structure there is too dense for warping to pierce. (This is normal in high-security areas.)"

	var/fire = null
	var/atmos = TRUE
	var/atmosalm = FALSE
	var/poweralm = TRUE
	var/lightswitch = TRUE

	var/requires_power = TRUE
	var/always_unpowered = FALSE

	var/outdoors = FALSE

	var/areasize = 0

	var/power_equip = TRUE
	var/power_light = TRUE
	var/power_environ = TRUE
	var/used_equip = 0
	var/used_light = 0
	var/used_environ = 0
	var/static_equip
	var/static_light = 0
	var/static_environ

	var/has_gravity = 0
	var/noteleport = FALSE
	var/hidden = FALSE
	var/safe = FALSE
	var/unique = TRUE

	var/list/ambientsounds = GENERIC
	flags_1 = CAN_BE_DIRTY_1

	var/list/firealarms
	var/list/canSmoothWithAreas

/area/New()
	if (unique)
		GLOB.areas_by_type[type] = src
	return ..()

/area/Initialize()
	icon_state = ""
	layer = AREA_LAYER
	//uid = ++global_uid
	map_name = name
	canSmoothWithAreas = typecacheof(canSmoothWithAreas)

	if(requires_power)
		luminosity = 0
	else
		power_light = TRUE
		power_equip = TRUE
		power_environ = TRUE

		if(dynamic_lighting == DYNAMIC_LIGHTING_FORCED)
			dynamic_lighting = DYNAMIC_LIGHTING_ENABLED
			luminosity = 0
		else if(dynamic_lighting != DYNAMIC_LIGHTING_IFSTARLIGHT)
			dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	//if(dynamic_lighting == DYNAMIC_LIGHTING_IFSTARLIGHT)
	//	dynamic_lighting = CONFIG_GET(flag/starlight) ? DYNAMIC_LIGHTING_ENABLED : DYNAMIC_LIGHTING_DISABLED

	. = ..()

	//blend_mode = BLEND_MULTIPLY

	//if(!IS_DYNAMIC_LIGHTING(src))
	//	add_overlay(/obj/effect/fullbright)

	//reg_in_areas_in_z()

	return INITIALIZE_HINT_LATELOAD

/area/LateInitialize()
	power_change()

/area/proc/reg_in_areas_in_z()
	if(contents.len)
		var/list/areas_in_z = SSmapping.areas_in_z
		var/z
		update_areasize()
		for(var/i in 1 to contents.len)
			var/atom/thing = contents[i]
			if(!thing)
				continue
			z = thing.z
			break
		if(!z)
			WARNING("No z found for [src]")
			return
		if(!areas_in_z["[z]"])
			areas_in_z["[z]"] = list()
		areas_in_z["[z]"] += src

/area/Destroy()
	//if(GLOB.areas_by_type[type] == src)
	//	GLOB.areas_by_type[type] = null
	STOP_PROCESSING(SSobj, src)
	return ..()

/area/proc/poweralert(state, obj/source)
	if (state != poweralm)
		poweralm = state
		//if(istype(source))
		//	for (var/item in GLOB.silicon_mobs)
		//		var/mob/living/silicon/aiPlayer = item
		//		if (state == 1)
		//			aiPlayer.cancelAlarm("Power", src, source)
		//		else
		//			aiPlayer.triggerAlarm("Power", src, cameras, source)

		//	for (var/item in GLOB.alert_consoles)
		//		var/obj/machinery/computer/station_alert/a = item
		//		if(state == 1)
		//			a.cancelAlarm("Power", src, source)
		//		else
		//			a.triggerAlarm("Power", src, cameras, source)

		//	for (var/item in GLOB.drones_list)
		//		var/mob/living/simple_animal/drone/D = item
		//		if(state == 1)
		//			D.cancelAlarm("Power", src, source)
		//		else
		//			D.triggerAlarm("Power", src, cameras, source)
		//	for(var/item in GLOB.alarmdisplay)
		//		var/datum/computer_file/program/alarm_monitor/p = item
		//		if(state == 1)
		//			p.cancelAlarm("Power", src, source)
		//		else
		//			p.triggerAlarm("Power", src, cameras, source)

/area/proc/firealert(obj/source)
	if(always_unpowered == 1)
		return

	if (!fire)
		set_fire_alarm_effect()
		//ModifyFiredoors(FALSE)
		for(var/item in firealarms)
			var/obj/machinery/firealarm/F = item
			F.update_icon()

	//for (var/item in GLOB.alert_consoles)
	//	var/obj/machinery/computer/station_alert/a = item
	//	a.triggerAlarm("Fire", src, cameras, source)
	//for (var/item in GLOB.silicon_mobs)
	//	var/mob/living/silicon/aiPlayer = item
	//	aiPlayer.triggerAlarm("Fire", src, cameras, source)
	//for (var/item in GLOB.drones_list)
	//	var/mob/living/simple_animal/drone/D = item
	//	D.triggerAlarm("Fire", src, cameras, source)
	//for(var/item in GLOB.alarmdisplay)
	//	var/datum/computer_file/program/alarm_monitor/p = item
	//	p.triggerAlarm("Fire", src, cameras, source)

	START_PROCESSING(SSobj, src)

/area/proc/firereset(obj/source)
	if (fire)
		unset_fire_alarm_effects()
		//ModifyFiredoors(TRUE)
		for(var/item in firealarms)
			var/obj/machinery/firealarm/F = item
			F.update_icon()

	//for (var/item in GLOB.silicon_mobs)
	//	var/mob/living/silicon/aiPlayer = item
	//	aiPlayer.cancelAlarm("Fire", src, source)
	//for (var/item in GLOB.alert_consoles)
	//	var/obj/machinery/computer/station_alert/a = item
	//	a.cancelAlarm("Fire", src, source)
	//for (var/item in GLOB.drones_list)
	//	var/mob/living/simple_animal/drone/D = item
	//	D.cancelAlarm("Fire", src, source)
	//for(var/item in GLOB.alarmdisplay)
	//	var/datum/computer_file/program/alarm_monitor/p = item
	//	p.cancelAlarm("Fire", src, source)

	STOP_PROCESSING(SSobj, src)

/area/proc/set_fire_alarm_effect()
	fire = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	for(var/alarm in firealarms)
		var/obj/machinery/firealarm/F = alarm
		F.update_fire_light(fire)
	for(var/obj/machinery/light/L in src)
		L.update()

/area/proc/unset_fire_alarm_effects()
	fire = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	for(var/alarm in firealarms)
		var/obj/machinery/firealarm/F = alarm
		F.update_fire_light(fire)
	for(var/obj/machinery/light/L in src)
		L.update()

/area/proc/updateicon()
	var/weather_icon
	//for(var/V in SSweather.processing)
	//	var/datum/weather/W = V
	//	if(W.stage != END_STAGE && (src in W.impacted_areas))
	//		W.update_areas()
	//		weather_icon = TRUE
	//if(!weather_icon)
	//	icon_state = null

/area/space/updateicon()
	icon_state = null

/area/proc/powered(chan)

	if(!requires_power)
		return 1
	if(always_unpowered)
		return 0
	switch(chan)
		if(EQUIP)
			return power_equip
		if(LIGHT)
			return power_light
		if(ENVIRON)
			return power_environ

	return 0

/area/space/powered(chan)
	return 0

/area/proc/power_change()
	for(var/obj/machinery/M in src)
		M.power_change()
	updateicon()

/area/proc/usage(chan)
	var/used = 0
	switch(chan)
		if(LIGHT)
			used += used_light
		if(EQUIP)
			used += used_equip
		if(ENVIRON)
			used += used_environ
		if(TOTAL)
			used += used_light + used_equip + used_environ
		if(STATIC_EQUIP)
			used += static_equip
		if(STATIC_LIGHT)
			used += static_light
		if(STATIC_ENVIRON)
			used += static_environ
	return used

/area/proc/addStaticPower(value, powerchannel)
	switch(powerchannel)
		if(STATIC_EQUIP)
			static_equip += value
		if(STATIC_LIGHT)
			static_light += value
		if(STATIC_ENVIRON)
			static_environ += value

/area/proc/clear_usage()
	used_equip = 0
	used_light = 0
	used_environ = 0

/area/proc/use_power(amount, chan)

	switch(chan)
		if(EQUIP)
			used_equip += amount
		if(LIGHT)
			used_light += amount
		if(ENVIRON)
			used_environ += amount

/area/Entered(atom/movable/M)
	set waitfor = FALSE
	SEND_SIGNAL(src, COMSIG_AREA_ENTERED, M)
	SEND_SIGNAL(M, COMSIG_ENTER_AREA, src)
	if(!isliving(M))
		return

	var/mob/living/L = M
	if(!L.ckey)
		return

	//if(L.client && !L.client.ambience_playing && L.client.prefs.toggles & SOUND_SHIP_AMBIENCE)
	if(L.client && !L.client.ambience_playing)//not_actual
		L.client.ambience_playing = 1
		SEND_SOUND(L, sound('sound/ambience/shipambience.ogg', repeat = 1, wait = 0, volume = 35, channel = CHANNEL_BUZZ))

	//if(!(L.client && (L.client.prefs.toggles & SOUND_AMBIENCE)))
	if(FALSE)//not_actual
		return

	if(prob(35))
		var/sound = pick(ambientsounds)

		if(!L.client.played)
			SEND_SOUND(L, sound(sound, repeat = 0, wait = 0, volume = 25, channel = CHANNEL_AMBIENCE))
			L.client.played = TRUE
			addtimer(CALLBACK(L.client, /client/proc/ResetAmbiencePlayed), 600)

/area/Exited(atom/movable/M)
	SEND_SIGNAL(src, COMSIG_AREA_EXITED, M)
	SEND_SIGNAL(M, COMSIG_EXIT_AREA, src)

/client/proc/ResetAmbiencePlayed()
	played = FALSE

/atom/proc/has_gravity(turf/T)
	if(!T || !isturf(T))
		T = get_turf(src)

	if(!T)
		return 0

	//var/list/forced_gravity = list()
	//SEND_SIGNAL(src, COMSIG_ATOM_HAS_GRAVITY, T, forced_gravity)
	//if(!forced_gravity.len)
	//	SEND_SIGNAL(T, COMSIG_TURF_HAS_GRAVITY, src, forced_gravity)
	//if(forced_gravity.len)
	//	var/max_grav
	//	for(var/i in forced_gravity)
	//		max_grav = max(max_grav, i)
	//	return max_grav

	if(isspaceturf(T))
		return 0

	var/area/A = get_area(T)
	if(A.has_gravity)
		return A.has_gravity
	//else
	//	if(GLOB.gravity_generators["[T.z]"])
	//		var/max_grav = 0
	//		for(var/obj/machinery/gravity_generator/main/G in GLOB.gravity_generators["[T.z]"])
	//			max_grav = max(G.setting,max_grav)
	//		return max_grav
	//return SSmapping.level_trait(T.z, ZTRAIT_GRAVITY)
	return 1//not_actual

/area/proc/update_areasize()
	if(outdoors)
		return FALSE
	areasize = 0
	for(var/turf/open/T in contents)
		areasize++

/area/AllowDrop()
	CRASH("Bad op: area/AllowDrop() called")

/area/drop_location()
	CRASH("Bad op: area/drop_location() called")

/area/proc/PlaceOnTopReact(list/new_baseturfs, turf/fake_turf_type, flags)
	return flags