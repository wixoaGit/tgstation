/mob/living/carbon
	possible_a_intents = list(INTENT_HELP, INTENT_HARM)
	held_items = list(null, null)

	var/obj/item/handcuffed = null
	var/obj/item/legcuffed = null

	var/obj/item/back = null
	var/obj/item/clothing/mask/wear_mask = null
	var/obj/item/clothing/neck/wear_neck = null
	var/obj/item/tank/internal = null
	var/obj/item/clothing/head = null

	var/obj/item/clothing/gloves = null
	var/obj/item/clothing/shoes = null
	var/obj/item/clothing/glasses/glasses = null
	var/obj/item/clothing/ears = null

	var/datum/dna/dna = null
	var/datum/mind/last_mind = null

	var/rotate_on_lying = 1

	var/list/bodyparts = list(/obj/item/bodypart/chest, /obj/item/bodypart/head, /obj/item/bodypart/l_arm,
					 /obj/item/bodypart/r_arm, /obj/item/bodypart/r_leg, /obj/item/bodypart/l_leg)

	var/list/hand_bodyparts = list()

	var/icon_render_key = ""
	var/static/list/limb_icon_cache = list()

	var/hal_screwyhud = SCREWYHUD_NONE