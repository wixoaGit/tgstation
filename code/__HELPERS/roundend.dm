/datum/controller/subsystem/ticker/proc/declare_completion()
	set waitfor = FALSE

	to_chat(world, "<BR><BR><BR><span class='big bold'>The round has ended.</span>")
	//if(LAZYLEN(GLOB.round_end_notifiees))
	//	send2irc("Notice", "[GLOB.round_end_notifiees.Join(", ")] the round has ended.")

	//for(var/I in round_end_events)
	//	var/datum/callback/cb = I
	//	cb.InvokeAsync()
	//LAZYCLEARLIST(round_end_events)

	for(var/client/C in GLOB.clients)
		//if(!C.credits)
		//	C.RollCredits()
		C.playtitlemusic(40)

	//var/popcount = gather_roundend_feedback()
	var/popcount = list()//not_actual
	display_report(popcount)

	CHECK_TICK

	//for(var/datum/atom_hud/antag/H in GLOB.huds)
	//	for(var/m in GLOB.player_list)
	//		var/mob/M = m
	//		H.add_hud_to(M)

	CHECK_TICK

	//mode.set_round_result()

	//send2irc("Server", "Round just ended.")

	//if(length(CONFIG_GET(keyed_list/cross_server)))
	//	send_news_report()

	CHECK_TICK

	var/list/total_antagonists = list()
	for(var/datum/antagonist/A in GLOB.antagonists)
		if(!A.owner)
			continue
		if(!(A.name in total_antagonists))
			total_antagonists[A.name] = list()
		total_antagonists[A.name] += "[key_name(A.owner)]"

	CHECK_TICK

	log_game("Antagonists at round end were...")
	for(var/antag_name in total_antagonists)
		var/list/L = total_antagonists[antag_name]
		log_game("[antag_name]s :[L.Join(", ")].")

	CHECK_TICK
	//SSdbcore.SetRoundEnd()
	//if(mode.allow_persistence_save)
	//	SSpersistence.CollectData()

	//SSblackbox.Seal()

	sleep(50)
	//ready_for_reboot = TRUE
	//standard_reboot()

/datum/controller/subsystem/ticker/proc/build_roundend_report()
	var/list/parts = list()

	//parts += mode.special_report()

	CHECK_TICK

	//parts += law_report()

	CHECK_TICK

	parts += antag_report()

	CHECK_TICK
	//parts += medal_report()
	//parts += goal_report()

	listclearnulls(parts)

	return parts.Join()

/datum/controller/subsystem/ticker/proc/survivor_report(popcount)
	var/list/parts = list()
	var/station_evacuated = EMERGENCY_ESCAPED_OR_ENDGAMED

	//if(GLOB.round_id)
	//	var/statspage = CONFIG_GET(string/roundstatsurl)
	//	var/info = statspage ? "<a href='?action=openLink&link=[url_encode(statspage)][GLOB.round_id]'>[GLOB.round_id]</a>" : GLOB.round_id
	//	parts += "[GLOB.TAB]Round ID: <b>[info]</b>"
	parts += "[GLOB.TAB]Shift Duration: <B>[DisplayTimeText(world.time - SSticker.round_start_time)]</B>"
	//parts += "[GLOB.TAB]Station Integrity: <B>[mode.station_was_nuked ? "<span class='redtext'>Destroyed</span>" : "[popcount["station_integrity"]]%"]</B>"
	var/total_players = GLOB.joined_player_list.len
	if(total_players)
		parts+= "[GLOB.TAB]Total Population: <B>[total_players]</B>"
		//if(station_evacuated)
		//	parts += "<BR>[GLOB.TAB]Evacuation Rate: <B>[popcount[POPCOUNT_ESCAPEES]] ([PERCENT(popcount[POPCOUNT_ESCAPEES]/total_players)]%)</B>"
		//	parts += "[GLOB.TAB](on emergency shuttle): <B>[popcount[POPCOUNT_SHUTTLE_ESCAPEES]] ([PERCENT(popcount[POPCOUNT_SHUTTLE_ESCAPEES]/total_players)]%)</B>"
		//parts += "[GLOB.TAB]Survival Rate: <B>[popcount[POPCOUNT_SURVIVORS]] ([PERCENT(popcount[POPCOUNT_SURVIVORS]/total_players)]%)</B>"
		//if(SSblackbox.first_death)
		//	var/list/ded = SSblackbox.first_death
		//	if(ded.len)
		//		parts += "[GLOB.TAB]First Death: <b>[ded["name"]], [ded["role"]], at [ded["area"]]. Damage taken: [ded["damage"]].[ded["last_words"] ? " Their last words were: \"[ded["last_words"]]\"" : ""]</b>"
		//	//ignore this comment, it fixes the broken sytax parsing caused by the " above
		//	else
		//		parts += "[GLOB.TAB]<i>Nobody died this shift!</i>"
	return parts.Join("<br>")

/client/proc/roundend_report_file()
	//return "data/roundend_reports/[ckey].html"
	return ""//not_actual

/datum/controller/subsystem/ticker/proc/show_roundend_report(client/C, previous = FALSE)
	var/datum/browser/roundend_report = new(C, "roundend")
	roundend_report.width = 800
	roundend_report.height = 600
	var/content
	var/filename = C.roundend_report_file()
	if(!previous)
		var/list/report_parts = list(personal_report(C), GLOB.common_report)
		content = report_parts.Join()
		//C.verbs -= /client/proc/show_previous_roundend_report
		//fdel(filename)
		//text2file(content, filename)
	else
		content = file2text(filename)
	roundend_report.set_content(content)
	roundend_report.stylesheets = list()
	roundend_report.add_stylesheet("roundend", 'html/browser/roundend.css')
	roundend_report.open(FALSE)

/datum/controller/subsystem/ticker/proc/personal_report(client/C, popcount)
	var/list/parts = list()
	var/mob/M = C.mob
	if(M.mind && !isnewplayer(M))
		if(M.stat != DEAD && !isbrain(M))
			if(EMERGENCY_ESCAPED_OR_ENDGAMED)
				if(!M.onCentCom() && !M.onSyndieBase())
					parts += "<div class='panel stationborder'>"
					parts += "<span class='marooned'>You managed to survive, but were marooned on [station_name()]...</span>"
				else
					parts += "<div class='panel greenborder'>"
					parts += "<span class='greentext'>You managed to survive the events on [station_name()] as [M.real_name].</span>"
			else
				parts += "<div class='panel greenborder'>"
				parts += "<span class='greentext'>You managed to survive the events on [station_name()] as [M.real_name].</span>"

		else
			parts += "<div class='panel redborder'>"
			parts += "<span class='redtext'>You did not survive the events on [station_name()]...</span>"
	else
		parts += "<div class='panel stationborder'>"
	parts += "<br>"
	parts += GLOB.survivor_report
	parts += "</div>"

	return parts.Join()

/datum/controller/subsystem/ticker/proc/display_report(popcount)
	GLOB.common_report = build_roundend_report()
	GLOB.survivor_report = survivor_report(popcount)
	for(var/client/C in GLOB.clients)
		show_roundend_report(C, FALSE)
		//give_show_report_button(C)
		CHECK_TICK

/datum/controller/subsystem/ticker/proc/antag_report()
	var/list/result = list()
	var/list/all_teams = list()
	var/list/all_antagonists = list()

	for(var/datum/team/A in GLOB.antagonist_teams)
		if(!A.members)
			continue
		all_teams |= A
	
	for(var/datum/antagonist/A in GLOB.antagonists)
		if(!A.owner)
			continue
		all_antagonists |= A

	for(var/datum/team/T in all_teams)
		result += T.roundend_report()
		for(var/datum/antagonist/X in all_antagonists)
			if(X.get_team() == T)
				all_antagonists -= X
		result += " "
		CHECK_TICK

	var/currrent_category
	var/datum/antagonist/previous_category

	//sortTim(all_antagonists, /proc/cmp_antag_category)

	for(var/datum/antagonist/A in all_antagonists)
		if(!A.show_in_roundend)
			continue
		if(A.roundend_category != currrent_category)
			if(previous_category)
				result += previous_category.roundend_report_footer()
				result += "</div>"
			result += "<div class='panel redborder'>"
			result += A.roundend_report_header()
			currrent_category = A.roundend_category
			previous_category = A
		result += A.roundend_report()
		result += "<br><br>"
		CHECK_TICK

	if(all_antagonists.len)
		var/datum/antagonist/last = all_antagonists[all_antagonists.len]
		result += last.roundend_report_footer()
		result += "</div>"

	return result.Join()

/proc/printplayer(datum/mind/ply, fleecheck)
	var/jobtext = ""
	if(ply.assigned_role)
		jobtext = " the <b>[ply.assigned_role]</b>"
	var/text = "<b>[ply.key]</b> was <b>[ply.name]</b>[jobtext] and"
	if(ply.current)
		if(ply.current.stat == DEAD)
			text += " <span class='redtext'>died</span>"
		else
			text += " <span class='greentext'>survived</span>"
		if(fleecheck)
			var/turf/T = get_turf(ply.current)
			if(!T || !is_station_level(T.z))
				text += " while <span class='redtext'>fleeing the station</span>"
		if(ply.current.real_name != ply.name)
			text += " as <b>[ply.current.real_name]</b>"
	else
		text += " <span class='redtext'>had their body destroyed</span>"
	return text

/proc/printplayerlist(list/players,fleecheck)
	var/list/parts = list()

	parts += "<ul class='playerlist'>"
	for(var/datum/mind/M in players)
		parts += "<li>[printplayer(M,fleecheck)]</li>"
	parts += "</ul>"
	return parts.Join()

/proc/printobjectives(list/objectives)
	if(!objectives || !objectives.len)
		return
	var/list/objective_parts = list()
	var/count = 1
	for(var/datum/objective/objective in objectives)
		if(objective.check_completion())
			objective_parts += "<b>Objective #[count]</b>: [objective.explanation_text] <span class='greentext'>Success!</span>"
		else
			objective_parts += "<b>Objective #[count]</b>: [objective.explanation_text] <span class='redtext'>Fail.</span>"
		count++
	return objective_parts.Join("<br>")