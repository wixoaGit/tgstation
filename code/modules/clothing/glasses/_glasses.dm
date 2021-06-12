/obj/item/clothing/glasses
	name = "glasses"
	icon = 'icons/obj/clothing/glasses.dmi'
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_EYES
	strip_delay = 20
	equip_delay_other = 25

/obj/item/clothing/glasses/science
	name = "science goggles"
	desc = "A pair of snazzy goggles used to protect against chemical spills. Fitted with an analyzer for scanning items and reagents."
	icon_state = "purple"
	item_state = "glasses"
	scan_reagents = TRUE
	actions_types = list(/datum/action/item_action/toggle_research_scanner)
	glass_colour_type = /datum/client_colour/glass_colour/purple
	resistance_flags = ACID_PROOF
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 100)

///obj/item/clothing/glasses/science/item_action_slot_check(slot)
//	if(slot == SLOT_GLASSES)
//		return 1

/obj/item/clothing/glasses/science/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] is tightening \the [src]'s straps around [user.p_their()] neck! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return OXYLOSS

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