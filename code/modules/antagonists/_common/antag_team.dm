GLOBAL_LIST_EMPTY(antagonist_teams)

/datum/team
	var/list/datum/mind/members = list()
	var/name = "team"
	var/member_name = "member"
	var/list/objectives = list()

/datum/team/New(starting_members)
	. = ..()
	GLOB.antagonist_teams += src
	if(starting_members)
		if(islist(starting_members))
			for(var/datum/mind/M in starting_members)
				add_member(M)
		else
			add_member(starting_members)

/datum/team/Destroy(force, ...)
	GLOB.antagonist_teams -= src
	. = ..()

/datum/team/proc/add_member(datum/mind/new_member)
	members |= new_member

/datum/team/proc/roundend_report()
	var/list/report = list()

	report += "<span class='header'>[name]:</span>"
	report += "The [member_name]s were:"
	report += printplayerlist(members)

	if(objectives.len)
		report += "<span class='header'>Team had following objectives:</span>"
		var/win = TRUE
		var/objective_count = 1
		for(var/datum/objective/objective in objectives)
			if(objective.check_completion())
				report += "<B>Objective #[objective_count]</B>: [objective.explanation_text] <span class='greentext'><B>Success!</span>"
			else
				report += "<B>Objective #[objective_count]</B>: [objective.explanation_text] <span class='redtext'>Fail.</span>"
				win = FALSE
			objective_count++
		if(win)
			report += "<span class='greentext'>The [name] was successful!</span>"
		else
			report += "<span class='redtext'>The [name] have failed!</span>"


	return "<div class='panel redborder'>[report.Join("<br>")]</div>"