/obj/structure/chair
	name = "chair"
	desc = "You sit in this. Either by will or force."
	icon = 'icons/obj/chairs.dmi'
	icon_state = "chair"
	anchored = TRUE
	can_buckle = 1
	buckle_lying = 0
	resistance_flags = NONE
	max_integrity = 250
	integrity_failure = 25
	var/buildstacktype = /obj/item/stack/sheet/metal
	var/buildstackamount = 1
	var/item_chair = /obj/item/chair
	layer = OBJ_LAYER

/obj/structure/chair/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>It's held together by a couple of <b>bolts</b>.</span>")
	if(!has_buckled_mobs())
		to_chat(user, "<span class='notice'>Drag your sprite to sit in it.</span>")

/obj/structure/chair/Initialize()
	. = ..()
	//if(!anchored)
	//	addtimer(CALLBACK(src, .proc/RemoveFromLatejoin), 0)

/obj/structure/chair/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/simple_rotation,ROTATION_ALTCLICK | ROTATION_CLOCKWISE, CALLBACK(src, .proc/can_user_rotate),CALLBACK(src, .proc/can_be_rotated),null)

/obj/structure/chair/proc/can_be_rotated(mob/user)
	return TRUE

/obj/structure/chair/proc/can_user_rotate(mob/user)
	var/mob/living/L = user

	if(istype(L))
		if(!user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
			return FALSE
		else
			return TRUE
	//else if(isobserver(user) && CONFIG_GET(flag/ghost_interaction))
	//	return TRUE
	return FALSE

/obj/structure/chair/Destroy()
	//RemoveFromLatejoin()
	return ..()

/obj/structure/chair/deconstruct()
	if(buildstacktype && (!(flags_1 & NODECONSTRUCT_1)))
		new buildstacktype(loc,buildstackamount)
	..()

/obj/structure/chair/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/chair/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WRENCH && !(flags_1&NODECONSTRUCT_1))
		W.play_tool_sound(src)
		deconstruct()
	//else if(istype(W, /obj/item/assembly/shock_kit))
	//	if(!user.temporarilyRemoveItemFromInventory(W))
	//		return
	//	var/obj/item/assembly/shock_kit/SK = W
	//	var/obj/structure/chair/e_chair/E = new /obj/structure/chair/e_chair(src.loc)
	//	playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
	//	E.setDir(dir)
	//	E.part = SK
	//	SK.forceMove(E)
	//	SK.master = E
	//	qdel(src)
	else
		return ..()

/obj/structure/chair/stool
	name = "stool"
	desc = "Apply butt."
	icon_state = "stool"
	can_buckle = 0
	buildstackamount = 1
	item_chair = /obj/item/chair/stool

/obj/structure/chair/MouseDrop(over_object, src_location, over_location)
	. = ..()
	if(over_object == usr && Adjacent(usr))
		if(!item_chair || !usr.can_hold_items() || has_buckled_mobs() || src.flags_1 & NODECONSTRUCT_1)
			return
		if(!usr.canUseTopic(src, BE_CLOSE, ismonkey(usr)))
			return
		usr.visible_message("<span class='notice'>[usr] grabs \the [src.name].</span>", "<span class='notice'>You grab \the [src.name].</span>")
		var/C = new item_chair(loc)
		TransferComponents(C)
		usr.put_in_hands(C)
		qdel(src)

/obj/structure/chair/stool/bar
	name = "bar stool"
	desc = "It has some unsavory stains on it..."
	icon_state = "bar"
	item_chair = /obj/item/chair/stool/bar

/obj/item/chair
	name = "chair"
	desc = "Bar brawl essential."
	icon = 'icons/obj/chairs.dmi'
	icon_state = "chair_toppled"
	item_state = "chair"
	lefthand_file = 'icons/mob/inhands/misc/chairs_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/chairs_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	force = 8
	throwforce = 10
	throw_range = 3
	hitsound = 'sound/items/trayhit1.ogg'
	//hit_reaction_chance = 50
	materials = list(MAT_METAL = 2000)
	var/break_chance = 5
	var/obj/structure/chair/origin_type = /obj/structure/chair

/obj/item/chair/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins hitting [user.p_them()]self with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(src,hitsound,50,1)
	return BRUTELOSS

/obj/item/chair/attack_self(mob/user)
	plant(user)

/obj/item/chair/proc/plant(mob/user)
	for(var/obj/A in get_turf(loc))
		if(istype(A, /obj/structure/chair))
			to_chat(user, "<span class='danger'>There is already a chair here.</span>")
			return
		if(A.density && !(A.flags_1 & ON_BORDER_1))
			to_chat(user, "<span class='danger'>There is already something here.</span>")
			return

	user.visible_message("<span class='notice'>[user] rights \the [src.name].</span>", "<span class='notice'>You right \the [name].</span>")
	var/obj/structure/chair/C = new origin_type(get_turf(loc))
	TransferComponents(C)
	C.setDir(dir)
	qdel(src)

/obj/structure/chair/comfy
	name = "comfy chair"
	desc = "It looks comfy."
	icon_state = "comfychair"
	//color = rgb(255,255,255)
	color = "#FFFFFF"//not_actual
	resistance_flags = FLAMMABLE
	max_integrity = 70
	buildstackamount = 2
	item_chair = null
	var/mutable_appearance/armrest

/obj/structure/chair/comfy/Initialize()
	armrest = GetArmrest()
	armrest.layer = ABOVE_MOB_LAYER
	return ..()

/obj/structure/chair/comfy/proc/GetArmrest()
	return mutable_appearance('icons/obj/chairs.dmi', "comfychair_armrest")

/obj/structure/chair/comfy/Destroy()
	QDEL_NULL(armrest)
	return ..()

///obj/structure/chair/comfy/post_buckle_mob(mob/living/M)
//	. = ..()
//	update_armrest()

/obj/structure/chair/comfy/proc/update_armrest()
	if(has_buckled_mobs())
		add_overlay(armrest)
	else
		cut_overlay(armrest)

///obj/structure/chair/comfy/post_unbuckle_mob()
//	. = ..()
//	update_armrest()

/obj/structure/chair/comfy/brown
	//color = rgb(255,113,0)
	color = "#FF7100"//not_actual

/obj/structure/chair/comfy/beige
	//color = rgb(255,253,195)
	color = "#FFFDC3"//not_actual

/obj/structure/chair/comfy/teal
	//color = rgb(0,255,255)
	color = "#00FFFF"//not_actual

/obj/structure/chair/comfy/black
	//color = rgb(167,164,153)
	color = "#A7A499"//not_actual

/obj/structure/chair/comfy/lime
	//color = rgb(255,251,0)
	color = "#FFFB00"//not_actual

/obj/structure/chair/comfy/shuttle
	name = "shuttle seat"
	desc = "A comfortable, secure seat. It has a more sturdy looking buckling system, for smoother flights."
	icon_state = "shuttle_chair"

/obj/structure/chair/comfy/shuttle/GetArmrest()
	return mutable_appearance('icons/obj/chairs.dmi', "shuttle_chair_armrest")

/obj/structure/chair/office
	anchored = FALSE
	buildstackamount = 5
	item_chair = null


/obj/structure/chair/office/Moved()
	. = ..()
	if(has_gravity())
		playsound(src, 'sound/effects/roll.ogg', 100, 1)

/obj/structure/chair/office/light
	icon_state = "officechair_white"

/obj/structure/chair/office/dark
	icon_state = "officechair_dark"

/obj/item/chair/stool
	name = "stool"
	icon_state = "stool_toppled"
	item_state = "stool"
	origin_type = /obj/structure/chair/stool
	break_chance = 0

/obj/item/chair/stool/bar
	name = "bar stool"
	icon_state = "bar_toppled"
	item_state = "stool_bar"
	origin_type = /obj/structure/chair/stool/bar