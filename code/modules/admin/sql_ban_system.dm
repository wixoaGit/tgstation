/proc/is_banned_from(player_ckey, roles)
	if(!player_ckey)
		return
	//var/client/C = GLOB.directory[player_ckey]
	//if(C)
	//	if(!C.ban_cache)
	//		build_ban_cache(C)
	//	if(islist(roles))
	//		for(var/R in roles)
	//			if(R in C.ban_cache)
	//				return TRUE
	//	else if(roles in C.ban_cache)
	//		return TRUE
	//else
	//	player_ckey = sanitizeSQL(player_ckey)
	//	var/admin_where
	//	if(GLOB.admin_datums[player_ckey] || GLOB.deadmins[player_ckey])
	//		admin_where = " AND applies_to_admins = 1"
	//	var/sql_roles
	//	if(islist(roles))
	//		sql_roles = jointext(roles, "', '")
	//	else
	//		sql_roles = roles
	//	sql_roles = sanitizeSQL(sql_roles)
	//	var/datum/DBQuery/query_check_ban = SSdbcore.NewQuery("SELECT 1 FROM [format_table_name("ban")] WHERE ckey = '[player_ckey]' AND role IN ('[sql_roles]') AND unbanned_datetime IS NULL AND (expiration_time IS NULL OR expiration_time > NOW())[admin_where]")
	//	if(!query_check_ban.warn_execute())
	//		qdel(query_check_ban)
	//		return
	//	if(query_check_ban.NextRow())
	//		qdel(query_check_ban)
	//		return TRUE
	//	qdel(query_check_ban)
	return FALSE//not_actual