/mob/living/carbon/human
	hud_type = /datum/hud/human
	possible_a_intents = list(INTENT_HELP, INTENT_DISARM, INTENT_GRAB, INTENT_HARM)
	var/hair_color = "000"
	var/hair_style = "Bald"

	var/facial_hair_color = "000"
	var/facial_hair_style = "Shaved"

	var/eye_color = "000"

	var/skin_tone = "caucasian1"

	var/lip_style = null
	var/lip_color = "white"

	var/age = 30

	var/underwear = "Nude"
	var/undershirt = "Nude"
	var/socks = "Nude"
	var/backbag = DBACKPACK
	
	var/obj/item/clothing/wear_suit = null
	var/obj/item/clothing/w_uniform = null
	var/obj/item/belt = null
	var/obj/item/wear_id = null
	var/obj/item/r_store = null
	var/obj/item/l_store = null
	var/obj/item/s_store = null

	var/bleed_rate = 0

	var/datum/physiology/physiology

	var/account_id