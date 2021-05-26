/datum/game_mode
	var/traitor_name = "traitor"
	var/list/datum/mind/traitors = list()

	var/datum/mind/exchange_red
	var/datum/mind/exchange_blue

/datum/game_mode/traitor
	name = "traitor"
	config_tag = "traitor"
	report_type = "traitor"
	antag_flag = ROLE_TRAITOR
	false_report_weight = 20
	restricted_jobs = list("Cyborg")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain")
	required_players = 0
	required_enemies = 1
	recommended_enemies = 4

	announce_span = "danger"
	announce_text = "There are Syndicate agents on the station!\n\
	<span class='danger'>Traitors</span>: Accomplish your objectives.\n\
	<span class='notice'>Crew</span>: Do not let the traitors succeed!"
	
	var/list/datum/mind/pre_traitors = list()
	var/antag_datum = /datum/antagonist/traitor
	var/traitors_required = TRUE

/datum/game_mode/traitor/pre_setup()

	//if(CONFIG_GET(flag/protect_roles_from_antagonist))
	//	restricted_jobs += protected_jobs

	//if(CONFIG_GET(flag/protect_assistant_from_antagonist))
	//	restricted_jobs += "Assistant"

	var/num_traitors = 1

	//var/tsc = CONFIG_GET(number/traitor_scaling_coeff)
	//if(tsc)
	//	num_traitors = max(1, min(round(num_players() / (tsc * 2)) + 2 + num_modifier, round(num_players() / tsc) + num_modifier))
	//else
	//	num_traitors = max(1, min(num_players(), traitors_possible))

	for(var/j = 0, j < num_traitors, j++)
		if (!antag_candidates.len)
			break
		var/datum/mind/traitor = antag_pick(antag_candidates)
		pre_traitors += traitor
		traitor.special_role = traitor_name
		traitor.restricted_roles = restricted_jobs
		log_game("[key_name(traitor)] has been selected as a [traitor_name]")
		antag_candidates.Remove(traitor)

	var/enough_tators = !traitors_required || pre_traitors.len > 0

	if(!enough_tators)
		setup_error = "Not enough traitor candidates"
		return FALSE
	else
		return TRUE

//not_actual
/datum/game_mode/traitor/proc/add_antag_datum_not_actual(datum/mind/traitor, datum/mind/new_antag)
	traitor.add_antag_datum(new_antag)

/datum/game_mode/traitor/post_setup()
	for(var/datum/mind/traitor in pre_traitors)
		var/datum/antagonist/traitor/new_antag = new antag_datum()
		//addtimer(CALLBACK(traitor, /datum/mind.proc/add_antag_datum, new_antag), rand(10,100))
		addtimer(CALLBACK(src, .proc/add_antag_datum_not_actual, traitor, new_antag), rand(10,100))//not_actual
	//if(!exchange_blue)
	//	exchange_blue = -1
	..()

	//gamemode_ready = FALSE
	//addtimer(VARSET_CALLBACK(src, gamemode_ready, TRUE), 101)
	return TRUE