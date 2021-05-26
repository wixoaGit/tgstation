/obj/item/clothing/glasses
	name = "glasses"
	icon = 'icons/obj/clothing/glasses.dmi'
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_EYES
	strip_delay = 20
	equip_delay_other = 25

/obj/item/clothing/glasses/sunglasses
	name = "sunglasses"
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Enhanced shielding blocks flashes."
	icon_state = "sun"
	item_state = "sunglasses"

/obj/item/clothing/glasses/sunglasses/reagent
	name = "beer goggles"
	desc = "A pair of sunglasses outfitted with apparatus to scan reagents, as well as providing an innate understanding of liquid viscosity while in motion."
	scan_reagents = TRUE

/obj/item/clothing/glasses/sunglasses/reagent/equipped(mob/user, slot)
	. = ..()
	//if(ishuman(user) && slot == SLOT_GLASSES)
	//	user.add_trait(TRAIT_BOOZE_SLIDER, CLOTHING_TRAIT)

/obj/item/clothing/glasses/sunglasses/reagent/dropped(mob/user)
	. = ..()
	//user.remove_trait(TRAIT_BOOZE_SLIDER, CLOTHING_TRAIT)