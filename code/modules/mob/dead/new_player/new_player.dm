#define LINKIFY_READY(string, value) "<a href='byond://?src=[REF(src)];ready=[value]'>[string]</a>"

/mob/dead/new_player
	var/ready = 1
	var/spawning = 0
	
	flags_1 = NONE

	density = FALSE

	var/mob/living/new_character

/mob/dead/new_player/Initialize()
	if(client && SSticker.state == GAME_STATE_STARTUP)
		var/obj/screen/splash/S = new /obj/screen/splash(client, TRUE, TRUE)
		S.Fade(TRUE)

	if(length(GLOB.newplayer_start))
		forceMove(pick(GLOB.newplayer_start))
	else
		forceMove(locate(1,1,1))

	ComponentInitialize()

	. = ..()

/mob/dead/new_player/prepare_huds()
	return

/mob/dead/new_player/proc/new_player_panel()
	var/output = "<center><p><a href='byond://?src=[REF(src)];show_preferences=1'>Setup Character</a></p>"
	
	if(SSticker.current_state <= GAME_STATE_PREGAME)
		switch(ready)
			if(PLAYER_NOT_READY)
				output += "<p>\[ [LINKIFY_READY("Ready", PLAYER_READY_TO_PLAY)] | <b>Not Ready</b> | [LINKIFY_READY("Observe", PLAYER_READY_TO_OBSERVE)] \]</p>"
			if(PLAYER_READY_TO_PLAY)
				output += "<p>\[ <b>Ready</b> | [LINKIFY_READY("Not Ready", PLAYER_NOT_READY)] | [LINKIFY_READY("Observe", PLAYER_READY_TO_OBSERVE)] \]</p>"
			if(PLAYER_READY_TO_OBSERVE)
				output += "<p>\[ [LINKIFY_READY("Ready", PLAYER_READY_TO_PLAY)] | [LINKIFY_READY("Not Ready", PLAYER_NOT_READY)] | <b> Observe </b> \]</p>"
	else
		output += "<p><a href='byond://?src=[REF(src)];manifest=1'>View the Crew Manifest</a></p>"
		output += "<p><a href='byond://?src=[REF(src)];late_join=1'>Join Game!</a></p>"
		output += "<p>[LINKIFY_READY("Observe", PLAYER_READY_TO_OBSERVE)]</p>"
	
	output += "</center>"
	
	var/datum/browser/popup = new (src, "playersetup", "<div align='center'>New Player Options</div>", 250, 265)
	popup.set_window_options("can_close=0")
	popup.set_content(output)
	popup.open(FALSE)

///mob/dead/new_player/Topic(href, href_list[])
/mob/dead/new_player/Topic(href, list/href_list)//not_actual
	if(src != usr)
		return 0
	
	if(!client)
		return 0
	
	if(href_list["show_preferences"])
		client.prefs.ShowChoices(src)
		return 1
	
	if(href_list["ready"])
		var/tready = text2num(href_list["ready"])
		if(SSticker.current_state <= GAME_STATE_PREGAME)
			ready = tready
		if(!SSticker.current_state < GAME_STATE_PREGAME && tready == PLAYER_READY_TO_OBSERVE)
			ready = tready
			//make_me_an_observer()
			return
	
	if(href_list["late_join"])
		LateChoices()
	
	if(href_list["SelectedJob"])
		AttemptLateSpawn(href_list["SelectedJob"])
		return
	
	else if(!href_list["late_join"])
		new_player_panel()

/mob/dead/new_player/proc/IsJobUnavailable(rank, latejoin = FALSE)
	var/datum/job/job = SSjob.GetJob(rank)
	if(!job)
		return JOB_UNAVAILABLE_GENERIC
	if((job.current_positions >= job.total_positions) && job.total_positions != -1)
		if(job.title == "Assistant")
			//if(isnum(client.player_age) && client.player_age <= 14)
			//	return JOB_AVAILABLE
			for(var/datum/job/J in SSjob.occupations)
				if(J && J.current_positions < J.total_positions && J.title != job.title)
					return JOB_UNAVAILABLE_SLOTFULL
		else
			return JOB_UNAVAILABLE_SLOTFULL
	//if(is_banned_from(ckey, rank))
	//	return JOB_UNAVAILABLE_BANNED
	if(QDELETED(src))
		return JOB_UNAVAILABLE_GENERIC
	//if(!job.player_old_enough(client))
	//	return JOB_UNAVAILABLE_ACCOUNTAGE
	//if(job.required_playtime_remaining(client))
	//	return JOB_UNAVAILABLE_PLAYTIME
	//if(latejoin && !job.special_check_latejoin(client))
	//	return JOB_UNAVAILABLE_GENERIC
	return JOB_AVAILABLE

/mob/dead/new_player/proc/AttemptLateSpawn(rank)
	SSjob.AssignRole(src, rank, 1)
	
	var/mob/living/character = create_character(TRUE)
	var/equip = SSjob.EquipRank(character, rank, TRUE)
	
	var/datum/job/job = SSjob.GetJob(rank)
	
	//if(job && !job.override_latejoin_spawn(character))
	if(job)//not_actual
		SSjob.SendToLateJoin(character)
	
	var/mob/living/carbon/human/humanc
	if(ishuman(character))
		humanc = character

	if(humanc)
		//GLOB.data_core.manifest_inject(humanc)
		if(SSshuttle.arrivals)
			SSshuttle.arrivals.QueueAnnounce(humanc, rank)
		else
			AnnounceArrival(humanc, rank)
		//AddEmploymentContract(humanc)
		//if(GLOB.highlander)
		//	to_chat(humanc, "<span class='userdanger'><i>THERE CAN BE ONLY ONE!!!</i></span>")
		//	humanc.make_scottish()

		//if(GLOB.summon_guns_triggered)
		//	give_guns(humanc)
		//if(GLOB.summon_magic_triggered)
		//	give_magic(humanc)
		//if(GLOB.curse_of_madness_triggered)
		//	give_madness(humanc, GLOB.curse_of_madness_triggered)
	
	GLOB.joined_player_list += character.ckey

/mob/dead/new_player/proc/LateChoices()
	var/dat = "<div class='notice'>Round Duration: [DisplayTimeText(world.time - SSticker.round_start_time)]</div>"

	//if(SSshuttle.emergency)
	//	switch(SSshuttle.emergency.mode)
	//		if(SHUTTLE_ESCAPE)
	//			dat += "<div class='notice red'>The station has been evacuated.</div><br>"
	//		if(SHUTTLE_CALL)
	//			if(!SSshuttle.canRecall())
	//				dat += "<div class='notice red'>The station is currently undergoing evacuation procedures.</div><br>"

	var/available_job_count = 0
	for(var/datum/job/job in SSjob.occupations)
		if(job && IsJobUnavailable(job.title, TRUE) == JOB_AVAILABLE)
			available_job_count++;

	//for(var/datum/job/prioritized_job in SSjob.prioritized_jobs)
	//	if(prioritized_job.current_positions >= prioritized_job.total_positions)
	//		SSjob.prioritized_jobs -= prioritized_job

	//if(length(SSjob.prioritized_jobs))
	//	dat += "<div class='notice red'>The station has flagged these jobs as high priority:<br>"
	//	var/amt = length(SSjob.prioritized_jobs)
	//	var/amt_count
	//	for(var/datum/job/a in SSjob.prioritized_jobs)
	//		amt_count++
	//		if(amt_count != amt)
	//			dat += " [a.title], "
	//		else
	//			dat += " [a.title]. </div>"

	dat += "<div class='clearBoth'>Choose from the following open positions:</div><br>"
	dat += "<div class='jobs'><div class='jobsColumn'>"
	var/job_count = 0
	for(var/datum/job/job in SSjob.occupations)
		if(job && IsJobUnavailable(job.title, TRUE) == JOB_AVAILABLE)
			job_count++;
			if (job_count > round(available_job_count / 2))
				dat += "</div><div class='jobsColumn'>"
			var/position_class = "otherPosition"
			if (job.title in GLOB.command_positions)
				position_class = "commandPosition"
			dat += "<a class='[position_class]' href='byond://?src=[REF(src)];SelectedJob=[job.title]'>[job.title] ([job.current_positions])</a><br>"
	//if(!job_count)
	//	for(var/datum/job/job in SSjob.occupations)
	//		if(job.title != SSjob.overflow_role)
	//			continue
	//		dat += "<a class='otherPosition' href='byond://?src=[REF(src)];SelectedJob=[job.title]'>[job.title] ([job.current_positions])</a><br>"
	//		break
	dat += "</div></div>"

	var/datum/browser/popup = new(src, "latechoices", "Choose Profession", 440, 500)
	popup.add_stylesheet("playeroptions", 'html/browser/playeroptions.css')
	popup.set_content(dat)
	popup.open(FALSE)

/mob/dead/new_player/proc/create_character(transfer_after)
	spawning = 1
	close_spawn_windows()

	var/mob/living/carbon/human/H = new(loc)

	//var/frn = CONFIG_GET(flag/force_random_names)
	var/frn = FALSE //not_actual
	if(!frn)
		frn = is_banned_from(ckey, "Appearance")
		if(QDELETED(src))
			return
	if(frn)
		client.prefs.random_character()
		client.prefs.real_name = client.prefs.pref_species.random_name(gender,1)
	client.prefs.copy_to(H)
	//H.dna.update_dna_identity()
	if (mind)
		if(transfer_after)
			mind.late_joiner = TRUE
		mind.active = 0
		mind.transfer_to(H)
	
	//H.name = real_name

	. = H
	new_character = H
	if (transfer_after)
		transfer_character()

/mob/dead/new_player/proc/transfer_character()
	. = new_character
	if (new_character)
		new_character.key = key
		new_character.stop_sound_channel(CHANNEL_LOBBYMUSIC)
		new_character = null
		qdel(src)

/mob/dead/new_player/Move()
	return 0

/mob/dead/new_player/proc/close_spawn_windows()

	src << browse(null, "window=latechoices")
	src << browse(null, "window=playersetup")
	src << browse(null, "window=preferences")
	src << browse(null, "window=mob_occupation")
	src << browse(null, "window=latechoices")