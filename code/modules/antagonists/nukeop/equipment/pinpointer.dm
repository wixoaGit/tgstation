/obj/item/pinpointer/nuke
	var/mode = TRACK_NUKE_DISK

/obj/item/pinpointer/nuke/examine(mob/user)
	..()
	var/msg = "Its tracking indicator reads "
	switch(mode)
		if(TRACK_NUKE_DISK)
			msg += "\"nuclear_disk\"."
		if(TRACK_MALF_AI)
			msg += "\"01000001 01001001\"."
		if(TRACK_INFILTRATOR)
			msg += "\"vasvygengbefuvc\"."
		else
			msg = "Its tracking indicator is blank."
	to_chat(user, msg)
	//for(var/obj/machinery/nuclearbomb/bomb in GLOB.machines)
	//	if(bomb.timing)
	//		to_chat(user, "Extreme danger. Arming signal detected. Time remaining: [bomb.get_time_left()].")

/obj/item/pinpointer/nuke/process()
	..()
	//if(active)
	//	for(var/obj/machinery/nuclearbomb/bomb in GLOB.nuke_list)
	//		if(bomb.timing)
	//			if(!alert)
	//				alert = TRUE
	//				playsound(src, 'sound/items/nuke_toy_lowpower.ogg', 50, 0)
	//				if(isliving(loc))
	//					var/mob/living/L = loc
	//					to_chat(L, "<span class='userdanger'>Your [name] vibrates and lets out a tinny alarm. Uh oh.</span>")

/obj/item/pinpointer/nuke/scan_for_target()
	target = null
	switch(mode)
		if(TRACK_NUKE_DISK)
			var/obj/item/disk/nuclear/N = locate() in GLOB.poi_list
			target = N
		//if(TRACK_MALF_AI)
		//	for(var/V in GLOB.ai_list)
		//		var/mob/living/silicon/ai/A = V
		//		if(A.nuking)
		//			target = A
		//	for(var/V in GLOB.apcs_list)
		//		var/obj/machinery/power/apc/A = V
		//		if(A.malfhack && A.occupier)
		//			target = A
		//if(TRACK_INFILTRATOR)
		//	target = SSshuttle.getShuttle("syndicate")
	..()

/obj/item/pinpointer/nuke/proc/switch_mode_to(new_mode)
	if(isliving(loc))
		var/mob/living/L = loc
		to_chat(L, "<span class='userdanger'>Your [name] beeps as it reconfigures it's tracking algorithms.</span>")
		playsound(L, 'sound/machines/triple_beep.ogg', 50, 1)
	mode = new_mode
	scan_for_target()