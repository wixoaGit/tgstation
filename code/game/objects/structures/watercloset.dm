/obj/structure/toilet
	name = "toilet"
	desc = "The HT-451, a torque rotation-based, waste disposal unit for small matter. This one seems remarkably clean."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "toilet00"
	density = FALSE
	anchored = TRUE
	var/open = FALSE
	var/cistern = 0
	var/w_items = 0
	var/mob/living/swirlie = null

/obj/structure/toilet/Initialize()
	. = ..()
	open = round(rand(0, 1))
	update_icon()


/obj/structure/toilet/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(swirlie)
		user.changeNext_move(CLICK_CD_MELEE)
		playsound(src.loc, "swing_hit", 25, 1)
		swirlie.visible_message("<span class='danger'>[user] slams the toilet seat onto [swirlie]'s head!</span>", "<span class='userdanger'>[user] slams the toilet seat onto your head!</span>", "<span class='italics'>You hear reverberating porcelain.</span>")
		swirlie.adjustBruteLoss(5)

	else if(user.pulling && user.a_intent == INTENT_GRAB && isliving(user.pulling))
		user.changeNext_move(CLICK_CD_MELEE)
		var/mob/living/GM = user.pulling
		if(user.grab_state >= GRAB_AGGRESSIVE)
			if(GM.loc != get_turf(src))
				to_chat(user, "<span class='warning'>[GM] needs to be on [src]!</span>")
				return
			if(!swirlie)
				if(open)
					GM.visible_message("<span class='danger'>[user] starts to give [GM] a swirlie!</span>", "<span class='userdanger'>[user] starts to give you a swirlie...</span>")
					swirlie = GM
					if(do_after(user, 30, 0, target = src))
						GM.visible_message("<span class='danger'>[user] gives [GM] a swirlie!</span>", "<span class='userdanger'>[user] gives you a swirlie!</span>", "<span class='italics'>You hear a toilet flushing.</span>")
						if(iscarbon(GM))
							var/mob/living/carbon/C = GM
							if(!C.internal)
								C.adjustOxyLoss(5)
						else
							GM.adjustOxyLoss(5)
					swirlie = null
				else
					playsound(src.loc, 'sound/effects/bang.ogg', 25, 1)
					GM.visible_message("<span class='danger'>[user] slams [GM.name] into [src]!</span>", "<span class='userdanger'>[user] slams you into [src]!</span>")
					GM.adjustBruteLoss(5)
		else
			to_chat(user, "<span class='warning'>You need a tighter grip!</span>")

	else if(cistern && !open && user.CanReach(src))
		if(!contents.len)
			to_chat(user, "<span class='notice'>The cistern is empty.</span>")
		else
			var/obj/item/I = pick(contents)
			if(ishuman(user))
				user.put_in_hands(I)
			else
				I.forceMove(drop_location())
			to_chat(user, "<span class='notice'>You find [I] in the cistern.</span>")
			w_items -= I.w_class
	else
		open = !open
		update_icon()


/obj/structure/toilet/update_icon()
	icon_state = "toilet[open][cistern]"

/obj/structure/toilet/attackby(obj/item/I, mob/living/user, params)
	if(I.tool_behaviour == TOOL_CROWBAR)
		to_chat(user, "<span class='notice'>You start to [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"]...</span>")
		playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 50, 1)
		if(I.use_tool(src, user, 30))
			user.visible_message("[user] [cistern ? "replaces the lid on the cistern" : "lifts the lid off the cistern"]!", "<span class='notice'>You [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"]!</span>", "<span class='italics'>You hear grinding porcelain.</span>")
			cistern = !cistern
			update_icon()

	else if(cistern)
		if(user.a_intent != INTENT_HARM)
			if(I.w_class > WEIGHT_CLASS_NORMAL)
				to_chat(user, "<span class='warning'>[I] does not fit!</span>")
				return
			if(w_items + I.w_class > WEIGHT_CLASS_HUGE)
				to_chat(user, "<span class='warning'>The cistern is full!</span>")
				return
			if(!user.transferItemToLoc(I, src))
				to_chat(user, "<span class='warning'>\The [I] is stuck to your hand, you cannot put it in the cistern!</span>")
				return
			w_items += I.w_class
			to_chat(user, "<span class='notice'>You carefully place [I] into the cistern.</span>")

	else if(istype(I, /obj/item/reagent_containers))
		if (!open)
			return
		var/obj/item/reagent_containers/RG = I
		RG.reagents.add_reagent("water", min(RG.volume - RG.reagents.total_volume, RG.amount_per_transfer_from_this))
		to_chat(user, "<span class='notice'>You fill [RG] from [src]. Gross.</span>")
	else
		return ..()

/obj/structure/sink
	name = "sink"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "sink"
	desc = "A sink used for washing one's hands and face."
	anchored = TRUE
	var/busy = FALSE
	var/dispensedreagent = "water"

/obj/structure/sink/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!user || !istype(user))
		return
	if(!iscarbon(user))
		return
	if(!Adjacent(user))
		return

	if(busy)
		to_chat(user, "<span class='notice'>Someone's already washing here.</span>")
		return
	var/selected_area = parse_zone(user.zone_selected)
	var/washing_face = 0
	if(selected_area in list(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_PRECISE_EYES))
		washing_face = 1
	user.visible_message("<span class='notice'>[user] starts washing [user.p_their()] [washing_face ? "face" : "hands"]...</span>", \
						"<span class='notice'>You start washing your [washing_face ? "face" : "hands"]...</span>")
	busy = TRUE

	if(!do_after(user, 40, target = src))
		busy = FALSE
		return

	busy = FALSE

	user.visible_message("<span class='notice'>[user] washes [user.p_their()] [washing_face ? "face" : "hands"] using [src].</span>", \
						"<span class='notice'>You wash your [washing_face ? "face" : "hands"] using [src].</span>")
	if(washing_face)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.lip_style = null
			H.lip_color = initial(H.lip_color)
			//H.wash_cream()
			H.regenerate_icons()
			//H.adjust_hygiene(10)
		//user.drowsyness = max(user.drowsyness - rand(2,3), 0)
	else
		SEND_SIGNAL(user, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
		//if(ishuman(user))
		//	var/mob/living/carbon/human/dirtyboy
		//	dirtyboy.adjust_hygiene(10)

/obj/structure/sink/attackby(obj/item/O, mob/living/user, params)
	if(busy)
		to_chat(user, "<span class='warning'>Someone's already washing here!</span>")
		return

	if(istype(O, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/RG = O
		if(RG.is_refillable())
			if(!RG.reagents.holder_full())
				RG.reagents.add_reagent(dispensedreagent, min(RG.volume - RG.reagents.total_volume, RG.amount_per_transfer_from_this))
				to_chat(user, "<span class='notice'>You fill [RG] from [src].</span>")
				return TRUE
			to_chat(user, "<span class='notice'>\The [RG] is full.</span>")
			return FALSE

	//if(istype(O, /obj/item/melee/baton))
	//	var/obj/item/melee/baton/B = O
	//	if(B.cell)
	//		if(B.cell.charge > 0 && B.status == 1)
	//			flick("baton_active", src)
	//			var/stunforce = B.stunforce
	//			user.Paralyze(stunforce)
	//			user.stuttering = stunforce/20
	//			B.deductcharge(B.hitcost)
	//			user.visible_message("<span class='warning'>[user] shocks [user.p_them()]self while attempting to wash the active [B.name]!</span>", \
	//								"<span class='userdanger'>You unwisely attempt to wash [B] while it's still on.</span>")
	//			playsound(src, "sparks", 50, 1)
	//			return

	//if(istype(O, /obj/item/mop))
	//	O.reagents.add_reagent("[dispensedreagent]", 5)
	//	to_chat(user, "<span class='notice'>You wet [O] in [src].</span>")
	//	playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
	//	return

	//if(istype(O, /obj/item/stack/medical/gauze))
	//	var/obj/item/stack/medical/gauze/G = O
	//	new /obj/item/reagent_containers/glass/rag(src.loc)
	//	to_chat(user, "<span class='notice'>You tear off a strip of gauze and make a rag.</span>")
	//	G.use(1)
	//	return

	if(!istype(O))
		return
	if(O.item_flags & ABSTRACT)
		return

	if(user.a_intent != INTENT_HARM)
		to_chat(user, "<span class='notice'>You start washing [O]...</span>")
		busy = TRUE
		if(!do_after(user, 40, target = src))
			busy = FALSE
			return 1
		busy = FALSE
		SEND_SIGNAL(O, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
		//O.acid_level = 0
		create_reagents(5)
		reagents.add_reagent(dispensedreagent, 5)
		reagents.reaction(O, TOUCH)
		user.visible_message("<span class='notice'>[user] washes [O] using [src].</span>", \
							"<span class='notice'>You wash [O] using [src].</span>")
		return 1
	else
		return ..()

/obj/structure/sink/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/metal (loc, 3)
	qdel(src)



/obj/structure/sink/kitchen
	name = "kitchen sink"
	icon_state = "sink_alt"