/obj/item/paper_bin
	name = "paper bin"
	desc = "Contains all the paper you'll never need."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper_bin1"
	item_state = "sheet-metal"
	lefthand_file = 'icons/mob/inhands/misc/sheets_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/sheets_righthand.dmi'
	throwforce = 0
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 3
	throw_range = 7
	pressure_resistance = 8
	var/papertype = /obj/item/paper
	var/total_paper = 30
	var/list/papers = list()
	var/obj/item/pen/bin_pen

/obj/item/paper_bin/Initialize(mapload)
	. = ..()
	interaction_flags_item &= ~INTERACT_ITEM_ATTACK_HAND_PICKUP
	if(!mapload)
		return
	var/obj/item/pen/P = locate(/obj/item/pen) in src.loc
	if(P && !bin_pen)
		P.forceMove(src)
		bin_pen = P
		update_icon()

/obj/item/paper_bin/Destroy()
	if(papers)
		for(var/i in papers)
			qdel(i)
		papers = null
	. = ..()

/obj/item/paper_bin/fire_act(exposed_temperature, exposed_volume)
	if(total_paper)
		total_paper = 0
		update_icon()
	..()

/obj/item/paper_bin/attack_hand(mob/user)
	if(isliving(user))
		var/mob/living/L = user
		if(!(L.mobility_flags & MOBILITY_PICKUP))
			return
	user.changeNext_move(CLICK_CD_MELEE)
	if(bin_pen)
		var/obj/item/pen/P = bin_pen
		P.add_fingerprint(user)
		P.forceMove(user.loc)
		user.put_in_hands(P)
		to_chat(user, "<span class='notice'>You take [P] out of \the [src].</span>")
		bin_pen = null
		update_icon()
	else if(total_paper >= 1)
		total_paper--
		update_icon()
		var/obj/item/paper/P
		if(papers.len > 0)
			P = papers[papers.len]
			papers.Remove(P)
		else
			P = new papertype(src)
			//if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
			//	if(prob(30))
			//		P.info = "<font face=\"[CRAYON_FONT]\" color=\"red\"><b>HONK HONK HONK HONK HONK HONK HONK<br>HOOOOOOOOOOOOOOOOOOOOOONK<br>APRIL FOOLS</b></font>"
			//		P.rigged = 1
			//		P.updateinfolinks()

		P.add_fingerprint(user)
		P.forceMove(user.loc)
		user.put_in_hands(P)
		to_chat(user, "<span class='notice'>You take [P] out of \the [src].</span>")
	else
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
	add_fingerprint(user)
	return ..()

/obj/item/paper_bin/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/paper))
		var/obj/item/paper/P = I
		if(!user.transferItemToLoc(P, src))
			return
		to_chat(user, "<span class='notice'>You put [P] in [src].</span>")
		papers.Add(P)
		total_paper++
		update_icon()
	else if(istype(I, /obj/item/pen) && !bin_pen)
		var/obj/item/pen/P = I
		if(!user.transferItemToLoc(P, src))
			return
		to_chat(user, "<span class='notice'>You put [P] in [src].</span>")
		bin_pen = P
		update_icon()
	else
		return ..()

/obj/item/paper_bin/examine(mob/user)
	..()
	if(total_paper)
		to_chat(user, "It contains " + (total_paper > 1 ? "[total_paper] papers" : " one paper")+".")
	else
		to_chat(user, "It doesn't contain anything.")


/obj/item/paper_bin/update_icon()
	if(total_paper < 1)
		icon_state = "paper_bin0"
	else
		icon_state = "[initial(icon_state)]"
	cut_overlays()
	if(bin_pen)
		add_overlay(mutable_appearance(bin_pen.icon, bin_pen.icon_state))