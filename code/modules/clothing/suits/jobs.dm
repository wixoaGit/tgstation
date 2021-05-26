/obj/item/clothing/suit/apron
	name = "apron"
	desc = "A basic blue apron."
	icon_state = "apron"
	item_state = "apron"
	blood_overlay_type = "armor"
	body_parts_covered = CHEST|GROIN
	//allowed = list(/obj/item/reagent_containers/spray/plantbgone, /obj/item/plant_analyzer, /obj/item/seeds, /obj/item/reagent_containers/glass/bottle, /obj/item/reagent_containers/glass/beaker, /obj/item/cultivator, /obj/item/reagent_containers/spray/pestspray, /obj/item/hatchet, /obj/item/storage/bag/plants)
	allowed = list(/obj/item/plant_analyzer)//not_actual

/obj/item/clothing/suit/toggle/chef
	name = "chef's apron"
	desc = "An apron-jacket used by a high class chef."
	icon_state = "chef"
	item_state = "chef"
	gas_transfer_coefficient = 0.9
	permeability_coefficient = 0.5
	body_parts_covered = CHEST|GROIN|ARMS
	allowed = list(/obj/item/kitchen)
	togglename = "sleeves"

/obj/item/clothing/suit/apron/chef
	name = "cook's apron"
	desc = "A basic, dull, white chef's apron."
	icon_state = "apronchef"
	item_state = "apronchef"
	blood_overlay_type = "armor"
	body_parts_covered = CHEST|GROIN
	allowed = list(/obj/item/kitchen)