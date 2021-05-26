/obj/item/pen
	desc = "It's a normal black ink pen."
	name = "pen"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	item_state = "pen"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_EARS
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=10)
	pressure_resistance = 2
	grind_results = list("iron" = 2, "iodine" = 1)
	var/colour = "black"
	var/degrees = 0
	var/font = PEN_FONT

/obj/item/pen/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is scribbling numbers all over [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit sudoku...</span>")
	return(BRUTELOSS)