INITIALIZE_IMMEDIATE(/mob/dead)

/mob/dead
	//sight = SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
	move_resist = INFINITY
	throwforce = 0

/mob/dead/Initialize()
	if(flags_1 & INITIALIZED_1)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	flags_1 |= INITIALIZED_1
	//tag = "mob_[next_mob_id++]"
	GLOB.mob_list += src

	prepare_huds()

	//if(length(CONFIG_GET(keyed_list/cross_server)))
	//	verbs += /mob/dead/proc/server_hop
	//set_focus(src)
	return INITIALIZE_HINT_NORMAL

/mob/dead/canUseStorage()
	return FALSE

///mob/dead/dust(just_ash, drop_items, force)
//	return

/mob/dead/gib()
	return

/mob/dead/ConveyorMove()
	return

/mob/dead/forceMove(atom/destination)
	var/turf/old_turf = get_turf(src)
	var/turf/new_turf = get_turf(destination)
	if (old_turf?.z != new_turf?.z)
		onTransitZ(old_turf?.z, new_turf?.z)
	var/oldloc = loc
	loc = destination
	Moved(oldloc, NONE, TRUE)

/mob/dead/Stat()
	..()

	if (!statpanel("Status"))
		return
	stat(null, "Game Mode: [SSticker.hide_mode ? "Secret" : "[GLOB.master_mode]"]")

	if(SSticker.HasRoundStarted())
		return
	
	var/time_remaining = SSticker.GetTimeLeft()
	if(time_remaining > 0)
		stat(null, "Time To Start: [round(time_remaining/10)]s")
	else if(time_remaining == -10)
		stat(null, "Time To Start: DELAYED")
	else
		stat(null, "Time To Start: SOON")
	
	stat(null, "Players: [SSticker.totalPlayers]")
	if(client.holder)
		stat(null, "Players Ready: [SSticker.totalPlayersReady]")