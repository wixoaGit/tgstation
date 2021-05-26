/datum/mind
	var/key
	var/name
	var/mob/living/current
	var/active = 0
	
	var/assigned_role
	var/special_role
	var/list/restricted_roles = list()

	var/list/antag_datums
	var/datum/mind/soulOwner

	var/late_joiner = FALSE

	var/force_escaped = FALSE

/datum/mind/New(key)
	src.key = key
	soulOwner = src
	//martial_art = default_martial_art

/datum/mind/Destroy()
	SSticker.minds -= src
	if(islist(antag_datums))
		for(var/i in antag_datums)
			var/datum/antagonist/antag_datum = i
			//if(antag_datum.delete_on_mind_deletion)
			//	qdel(i)
		antag_datums = null
	return ..()

/datum/mind/proc/transfer_to(mob/new_character)
	if (current)
		current.mind = null

	if (key)
		if (new_character.key != key)
			new_character.ghostize(1)
	else
		key = new_character.key

	if (new_character.mind)
		new_character.mind.current = null

	current = new_character
	new_character.mind = src
	if (active)
		new_character.key = key

/datum/mind/proc/add_antag_datum(datum_type_or_instance, team)
	if(!datum_type_or_instance)
		return
	var/datum/antagonist/A
	if(!ispath(datum_type_or_instance))
		A = datum_type_or_instance
		if(!istype(A))
			return
	else
		A = new datum_type_or_instance()
	var/datum/antagonist/S = A.specialization(src)
	if(S && S != A)
		qdel(A)
		A = S
	if(!A.can_be_owned(src))
		qdel(A)
		return
	A.owner = src
	LAZYADD(antag_datums, A)
	A.create_team(team)
	var/datum/team/antag_team = A.get_team()
	if(antag_team)
		antag_team.add_member(src)
	A.on_gain()
	return A

/datum/mind/proc/has_antag_datum(datum_type, check_subtypes = TRUE)
	if(!datum_type)
		return
	. = FALSE
	for(var/a in antag_datums)
		var/datum/antagonist/A = a
		if(check_subtypes && istype(A, datum_type))
			return A
		else if(A.type == datum_type)
			return A

/datum/mind/proc/get_all_objectives()
	var/list/all_objectives = list()
	for(var/datum/antagonist/A in antag_datums)
		all_objectives |= A.objectives
	return all_objectives

/datum/mind/proc/announce_objectives()
	var/obj_count = 1
	to_chat(current, "<span class='notice'>Your current objectives:</span>")
	for(var/objective in get_all_objectives())
		var/datum/objective/O = objective
		to_chat(current, "<B>Objective #[obj_count]</B>: [O.explanation_text]")
		obj_count++

/mob/proc/sync_mind()
	mind_initialize()
	mind.active = 1

/mob/dead/new_player/sync_mind()
	return

/mob/dead/observer/sync_mind()
	return

/mob/proc/mind_initialize()
	if(mind)
		mind.key = key

	else
		mind = new /datum/mind(key)
		SSticker.minds += mind
	if(!mind.name)
		mind.name = real_name
	mind.current = src