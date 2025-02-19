/obj/structure/closet/secure_closet/engineering_chief
	name = "\proper chief engineer's locker"
	icon_state = "ce"

/obj/structure/closet/secure_closet/engineering_chief/PopulateContents()
	..()

/obj/structure/closet/secure_closet/engineering_electrical
	name = "electrical supplies locker"
	req_access = list(ACCESS_ENGINE_EQUIP)
	icon_state = "eng"
	icon_door = "eng_elec"

/obj/structure/closet/secure_closet/engineering_electrical/PopulateContents()
	..()
	//var/static/items_inside = list(
	//	/obj/item/clothing/gloves/color/yellow = 2,
	//	/obj/item/inducer = 2,
	//	/obj/item/storage/toolbox/electrical = 3,
	//	/obj/item/electronics/apc = 3,
	//	/obj/item/multitool = 3)
	//not_actual
	var/items_inside = list(
		/obj/item/clothing/gloves/color/yellow = 2,
		/obj/item/inducer = 2,
		/obj/item/storage/toolbox/electrical = 3,
		/obj/item/electronics/apc = 3,
		/obj/item/multitool = 3)
	generate_items_inside(items_inside,src)

/obj/structure/closet/secure_closet/engineering_welding
	name = "welding supplies locker"
	req_access = list(ACCESS_ENGINE_EQUIP)
	icon_state = "eng"
	icon_door = "eng_weld"

/obj/structure/closet/secure_closet/engineering_welding/PopulateContents()
	..()
	//for(var/i in 1 to 3)
	//	new /obj/item/clothing/head/welding(src)
	for(var/i in 1 to 3)
		new /obj/item/weldingtool(src)

/obj/structure/closet/secure_closet/atmospherics
	name = "\proper atmospheric technician's locker"
	req_access = list(ACCESS_ATMOSPHERICS)
	icon_state = "atmos"

/obj/structure/closet/secure_closet/atmospherics/PopulateContents()
	..()
	new /obj/item/radio/headset/headset_eng(src)
	//new /obj/item/pipe_dispenser(src)
	new /obj/item/storage/toolbox/mechanical(src)
	//new /obj/item/tank/internals/emergency_oxygen/engi(src)
	new /obj/item/analyzer(src)
	//new /obj/item/holosign_creator/atmos(src)
	//new /obj/item/watertank/atmos(src)
	//new /obj/item/clothing/suit/fire/atmos(src)
	//new /obj/item/clothing/head/hardhat/atmos(src)
	//new /obj/item/clothing/glasses/meson/engine/tray(src)
	//new /obj/item/extinguisher/advanced(src)