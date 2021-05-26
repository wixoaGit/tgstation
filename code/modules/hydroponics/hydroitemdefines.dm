/obj/item/plant_analyzer
	name = "plant analyzer"
	desc = "A scanner used to evaluate a plant's various areas of growth."
	icon = 'icons/obj/device.dmi'
	icon_state = "hydro"
	item_state = "analyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	slot_flags = ITEM_SLOT_BELT
	materials = list(MAT_METAL=30, MAT_GLASS=20)

/obj/item/cultivator
	name = "cultivator"
	desc = "It's used for removing weeds or scratching your back."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "cultivator"
	item_state = "cultivator"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	flags_1 = CONDUCT_1
	force = 5
	throwforce = 7
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=50)
	attack_verb = list("slashed", "sliced", "cut", "clawed")
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/cultivator/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is scratching [user.p_their()] back as hard as [user.p_they()] can with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (BRUTELOSS)

/obj/item/reagent_containers/glass/bottle/nutrient
	name = "bottle of nutrient"
	volume = 50
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(1,2,5,10,15,25,50)

/obj/item/reagent_containers/glass/bottle/nutrient/Initialize()
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)


/obj/item/reagent_containers/glass/bottle/nutrient/ez
	name = "bottle of E-Z-Nutrient"
	desc = "Contains a fertilizer that causes mild mutations with each harvest."
	list_reagents = list("eznutriment" = 50)