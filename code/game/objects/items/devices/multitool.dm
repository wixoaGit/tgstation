/obj/item/multitool
	name = "multitool"
	desc = "Used for pulsing wires to test which to cut. Not recommended by doctors."
	icon = 'icons/obj/device.dmi'
	icon_state = "multitool"
	item_state = "multitool"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	force = 5
	w_class = WEIGHT_CLASS_SMALL
	tool_behaviour = TOOL_MULTITOOL
	throwforce = 0
	throw_range = 7
	throw_speed = 3
	materials = list(MAT_METAL=50, MAT_GLASS=20)
	var/obj/machinery/buffer
	toolspeed = 1
	usesound = 'sound/weapons/empty.ogg'
	var/mode = 0

/obj/item/multitool/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Its buffer [buffer ? "contains [buffer]." : "is empty."]</span>")

/obj/item/multitool/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] puts the [src] to [user.p_their()] chest. It looks like [user.p_theyre()] trying to pulse [user.p_their()] heart off!</span>")
	return OXYLOSS