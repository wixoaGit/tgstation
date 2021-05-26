/obj/item/broken_bottle
	name = "broken bottle"
	desc = "A bottle with a sharp broken bottom."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "broken_bottle"
	force = 9
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	item_state = "beer"
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("stabbed", "slashed", "attacked")
	//var/icon/broken_outline = icon('icons/obj/drinks.dmi', "broken")
	sharpness = IS_SHARP

/obj/item/broken_bottle/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 200, 55)