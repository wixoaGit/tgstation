GLOBAL_LIST_EMPTY(admin_ranks)
//GLOBAL_PROTECT(admin_ranks)

GLOBAL_LIST_EMPTY(protected_ranks)
//GLOBAL_PROTECT(protected_ranks)

/datum/admin_rank
	var/name = "NoRank"
	var/rights = R_DEFAULT
	var/exclude_rights = 0
	var/include_rights = 0
	var/can_edit_rights = 0

/datum/admin_rank/New(init_name, init_rights, init_exclude_rights, init_edit_rights)
	//if(IsAdminAdvancedProcCall())
	//	var/msg = " has tried to elevate permissions!"
	//	message_admins("[key_name_admin(usr)][msg]")
	//	log_admin("[key_name(usr)][msg]")
	//	if (name == "NoRank")
	//		QDEL_IN(src, 0)
	//		CRASH("Admin proc call creation of admin datum")
	//	return
	name = init_name
	if(!name)
		qdel(src)
		//throw EXCEPTION("Admin rank created without name.")
		CRASH("Admin rank created without name.")//not_actual
		return
	if(init_rights)
		rights = init_rights
	include_rights = rights
	if(init_exclude_rights)
		exclude_rights = init_exclude_rights
		rights &= ~exclude_rights
	if(init_edit_rights)
		can_edit_rights = init_edit_rights

/datum/admin_rank/Destroy()
	//if(IsAdminAdvancedProcCall())
	//	var/msg = " has tried to elevate permissions!"
	//	message_admins("[key_name_admin(usr)][msg]")
	//	log_admin("[key_name(usr)][msg]")
	//	return QDEL_HINT_LETMELIVE
	. = ..()

///datum/admin_rank/vv_edit_var(var_name, var_value)
//	return FALSE