/mob/Destroy()
	GLOB.mob_list -= src
	GLOB.dead_mob_list -= src
	GLOB.alive_mob_list -= src
	//GLOB.all_clockwork_mobs -= src
	//GLOB.mob_directory -= tag
	//focus = null
	//for (var/alert in alerts)
	//	clear_alert(alert, TRUE)
	//if(observers && observers.len)
	//	for(var/M in observers)
	//		var/mob/dead/observe = M
	//		observe.reset_perspective(null)
	qdel(hud_used)
	//for(var/cc in client_colours)
	//	qdel(cc)
	//client_colours = null
	ghostize()
	..()
	return QDEL_HINT_HARDDEL

/mob/Initialize()
	//SEND_GLOBAL_SIGNAL(COMSIG_GLOB_MOB_CREATED, src)
	GLOB.mob_list += src
	//GLOB.mob_directory[tag] = src
	if(stat == DEAD)
		GLOB.dead_mob_list += src
	else
		GLOB.alive_mob_list += src
	//set_focus(src)
	prepare_huds()
	//for(var/v in GLOB.active_alternate_appearances)
	//	if(!v)
	//		continue
	//	var/datum/atom_hud/alternate_appearance/AA = v
	//	AA.onNewMob(src)
	//set_nutrition(rand(NUTRITION_LEVEL_START_MIN, NUTRITION_LEVEL_START_MAX))
	. = ..()
	update_config_movespeed()
	update_movespeed(TRUE)

/atom/proc/prepare_huds()
	//hud_list = list()
	//for(var/hud in hud_possible)
	//	var/hint = hud_possible[hud]
	//	switch(hint)
	//		if(HUD_LIST_LIST)
	//			hud_list[hud] = list()
	//		else
	//			var/image/I = image('icons/mob/hud.dmi', src, "")
	//			I.appearance_flags = RESET_COLOR|RESET_TRANSFORM
	//			hud_list[hud] = I

/mob/proc/show_message(msg, type, alt_msg, alt_type)

	if(!client)
		return

	msg = copytext(msg, 1, MAX_MESSAGE_LEN)

	if(type)
		if(type & 1 && eye_blind )
			if(!alt_msg)
				return
			else
				msg = alt_msg
				type = alt_type

		if(type & 2 && !can_hear())
			if(!alt_msg)
				return
			else
				msg = alt_msg
				type = alt_type
				if(type & 1 && eye_blind)
					return
	if(stat == UNCONSCIOUS)
		if(type & 2)
			to_chat(src, "<I>... You can almost hear something ...</I>")
	else
		to_chat(src, msg)

/atom/proc/visible_message(message, self_message, blind_message, vision_distance, ignored_mob)
	var/turf/T = get_turf(src)
	if(!T)
		return
	var/range = 7
	if(vision_distance)
		range = vision_distance
	for(var/mob/M in get_hearers_in_view(range, src))
		if(!M.client)
			continue
		if(M == ignored_mob)
			continue
		var/msg = message
		if(M == src)
			if(self_message)
				msg = self_message
		else
			if(M.see_invisible<invisibility || (T != loc && T != src))
				if(blind_message)
					msg = blind_message
				else
					continue

			//else if(T.lighting_object)
			//	if(T.lighting_object.invisibility <= M.see_invisible && T.is_softly_lit())
			//		if(blind_message)
			//			msg = blind_message
			//		else
			//			continue

		M.show_message(msg,1,blind_message,2)

/mob/audible_message(message, deaf_message, hearing_distance, self_message)
	var/range = 7
	if(hearing_distance)
		range = hearing_distance
	for(var/mob/M in get_hearers_in_view(range, src))
		var/msg = message
		if(self_message && M==src)
			msg = self_message
		M.show_message( msg, 2, deaf_message, 1)

/atom/proc/audible_message(message, deaf_message, hearing_distance)
	var/range = 7
	if(hearing_distance)
		range = hearing_distance
	for(var/mob/M in get_hearers_in_view(range, src))
		M.show_message( message, 2, deaf_message, 1)

/mob/proc/Life()
	set waitfor = FALSE

/mob/proc/get_item_by_slot(slot_id)
	return null

/mob/proc/restrained(ignore_grab)
	return

/mob/proc/incapacitated(ignore_restraints = FALSE, ignore_grab = FALSE, check_immobilized = FALSE)
	return

/mob/proc/attack_ui(slot)
	var/obj/item/W = get_active_held_item()

	if(istype(W))
		if(equip_to_slot_if_possible(W, slot,0,0,0))
			return 1

	if(!W)
		var/obj/item/I = get_item_by_slot(slot)
		if(istype(I))
			I.attack_hand(src)

	return 0

/mob/proc/equip_to_slot_if_possible(obj/item/W, slot, qdel_on_fail = FALSE, disable_warning = FALSE, redraw_mob = TRUE, bypass_equip_delay_self = FALSE)
	if(!istype(W))
		return FALSE
	if(!W.mob_can_equip(src, null, slot, disable_warning, bypass_equip_delay_self))
		if(qdel_on_fail)
			qdel(W)
		else
			if(!disable_warning)
				to_chat(src, "<span class='warning'>You are unable to equip that!</span>")
		return FALSE
	equip_to_slot(W, slot, redraw_mob)
	return TRUE

/mob/proc/equip_to_slot(obj/item/W, slot)
	return

/mob/proc/equip_to_slot_or_del(obj/item/W, slot)
	return equip_to_slot_if_possible(W, slot, TRUE, TRUE, FALSE, TRUE)

/mob/proc/show_inv(mob/user)
	return

/mob/verb/examinate(atom/A as mob|obj|turf in view())
	//set name = "Examine"
	//set category = "IC"

	//if(isturf(A) && !(sight & SEE_TURFS) && !(A in view(client ? client.view : world.view, src)))
	//	return

	if(is_blind(src))
		to_chat(src, "<span class='notice'>Something is there but you can't see it.</span>")
		return

	face_atom(A)
	A.examine(src)

/mob/proc/update_pull_hud_icon()
	if(hud_used)
		if(hud_used.pull_icon)
			hud_used.pull_icon.update_icon(src)

/mob/proc/update_rest_hud_icon()
	if(hud_used)
		if(hud_used.rest_icon)
			hud_used.rest_icon.update_icon(src)

/mob/Topic(href, href_list)
	if(href_list["mach_close"])
		var/t1 = text("window=[href_list["mach_close"]]")
		unset_machine()
		src << browse(null, t1)

	//if(href_list["refresh"])
	//	if(machine && in_range(src, usr))
	//		show_inv(machine)


	if(href_list["item"] && usr.canUseTopic(src, BE_CLOSE, NO_DEXTERY))
		var/slot = text2num(href_list["item"])
		var/hand_index = text2num(href_list["hand_index"])
		var/obj/item/what
		if(hand_index)
			what = get_item_for_held_index(hand_index)
			slot = list(slot,hand_index)
		else
			what = get_item_by_slot(slot)
		if(what)
			if(!(what.item_flags & ABSTRACT))
				usr.stripPanelUnequip(what,src,slot)
		else
			usr.stripPanelEquip(what,src,slot)

	if(usr.machine == src)
		if(Adjacent(usr))
			show_inv(usr)
		else
			usr << browse(null,"window=mob[REF(src)]")

/mob/proc/stripPanelUnequip(obj/item/what, mob/who)
	return

/mob/proc/stripPanelEquip(obj/item/what, mob/who)
	return

/mob/MouseDrop(mob/M)
	. = ..()
	if(M != usr)
		return
	if(usr == src)
		return
	if(!Adjacent(usr))
		return
	if(isAI(M))
		return
	show_inv(usr)

/mob/Stat()
	..()

	if(statpanel("Status"))
		//if (client)
		//	stat(null, "Ping: [round(client.lastping, 1)]ms (Average: [round(client.avgping, 1)]ms)")
		stat(null, "Map: [SSmapping.config?.map_name || "Loading..."]")
		var/datum/map_config/cached = SSmapping.next_map_config
		if(cached)
			stat(null, "Next Map: [cached.map_name]")
		stat(null, "Round ID: [GLOB.round_id ? GLOB.round_id : "NULL"]")
		stat(null, "Server Time: [time2text(world.timeofday, "YYYY-MM-DD hh:mm:ss")]")
		//stat(null, "Round Time: [worldtime2text()]")
		stat(null, "Station Time: [station_time_timestamp()]")
		//stat(null, "Time Dilation: [round(SStime_track.time_dilation_current,1)]% AVG:([round(SStime_track.time_dilation_avg_fast,1)]%, [round(SStime_track.time_dilation_avg,1)]%, [round(SStime_track.time_dilation_avg_slow,1)]%)")
		if(SSshuttle.emergency)
			var/ETA = SSshuttle.emergency.getModeStr()
			if(ETA)
				stat(null, "[ETA] [SSshuttle.emergency.getTimerStr()]")

	if(client && client.holder)
		if(statpanel("MC"))
			//var/turf/T = get_turf(client.eye)
			//stat("Location:", COORD(T))
			stat("CPU:", "[world.cpu]")
			stat("Instances:", "[num2text(world.contents.len, 10)]")
			stat("World Time:", "[world.time]")
			GLOB.stat_entry()
			//config.stat_entry()
			stat(null)
			if(Master)
				Master.stat_entry()
			else
				stat("Master Controller:", "ERROR")
			//if(Failsafe)
			//	Failsafe.stat_entry()
			//else
			//	stat("Failsafe Controller:", "ERROR")
			if(Master)
				stat(null)
				for(var/datum/controller/subsystem/SS in Master.subsystems)
					SS.stat_entry()
			//GLOB.cameranet.stat_entry()
		//if(statpanel("Tickets"))
		//	GLOB.ahelp_tickets.stat_entry()
		//if(length(GLOB.sdql2_queries))
		//	if(statpanel("SDQL2"))
		//		stat("Access Global SDQL2 List", GLOB.sdql2_vv_statobj)
		//		for(var/i in GLOB.sdql2_queries)
		//			var/datum/SDQL2_query/Q = i
		//			Q.generate_stat()

	if(listed_turf && client)
		if(!TurfAdjacent(listed_turf))
			listed_turf = null
		else
			statpanel(listed_turf.name, null, listed_turf)
			var/list/overrides = list()
			//for(var/image/I in client.images)
			//	if(I.loc && I.loc.loc == listed_turf && I.override)
			//		overrides += I.loc
			for(var/atom/A in listed_turf)
				if(!A.mouse_opacity)
					continue
				if(A.invisibility > see_invisible)
					continue
				if(overrides.len && (A in overrides))
					continue
				//if(A.IsObscured())
				//	continue
				statpanel(listed_turf.name, null, A)


	//if(mind)
	//	add_spells_to_statpanel(mind.spell_list)
	//add_spells_to_statpanel(mob_spell_list)

/mob/proc/IsAdvancedToolUser()
	return FALSE

/mob/proc/swap_hand()
	return

/mob/proc/can_interact_with(atom/A)
	return IsAdminGhost(src) || Adjacent(A)

/mob/proc/canUseTopic(atom/movable/M, be_close=FALSE, no_dextery=FALSE, no_tk=FALSE)
	return

/mob/proc/canUseStorage()
	return FALSE

/mob/proc/fully_replace_character_name(oldname,newname)
	//log_message("[src] name changed from [oldname] to [newname]", LOG_OWNERSHIP)
	if(!newname)
		return 0

	//log_played_names(ckey,newname)

	real_name = newname
	name = newname
	//if(mind)
	//	mind.name = newname
	//	if(mind.key)
	//		log_played_names(mind.key,newname)

	if(oldname)
		replace_records_name(oldname,newname)

		replace_identification_name(oldname,newname)

		for(var/datum/mind/T in SSticker.minds)
			for(var/datum/objective/obj in T.get_all_objectives())
				if(obj.target && obj.target.current && obj.target.current.real_name == name)
					obj.update_explanation_text()
	return 1

/mob/proc/replace_records_name(oldname,newname)
	return

/mob/proc/replace_identification_name(oldname,newname)
	var/list/searching = GetAllContents()
	var/search_id = 1
	var/search_pda = 1

	for(var/A in searching)
		if( search_id && istype(A, /obj/item/card/id) )
			var/obj/item/card/id/ID = A
			if(ID.registered_name == oldname)
				ID.registered_name = newname
				ID.update_label()
				//if(ID.registered_account?.account_holder == oldname)
				//	ID.registered_account.account_holder = newname
				if(!search_pda)
					break
				search_id = 0

		else if( search_pda && istype(A, /obj/item/pda) )
			var/obj/item/pda/PDA = A
			if(PDA.owner == oldname)
				PDA.owner = newname
				PDA.update_label()
				if(!search_id)
					break
				search_pda = 0

/mob/proc/update_stat()
	return

/mob/proc/update_health_hud()
	return

/mob/proc/is_literate()
	return FALSE

/mob/proc/can_hold_items()
	return FALSE

/mob/proc/get_idcard(hand_first)
	return

/mob/setMovetype(newval)
	. = ..()
	update_movespeed(FALSE)