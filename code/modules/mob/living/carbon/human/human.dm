/mob/living/carbon/human
	name = "Unknown"
	real_name = "Unknown"
	icon = 'icons/mob/human.dmi'
	icon_state = "human_basic"

/mob/living/carbon/human/Initialize()
	icon_state = ""

	create_bodyparts()

	create_dna(src)
	randomize_human(src)
	dna.initialize_dna()

	if(dna.species)
		set_species(dna.species.type)
	
	//physiology = new()
	physiology = new /datum/physiology()//not_actual

	. = ..()

/mob/living/carbon/human/Destroy()
	QDEL_NULL(physiology)
	return ..()

/mob/living/carbon/human/Stat()
	..()

	if(statpanel("Status"))
		stat(null, "Intent: [a_intent]")
		stat(null, "Move Mode: [m_intent]")
		//if (internal)
		//	if (!internal.air_contents)
		//		qdel(internal)
		//	else
		//		stat("Internal Atmosphere Info", internal.name)
		//		stat("Tank Pressure", internal.air_contents.return_pressure())
		//		stat("Distribution Pressure", internal.distribute_pressure)

		//if(mind)
		//	var/datum/antagonist/changeling/changeling = mind.has_antag_datum(/datum/antagonist/changeling)
		//	if(changeling)
		//		stat("Chemical Storage", "[changeling.chem_charges]/[changeling.chem_storage]")
		//		stat("Absorbed DNA", changeling.absorbedcount)
		//	var/datum/antagonist/hivemind/hivemind = mind.has_antag_datum(/datum/antagonist/hivemind)
		//	if(hivemind)
		//		stat("Hivemind Vessels", hivemind.hive_size)

	//if(istype(wear_suit, /obj/item/clothing/suit/space/space_ninja)) //Only display if actually a ninja.
	//	var/obj/item/clothing/suit/space/space_ninja/SN = wear_suit
	//	if(statpanel("SpiderOS"))
	//		stat("SpiderOS Status:","[SN.s_initialized ? "Initialized" : "Disabled"]")
	//		stat("Current Time:", "[station_time_timestamp()]")
	//		if(SN.s_initialized)
	//			stat("Energy Charge:", "[round(SN.cell.charge/100)]%")
	//			stat("Smoke Bombs:", "\Roman [SN.s_bombs]")
	//			stat("Fingerprints:", "[md5(dna.uni_identity)]")
	//			stat("Unique Identity:", "[dna.unique_enzymes]")
	//			stat("Overall Status:", "[stat > 1 ? "dead" : "[health]% healthy"]")
	//			stat("Nutrition Status:", "[nutrition]")
	//			stat("Oxygen Loss:", "[getOxyLoss()]")
	//			stat("Toxin Levels:", "[getToxLoss()]")
	//			stat("Burn Severity:", "[getFireLoss()]")
	//			stat("Brute Trauma:", "[getBruteLoss()]")
	//			stat("Radiation Levels:","[radiation] rad")
	//			stat("Body Temperature:","[bodytemperature-T0C] degrees C ([bodytemperature*1.8-459.67] degrees F)")

	//			if(diseases.len)
	//				stat("Viruses:", null)
	//				for(var/thing in diseases)
	//					var/datum/disease/D = thing
	//					stat("*", "[D.name], Type: [D.spread_text], Stage: [D.stage]/[D.max_stages], Possible Cure: [D.cure_text]")

/mob/living/carbon/human/show_inv(mob/user)
	user.set_machine(src)
	//var/has_breathable_mask = istype(wear_mask, /obj/item/clothing/mask)
	var/list/obscured = check_obscured_slots()
	var/list/dat = list()

	dat += "<table>"
	//for(var/i in 1 to held_items.len)
	//	var/obj/item/I = get_item_for_held_index(i)
	//	dat += "<tr><td><B>[get_held_index_name(i)]:</B></td><td><A href='?src=[REF(src)];item=[SLOT_HANDS];hand_index=[i]'>[(I && !(I.item_flags & ABSTRACT)) ? I : "<font color=grey>Empty</font>"]</a></td></tr>"
	dat += "<tr><td>&nbsp;</td></tr>"

	//not_actual: macros have been removed from within the strings
	dat += "<tr><td><B>Back:</B></td><td><A href='?src=[REF(src)];item=[SLOT_BACK]'>[(back && !(back.item_flags & ABSTRACT)) ? back : "<font color=grey>Empty</font>"]</A>"
	//if(has_breathable_mask && istype(back, /obj/item/tank))
	//	dat += "&nbsp;<A href='?src=[REF(src)];internal=[SLOT_BACK]'>[internal ? "Disable Internals" : "Set Internals"]</A>"

	dat += "</td></tr><tr><td>&nbsp;</td></tr>"

	dat += "<tr><td><B>Head:</B></td><td><A href='?src=[REF(src)];item=[SLOT_HEAD]'>[(head && !(head.item_flags & ABSTRACT)) ? head : "<font color=grey>Empty</font>"]</A></td></tr>"

	if(SLOT_WEAR_MASK in obscured)
		dat += "<tr><td><font color=grey><B>Mask:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Mask:</B></td><td><A href='?src=[REF(src)];item=[SLOT_WEAR_MASK]'>[(wear_mask && !(wear_mask.item_flags & ABSTRACT)) ? wear_mask : "<font color=grey>Empty</font>"]</A></td></tr>"

	if(SLOT_NECK in obscured)
		dat += "<tr><td><font color=grey><B>Neck:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Neck:</B></td><td><A href='?src=[REF(src)];item=[SLOT_NECK]'>[(wear_neck && !(wear_neck.item_flags & ABSTRACT)) ? wear_neck : "<font color=grey>Empty</font>"]</A></td></tr>"

	if(SLOT_GLASSES in obscured)
		dat += "<tr><td><font color=grey><B>Eyes:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Eyes:</B></td><td><A href='?src=[REF(src)];item=[SLOT_GLASSES]'>[(glasses && !(glasses.item_flags & ABSTRACT))	? glasses : "<font color=grey>Empty</font>"]</A></td></tr>"

	if(SLOT_EARS in obscured)
		dat += "<tr><td><font color=grey><B>Ears:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Ears:</B></td><td><A href='?src=[REF(src)];item=[SLOT_EARS]'>[(ears && !(ears.item_flags & ABSTRACT))		? ears		: "<font color=grey>Empty</font>"]</A></td></tr>"

	dat += "<tr><td>&nbsp;</td></tr>"

	dat += "<tr><td><B>Exosuit:</B></td><td><A href='?src=[REF(src)];item=[SLOT_WEAR_SUIT]'>[(wear_suit && !(wear_suit.item_flags & ABSTRACT)) ? wear_suit : "<font color=grey>Empty</font>"]</A></td></tr>"
	if(wear_suit)
		if(SLOT_S_STORE in obscured)
			dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>Suit Storage:</B></font></td></tr>"
		else
			dat += "<tr><td>&nbsp;&#8627;<B>Suit Storage:</B></td><td><A href='?src=[REF(src)];item=[SLOT_S_STORE]'>[(s_store && !(s_store.item_flags & ABSTRACT)) ? s_store : "<font color=grey>Empty</font>"]</A>"
			//if(has_breathable_mask && istype(s_store, /obj/item/tank))
			//	dat += "&nbsp;<A href='?src=[REF(src)];internal=[SLOT_S_STORE]'>[internal ? "Disable Internals" : "Set Internals"]</A>"
			dat += "</td></tr>"
	else
		dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>Suit Storage:</B></font></td></tr>"

	if(SLOT_SHOES in obscured)
		dat += "<tr><td><font color=grey><B>Shoes:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Shoes:</B></td><td><A href='?src=[REF(src)];item=[SLOT_SHOES]'>[(shoes && !(shoes.item_flags & ABSTRACT))		? shoes		: "<font color=grey>Empty</font>"]</A></td></tr>"

	if(SLOT_GLOVES in obscured)
		dat += "<tr><td><font color=grey><B>Gloves:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Gloves:</B></td><td><A href='?src=[REF(src)];item=[SLOT_GLOVES]'>[(gloves && !(gloves.item_flags & ABSTRACT))		? gloves	: "<font color=grey>Empty</font>"]</A></td></tr>"

	if(SLOT_W_UNIFORM in obscured)
		dat += "<tr><td><font color=grey><B>Uniform:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Uniform:</B></td><td><A href='?src=[REF(src)];item=[SLOT_W_UNIFORM]'>[(w_uniform && !(w_uniform.item_flags & ABSTRACT)) ? w_uniform : "<font color=grey>Empty</font>"]</A></td></tr>"

	//if((w_uniform == null && !(dna && dna.species.nojumpsuit)) || (SLOT_W_UNIFORM in obscured))
	//	dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>Pockets:</B></font></td></tr>"
	//	dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>ID:</B></font></td></tr>"
	//	dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>Belt:</B></font></td></tr>"
	//else
	//	dat += "<tr><td>&nbsp;&#8627;<B>Belt:</B></td><td><A href='?src=[REF(src)];item=[SLOT_BELT]'>[(belt && !(belt.item_flags & ABSTRACT)) ? belt : "<font color=grey>Empty</font>"]</A>"
	//	if(has_breathable_mask && istype(belt, /obj/item/tank))
	//		dat += "&nbsp;<A href='?src=[REF(src)];internal=[SLOT_BELT]'>[internal ? "Disable Internals" : "Set Internals"]</A>"
	//	dat += "</td></tr>"
	//	dat += "<tr><td>&nbsp;&#8627;<B>Pockets:</B></td><td><A href='?src=[REF(src)];pockets=left'>[(l_store && !(l_store.item_flags & ABSTRACT)) ? "Left (Full)" : "<font color=grey>Left (Empty)</font>"]</A>"
	//	dat += "&nbsp;<A href='?src=[REF(src)];pockets=right'>[(r_store && !(r_store.item_flags & ABSTRACT)) ? "Right (Full)" : "<font color=grey>Right (Empty)</font>"]</A></td></tr>"
	//	dat += "<tr><td>&nbsp;&#8627;<B>ID:</B></td><td><A href='?src=[REF(src)];item=[SLOT_WEAR_ID]'>[(wear_id && !(wear_id.item_flags & ABSTRACT)) ? wear_id : "<font color=grey>Empty</font>"]</A></td></tr>"

	//if(handcuffed)
	//	dat += "<tr><td><B>Handcuffed:</B> <A href='?src=[REF(src)];item=[SLOT_HANDCUFFED]'>Remove</A></td></tr>"
	//if(legcuffed)
	//	dat += "<tr><td><A href='?src=[REF(src)];item=[SLOT_LEGCUFFED]'>Legcuffed</A></td></tr>"

	dat += {"</table>
	<A href='?src=[REF(user)];mach_close=mob[REF(src)]'>Close</A>
	"}

	var/datum/browser/popup = new(user, "mob[REF(src)]", "[src]", 440, 510)
	popup.set_content(dat.Join())
	popup.open()

/mob/living/carbon/human/Topic(href, href_list)
	//if(href_list["embedded_object"] && usr.canUseTopic(src, BE_CLOSE, NO_DEXTERY))
	//	var/obj/item/bodypart/L = locate(href_list["embedded_limb"]) in bodyparts
	//	if(!L)
	//		return
	//	var/obj/item/I = locate(href_list["embedded_object"]) in L.embedded_objects
	//	if(!I || I.loc != src) //no item, no limb, or item is not in limb or in the person anymore
	//		return
	//	var/time_taken = I.embedding.embedded_unsafe_removal_time*I.w_class
	//	usr.visible_message("<span class='warning'>[usr] attempts to remove [I] from [usr.p_their()] [L.name].</span>","<span class='notice'>You attempt to remove [I] from your [L.name]... (It will take [DisplayTimeText(time_taken)].)</span>")
	//	if(do_after(usr, time_taken, needhand = 1, target = src))
	//		if(!I || !L || I.loc != src || !(I in L.embedded_objects))
	//			return
	//		L.embedded_objects -= I
	//		L.receive_damage(I.embedding.embedded_unsafe_removal_pain_multiplier*I.w_class)//It hurts to rip it out, get surgery you dingus.
	//		I.forceMove(get_turf(src))
	//		usr.put_in_hands(I)
	//		usr.emote("scream")
	//		usr.visible_message("[usr] successfully rips [I] out of [usr.p_their()] [L.name]!","<span class='notice'>You successfully remove [I] from your [L.name].</span>")
	//		if(!has_embedded_objects())
	//			clear_alert("embeddedobject")
	//			SEND_SIGNAL(usr, COMSIG_CLEAR_MOOD_EVENT, "embedded")
	//	return

	//if(href_list["item"])
	//	var/slot = text2num(href_list["item"])
	//	if(slot in check_obscured_slots(TRUE))
	//		to_chat(usr, "<span class='warning'>You can't reach that! Something is covering it.</span>")
	//		return

	//if(href_list["pockets"] && usr.canUseTopic(src, BE_CLOSE, NO_DEXTERY))
	//	var/pocket_side = href_list["pockets"]
	//	var/pocket_id = (pocket_side == "right" ? SLOT_R_STORE : SLOT_L_STORE)
	//	var/obj/item/pocket_item = (pocket_id == SLOT_R_STORE ? r_store : l_store)
	//	var/obj/item/place_item = usr.get_active_held_item()

	//	var/delay_denominator = 1
	//	if(pocket_item && !(pocket_item.item_flags & ABSTRACT))
	//		if(pocket_item.item_flags & NODROP)
	//			to_chat(usr, "<span class='warning'>You try to empty [src]'s [pocket_side] pocket, it seems to be stuck!</span>")
	//		to_chat(usr, "<span class='notice'>You try to empty [src]'s [pocket_side] pocket.</span>")
	//	else if(place_item && place_item.mob_can_equip(src, usr, pocket_id, 1) && !(place_item.item_flags & ABSTRACT))
	//		to_chat(usr, "<span class='notice'>You try to place [place_item] into [src]'s [pocket_side] pocket.</span>")
	//		delay_denominator = 4
	//	else
	//		return

	//	if(do_mob(usr, src, POCKET_STRIP_DELAY/delay_denominator))
	//		if(pocket_item)
	//			if(pocket_item == (pocket_id == SLOT_R_STORE ? r_store : l_store))
	//				dropItemToGround(pocket_item)
	//		else
	//			if(place_item)
	//				if(place_item.mob_can_equip(src, usr, pocket_id, FALSE, TRUE))
	//					usr.temporarilyRemoveItemFromInventory(place_item, TRUE)
	//					equip_to_slot(place_item, pocket_id, TRUE)
	//	else
	//		to_chat(src, "<span class='warning'>You feel your [pocket_side] pocket being fumbled with!</span>")

	//if(href_list["hud"])
	//	if(ishuman(usr))
	//		var/mob/living/carbon/human/H = usr
	//		var/perpname = get_face_name(get_id_name(""))
	//		if(istype(H.glasses, /obj/item/clothing/glasses/hud) || istype(H.getorganslot(ORGAN_SLOT_HUD), /obj/item/organ/cyberimp/eyes/hud))
	//			var/datum/data/record/R = find_record("name", perpname, GLOB.data_core.general)
	//			if(href_list["photo_front"] || href_list["photo_side"])
	//				if(R)
	//					if(!H.canUseHUD())
	//						return
	//					else if(!istype(H.glasses, /obj/item/clothing/glasses/hud) && !istype(H.getorganslot(ORGAN_SLOT_HUD), /obj/item/organ/cyberimp/eyes/hud/medical))
	//						return
	//					var/obj/item/photo/P = null
	//					if(href_list["photo_front"])
	//						P = R.fields["photo_front"]
	//					else if(href_list["photo_side"])
	//						P = R.fields["photo_side"]
	//					if(P)
	//						P.show(H)

	//			if(href_list["hud"] == "m")
	//				if(istype(H.glasses, /obj/item/clothing/glasses/hud/health) || istype(H.getorganslot(ORGAN_SLOT_HUD), /obj/item/organ/cyberimp/eyes/hud/medical))
	//					if(href_list["p_stat"])
	//						var/health_status = input(usr, "Specify a new physical status for this person.", "Medical HUD", R.fields["p_stat"]) in list("Active", "Physically Unfit", "*Unconscious*", "*Deceased*", "Cancel")
	//						if(R)
	//							if(!H.canUseHUD())
	//								return
	//							else if(!istype(H.glasses, /obj/item/clothing/glasses/hud/health) && !istype(H.getorganslot(ORGAN_SLOT_HUD), /obj/item/organ/cyberimp/eyes/hud/medical))
	//								return
	//							if(health_status && health_status != "Cancel")
	//								R.fields["p_stat"] = health_status
	//						return
	//					if(href_list["m_stat"])
	//						var/health_status = input(usr, "Specify a new mental status for this person.", "Medical HUD", R.fields["m_stat"]) in list("Stable", "*Watch*", "*Unstable*", "*Insane*", "Cancel")
	//						if(R)
	//							if(!H.canUseHUD())
	//								return
	//							else if(!istype(H.glasses, /obj/item/clothing/glasses/hud/health) && !istype(H.getorganslot(ORGAN_SLOT_HUD), /obj/item/organ/cyberimp/eyes/hud/medical))
	//								return
	//							if(health_status && health_status != "Cancel")
	//								R.fields["m_stat"] = health_status
	//						return
	//					if(href_list["evaluation"])
	//						if(!getBruteLoss() && !getFireLoss() && !getOxyLoss() && getToxLoss() < 20)
	//							to_chat(usr, "<span class='notice'>No external injuries detected.</span><br>")
	//							return
	//						var/span = "notice"
	//						var/status = ""
	//						if(getBruteLoss())
	//							to_chat(usr, "<b>Physical trauma analysis:</b>")
	//							for(var/X in bodyparts)
	//								var/obj/item/bodypart/BP = X
	//								var/brutedamage = BP.brute_dam
	//								if(brutedamage > 0)
	//									status = "received minor physical injuries."
	//									span = "notice"
	//								if(brutedamage > 20)
	//									status = "been seriously damaged."
	//									span = "danger"
	//								if(brutedamage > 40)
	//									status = "sustained major trauma!"
	//									span = "userdanger"
	//								if(brutedamage)
	//									to_chat(usr, "<span class='[span]'>[BP] appears to have [status]</span>")
	//						if(getFireLoss())
	//							to_chat(usr, "<b>Analysis of skin burns:</b>")
	//							for(var/X in bodyparts)
	//								var/obj/item/bodypart/BP = X
	//								var/burndamage = BP.burn_dam
	//								if(burndamage > 0)
	//									status = "signs of minor burns."
	//									span = "notice"
	//								if(burndamage > 20)
	//									status = "serious burns."
	//									span = "danger"
	//								if(burndamage > 40)
	//									status = "major burns!"
	//									span = "userdanger"
	//								if(burndamage)
	//									to_chat(usr, "<span class='[span]'>[BP] appears to have [status]</span>")
	//						if(getOxyLoss())
	//							to_chat(usr, "<span class='danger'>Patient has signs of suffocation, emergency treatment may be required!</span>")
	//						if(getToxLoss() > 20)
	//							to_chat(usr, "<span class='danger'>Gathered data is inconsistent with the analysis, possible cause: poisoning.</span>")

	//			if(href_list["hud"] == "s")
	//				if(istype(H.glasses, /obj/item/clothing/glasses/hud/security) || istype(H.getorganslot(ORGAN_SLOT_HUD), /obj/item/organ/cyberimp/eyes/hud/security))
	//					if(usr.stat || usr == src)
	//						return
	//					var/allowed_access = null
	//					var/obj/item/clothing/glasses/hud/security/G = H.glasses
	//					if(istype(G) && (G.obj_flags & EMAGGED))
	//						allowed_access = "@%&ERROR_%$*"
	//					else
	//						if(H.wear_id)
	//							var/list/access = H.wear_id.GetAccess()
	//							if(ACCESS_SEC_DOORS in access)
	//								allowed_access = H.get_authentification_name()

	//					if(!allowed_access)
	//						to_chat(H, "<span class='warning'>ERROR: Invalid Access</span>")
	//						return

	//					if(perpname)
	//						R = find_record("name", perpname, GLOB.data_core.security)
	//						if(R)
	//							if(href_list["status"])
	//								var/setcriminal = input(usr, "Specify a new criminal status for this person.", "Security HUD", R.fields["criminal"]) in list("None", "*Arrest*", "Incarcerated", "Paroled", "Discharged", "Cancel")
	//								if(setcriminal != "Cancel")
	//									if(R)
	//										if(H.canUseHUD())
	//											if(istype(H.glasses, /obj/item/clothing/glasses/hud/security) || istype(H.getorganslot(ORGAN_SLOT_HUD), /obj/item/organ/cyberimp/eyes/hud/security))
	//												investigate_log("[key_name(src)] has been set from [R.fields["criminal"]] to [setcriminal] by [key_name(usr)].", INVESTIGATE_RECORDS)
	//												R.fields["criminal"] = setcriminal
	//												sec_hud_set_security_status()
	//								return

	//							if(href_list["view"])
	//								if(R)
	//									if(!H.canUseHUD())
	//										return
	//									else if(!istype(H.glasses, /obj/item/clothing/glasses/hud/security) && !istype(H.getorganslot(ORGAN_SLOT_HUD), /obj/item/organ/cyberimp/eyes/hud/security))
	//										return
	//									to_chat(usr, "<b>Name:</b> [R.fields["name"]]	<b>Criminal Status:</b> [R.fields["criminal"]]")
	//									to_chat(usr, "<b>Minor Crimes:</b>")
	//									for(var/datum/data/crime/c in R.fields["mi_crim"])
	//										to_chat(usr, "<b>Crime:</b> [c.crimeName]")
	//										to_chat(usr, "<b>Details:</b> [c.crimeDetails]")
	//										to_chat(usr, "Added by [c.author] at [c.time]")
	//										to_chat(usr, "----------")
	//									to_chat(usr, "<b>Major Crimes:</b>")
	//									for(var/datum/data/crime/c in R.fields["ma_crim"])
	//										to_chat(usr, "<b>Crime:</b> [c.crimeName]")
	//										to_chat(usr, "<b>Details:</b> [c.crimeDetails]")
	//										to_chat(usr, "Added by [c.author] at [c.time]")
	//										to_chat(usr, "----------")
	//									to_chat(usr, "<b>Notes:</b> [R.fields["notes"]]")
	//								return

	//							if(href_list["add_crime"])
	//								switch(alert("What crime would you like to add?","Security HUD","Minor Crime","Major Crime","Cancel"))
	//									if("Minor Crime")
	//										if(R)
	//											var/t1 = stripped_input("Please input minor crime names:", "Security HUD", "", null)
	//											var/t2 = stripped_multiline_input("Please input minor crime details:", "Security HUD", "", null)
	//											if(R)
	//												if (!t1 || !t2 || !allowed_access)
	//													return
	//												else if(!H.canUseHUD())
	//													return
	//												else if(!istype(H.glasses, /obj/item/clothing/glasses/hud/security) && !istype(H.getorganslot(ORGAN_SLOT_HUD), /obj/item/organ/cyberimp/eyes/hud/security))
	//													return
	//												var/crime = GLOB.data_core.createCrimeEntry(t1, t2, allowed_access, station_time_timestamp())
	//												GLOB.data_core.addMinorCrime(R.fields["id"], crime)
	//												investigate_log("New Minor Crime: <strong>[t1]</strong>: [t2] | Added to [R.fields["name"]] by [key_name(usr)]", INVESTIGATE_RECORDS)
	//												to_chat(usr, "<span class='notice'>Successfully added a minor crime.</span>")
	//												return
	//									if("Major Crime")
	//										if(R)
	//											var/t1 = stripped_input("Please input major crime names:", "Security HUD", "", null)
	//											var/t2 = stripped_multiline_input("Please input major crime details:", "Security HUD", "", null)
	//											if(R)
	//												if (!t1 || !t2 || !allowed_access)
	//													return
	//												else if (!H.canUseHUD())
	//													return
	//												else if (!istype(H.glasses, /obj/item/clothing/glasses/hud/security) && !istype(H.getorganslot(ORGAN_SLOT_HUD), /obj/item/organ/cyberimp/eyes/hud/security))
	//													return
	//												var/crime = GLOB.data_core.createCrimeEntry(t1, t2, allowed_access, station_time_timestamp())
	//												GLOB.data_core.addMajorCrime(R.fields["id"], crime)
	//												investigate_log("New Major Crime: <strong>[t1]</strong>: [t2] | Added to [R.fields["name"]] by [key_name(usr)]", INVESTIGATE_RECORDS)
	//												to_chat(usr, "<span class='notice'>Successfully added a major crime.</span>")
	//								return

	//							if(href_list["view_comment"])
	//								if(R)
	//									if(!H.canUseHUD())
	//										return
	//									else if(!istype(H.glasses, /obj/item/clothing/glasses/hud/security) && !istype(H.getorganslot(ORGAN_SLOT_HUD), /obj/item/organ/cyberimp/eyes/hud/security))
	//										return
	//									to_chat(usr, "<b>Comments/Log:</b>")
	//									var/counter = 1
	//									while(R.fields[text("com_[]", counter)])
	//										to_chat(usr, R.fields[text("com_[]", counter)])
	//										to_chat(usr, "----------")
	//										counter++
	//									return

	//							if(href_list["add_comment"])
	//								if(R)
	//									var/t1 = stripped_multiline_input("Add Comment:", "Secure. records", null, null)
	//									if(R)
	//										if (!t1 || !allowed_access)
	//											return
	//										else if(!H.canUseHUD())
	//											return
	//										else if(!istype(H.glasses, /obj/item/clothing/glasses/hud/security) && !istype(H.getorganslot(ORGAN_SLOT_HUD), /obj/item/organ/cyberimp/eyes/hud/security))
	//											return
	//										var/counter = 1
	//										while(R.fields[text("com_[]", counter)])
	//											counter++
	//										R.fields[text("com_[]", counter)] = text("Made by [] on [] [], []<BR>[]", allowed_access, station_time_timestamp(), time2text(world.realtime, "MMM DD"), GLOB.year_integer+540, t1)
	//										to_chat(usr, "<span class='notice'>Successfully added comment.</span>")
	//										return
	//						to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")

	..()

/mob/living/carbon/human/can_inject(mob/user, error_msg, target_zone, var/penetrate_thick = 0)
	. = 1
	if(user && !target_zone)
		target_zone = user.zone_selected
	if(has_trait(TRAIT_PIERCEIMMUNE))
		. = 0
	if (!penetrate_thick)
		if(above_neck(target_zone))
			if(head && istype(head, /obj/item/clothing))
				var/obj/item/clothing/CH = head
				if (CH.clothing_flags & THICKMATERIAL)
					. = 0
		else
			if(wear_suit && istype(wear_suit, /obj/item/clothing))
				var/obj/item/clothing/CS = wear_suit
				if (CS.clothing_flags & THICKMATERIAL)
					. = 0
	if(!. && error_msg && user)
		to_chat(user, "<span class='alert'>There is no exposed flesh or thin material [above_neck(target_zone) ? "on [p_their()] head" : "on [p_their()] body"].</span>")

/mob/living/carbon/human/canUseTopic(atom/movable/M, be_close=FALSE, no_dextery=FALSE, no_tk=FALSE)
	if(!(mobility_flags & MOBILITY_UI))
		to_chat(src, "<span class='warning'>You can't do that right now!</span>")
		return FALSE
	if(!Adjacent(M) && (M.loc != src))
		//if((be_close == 0) || (!no_tk && (dna.check_mutation(TK) && tkMaxRangeCheck(src, M))))
		if(be_close == 0)//not_actual
			return TRUE
		to_chat(src, "<span class='warning'>You are too far away!</span>")
		return FALSE
	return TRUE

/mob/living/carbon/human/replace_records_name(oldname,newname)
	for(var/list/L in list(GLOB.data_core.general,GLOB.data_core.medical,GLOB.data_core.security,GLOB.data_core.locked))
		var/datum/data/record/R = find_record("name", oldname, L)
		if(R)
			R.fields["name"] = newname

/mob/living/carbon/human/update_health_hud()
	if(!client || !hud_used)
		return
	if(dna.species.update_health_hud())
		return
	else
		if(hud_used.healths)
			var/health_amount = health - getStaminaLoss()
			if(..(health_amount))
				switch(hal_screwyhud)
					if(SCREWYHUD_CRIT)
						hud_used.healths.icon_state = "health6"
					if(SCREWYHUD_DEAD)
						hud_used.healths.icon_state = "health7"
					if(SCREWYHUD_HEALTHY)
						hud_used.healths.icon_state = "health0"
		if(hud_used.healthdoll)
			hud_used.healthdoll.cut_overlays()
			if(stat != DEAD)
				hud_used.healthdoll.icon_state = "healthdoll_OVERLAY"
				for(var/X in bodyparts)
					var/obj/item/bodypart/BP = X
					var/damage = BP.burn_dam + BP.brute_dam
					var/comparison = (BP.max_damage/5)
					var/icon_num = 0
					if(damage)
						icon_num = 1
					if(damage > (comparison))
						icon_num = 2
					if(damage > (comparison*2))
						icon_num = 3
					if(damage > (comparison*3))
						icon_num = 4
					if(damage > (comparison*4))
						icon_num = 5
					if(hal_screwyhud == SCREWYHUD_HEALTHY)
						icon_num = 0
					if(icon_num)
						hud_used.healthdoll.add_overlay(mutable_appearance('icons/mob/screen_gen.dmi', "[BP.body_zone][icon_num]"))
				for(var/t in get_missing_limbs()) 
					hud_used.healthdoll.add_overlay(mutable_appearance('icons/mob/screen_gen.dmi', "[t]6"))
				//for(var/t in get_disabled_limbs())
				//	hud_used.healthdoll.add_overlay(mutable_appearance('icons/mob/screen_gen.dmi', "[t]7"))
			else
				hud_used.healthdoll.icon_state = "healthdoll_DEAD"

/mob/living/carbon/human/fully_heal(admin_revive = 0)
	//dna?.species.spec_fully_heal(src)
	//if(admin_revive)
	//	regenerate_limbs()
	//	regenerate_organs()
	//remove_all_embedded_objects()
	//set_heartattack(FALSE)
	//drunkenness = 0
	//set_hygiene(HYGIENE_LEVEL_NORMAL)
	//for(var/datum/mutation/human/HM in dna.mutations)
	//	if(HM.quality != POSITIVE)
	//		dna.remove_mutation(HM.name)
	..()

/mob/living/carbon/human/is_literate()
	return TRUE

/mob/living/carbon/human/can_hold_items()
	return TRUE