/obj/item/storage/backpack
	name = "backpack"
	desc = "You wear this on your back and put items into it."
	icon_state = "backpack"
	item_state = "backpack"
	lefthand_file = 'icons/mob/inhands/equipment/backpack_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/backpack_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	resistance_flags = NONE
	max_integrity = 300

/obj/item/storage/backpack/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_combined_w_class = 21
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_items = 21

/obj/item/storage/backpack/examine(mob/user)
	..()
	clothing_resistance_flag_examine_message(user)

/obj/item/storage/backpack/holding
	name = "bag of holding"
	desc = "A backpack that opens into a localized pocket of bluespace."
	icon_state = "holdingpack"
	item_state = "holdingpack"
	resistance_flags = FIRE_PROOF
	item_flags = NO_MAT_REDEMPTION
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 60, "acid" = 50)
	//component_type = /datum/component/storage/concrete/bluespace/bag_of_holding

/obj/item/storage/backpack/holding/ComponentInitialize()
	. = ..()
	//GET_COMPONENT(STR, /datum/component/storage)
	//STR.allow_big_nesting = TRUE
	//STR.max_w_class = WEIGHT_CLASS_GIGANTIC
	//STR.max_combined_w_class = 35

/obj/item/storage/backpack/holding/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] is jumping into [src]! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	user.dropItemToGround(src, TRUE)
	//user.Stun(100, ignore_canstun = TRUE)
	sleep(20)
	playsound(src, "rustle", 50, 1, -5)
	qdel(user)

/obj/item/storage/backpack/duffelbag
	name = "duffel bag"
	desc = "A large duffel bag for holding extra things."
	icon_state = "duffel"
	item_state = "duffel"
	slowdown = 1

/obj/item/storage/backpack/duffelbag/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_combined_w_class = 30

/obj/item/storage/backpack/duffelbag/syndie
	name = "suspicious looking duffel bag"
	desc = "A large duffel bag for holding extra tactical supplies."
	icon_state = "duffel-syndie"
	item_state = "duffel-syndieammo"
	slowdown = 0
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/duffelbag/syndie/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.silent = TRUE

/obj/item/storage/backpack/duffelbag/syndie/surgery
	name = "surgery duffel bag"
	desc = "A suspicious looking duffel bag for holding surgery tools."
	icon_state = "duffel-syndiemed"
	item_state = "duffel-syndiemed"

/obj/item/storage/backpack/duffelbag/syndie/surgery/PopulateContents()
	//new /obj/item/scalpel(src)
	//new /obj/item/hemostat(src)
	//new /obj/item/retractor(src)
	//new /obj/item/circular_saw(src)
	//new /obj/item/surgicaldrill(src)
	//new /obj/item/cautery(src)
	//new /obj/item/surgical_drapes(src)
	//new /obj/item/clothing/suit/straight_jacket(src)
	//new /obj/item/clothing/mask/muzzle(src)
	//new /obj/item/mmi/syndie(src)