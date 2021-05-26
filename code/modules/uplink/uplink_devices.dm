/obj/item/uplink
	name = "station bounced radio"
	icon = 'icons/obj/radio.dmi'
	icon_state = "radio"
	item_state = "walkietalkie"
	desc = "A basic handheld radio that communicates with local telecommunication networks."
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	//dog_fashion = /datum/dog_fashion/back

	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	throw_speed = 3
	throw_range = 7
	w_class = WEIGHT_CLASS_SMALL

/obj/item/uplink/Initialize(mapload, owner, tc_amount = 20)
	. = ..()
	AddComponent(/datum/component/uplink, owner, FALSE, TRUE, null, tc_amount)

/obj/item/uplink/debug
	name = "debug uplink"

/obj/item/uplink/debug/Initialize(mapload, owner, tc_amount = 9000)
	. = ..()
	GET_COMPONENT(hidden_uplink, /datum/component/uplink)
	hidden_uplink.name = "debug uplink"

/obj/item/uplink/nuclear/Initialize()
	. = ..()
	GET_COMPONENT(hidden_uplink, /datum/component/uplink)
	//hidden_uplink.set_gamemode(/datum/game_mode/nuclear)

/obj/item/uplink/nuclear/debug
	name = "debug nuclear uplink"

/obj/item/uplink/nuclear/debug/Initialize(mapload, owner, tc_amount = 9000)
	. = ..()
	GET_COMPONENT(hidden_uplink, /datum/component/uplink)
	//hidden_uplink.set_gamemode(/datum/game_mode/nuclear)
	hidden_uplink.name = "debug nuclear uplink"