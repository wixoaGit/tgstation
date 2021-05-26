/obj/item/clothing/suit/fire
	name = "emergency firesuit"
	desc = "A suit that helps protect against fire and heat."
	icon_state = "fire"
	item_state = "ro_suit"
	w_class = WEIGHT_CLASS_BULKY
	gas_transfer_coefficient = 0.9
	permeability_coefficient = 0.5
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	//allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/extinguisher, /obj/item/crowbar)
	slowdown = 1
	armor = list("melee" = 15, "bullet" = 5, "laser" = 20, "energy" = 10, "bomb" = 20, "bio" = 10, "rad" = 20, "fire" = 100, "acid" = 50)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	strip_delay = 60
	equip_delay_other = 60
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/fire/firefighter
	icon_state = "firesuit"
	item_state = "firefighter"


/obj/item/clothing/suit/fire/heavy
	name = "heavy firesuit"
	desc = "An old, bulky thermal protection suit."
	icon_state = "thermal"
	item_state = "ro_suit"
	slowdown = 1.5

/obj/item/clothing/suit/fire/atmos
	name = "firesuit"
	desc = "An expensive firesuit that protects against even the most deadly of station fires. Designed to protect even if the wearer is set aflame."
	icon_state = "atmos_firesuit"
	item_state = "firesuit_atmos"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT