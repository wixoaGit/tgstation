/datum/objective
	var/datum/mind/owner
	var/datum/team/team
	var/name = "generic objective"
	var/explanation_text = "Nothing"
	var/team_explanation_text
	var/datum/mind/target = null
	var/target_amount = 0
	var/completed = 0
	var/martyr_compatible = 0

/datum/objective/New(var/text)
	if(text)
		explanation_text = text

/datum/objective/proc/get_owners()
	. = (team && team.members) ? team.members.Copy() : list()
	if(owner)
		. += owner

/datum/objective/proc/considered_escaped(datum/mind/M)
	if(!considered_alive(M))
		return FALSE
	if(M.force_escaped)
		return TRUE
	//if(SSticker.force_ending || SSticker.mode.station_was_nuked)
	if(SSticker.force_ending)//not_actual
		return TRUE
	//if(SSshuttle.emergency.mode != SHUTTLE_ENDGAME)
	//	return FALSE
	var/turf/location = get_turf(M.current)
	//if(!location || istype(location, /turf/open/floor/plasteel/shuttle/red) || istype(location, /turf/open/floor/mineral/plastitanium/red/brig))
	//	return FALSE
	//return location.onCentCom() || location.onSyndieBase()
	return TRUE//not_actual

/datum/objective/proc/check_completion()
	return completed

/datum/objective/proc/is_unique_objective(possible_target, dupe_search_range)
	if(!islist(dupe_search_range))
		//stack_trace("Non-list passed as duplicate objective search range")
		dupe_search_range = list(dupe_search_range)

	for(var/A in dupe_search_range)
		var/list/objectives_to_compare
		if(istype(A,/datum/mind))
			var/datum/mind/M = A
			objectives_to_compare = M.get_all_objectives()
		else if(istype(A,/datum/antagonist))
			var/datum/antagonist/G = A
			objectives_to_compare = G.objectives
		else if(istype(A,/datum/team))
			var/datum/team/T = A
			objectives_to_compare = T.objectives
		for(var/datum/objective/O in objectives_to_compare)
			if(istype(O, type) && O.get_target() == possible_target)
				return FALSE
	return TRUE

/datum/objective/proc/get_target()
	return target

/datum/objective/proc/get_crewmember_minds()
	. = list()
	for(var/V in GLOB.data_core.locked)
		var/datum/data/record/R = V
		var/datum/mind/M = R.fields["mindref"]
		if(M)
			. += M

/datum/objective/proc/find_target(dupe_search_range)
	var/list/datum/mind/owners = get_owners()
	if(!dupe_search_range)
		dupe_search_range = get_owners()
	var/list/possible_targets = list()
	var/try_target_late_joiners = FALSE
	for(var/I in owners)
		var/datum/mind/O = I
		if(O.late_joiner)
			try_target_late_joiners = TRUE
	for(var/datum/mind/possible_target in get_crewmember_minds())
		if(!(possible_target in owners) && ishuman(possible_target.current) && (possible_target.current.stat != DEAD) && is_unique_objective(possible_target,dupe_search_range))
			possible_targets += possible_target
	if(try_target_late_joiners)
		var/list/all_possible_targets = possible_targets.Copy()
		for(var/I in all_possible_targets)
			var/datum/mind/PT = I
			if(!PT.late_joiner)
				possible_targets -= PT
		if(!possible_targets.len)
			possible_targets = all_possible_targets
	if(possible_targets.len > 0)
		target = pick(possible_targets)
	update_explanation_text()
	return target

/datum/objective/proc/update_explanation_text()
	if(team_explanation_text && LAZYLEN(get_owners()) > 1)
		explanation_text = team_explanation_text

/datum/objective/assassinate
	name = "assasinate"
	var/target_role_type=FALSE
	martyr_compatible = 1

/datum/objective/assassinate/check_completion()
	return completed || (!considered_alive(target) || considered_afk(target))

/datum/objective/assassinate/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Assassinate [target.name], the [!target_role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"

/datum/objective/maroon
	name = "maroon"
	var/target_role_type=FALSE
	martyr_compatible = 1

/datum/objective/maroon/check_completion()
	//return !target || !considered_alive(target) || (!target.current.onCentCom() && !target.current.onSyndieBase())
	return TRUE//not_actual

/datum/objective/maroon/update_explanation_text()
	if(target && target.current)
		explanation_text = "Prevent [target.name], the [!target_role_type ? target.assigned_role : target.special_role], from escaping alive."
	else
		explanation_text = "Free Objective"

/datum/objective/escape
	name = "escape"
	explanation_text = "Escape on the shuttle or an escape pod alive and without being in custody."
	team_explanation_text = "Have all members of your team escape on a shuttle or pod alive, without being in custody."

/datum/objective/escape/check_completion()
	var/list/datum/mind/owners = get_owners()
	for(var/datum/mind/M in owners)
		if(!considered_escaped(M))
			return FALSE
	return TRUE

/datum/objective/martyr
	name = "martyr"
	explanation_text = "Die a glorious death."

/datum/objective/martyr/check_completion()
	var/list/datum/mind/owners = get_owners()
	for(var/datum/mind/M in owners)
		if(considered_alive(M))
			return FALSE
		if(M.current?.suiciding)
			return FALSE
	return TRUE

GLOBAL_LIST_EMPTY(possible_items)
/datum/objective/steal
	name = "steal"
	var/datum/objective_item/targetinfo = null
	var/obj/item/steal_target = null
	martyr_compatible = 0

/datum/objective/steal/get_target()
	return steal_target

/datum/objective/steal/New()
	..()
	if(!GLOB.possible_items.len)
		for(var/I in subtypesof(/datum/objective_item/steal))
			new I

/datum/objective/steal/find_target(dupe_search_range)
	var/list/datum/mind/owners = get_owners()
	if(!dupe_search_range)
		dupe_search_range = get_owners()
	var/approved_targets = list()
	//check_items:
	//	for(var/datum/objective_item/possible_item in GLOB.possible_items)
	//		if(!is_unique_objective(possible_item.targetitem,dupe_search_range))
	//			continue
	//		for(var/datum/mind/M in owners)
	//			if(M.current.mind.assigned_role in possible_item.excludefromjob)
	//				continue check_items
	//		approved_targets += possible_item
	//not_actual
	for(var/datum/objective_item/possible_item in GLOB.possible_items)
		if(!is_unique_objective(possible_item.targetitem,dupe_search_range))
			continue
		//for(var/datum/mind/M in owners)
		//	if(M.current.mind.assigned_role in possible_item.excludefromjob)
		//		continue check_items
		approved_targets += possible_item
	return set_target(safepick(approved_targets))

/datum/objective/steal/proc/set_target(datum/objective_item/item)
	if(item)
		targetinfo = item
		steal_target = targetinfo.targetitem
		explanation_text = "Steal [targetinfo.name]"
		//give_special_equipment(targetinfo.special_equipment)
		return steal_target
	else
		explanation_text = "Free objective"
		return

/datum/objective/steal/check_completion()
	var/list/datum/mind/owners = get_owners()
	if(!steal_target)
		return TRUE
	for(var/datum/mind/M in owners)
		if(!isliving(M.current))
			continue

		var/list/all_items = M.current.GetAllContents()

		for(var/obj/I in all_items)
			if(istype(I, steal_target))
				if(!targetinfo)
					return TRUE
				else if(targetinfo.check_special_completion(I))
					return TRUE

			if(targetinfo && I.type in targetinfo.altitems)
				if(targetinfo.check_special_completion(I))
					return TRUE
	return FALSE