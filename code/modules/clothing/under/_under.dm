/obj/item/clothing/under
	icon = 'icons/obj/clothing/uniforms.dmi'
	name = "under"
	slot_flags = ITEM_SLOT_ICLOTHING

/obj/item/clothing/under
	icon = 'icons/obj/clothing/uniforms.dmi'
	name = "under"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	permeability_coefficient = 0.9
	slot_flags = ITEM_SLOT_ICLOTHING
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	var/fitted = FEMALE_UNIFORM_FULL
	//var/has_sensor = HAS_SENSORS
	var/random_sensor = TRUE
	//var/sensor_mode = NO_SENSORS
	var/can_adjust = TRUE
	//var/adjusted = NORMAL_STYLE
	var/alt_covers_chest = FALSE
	//var/obj/item/clothing/accessory/attached_accessory
	var/mutable_appearance/accessory_overlay
	var/mutantrace_variation = NO_MUTANTRACE_VARIATION
	var/freshly_laundered = FALSE
	var/dodgy_colours = FALSE