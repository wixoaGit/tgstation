/obj/item/kitchen
	icon = 'icons/obj/kitchen.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'

/obj/item/kitchen/knife
	name = "kitchen knife"
	icon_state = "knife"
	item_state = "knife"
	desc = "A general purpose Chef's Knife made by SpaceCook Incorporated. Guaranteed to stay sharp for years to come."
	flags_1 = CONDUCT_1
	force = 10
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	throw_speed = 3
	throw_range = 6
	materials = list(MAT_METAL=12000)
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	sharpness = IS_SHARP_ACCURATE
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	var/bayonet = FALSE
	custom_price = 30

/obj/item/kitchen/knife/Initialize()
	. = ..()
	//AddComponent(/datum/component/butchering, 80 - force, 100, force - 10)

/obj/item/kitchen/knife/suicide_act(mob/user)
	user.visible_message(pick("<span class='suicide'>[user] is slitting [user.p_their()] wrists with the [src.name]! It looks like [user.p_theyre()] trying to commit suicide.</span>", \
						"<span class='suicide'>[user] is slitting [user.p_their()] throat with the [src.name]! It looks like [user.p_theyre()] trying to commit suicide.</span>", \
						"<span class='suicide'>[user] is slitting [user.p_their()] stomach open with the [src.name]! It looks like [user.p_theyre()] trying to commit seppuku.</span>"))
	return BRUTELOSS

/obj/item/kitchen/knife/combat
	name = "combat knife"
	icon_state = "buckknife"
	desc = "A military combat utility survival knife."
	//embedding = list("embedded_pain_multiplier" = 4, "embed_chance" = 65, "embedded_fall_chance" = 10, "embedded_ignore_throwspeed_threshold" = TRUE)
	force = 20
	throwforce = 20
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "cut")
	bayonet = TRUE

/obj/item/kitchen/knife/combat/survival
	name = "survival knife"
	icon_state = "survivalknife"
	//embedding = list("embedded_pain_multiplier" = 4, "embed_chance" = 35, "embedded_fall_chance" = 10)
	desc = "A hunting grade survival knife."
	force = 15
	throwforce = 15
	bayonet = TRUE