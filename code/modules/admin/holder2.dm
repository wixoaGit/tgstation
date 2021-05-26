GLOBAL_LIST_EMPTY(admin_datums)
//GLOBAL_PROTECT(admin_datums)

GLOBAL_VAR_INIT(href_token, GenerateToken())
GLOBAL_PROTECT(href_token)

/datum/admins
	var/datum/admin_rank/rank

	var/target
	var/name = "nobody's admin datum (no rank)"
	var/client/owner	= null
	var/fakekey			= null

	var/datum/marked_datum

	var/spamcooldown = 0

	var/admincaster_screen = 0
	//var/datum/newscaster/feed_message/admincaster_feed_message = new /datum/newscaster/feed_message
	//var/datum/newscaster/wanted_message/admincaster_wanted_message = new /datum/newscaster/wanted_message
	//var/datum/newscaster/feed_channel/admincaster_feed_channel = new /datum/newscaster/feed_channel
	var/admin_signature

	var/href_token

	var/deadmined

/datum/admins/New(datum/admin_rank/R, ckey, force_active = FALSE, protected)
	//if(IsAdminAdvancedProcCall())
	//	var/msg = " has tried to elevate permissions!"
	//	message_admins("[key_name_admin(usr)][msg]")
	//	log_admin("[key_name(usr)][msg]")
	//	if (!target)
	//		QDEL_IN(src, 0)
	//		CRASH("Admin proc call creation of admin datum")
	//	return
	if(!ckey)
		QDEL_IN(src, 0)
		//throw EXCEPTION("Admin datum created without a ckey")
		CRASH("Admin datum created without a ckey")//not_actual
		return
	if(!istype(R))
		QDEL_IN(src, 0)
		//throw EXCEPTION("Admin datum created without a rank")
		CRASH("Admin datum created without a rank")//not_actual
		return
	target = ckey
	name = "[ckey]'s admin datum ([R])"
	rank = R
	admin_signature = "Nanotrasen Officer #[rand(0,9)][rand(0,9)][rand(0,9)]"
	href_token = GenerateToken()
	//if(R.rights & R_DEBUG)
	//	world.SetConfig("APP/admin", ckey, "role=admin")
	//if(protected)
	//	GLOB.protected_admins[target] = src
	if (force_active || (R.rights & R_AUTOADMIN))
		activate()
	else
		deactivate()

/datum/admins/Destroy()
	//if(IsAdminAdvancedProcCall())
	//	var/msg = " has tried to elevate permissions!"
	//	message_admins("[key_name_admin(usr)][msg]")
	//	log_admin("[key_name(usr)][msg]")
	//	return QDEL_HINT_LETMELIVE
	. = ..()

/datum/admins/proc/activate()
	//if(IsAdminAdvancedProcCall())
	//	var/msg = " has tried to elevate permissions!"
	//	message_admins("[key_name_admin(usr)][msg]")
	//	log_admin("[key_name(usr)][msg]")
	//	return
	GLOB.deadmins -= target
	GLOB.admin_datums[target] = src
	deadmined = FALSE
	if (GLOB.directory[target])
		associate(GLOB.directory[target])


/datum/admins/proc/deactivate()
	//if(IsAdminAdvancedProcCall())
	//	var/msg = " has tried to elevate permissions!"
	//	message_admins("[key_name_admin(usr)][msg]")
	//	log_admin("[key_name(usr)][msg]")
	//	return
	GLOB.deadmins[target] = src
	GLOB.admin_datums -= target
	deadmined = TRUE
	var/client/C
	if ((C = owner) || (C = GLOB.directory[target]))
		disassociate()
		//C.verbs += /client/proc/readmin

/datum/admins/proc/associate(client/C)
	//if(IsAdminAdvancedProcCall())
	//	var/msg = " has tried to elevate permissions!"
	//	message_admins("[key_name_admin(usr)][msg]")
	//	log_admin("[key_name(usr)][msg]")
	//	return

	if(istype(C))
		if(C.ckey != target)
			var/msg = " has attempted to associate with [target]'s admin datum"
			message_admins("[key_name_admin(C)][msg]")
			log_admin("[key_name(C)][msg]")
			return
		if (deadmined)
			activate()
		owner = C
		owner.holder = src
		owner.add_admin_verbs()
		//owner.verbs -= /client/proc/readmin
		GLOB.admins |= C

/datum/admins/proc/disassociate()
	//if(IsAdminAdvancedProcCall())
	//	var/msg = " has tried to elevate permissions!"
	//	message_admins("[key_name_admin(usr)][msg]")
	//	log_admin("[key_name(usr)][msg]")
	//	return
	if(owner)
		GLOB.admins -= owner
		//owner.remove_admin_verbs()
		owner.holder = null
		owner = null

/datum/admins/proc/check_for_rights(rights_required)
	//if(rights_required && !(rights_required & rank.rights))
	//	return 0
	return 1

/proc/check_rights(rights_required, show_msg=1)
	if(usr && usr.client)
		if (check_rights_for(usr.client, rights_required))
			return 1
		else
			if(show_msg)
				to_chat(usr, "<font color='red'>Error: You do not have sufficient rights to do that. You require one of the following flags:[rights2text(rights_required," ")].</font>")
	return 0

/proc/check_rights_for(client/subject, rights_required)
	if(subject && subject.holder)
		return subject.holder.check_for_rights(rights_required)
	return 0

/proc/GenerateToken()
	. = ""
	for(var/I in 1 to 32)
		. += "[rand(10)]"

/proc/RawHrefToken(forceGlobal = FALSE)
	var/tok = GLOB.href_token
	if(!forceGlobal && usr)
		var/client/C = usr.client
		if(!C)
			CRASH("No client for HrefToken()!")
		var/datum/admins/holder = C.holder
		if(holder)
			tok = holder.href_token
	return tok

/proc/HrefToken(forceGlobal = FALSE)
	return "admin_token=[RawHrefToken(forceGlobal)]"

/proc/HrefTokenFormField(forceGlobal = FALSE)
	return "<input type='hidden' name='admin_token' value='[RawHrefToken(forceGlobal)]'>"