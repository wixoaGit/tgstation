/obj/machinery/computer/gulag_teleporter_computer
	name = "labor camp teleporter console"
	desc = "Used to send criminals to the Labor Camp."
	icon_screen = "explosive"
	icon_keyboard = "security_key"
	req_access = list(ACCESS_ARMORY)
	circuit = /obj/item/circuitboard/computer/gulag_teleporter_console
	var/default_goal = 200
	var/obj/item/card/id/prisoner/id = null
	var/obj/machinery/gulag_teleporter/teleporter = null
	//var/obj/structure/gulag_beacon/beacon = null
	var/mob/living/carbon/human/prisoner = null
	var/datum/data/record/temporary_record = null

	light_color = LIGHT_COLOR_RED