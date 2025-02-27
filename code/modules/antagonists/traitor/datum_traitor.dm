#define TRAITOR_HUMAN "human"
#define TRAITOR_AI	  "AI"

/datum/antagonist/traitor
	name = "Traitor"
	var/special_role = ROLE_TRAITOR
	var/give_objectives = TRUE
	var/should_give_codewords = TRUE
	var/traitor_kind = TRAITOR_HUMAN

/datum/antagonist/traitor/on_gain()
	//if(owner.current && isAI(owner.current))
	//	traitor_kind = TRAITOR_AI

	SSticker.mode.traitors += owner
	owner.special_role = special_role
	if(give_objectives)
		forge_traitor_objectives()
	finalize_traitor()
	..()

/datum/antagonist/traitor/proc/add_objective(datum/objective/O)
	objectives += O

/datum/antagonist/traitor/proc/remove_objective(datum/objective/O)
	objectives -= O

/datum/antagonist/traitor/proc/forge_traitor_objectives()
	switch(traitor_kind)
		if(TRAITOR_AI)
			forge_ai_objectives()
		else
			forge_human_objectives()

/datum/antagonist/traitor/proc/forge_human_objectives()
	var/is_hijacker = FALSE
	//if (GLOB.joined_player_list.len >= 30)
	//	is_hijacker = prob(10)
	var/martyr_chance = prob(20)
	var/objective_count = is_hijacker
	//if(!SSticker.mode.exchange_blue && SSticker.mode.traitors.len >= 8)
	//	if(!SSticker.mode.exchange_red)
	//		SSticker.mode.exchange_red = owner
	//	else
	//		SSticker.mode.exchange_blue = owner
	//		assign_exchange_role(SSticker.mode.exchange_red)
	//		assign_exchange_role(SSticker.mode.exchange_blue)
	//	objective_count += 1
	//var/toa = CONFIG_GET(number/traitor_objectives_amount)
	var/toa = 2//not_actual
	var/i = objective_count//not_actual
	//for(var/i = objective_count, i < toa, i++)
	while (i < toa)//not_actual
		forge_single_objective()
		i += 1//not_actual

	//if(is_hijacker && objective_count <= toa)
	//	if (!(locate(/datum/objective/hijack) in objectives))
	//		var/datum/objective/hijack/hijack_objective = new
	//		hijack_objective.owner = owner
	//		add_objective(hijack_objective)
	//		return


	var/martyr_compatibility = 1
	for(var/datum/objective/O in objectives)
		if(!O.martyr_compatible)
			martyr_compatibility = 0
			break

	if(martyr_compatibility && martyr_chance)
		var/datum/objective/martyr/martyr_objective = new
		martyr_objective.owner = owner
		add_objective(martyr_objective)
		return

	else
		if(!(locate(/datum/objective/escape) in objectives))
			var/datum/objective/escape/escape_objective = new
			escape_objective.owner = owner
			add_objective(escape_objective)
			return

/datum/antagonist/traitor/proc/forge_ai_objectives()
	//var/objective_count = 0

	//if(prob(30))
	//	objective_count += forge_single_objective()

	//for(var/i = objective_count, i < CONFIG_GET(number/traitor_objectives_amount), i++)
	//	var/datum/objective/assassinate/kill_objective = new
	//	kill_objective.owner = owner
	//	kill_objective.find_target()
	//	add_objective(kill_objective)

	//var/datum/objective/survive/exist/exist_objective = new
	//exist_objective.owner = owner
	//add_objective(exist_objective)

/datum/antagonist/traitor/proc/forge_single_objective()
	switch(traitor_kind)
		if(TRAITOR_AI)
			return forge_single_AI_objective()
		else
			return forge_single_human_objective()

/datum/antagonist/traitor/proc/forge_single_human_objective()
	.=1
	if(prob(50))
		//var/list/active_ais = active_ais()
		var/list/active_ais = list()//not_actual
		//if(active_ais.len && prob(100/GLOB.joined_player_list.len))
		if (FALSE)//not_actual
			//var/datum/objective/destroy/destroy_objective = new
			//destroy_objective.owner = owner
			//destroy_objective.find_target()
			//add_objective(destroy_objective)
		else if(prob(30))
			var/datum/objective/maroon/maroon_objective = new
			maroon_objective.owner = owner
			maroon_objective.find_target()
			add_objective(maroon_objective)
		else
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = owner
			kill_objective.find_target()
			add_objective(kill_objective)
	else
		//if(prob(15) && !(locate(/datum/objective/download) in objectives) && !(owner.assigned_role in list("Research Director", "Scientist", "Roboticist")))
		if(FALSE)//not_actual
			//var/datum/objective/download/download_objective = new
			//download_objective.owner = owner
			//download_objective.gen_amount_goal()
			//add_objective(download_objective)
		else
			var/datum/objective/steal/steal_objective = new
			steal_objective.owner = owner
			steal_objective.find_target()
			add_objective(steal_objective)

/datum/antagonist/traitor/proc/forge_single_AI_objective()
	.=1
	//var/special_pick = rand(1,4)
	//switch(special_pick)
	//	if(1)
	//		var/datum/objective/block/block_objective = new
	//		block_objective.owner = owner
	//		add_objective(block_objective)
	//	if(2)
	//		var/datum/objective/purge/purge_objective = new
	//		purge_objective.owner = owner
	//		add_objective(purge_objective)
	//	if(3)
	//		var/datum/objective/robot_army/robot_objective = new
	//		robot_objective.owner = owner
	//		add_objective(robot_objective)
	//	if(4)
	//		var/datum/objective/protect/yandere_one = new
	//		yandere_one.owner = owner
	//		add_objective(yandere_one)
	//		yandere_one.find_target()
	//		var/datum/objective/maroon/yandere_two = new
	//		yandere_two.owner = owner
	//		yandere_two.target = yandere_one.target
	//		yandere_two.update_explanation_text()
	//		add_objective(yandere_two)
	//		.=2

/datum/antagonist/traitor/greet()
	to_chat(owner.current, "<B><font size=3 color=red>You are the [owner.special_role].</font></B>")
	owner.announce_objectives()
	if(should_give_codewords)
		give_codewords()

/datum/antagonist/traitor/proc/finalize_traitor()
	switch(traitor_kind)
		//if(TRAITOR_AI)
		//	add_law_zero()
		//	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/malf.ogg', 100, FALSE, pressure_affected = FALSE)
		//	owner.current.grant_language(/datum/language/codespeak)
		if(TRAITOR_HUMAN)
			//if(should_equip)
			//	equip(silent)
			owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/tatoralert.ogg', 100, FALSE, pressure_affected = FALSE)

/datum/antagonist/traitor/proc/give_codewords()
	if(!owner.current)
		return
	var/mob/traitor_mob=owner.current

	to_chat(traitor_mob, "<U><B>The Syndicate provided you with the following information on how to identify their agents:</B></U>")
	to_chat(traitor_mob, "<B>Code Phrase</B>: <span class='danger'>[GLOB.syndicate_code_phrase]</span>")
	to_chat(traitor_mob, "<B>Code Response</B>: <span class='danger'>[GLOB.syndicate_code_response]</span>")

	//antag_memory += "<b>Code Phrase</b>: [GLOB.syndicate_code_phrase]<br>"
	//antag_memory += "<b>Code Response</b>: [GLOB.syndicate_code_response]<br>"

	to_chat(traitor_mob, "Use the code words in the order provided, during regular conversation, to identify other agents. Proceed with caution, however, as everyone is a potential foe.")

/datum/antagonist/traitor/roundend_report()
	var/list/result = list()

	var/traitorwin = TRUE

	result += printplayer(owner)

	var/TC_uses = 0
	var/uplink_true = FALSE
	var/purchases = ""
	//LAZYINITLIST(GLOB.uplink_purchase_logs_by_key)
	//var/datum/uplink_purchase_log/H = GLOB.uplink_purchase_logs_by_key[owner.key]
	//if(H)
	//	TC_uses = H.total_spent
	//	uplink_true = TRUE
	//	purchases += H.generate_render(FALSE)

	var/objectives_text = ""
	if(objectives.len)
		var/count = 1
		for(var/datum/objective/objective in objectives)
			if(objective.check_completion())
				objectives_text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <span class='greentext'>Success!</span>"
			else
				objectives_text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <span class='redtext'>Fail.</span>"
				traitorwin = FALSE
			count++

	if(uplink_true)
		var/uplink_text = "(used [TC_uses] TC) [purchases]"
		//if(TC_uses==0 && traitorwin)
		//	var/static/icon/badass = icon('icons/badass.dmi', "badass")
		//	uplink_text += "<BIG>[icon2html(badass, world)]</BIG>"
		result += uplink_text

	result += objectives_text

	var/special_role_text = lowertext(name)

	if(traitorwin)
		result += "<span class='greentext'>The [special_role_text] was successful!</span>"
	else
		result += "<span class='redtext'>The [special_role_text] has failed!</span>"
		//SEND_SOUND(owner.current, 'sound/ambience/ambifailure.ogg')
		SEND_SOUND(owner.current, sound('sound/ambience/ambifailure.ogg'))//not_actual
	
	return result.Join("<br>")

/datum/antagonist/traitor/roundend_report_footer()
	//return "<br><b>The code phrases were:</b> <span class='codephrase'>[GLOB.syndicate_code_phrase]</span><br>\
	//	<b>The code responses were:</b> <span class='codephrase'>[GLOB.syndicate_code_response]</span><br>"
	return "<br><b>The code phrases were:</b> <span class='codephrase'>[GLOB.syndicate_code_phrase]</span><br><b>The code responses were:</b> <span class='codephrase'>[GLOB.syndicate_code_response]</span><br>"//not_actual