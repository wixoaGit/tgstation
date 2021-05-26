/obj
	var/obj_flags = CAN_BE_HIT

	var/damtype = BRUTE
	var/force = 0

	var/datum/armor/armor
	var/obj_integrity
	var/max_integrity = 500
	var/integrity_failure = 0

	var/resistance_flags = NONE

	var/list/req_access
	var/req_access_txt = "0"
	var/list/req_one_access
	var/req_one_access_txt = "0"

	var/renamedByPlayer = FALSE

/obj/Initialize()
	. = ..()
	if (islist(armor))
		armor = getArmor(arglist(armor))
	else if (!armor)
		armor = getArmor()
	else if (!istype(armor, /datum/armor))
		stack_trace("Invalid type [armor.type] found in .armor during /obj Initialize()")

	if(obj_integrity == null)
		obj_integrity = max_integrity
	//if (set_obj_flags)
	//	var/flagslist = splittext(set_obj_flags,";")
	//	var/list/string_to_objflag = GLOB.bitfields["obj_flags"]
	//	for (var/flag in flagslist)
	//		if (findtext(flag,"!",1,2))
	//			flag = copytext(flag,1-(length(flag)))
	//			obj_flags &= ~string_to_objflag[flag]
	//		else
	//			obj_flags |= string_to_objflag[flag]
	//if((obj_flags & ON_BLUEPRINTS) && isturf(loc))
	//	var/turf/T = loc
	//	T.add_blueprints_preround(src)

/obj/Destroy(force=FALSE)
	if(!ismachinery(src))
		STOP_PROCESSING(SSobj, src)
	SStgui.close_uis(src)
	. = ..()

/obj/proc/setAnchored(anchorvalue)
	//SEND_SIGNAL(src, COMSIG_OBJ_SETANCHORED, anchorvalue)
	anchored = anchorvalue

/obj/assume_air(datum/gas_mixture/giver)
	if(loc)
		return loc.assume_air(giver)
	else
		return null

/obj/remove_air(amount)
	if(loc)
		return loc.remove_air(amount)
	else
		return null

/obj/return_air()
	if(loc)
		return loc.return_air()
	else
		return null

/obj/proc/updateUsrDialog()
	if((obj_flags & IN_USE) && !(obj_flags & USES_TGUI))
		var/is_in_use = FALSE
		var/list/nearby = viewers(1, src)
		for(var/mob/M in nearby)
			if ((M.client && M.machine == src))
				is_in_use = TRUE
				ui_interact(M)
		//if(isAI(usr) || iscyborg(usr) || IsAdminGhost(usr))
		//	if (!(usr in nearby))
		//		if (usr.client && usr.machine==src)
		//			is_in_use = TRUE
		//			ui_interact(usr)

		//if(ishuman(usr))
		//	var/mob/living/carbon/human/H = usr
		//	if(!(usr in nearby))
		//		if(usr.client && usr.machine==src)
		//			if(H.dna.check_mutation(TK))
		//				is_in_use = TRUE
		//				ui_interact(usr)
		if (is_in_use)
			obj_flags |= IN_USE
		else
			obj_flags &= ~IN_USE

/obj/proc/updateDialog(update_viewers = TRUE,update_ais = TRUE)
	if(obj_flags & IN_USE)
		var/is_in_use = FALSE
		if(update_viewers)
			for(var/mob/M in viewers(1, src))
				if ((M.client && M.machine == src))
					is_in_use = TRUE
					src.interact(M)
		var/ai_in_use = FALSE
		//if(update_ais)
		//	ai_in_use = AutoUpdateAI(src)

		if(update_viewers && update_ais)
			if(!ai_in_use && !is_in_use)
				obj_flags &= ~IN_USE

/obj/proc/update_icon()
	return

/mob/proc/unset_machine()
	if(machine)
		machine.on_unset_machine(src)
		machine = null

/atom/movable/proc/on_unset_machine(mob/user)
	return

/mob/proc/set_machine(obj/O)
	if(src.machine)
		unset_machine()
	src.machine = O
	if(istype(O))
		O.obj_flags |= IN_USE

/obj/item/proc/updateSelfDialog()
	var/mob/M = src.loc
	if(istype(M) && M.client && M.machine == src)
		src.attack_self(M)

/obj/proc/hide(h)
	return

/obj/get_dumping_location(datum/component/storage/source,mob/user)
	return get_turf(src)

/obj/proc/container_resist(mob/living/user)
	return