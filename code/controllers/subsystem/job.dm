SUBSYSTEM_DEF(job)
	name = "Jobs"
	init_order = INIT_ORDER_JOBS
	flags = SS_NO_FIRE

	var/list/occupations = list()
	var/list/name_occupations = list()
	var/list/type_occupations = list()
	var/list/unassigned = list()
	var/initial_players_to_assign = 0
	
	var/list/latejoin_trackers = list()

	var/overflow_role = "Assistant"

/datum/controller/subsystem/job/Initialize(timeofday)
	//SSmapping.HACK_LoadMapConfig()
	if(!occupations.len)
		SetupOccupations()
	//if(CONFIG_GET(flag/load_jobs_from_txt))
	//	LoadJobs()
	generate_selectable_species()
	//set_overflow_role(CONFIG_GET(string/overflow_job))
	return ..()

/datum/controller/subsystem/job/proc/SetupOccupations(faction = "Station")
	occupations = list()
	var/list/all_jobs = subtypesof(/datum/job)
	if(!all_jobs.len)
		to_chat(world, "<span class='boldannounce'>Error setting up jobs, no job datums found</span>")
		return 0

	for(var/J in all_jobs)
		var/datum/job/job = new J()
		if(!job)
			continue
		if(job.faction != faction)
			continue
		//if(!job.config_check())
		//	continue
		//if(!job.map_check())
		//	testing("Removed [job.type] due to map config");
		//	continue
		occupations += job
		name_occupations[job.title] = job
		type_occupations[J] = job

	return 1

/datum/controller/subsystem/job/proc/GetJob(rank)
	if(!occupations.len)
		SetupOccupations()
	return name_occupations[rank]

/datum/controller/subsystem/job/proc/GetJobType(jobtype)
	if(!occupations.len)
		SetupOccupations()
	return type_occupations[jobtype]

/datum/controller/subsystem/job/proc/AssignRole(mob/dead/new_player/player, rank, latejoin = FALSE)
	if (player && player.mind && rank)
		var/datum/job/job = GetJob(rank)
		if (!job)
			return FALSE
		player.mind.assigned_role = rank
		unassigned -= player
		job.current_positions++
		return TRUE
	return FALSE

/datum/controller/subsystem/job/proc/FindOccupationCandidates(datum/job/job, level, flag)
	JobDebug("Running FOC, Job: [job], Level: [level], Flag: [flag]")
	var/list/candidates = list()
	for(var/mob/dead/new_player/player in unassigned)
		if(is_banned_from(player.ckey, job.title) || QDELETED(player))
			JobDebug("FOC isbanned failed, Player: [player]")
			continue
		//if(!job.player_old_enough(player.client))
		//	JobDebug("FOC player not old enough, Player: [player]")
		//	continue
		//if(job.required_playtime_remaining(player.client))
		//	JobDebug("FOC player not enough xp, Player: [player]")
		//	continue
		if(flag && (!(flag in player.client.prefs.be_special)))
			JobDebug("FOC flag failed, Player: [player], Flag: [flag], ")
			continue
		if(player.mind && job.title in player.mind.restricted_roles)
			JobDebug("FOC incompatible with antagonist role, Player: [player]")
			continue
		if(player.client.prefs.GetJobDepartment(job, level) & job.flag)
			JobDebug("FOC pass, Player: [player], Level:[level]")
			candidates += player
	return candidates

/datum/controller/subsystem/job/proc/GiveRandomJob(mob/dead/new_player/player)
	JobDebug("GRJ Giving random job, Player: [player]")
	. = FALSE
	for(var/datum/job/job in shuffle(occupations))
		if(!job)
			continue

		if(istype(job, GetJob(SSjob.overflow_role)))
			continue

		if(job.title in GLOB.command_positions)
			continue

		if(is_banned_from(player.ckey, job.title) || QDELETED(player))
			if(QDELETED(player))
				JobDebug("GRJ isbanned failed, Player deleted")
				break
			JobDebug("GRJ isbanned failed, Player: [player], Job: [job.title]")
			continue

		//if(!job.player_old_enough(player.client))
		//	JobDebug("GRJ player not old enough, Player: [player]")
		//	continue

		//if(job.required_playtime_remaining(player.client))
		//	JobDebug("GRJ player not enough xp, Player: [player]")
		//	continue

		if(player.mind && job.title in player.mind.restricted_roles)
			JobDebug("GRJ incompatible with antagonist role, Player: [player], Job: [job.title]")
			continue

		if((job.current_positions < job.spawn_positions) || job.spawn_positions == -1)
			JobDebug("GRJ Random job given, Player: [player], Job: [job]")
			if(AssignRole(player, job.title))
				return TRUE

/datum/controller/subsystem/job/proc/ResetOccupations()
	JobDebug("Occupations reset.")
	for(var/mob/dead/new_player/player in GLOB.player_list)
		if((player) && (player.mind))
			player.mind.assigned_role = null
			player.mind.special_role = null
			//SSpersistence.antag_rep_change[player.ckey] = 0
	SetupOccupations()
	unassigned = list()
	return

/datum/controller/subsystem/job/proc/FillHeadPosition()
	for(var/level = 1 to 3)
		for(var/command_position in GLOB.command_positions)
			var/datum/job/job = GetJob(command_position)
			if(!job)
				continue
			if((job.current_positions >= job.total_positions) && job.total_positions != -1)
				continue
			var/list/candidates = FindOccupationCandidates(job, level)
			if(!candidates.len)
				continue
			var/mob/dead/new_player/candidate = pick(candidates)
			if(AssignRole(candidate, command_position))
				return 1
	return 0

/datum/controller/subsystem/job/proc/CheckHeadPositions(level)
	for(var/command_position in GLOB.command_positions)
		var/datum/job/job = GetJob(command_position)
		if(!job)
			continue
		if((job.current_positions >= job.total_positions) && job.total_positions != -1)
			continue
		var/list/candidates = FindOccupationCandidates(job, level)
		if(!candidates.len)
			continue
		var/mob/dead/new_player/candidate = pick(candidates)
		AssignRole(candidate, command_position)

/datum/controller/subsystem/job/proc/HandleUnassigned(mob/dead/new_player/player)
	if(PopcapReached())
		RejectPlayer(player)
	else if(player.client.prefs.joblessrole == BEOVERFLOW)
		var/allowed_to_be_a_loser = !is_banned_from(player.ckey, SSjob.overflow_role)
		if(QDELETED(player) || !allowed_to_be_a_loser)
			RejectPlayer(player)
		else
			if(!AssignRole(player, SSjob.overflow_role))
				RejectPlayer(player)
	else if(player.client.prefs.joblessrole == BERANDOMJOB)
		if(!GiveRandomJob(player))
			RejectPlayer(player)
	else if(player.client.prefs.joblessrole == RETURNTOLOBBY)
		RejectPlayer(player)
	else
		var/message = "DO: [player] fell through handling unassigned"
		JobDebug(message)
		log_game(message)
		message_admins(message)
		RejectPlayer(player)

/datum/controller/subsystem/job/proc/EquipRank(mob/M, rank, joined_late = FALSE)
	var/mob/dead/new_player/N
	var/mob/living/H
	if (!joined_late)
		N = M
		H = N.new_character
	else
		H = M

	var/datum/job/job = GetJob(rank)

	H.job = rank

	if (!joined_late)
		var/obj/S = null
		for (var/obj/effect/landmark/start/sloc in GLOB.start_landmarks_list)
			if (sloc.name != rank)
				S = sloc
				continue
			if (locate(/mob/living) in sloc.loc)
				continue
			S = sloc
			sloc.used = TRUE
			break
		if (S)
			SendToAtom(H, S)

	if (H.mind)
		H.mind.assigned_role = rank

	if (job)
		var/new_mob = job.equip(H, null, null, joined_late , null, M.client)
		if (ismob(new_mob))
			H = new_mob
			if (!joined_late)
				N.new_character = H
			else
				M = H

/datum/controller/subsystem/job/proc/PopcapReached()
	//var/hpc = CONFIG_GET(number/hard_popcap)
	//var/epc = CONFIG_GET(number/extreme_popcap)
	//if(hpc || epc)
	//	var/relevent_cap = max(hpc, epc)
	//	if((initial_players_to_assign - unassigned.len) >= relevent_cap)
	//		return 1
	return 0

/datum/controller/subsystem/job/proc/RejectPlayer(mob/dead/new_player/player)
	if(player.mind && player.mind.special_role)
		return
	if(PopcapReached())
		JobDebug("Popcap overflow Check observer located, Player: [player]")
	JobDebug("Player rejected :[player]")
	to_chat(player, "<b>You have failed to qualify for any job you desired.</b>")
	unassigned -= player
	player.ready = PLAYER_NOT_READY

/datum/controller/subsystem/job/proc/SendToAtom(mob/M, atom/A, buckle)
	//if (buckle && isliving(M) && istype(A, /obj/structure/chair))
	//	var/obj/structure/chair/C = A
	//	if (C.buckle_mob(M, FALSE, FALSE))
	//		return
	M.forceMove(get_turf(A))

/datum/controller/subsystem/job/proc/SendToLateJoin(mob/M, buckle = TRUE)
	if(latejoin_trackers.len)
		SendToAtom(M, pick(latejoin_trackers), buckle)

/datum/controller/subsystem/job/proc/DivideOccupations()
	JobDebug("Running DO")

	//if(SSticker.triai)
	//	for(var/datum/job/ai/A in occupations)
	//		A.spawn_positions = 3
	//	for(var/obj/effect/landmark/start/ai/secondary/S in GLOB.start_landmarks_list)
	//		S.latejoin_active = TRUE

	for(var/mob/dead/new_player/player in GLOB.player_list)
		if(player.ready == PLAYER_READY_TO_PLAY && player.mind && !player.mind.assigned_role)
			unassigned += player

	initial_players_to_assign = unassigned.len

	JobDebug("DO, Len: [unassigned.len]")
	if(unassigned.len == 0)
		return 0

	//setup_officer_positions()

	//var/mat = CONFIG_GET(number/minimal_access_threshold)
	//if(mat)
	//	if(mat > unassigned.len)
	//		CONFIG_SET(flag/jobs_have_minimal_access, FALSE)
	//	else
	//		CONFIG_SET(flag/jobs_have_minimal_access, TRUE)

	unassigned = shuffle(unassigned)

	//HandleFeedbackGathering()

	JobDebug("DO, Running Overflow Check 1")
	var/datum/job/overflow = GetJob(SSjob.overflow_role)
	var/list/overflow_candidates = FindOccupationCandidates(overflow, 3)
	JobDebug("AC1, Candidates: [overflow_candidates.len]")
	for(var/mob/dead/new_player/player in overflow_candidates)
		JobDebug("AC1 pass, Player: [player]")
		AssignRole(player, SSjob.overflow_role)
		overflow_candidates -= player
	JobDebug("DO, AC1 end")

	JobDebug("DO, Running Head Check")
	FillHeadPosition()
	JobDebug("DO, Head Check end")

	JobDebug("DO, Running AI Check")
	//FillAIPosition()
	JobDebug("DO, AI Check end")

	JobDebug("DO, Running Standard Check")

	var/list/shuffledoccupations = shuffle(occupations)
	for(var/level = 1 to 3)
		CheckHeadPositions(level)

		for(var/mob/dead/new_player/player in unassigned)
			if(PopcapReached())
				RejectPlayer(player)

			for(var/datum/job/job in shuffledoccupations)
				if(!job)
					continue

				if(is_banned_from(player.ckey, job.title))
					JobDebug("DO isbanned failed, Player: [player], Job:[job.title]")
					continue

				if(QDELETED(player))
					JobDebug("DO player deleted during job ban check")
					break

				//if(!job.player_old_enough(player.client))
				//	JobDebug("DO player not old enough, Player: [player], Job:[job.title]")
				//	continue

				//if(job.required_playtime_remaining(player.client))
				//	JobDebug("DO player not enough xp, Player: [player], Job:[job.title]")
				//	continue

				if(player.mind && job.title in player.mind.restricted_roles)
					JobDebug("DO incompatible with antagonist role, Player: [player], Job:[job.title]")
					continue

				if(player.client.prefs.GetJobDepartment(job, level) & job.flag)
					if((job.current_positions < job.spawn_positions) || job.spawn_positions == -1)
						JobDebug("DO pass, Player: [player], Level:[level], Job:[job.title]")
						AssignRole(player, job.title)
						unassigned -= player
						break


	JobDebug("DO, Handling unassigned.")
	for(var/mob/dead/new_player/player in unassigned)
		HandleUnassigned(player)

	JobDebug("DO, Handling unrejectable unassigned")
	for(var/mob/dead/new_player/player in unassigned)
		if(!GiveRandomJob(player))
			AssignRole(player, SSjob.overflow_role)

	return 1

/datum/controller/subsystem/job/proc/JobDebug(message)
	//log_job_debug(message)