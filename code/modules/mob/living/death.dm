/mob/living/death(gibbed)
	stat = DEAD
	unset_machine()
	timeofdeath = world.time
	tod = station_time_timestamp()
	var/turf/T = get_turf(src)
	for(var/obj/item/I in contents)
		I.on_mob_death(src, gibbed)
	//if(mind && mind.name && mind.active && !istype(T.loc, /area/ctf))
	//	var/rendered = "<span class='deadsay'><b>[mind.name]</b> has died at <b>[get_area_name(T)]</b>.</span>"
	//	deadchat_broadcast(rendered, follow_target = src, turf_target = T, message_type=DEADCHAT_DEATHRATTLE)
	//if(mind)
	//	mind.store_memory("Time of death: [tod]", 0)
	GLOB.alive_mob_list -= src
	if(!gibbed)
		GLOB.dead_mob_list += src
	//set_drugginess(0)
	//set_disgust(0)
	//SetSleeping(0, 0)
	//blind_eyes(1)
	//reset_perspective(null)
	reload_fullscreen()
	//update_action_buttons_icon()
	update_damage_hud()
	update_health_hud()
	update_mobility()
	//med_hud_set_health()
	//med_hud_set_status()
	//if(!gibbed && !QDELETED(src))
	//	addtimer(CALLBACK(src, .proc/med_hud_set_status), (DEFIB_TIME_LIMIT * 10) + 1)
	stop_pulling()

	. = ..()

	if (client)
		client.move_delay = initial(client.move_delay)

	//for(var/s in ownedSoullinks)
	//	var/datum/soullink/S = s
	//	S.ownerDies(gibbed)
	//for(var/s in sharedSoullinks)
	//	var/datum/soullink/S = s
	//	S.sharerDies(gibbed)

	return TRUE