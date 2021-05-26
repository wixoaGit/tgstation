/obj/item/storage/bag
	slot_flags = ITEM_SLOT_BELT

/obj/item/storage/bag/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.allow_quick_gather = TRUE
	STR.allow_quick_empty = TRUE
	STR.display_numerical_stacking = TRUE
	STR.click_gather = TRUE

/obj/item/storage/bag/tray
	name = "tray"
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "tray"
	desc = "A metal tray to lay food on."
	force = 5
	throwforce = 10
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_BULKY
	flags_1 = CONDUCT_1
	materials = list(MAT_METAL=3000)

/obj/item/storage/bag/tray/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.insert_preposition = "on"

/obj/item/storage/bag/tray/attack(mob/living/M, mob/living/user)
	. = ..()
	var/list/obj/item/oldContents = contents.Copy()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.quick_empty()

	for(var/obj/item/I in oldContents)
		spawn()
			for(var/i = 1, i <= rand(1,2), i++)
				if(I)
					step(I, pick(NORTH,SOUTH,EAST,WEST))
					sleep(rand(2,4))

	if(prob(50))
		playsound(M, 'sound/items/trayhit1.ogg', 50, 1)
	else
		playsound(M, 'sound/items/trayhit2.ogg', 50, 1)

	//if(ishuman(M) || ismonkey(M))
	//	if(prob(10))
	//		M.Paralyze(40)
	update_icon()

/obj/item/storage/bag/tray/update_icon()
	cut_overlays()
	//for(var/obj/item/I in contents)
	//	add_overlay(new /mutable_appearance(I))

/obj/item/storage/bag/tray/Entered()
	. = ..()
	update_icon()

/obj/item/storage/bag/tray/Exited()
	. = ..()
	update_icon()