/mob/proc/add_movespeed_modifier(id, update=TRUE, priority=0, flags=NONE, override=FALSE, multiplicative_slowdown=0, movetypes=ALL, blacklisted_movetypes=NONE, conflict=FALSE)
	var/list/temp = list(priority, flags, multiplicative_slowdown, movetypes, blacklisted_movetypes, conflict)
	var/resort = TRUE
	if(LAZYACCESS(movespeed_modification, id))
		var/list/existing_data = movespeed_modification[id]
		if(movespeed_modifier_identical_check(existing_data, temp))
			return FALSE
		if(!override)
			return FALSE
		if(priority == existing_data[MOVESPEED_DATA_INDEX_PRIORITY])
			resort = FALSE
	LAZYSET(movespeed_modification, id, temp)
	if(update)
		update_movespeed(resort)
	return TRUE

/mob/proc/remove_movespeed_modifier(id, update = TRUE)
	if(!LAZYACCESS(movespeed_modification, id))
		return FALSE
	LAZYREMOVE(movespeed_modification, id)
	UNSETEMPTY(movespeed_modification)
	if(update)
		update_movespeed(FALSE)
	return TRUE

/mob/proc/update_config_movespeed()
	//add_movespeed_modifier(MOVESPEED_ID_CONFIG_SPEEDMOD, FALSE, 100, override = TRUE, multiplicative_slowdown = get_config_multiplicative_speed())
	add_movespeed_modifier(MOVESPEED_ID_CONFIG_SPEEDMOD, FALSE, 100, override = TRUE, multiplicative_slowdown = 0)//not_actual

/mob/proc/update_movespeed(resort = TRUE)
	//if(resort)
	//	sort_movespeed_modlist()
	. = 0
	var/list/conflict_tracker = list()
	for(var/id in get_movespeed_modifiers())
		var/list/data = movespeed_modification[id]
		if(!(data[MOVESPEED_DATA_INDEX_MOVETYPE] & movement_type))
			continue
		if(data[MOVESPEED_DATA_INDEX_BL_MOVETYPE] & movement_type)
			continue
		var/conflict = data[MOVESPEED_DATA_INDEX_CONFLICT]
		var/amt = data[MOVESPEED_DATA_INDEX_MULTIPLICATIVE_SLOWDOWN]
		if(conflict)
			if(abs(conflict_tracker[conflict]) < abs(amt))
				conflict_tracker[conflict] = amt
			else
				continue
		. += amt
	cached_multiplicative_slowdown = .

/mob/proc/get_movespeed_modifiers()
	return movespeed_modification

/mob/proc/movespeed_modifier_identical_check(list/mod1, list/mod2)
	if(!islist(mod1) || !islist(mod2) || mod1.len < MOVESPEED_DATA_INDEX_MAX || mod2.len < MOVESPEED_DATA_INDEX_MAX)
		return FALSE
	for(var/i in 1 to MOVESPEED_DATA_INDEX_MAX)
		if(mod1[i] != mod2[i])
			return FALSE
	return TRUE