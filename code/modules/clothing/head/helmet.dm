/obj/item/clothing/head/helmet
	name = "helmet"
	desc = "Standard Security gear. Protects the head from impacts."
	icon_state = "helmet"
	item_state = "helmet"
	armor = list("melee" = 35, "bullet" = 30, "laser" = 30,"energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	flags_inv = HIDEEARS
	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_TEMP_PROTECT
	strip_delay = 60
	resistance_flags = NONE
	flags_cover = HEADCOVERSEYES
	flags_inv = HIDEHAIR

	//dog_fashion = /datum/dog_fashion/head/helmet

	var/can_flashlight = FALSE
	var/obj/item/flashlight/seclite/attached_light
	//var/datum/action/item_action/toggle_helmet_flashlight/alight

/obj/item/clothing/head/helmet/Initialize()
	. = ..()
	//if(attached_light)
	//	alight = new(src)

/obj/item/clothing/head/helmet/ComponentInitialize()
	. = ..()
	//AddComponent(/datum/component/wearertargeting/earprotection, list(SLOT_HEAD))

/obj/item/clothing/head/helmet/examine(mob/user)
	..()
	if(attached_light)
		to_chat(user, "It has \a [attached_light] [can_flashlight ? "" : "permanently "]mounted on it.")
		if(can_flashlight)
			to_chat(user, "<span class='info'>[attached_light] looks like it can be <b>unscrewed</b> from [src].</span>")
	else if(can_flashlight)
		to_chat(user, "It has a mounting point for a <b>seclite</b>.")

/obj/item/clothing/head/helmet/Destroy()
	QDEL_NULL(attached_light)
	return ..()

/obj/item/clothing/head/helmet/handle_atom_del(atom/A)
	if(A == attached_light)
		attached_light = null
		update_helmlight()
		update_icon()
		//QDEL_NULL(alight)
	return ..()

/obj/item/clothing/head/helmet/proc/update_helmlight()
	if(attached_light)
		if(attached_light.on)
			set_light(attached_light.brightness_on)
		else
			set_light(0)
		update_icon()

	else
		set_light(0)
	//for(var/X in actions)
	//	var/datum/action/A = X
	//	A.UpdateButtonIcon()