/obj/item/storage/belt
	name = "belt"
	desc = "Can hold various things."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "utilitybelt"
	item_state = "utility"
	lefthand_file = 'icons/mob/inhands/equipment/belt_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/belt_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	attack_verb = list("whipped", "lashed", "disciplined")
	max_integrity = 300
	var/content_overlays = FALSE

/obj/item/storage/belt/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins belting [user.p_them()]self with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS

/obj/item/storage/belt/update_icon()
	cut_overlays()
	if(content_overlays)
		for(var/obj/item/I in contents)
			var/mutable_appearance/M = I.get_belt_overlay()
			add_overlay(M)
	..()

/obj/item/storage/belt/Initialize()
	. = ..()
	update_icon()

/obj/item/storage/belt/examine(mob/user)
	..()
	clothing_resistance_flag_examine_message(user)

/obj/item/storage/belt/utility
	name = "toolbelt"
	desc = "Holds tools."
	icon_state = "utilitybelt"
	item_state = "utility"
	content_overlays = TRUE
	custom_price = 50

/obj/item/storage/belt/utility/ComponentInitialize()
	. = ..()
	//GET_COMPONENT(STR, /datum/component/storage)
	//var/static/list/can_hold = typecacheof(list(
	//	/obj/item/crowbar,
	//	/obj/item/screwdriver,
	//	/obj/item/weldingtool,
	//	/obj/item/wirecutters,
	//	/obj/item/wrench,
	//	/obj/item/multitool,
	//	/obj/item/flashlight,
	//	/obj/item/stack/cable_coil,
	//	/obj/item/t_scanner,
	//	/obj/item/analyzer,
	//	/obj/item/geiger_counter,
	//	/obj/item/extinguisher/mini,
	//	/obj/item/radio,
	//	/obj/item/clothing/gloves,
	//	/obj/item/holosign_creator,
	//	/obj/item/forcefield_projector,
	//	/obj/item/assembly/signaler
	//	))
	//STR.can_hold = can_hold

/obj/item/storage/belt/utility/chief
	name = "\improper Chief Engineer's toolbelt"
	desc = "Holds tools, looks snazzy."
	icon_state = "utilitybelt_ce"
	item_state = "utility_ce"

/obj/item/storage/belt/utility/chief/full/PopulateContents()
	new /obj/item/screwdriver/power(src)
	new /obj/item/crowbar/power(src)
	new /obj/item/weldingtool/experimental(src)
	new /obj/item/multitool(src)
	new /obj/item/stack/cable_coil(src,30,pick("red","yellow","orange"))
	new /obj/item/extinguisher/mini(src)
	new /obj/item/analyzer(src)

/obj/item/storage/belt/utility/full/PopulateContents()
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool(src)
	new /obj/item/crowbar(src)
	new /obj/item/wirecutters(src)
	new /obj/item/multitool(src)
	new /obj/item/stack/cable_coil(src,30,pick("red","yellow","orange"))

/obj/item/storage/belt/utility/full/engi/PopulateContents()
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool/largetank(src)
	new /obj/item/crowbar(src)
	new /obj/item/wirecutters(src)
	new /obj/item/multitool(src)
	new /obj/item/stack/cable_coil(src,30,pick("red","yellow","orange"))

/obj/item/storage/belt/utility/atmostech/PopulateContents()
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool(src)
	new /obj/item/crowbar(src)
	new /obj/item/wirecutters(src)
	//new /obj/item/t_scanner(src)
	new /obj/item/extinguisher/mini(src)