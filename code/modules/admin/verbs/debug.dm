///client/proc/cmd_admin_grantfullaccess(mob/M in GLOB.mob_list)
/client/proc/cmd_admin_grantfullaccess()//not_actual
	//set category = "Admin"
	//set name = "Grant Full Access"

	var/mob/M = usr//not_actual
	if(!SSticker.HasRoundStarted())
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/worn = H.wear_id
		var/obj/item/card/id/id = null
		if(worn)
			id = worn.GetID()
		if(id)
			id.icon_state = "gold"
			id.access = get_all_accesses()+get_all_centcom_access()+get_all_syndicate_access()
		else
			id = new /obj/item/card/id/gold(H.loc)
			id.access = get_all_accesses()+get_all_centcom_access()+get_all_syndicate_access()
			id.registered_name = H.real_name
			id.assignment = "Captain"
			id.update_label()

			if(worn)
				if(istype(worn, /obj/item/pda))
					var/obj/item/pda/PDA = worn
					PDA.id = id
					id.forceMove(PDA)
				//else if(istype(worn, /obj/item/storage/wallet))
				//	var/obj/item/storage/wallet/W = worn
				//	W.front_id = id
				//	id.forceMove(W)
				//	W.update_icon()
			else
				H.equip_to_slot(id,SLOT_WEAR_ID)

	else
		alert("Invalid mob")
	//SSblackbox.record_feedback("tally", "admin_verb", 1, "Grant Full Access") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	//log_admin("[key_name(src)] has granted [M.key] full access.")
	//message_admins("<span class='adminnotice'>[key_name_admin(usr)] has granted [M.key] full access.</span>")