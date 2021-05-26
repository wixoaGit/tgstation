/datum/game_mode
	var/name = "invalid"
	var/config_tag = null
	var/votable = 1
	var/probability = 0
	var/false_report_weight = 0
	var/report_type = "invalid"
	var/station_was_nuked = 0
	var/list/datum/mind/antag_candidates = list()
	var/list/restricted_jobs = list()
	var/list/protected_jobs = list()
	var/required_players = 0
	var/maximum_players = -1
	var/required_enemies = 0
	var/recommended_enemies = 0
	var/antag_flag = null
	//var/list/datum/game_mode/replacementmode = null
	var/datum/game_mode/replacementmode = null//not_actual
	var/round_converted = 0

	var/announce_span = "warning"
	var/announce_text = "This gamemode forgot to set a descriptive text! Uh oh!"

	var/gamemode_ready = FALSE
	var/setup_error

/datum/game_mode/proc/announce()
	to_chat(world, "<b>The gamemode is: <span class='[announce_span]'>[name]</span>!</b>")
	to_chat(world, "<b>[announce_text]</b>")

/datum/game_mode/proc/can_start()
	var/playerC = 0
	for(var/mob/dead/new_player/player in GLOB.player_list)
		if((player.client)&&(player.ready == PLAYER_READY_TO_PLAY))
			playerC++
	if(!GLOB.Debug2)
		if(playerC < required_players || (maximum_players >= 0 && playerC > maximum_players))
			return 0
	antag_candidates = get_players_for_role(antag_flag)
	if(!GLOB.Debug2)
		if(antag_candidates.len < required_enemies)
			return 0
		return 1
	else
		message_admins("<span class='notice'>DEBUG: GAME STARTING WITHOUT PLAYER NUMBER CHECKS, THIS WILL PROBABLY BREAK SHIT.</span>")
		return 1

/datum/game_mode/proc/pre_setup()
	return 1

/datum/game_mode/proc/post_setup(report)
	//if(!report)
	//	report = !CONFIG_GET(flag/no_intercept_report)
	//addtimer(CALLBACK(GLOBAL_PROC, .proc/display_roundstart_logout_report), ROUNDSTART_LOGOUT_REPORT_TIME)

	//if(CONFIG_GET(flag/reopen_roundstart_suicide_roles))
	//	var/delay = CONFIG_GET(number/reopen_roundstart_suicide_roles_delay)
	//	if(delay)
	//		delay = (delay SECONDS)
	//	else
	//		delay = (4 MINUTES)
	//	addtimer(CALLBACK(GLOBAL_PROC, .proc/reopen_roundstart_suicide_roles), delay)

	//if(SSdbcore.Connect())
	//	var/sql
	//	if(SSticker.mode)
	//		sql += "game_mode = '[SSticker.mode]'"
	//	if(GLOB.revdata.originmastercommit)
	//		if(sql)
	//			sql += ", "
	//		sql += "commit_hash = '[GLOB.revdata.originmastercommit]'"
	//	if(sql)
	//		var/datum/DBQuery/query_round_game_mode = SSdbcore.NewQuery("UPDATE [format_table_name("round")] SET [sql] WHERE id = [GLOB.round_id]")
	//		query_round_game_mode.Execute()
	//		qdel(query_round_game_mode)
	//if(report)
	//	addtimer(CALLBACK(src, .proc/send_intercept, 0), rand(waittime_l, waittime_h))
	//generate_station_goals()
	gamemode_ready = TRUE
	return 1

/datum/game_mode/proc/check_finished(force_ending)
	if(!SSticker.setup_done || !gamemode_ready)
		return FALSE
	if(replacementmode && round_converted == 2)
		return replacementmode.check_finished()
	if(SSshuttle.emergency && (SSshuttle.emergency.mode == SHUTTLE_ENDGAME))
		return TRUE
	if(station_was_nuked)
		return TRUE
	//var/list/continuous = CONFIG_GET(keyed_list/continuous)
	//var/list/midround_antag = CONFIG_GET(keyed_list/midround_antag)
	//if(!round_converted && (!continuous[config_tag] || (continuous[config_tag] && midround_antag[config_tag])))
	//	if(!continuous_sanity_checked)
	//		for(var/mob/Player in GLOB.mob_list)
	//			if(Player.mind)
	//				if(Player.mind.special_role || LAZYLEN(Player.mind.antag_datums))
	//					continuous_sanity_checked = 1
	//					return 0
	//		if(!continuous_sanity_checked)
	//			message_admins("The roundtype ([config_tag]) has no antagonists, continuous round has been defaulted to on and midround_antag has been defaulted to off.")
	//			continuous[config_tag] = TRUE
	//			midround_antag[config_tag] = FALSE
	//			SSshuttle.clearHostileEnvironment(src)
	//			return 0


	//	if(living_antag_player && living_antag_player.mind && isliving(living_antag_player) && living_antag_player.stat != DEAD && !isnewplayer(living_antag_player) &&!isbrain(living_antag_player) && (living_antag_player.mind.special_role || LAZYLEN(living_antag_player.mind.antag_datums)))
	//		return 0

	//	for(var/mob/Player in GLOB.alive_mob_list)
	//		if(Player.mind && Player.stat != DEAD && !isnewplayer(Player) &&!isbrain(Player) && Player.client)
	//			if(Player.mind.special_role || LAZYLEN(Player.mind.antag_datums))
	//				living_antag_player = Player
	//				return 0

	//	if(!are_special_antags_dead())
	//		return FALSE

	//	if(!continuous[config_tag] || force_ending)
	//		return 1

	//	else
	//		round_converted = convert_roundtype()
	//		if(!round_converted)
	//			if(round_ends_with_antag_death)
	//				return 1
	//			else
	//				midround_antag[config_tag] = 0
	//				return 0

	return 0

/datum/game_mode/proc/antag_pick(list/datum/candidates)
	//if(!CONFIG_GET(flag/use_antag_rep)) // || candidates.len <= 1)
	//	return pick(candidates)

	//var/DEFAULT_ANTAG_TICKETS = CONFIG_GET(number/default_antag_tickets)

	//var/MAX_TICKETS_PER_ROLL = CONFIG_GET(number/max_tickets_per_roll)


	//var/total_tickets = 0

	//MAX_TICKETS_PER_ROLL += DEFAULT_ANTAG_TICKETS

	//var/p_ckey
	//var/p_rep

	//for(var/datum/mind/mind in candidates)
	//	p_ckey = ckey(mind.key)
	//	total_tickets += min(SSpersistence.antag_rep[p_ckey] + DEFAULT_ANTAG_TICKETS, MAX_TICKETS_PER_ROLL)

	//var/antag_select = rand(1,total_tickets)
	//var/current = 1

	//for(var/datum/mind/mind in candidates)
	//	p_ckey = ckey(mind.key)
	//	p_rep = SSpersistence.antag_rep[p_ckey]

	//	var/previous = current
	//	var/spend = min(p_rep + DEFAULT_ANTAG_TICKETS, MAX_TICKETS_PER_ROLL)
	//	current += spend

	//	if(antag_select >= previous && antag_select <= (current-1))
	//		SSpersistence.antag_rep_change[p_ckey] = -(spend - DEFAULT_ANTAG_TICKETS)

	//		return mind

	//WARNING("Something has gone terribly wrong. /datum/game_mode/proc/antag_pick failed to select a candidate. Falling back to pick()")
	return pick(candidates)

/datum/game_mode/proc/get_players_for_role(role)
	var/list/players = list()
	var/list/candidates = list()
	var/list/drafted = list()
	var/datum/mind/applicant = null

	for(var/mob/dead/new_player/player in GLOB.player_list)
		if(player.client && player.ready == PLAYER_READY_TO_PLAY)
			players += player

	players = shuffle(players)

	for(var/mob/dead/new_player/player in players)
		if(player.client && player.ready == PLAYER_READY_TO_PLAY)
			//if(role in player.client.prefs.be_special)
			if (TRUE)//not_actual
				//if(!is_banned_from(player.ckey, list(role, ROLE_SYNDICATE)) && !QDELETED(player))
				if(!QDELETED(player))//not_actual
					//if(age_check(player.client))
					if(TRUE)//not_actual
						candidates += player.mind

	if(restricted_jobs)
		for(var/datum/mind/player in candidates)
			for(var/job in restricted_jobs)
				if(player.assigned_role == job)
					candidates -= player

	if(candidates.len < recommended_enemies)
		for(var/mob/dead/new_player/player in players)
			if(player.client && player.ready == PLAYER_READY_TO_PLAY)
				//if(!(role in player.client.prefs.be_special))
				if(FALSE)//not_actual
					//if(!is_banned_from(player.ckey, list(role, ROLE_SYNDICATE)) && !QDELETED(player))
					if (!QDELETED(player))//not_actual
						drafted += player.mind

	if(restricted_jobs)
		for(var/datum/mind/player in drafted)
			for(var/job in restricted_jobs)
				if(player.assigned_role == job)
					drafted -= player

	drafted = shuffle(drafted)

	while(candidates.len < recommended_enemies)
		if(drafted.len > 0)
			applicant = pick(drafted)
			if(applicant)
				candidates += applicant
				drafted.Remove(applicant)

		else
			break

	if(restricted_jobs)
		for(var/datum/mind/player in drafted)
			for(var/job in restricted_jobs)
				if(player.assigned_role == job)
					drafted -= player

	drafted = shuffle(drafted)

	while(candidates.len < recommended_enemies)
		if(drafted.len > 0)
			applicant = pick(drafted)
			if(applicant)
				candidates += applicant
				drafted.Remove(applicant)

		else
			break

	return candidates

/datum/game_mode/proc/generate_report()
	return "Gamemode report for [name] not set.  Contact a coder."