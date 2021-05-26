GLOBAL_LIST_EMPTY(antagonists)

/datum/antagonist
	var/name = "Antagonist"
	var/roundend_category = "other antagonists"
	var/show_in_roundend = TRUE
	var/datum/mind/owner
	var/silent = FALSE
	var/list/objectives = list()
	var/antag_moodlet

/datum/antagonist/New()
	GLOB.antagonists += src
	//typecache_datum_blacklist = typecacheof(typecache_datum_blacklist)

/datum/antagonist/Destroy()
	GLOB.antagonists -= src
	if(owner)
		LAZYREMOVE(owner.antag_datums, src)
	owner = null
	return ..()

/datum/antagonist/proc/can_be_owned(datum/mind/new_owner)
	. = TRUE
	var/datum/mind/tested = new_owner || owner
	if(tested.has_antag_datum(type))
		return FALSE
	for(var/i in tested.antag_datums)
		var/datum/antagonist/A = i
		//if(is_type_in_typecache(src, A.typecache_datum_blacklist))
		//	return FALSE

/datum/antagonist/proc/specialization(datum/mind/new_owner)
	return src

/datum/antagonist/proc/apply_innate_effects(mob/living/mob_override)
	return

/datum/antagonist/proc/create_team(datum/team/team)
	return

/datum/antagonist/proc/on_gain()
	if(owner && owner.current)
		if(!silent)
			greet()
		apply_innate_effects()
		give_antag_moodies()
		//if(is_banned(owner.current) && replace_banned)
		//	replace_banned_player()

/datum/antagonist/proc/greet()
	return

/datum/antagonist/proc/give_antag_moodies()
	if(!antag_moodlet)
		return
	//SEND_SIGNAL(owner.current, COMSIG_ADD_MOOD_EVENT, "antag_moodlet", antag_moodlet)

/datum/antagonist/proc/get_team()
	return

/datum/antagonist/proc/roundend_report()
	var/list/report = list()

	if(!owner)
		CRASH("antagonist datum without owner")

	report += printplayer(owner)

	var/objectives_complete = TRUE
	if(objectives.len)
		report += printobjectives(objectives)
		for(var/datum/objective/objective in objectives)
			if(!objective.check_completion())
				objectives_complete = FALSE
				break

	if(objectives.len == 0 || objectives_complete)
		report += "<span class='greentext big'>The [name] was successful!</span>"
	else
		report += "<span class='redtext big'>The [name] has failed!</span>"

	return report.Join("<br>")

/datum/antagonist/proc/roundend_report_header()
	return 	"<span class='header'>The [roundend_category] were:</span><br>"

/datum/antagonist/proc/roundend_report_footer()
	return