/obj/item/card
	name = "card"
	desc = "Does card things."
	icon = 'icons/obj/card.dmi'
	w_class = WEIGHT_CLASS_TINY

	var/list/files = list()

/obj/item/card/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins to swipe [user.p_their()] neck with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS

/obj/item/card/emag
	desc = "It's a card with a magnetic strip attached to some circuitry."
	name = "cryptographic sequencer"
	icon_state = "emag"
	item_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	item_flags = NO_MAT_REDEMPTION | NOBLUDGEON
	var/prox_check = TRUE

/obj/item/card/emag/attack()
	return

/obj/item/card/emag/afterattack(atom/target, mob/user, proximity)
	. = ..()
	var/atom/A = target
	if(!proximity && prox_check)
		return
	A.emag_act(user)

/obj/item/card/id
	name = "identification card"
	desc = "A card used to provide ID and determine access across the station."
	icon_state = "id"
	item_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	slot_flags = ITEM_SLOT_ID
	var/list/access = list()
	var/registered_name = null
	var/assignment = null
	var/datum/bank_account/registered_account

/obj/item/card/id/examine(mob/user)
	..()
	//if(mining_points)
	//	to_chat(user, "There's [mining_points] mining equipment redemption point\s loaded onto this card.")
	if(registered_account)
		to_chat(user, "The account linked to the ID belongs to '[registered_account.account_holder]' and reports a balance of $[registered_account.account_balance].")
		//if(registered_account.account_job)
		//	var/datum/bank_account/D = SSeconomy.get_dep_account(registered_account.account_job.paycheck_department)
		//	if(D)
		//		to_chat(user, "The [D.account_holder] reports a balance of $[D.account_balance].")
		to_chat(user, "<span class='info'>Alt-Click the ID while holding it to pull money from the linked account in the form of holochips.</span>")
		to_chat(user, "<span class='info'>You can insert credits into the linked account by pressing holochips, cash, or coins against the ID.</span>")
		if(registered_account.account_holder == user.real_name)
			to_chat(user, "<span class='boldnotice'>If you lose this ID card, you can reclaim your account by Alt-Clicking a blank ID card while holding it and entering your account ID number.</span>")
	else
		to_chat(user, "<span class='info'>There is no registered account linked to this card. Alt-Click to add one.</span>")

/obj/item/card/id/GetAccess()
	return access

/obj/item/card/id/GetID()
	return src

/obj/item/card/id/proc/update_label(newname, newjob)
	if(newname || newjob)
		name = "[(!newname)	? "identification card"	: "[newname]'s ID Card"][(!newjob) ? "" : " ([newjob])"]"
		return

	name = "[(!registered_name)	? "identification card"	: "[registered_name]'s ID Card"][(!assignment) ? "" : " ([assignment])"]"

/obj/item/card/id/silver
	name = "silver identification card"
	desc = "A silver card which shows honour and dedication."
	icon_state = "silver"

/obj/item/card/id/gold
	name = "gold identification card"
	desc = "A golden card which shows power and might."
	icon_state = "gold"

/obj/item/card/id/syndicate
	name = "agent card"

/obj/item/card/id/syndicate/nuke_leader
	name = "lead agent card"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER)

/obj/item/card/id/captains_spare
	name = "captain's spare ID"
	desc = "The spare ID of the High Lord himself."
	icon_state = "gold"

/obj/item/card/id/captains_spare/Initialize()
	var/datum/job/captain/J = new/datum/job/captain
	access = J.get_access()
	. = ..()

/obj/item/card/id/ert
	name = "\improper CentCom ID"
	desc = "An ERT ID card."
	icon_state = "centcom"

/obj/item/card/id/prisoner
	name = "prisoner ID card"
	desc = "You are a number, you are not a free man."
	icon_state = "orange"
	item_state = "orange-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	assignment = "Prisoner"
	registered_name = "Scum"
	var/goal = 0
	var/points = 0

/obj/item/card/id/prisoner/attack_self(mob/user)
	to_chat(usr, "<span class='notice'>You have accumulated [points] out of the [goal] points you need for freedom.</span>")

/obj/item/card/id/prisoner/one
	name = "Prisoner #13-001"
	registered_name = "Prisoner #13-001"

/obj/item/card/id/prisoner/two
	name = "Prisoner #13-002"
	registered_name = "Prisoner #13-002"

/obj/item/card/id/prisoner/three
	name = "Prisoner #13-003"
	registered_name = "Prisoner #13-003"

/obj/item/card/id/prisoner/four
	name = "Prisoner #13-004"
	registered_name = "Prisoner #13-004"

/obj/item/card/id/prisoner/five
	name = "Prisoner #13-005"
	registered_name = "Prisoner #13-005"

/obj/item/card/id/prisoner/six
	name = "Prisoner #13-006"
	registered_name = "Prisoner #13-006"

/obj/item/card/id/prisoner/seven
	name = "Prisoner #13-007"
	registered_name = "Prisoner #13-007"