/obj/item/mop
	desc = "The world of janitalia wouldn't be complete without a mop."
	name = "mop"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	force = 8
	throwforce = 10
	throw_speed = 3
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("mopped", "bashed", "bludgeoned", "whacked")
	resistance_flags = FLAMMABLE
	var/mopping = 0
	var/mopcount = 0
	var/mopcap = 15
	var/mopspeed = 15
	force_string = "robust... against germs"
	var/insertable = TRUE

/obj/item/mop/Initialize()
	. = ..()
	create_reagents(mopcap)