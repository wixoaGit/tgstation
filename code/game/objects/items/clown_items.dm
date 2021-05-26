/obj/item/bikehorn
	name = "bike horn"
	desc = "A horn off of a bicycle."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "bike_horn"
	item_state = "bike_horn"
	lefthand_file = 'icons/mob/inhands/equipment/horns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/horns_righthand.dmi'
	throwforce = 0
	hitsound = null
	w_class = WEIGHT_CLASS_TINY
	attack_verb = list("HONKED")

/obj/item/bikehorn/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/items/bikehorn.ogg'=1), 50)

/obj/item/bikehorn/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] solemnly points [src] at [user.p_their()] temple! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(src, 'sound/items/bikehorn.ogg', 50, TRUE)
	return (BRUTELOSS)