/obj/structure/closet/secure_closet/medical3
	name = "medical doctor's locker"
	req_access = list(ACCESS_SURGERY)
	icon_state = "med_secure"

/obj/structure/closet/secure_closet/medical3/PopulateContents()
	..()
	//new /obj/item/radio/headset/headset_med(src)
	//new /obj/item/defibrillator/loaded(src)
	//new /obj/item/clothing/gloves/color/latex/nitrile(src)
	//new /obj/item/storage/belt/medical(src)
	//new /obj/item/clothing/glasses/hud/health(src)
	return

/obj/structure/closet/secure_closet/CMO
	name = "\proper chief medical officer's locker"
	req_access = list(ACCESS_CMO)
	icon_state = "cmo"

/obj/structure/closet/secure_closet/CMO/PopulateContents()
	..()
	//new /obj/item/clothing/neck/cloak/cmo(src)
	//new /obj/item/storage/backpack/duffelbag/med(src)
	//new /obj/item/clothing/suit/bio_suit/cmo(src)
	//new /obj/item/clothing/head/bio_hood/cmo(src)
	new /obj/item/clothing/suit/toggle/labcoat/cmo(src)
	new /obj/item/clothing/under/rank/chief_medical_officer(src)
	new /obj/item/clothing/shoes/sneakers/brown	(src)
	new /obj/item/cartridge/cmo(src)
	new /obj/item/radio/headset/heads/cmo(src)
	//new /obj/item/megaphone/command(src)
	//new /obj/item/defibrillator/compact/loaded(src)
	//new /obj/item/clothing/gloves/color/latex/nitrile(src)
	//new /obj/item/storage/belt/medical(src)
	//new /obj/item/healthanalyzer/advanced(src)
	//new /obj/item/assembly/flash/handheld(src)
	//new /obj/item/reagent_containers/hypospray/CMO(src)
	//new /obj/item/autosurgeon/cmo(src)
	//new /obj/item/door_remote/chief_medical_officer(src)
	//new /obj/item/clothing/neck/petcollar(src)
	//new /obj/item/pet_carrier(src)
	//new /obj/item/wallframe/defib_mount(src)
	//new /obj/item/circuitboard/machine/techfab/department/medical(src)
	//new /obj/item/storage/photo_album/CMO(src)

/obj/structure/closet/secure_closet/chemical
	name = "chemical closet"
	desc = "Store dangerous chemicals in here."
	req_access = list(ACCESS_CHEMISTRY)
	icon_door = "chemical"

/obj/structure/closet/secure_closet/chemical/PopulateContents()
	..()
	//new /obj/item/storage/box/pillbottles(src)
	//new /obj/item/storage/box/pillbottles(src)
	//new /obj/item/storage/box/medsprays(src)
	//new /obj/item/storage/box/medsprays(src)

/obj/structure/closet/secure_closet/chemical/heisenberg
	name = "advanced chemical closet"

/obj/structure/closet/secure_closet/chemical/heisenberg/PopulateContents()
	..()
	new /obj/item/reagent_containers/dropper(src)
	new /obj/item/reagent_containers/dropper(src)
	new /obj/item/storage/box/syringes/variety(src)
	new /obj/item/storage/box/beakers/variety(src)
	new /obj/item/clothing/glasses/science(src)