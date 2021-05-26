/obj/machinery/computer/cargo/express
	name = "express supply console"
	desc = "This console allows the user to purchase a package \
		with 1/40th of the delivery time: made possible by NanoTrasen's new \"1500mm Orbital Railgun\".\
		All sales are near instantaneous - please choose carefully"
	icon_screen = "supply_express"
	circuit = /obj/item/circuitboard/computer/cargo/express
	blockade_warning = "Bluespace instability detected. Delivery impossible."
	req_access = list(ACCESS_QM)
	var/message
	var/printed_beacons = 0
	var/list/meme_pack_data
	//var/obj/item/supplypod_beacon/beacon
	var/area/landingzone = /area/quartermaster/storage
	//var/podType = /obj/structure/closet/supplypod
	var/cooldown = 0
	var/locked = TRUE
	var/usingBeacon = FALSE