/obj/structure/closet/secure_closet/captains
	name = "\proper captain's locker"
	req_access = list(ACCESS_CAPTAIN)
	icon_state = "cap"

/obj/structure/closet/secure_closet/captains/PopulateContents()
	..()
	//new /obj/item/clothing/suit/hooded/wintercoat/captain(src)
	//new /obj/item/storage/backpack/captain(src)
	//new /obj/item/storage/backpack/satchel/cap(src)
	//new /obj/item/storage/backpack/duffelbag/captain(src)
	//new /obj/item/clothing/neck/cloak/cap(src)
	//new /obj/item/clothing/neck/petcollar(src)
	//new /obj/item/pet_carrier(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
	new /obj/item/clothing/under/rank/captain(src)
	new /obj/item/clothing/suit/armor/vest/capcarapace(src)
	new /obj/item/clothing/head/caphat(src)
	//new /obj/item/clothing/under/captainparade(src)
	//new /obj/item/clothing/suit/armor/vest/capcarapace/alt(src)
	//new /obj/item/clothing/head/caphat/parade(src)
	//new /obj/item/clothing/suit/captunic(src)
	//new /obj/item/clothing/head/crown/fancy(src)
	new /obj/item/cartridge/captain(src)
	//new /obj/item/storage/box/silver_ids(src)
	//new /obj/item/radio/headset/heads/captain/alt(src)
	//new /obj/item/radio/headset/heads/captain(src)
	//new /obj/item/clothing/glasses/sunglasses/gar/supergar(src)
	new /obj/item/clothing/gloves/color/captain(src)
	//new /obj/item/restraints/handcuffs/cable/zipties(src)
	//new /obj/item/storage/belt/sabre(src)
	//new /obj/item/gun/energy/e_gun(src)
	//new /obj/item/door_remote/captain(src)
	new /obj/item/card/id/captains_spare(src)
	//new /obj/item/storage/photo_album/Captain(src)

/obj/structure/closet/secure_closet/hop
	name = "\proper head of personnel's locker"
	req_access = list(ACCESS_HOP)
	icon_state = "hop"

/obj/structure/closet/secure_closet/hop/PopulateContents()
	..()
	//new /obj/item/clothing/neck/cloak/hop(src)
	new /obj/item/clothing/under/rank/head_of_personnel(src)
	new /obj/item/clothing/head/hopcap(src)
	new /obj/item/cartridge/hop(src)
	new /obj/item/radio/headset/heads/hop(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
	new /obj/item/storage/box/ids(src)
	new /obj/item/storage/box/ids(src)
	//new /obj/item/megaphone/command(src)
	new /obj/item/clothing/suit/armor/vest/alt(src)
	//new /obj/item/assembly/flash/handheld(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	//new /obj/item/restraints/handcuffs/cable/zipties(src)
	//new /obj/item/gun/energy/e_gun(src)
	//new /obj/item/clothing/neck/petcollar(src)
	//new /obj/item/pet_carrier(src)
	//new /obj/item/door_remote/civillian(src)
	//new /obj/item/circuitboard/machine/techfab/department/service(src)
	//new /obj/item/storage/photo_album/HoP(src)

/obj/structure/closet/secure_closet/hos
	name = "\proper head of security's locker"
	req_access = list(ACCESS_HOS)
	icon_state = "hos"

/obj/structure/closet/secure_closet/hos/PopulateContents()
	..()
	//new /obj/item/clothing/neck/cloak/hos(src)
	//new /obj/item/cartridge/hos(src)
	//new /obj/item/radio/headset/heads/hos(src)
	//new /obj/item/clothing/under/hosparadefem(src)
	//new /obj/item/clothing/under/hosparademale(src)
	//new /obj/item/clothing/suit/armor/vest/leather(src)
	//new /obj/item/clothing/suit/armor/hos(src)
	//new /obj/item/clothing/under/rank/head_of_security/alt(src)
	//new /obj/item/clothing/head/HoS(src)
	//new /obj/item/clothing/glasses/hud/security/sunglasses/eyepatch(src)
	//new /obj/item/clothing/glasses/hud/security/sunglasses/gars/supergars(src)
	//new /obj/item/clothing/under/rank/head_of_security/grey(src)
	//new /obj/item/storage/lockbox/medal/sec(src)
	//new /obj/item/megaphone/sec(src)
	//new /obj/item/holosign_creator/security(src)
	//new /obj/item/storage/lockbox/loyalty(src)
	//new /obj/item/clothing/mask/gas/sechailer/swat(src)
	//new /obj/item/storage/box/flashbangs(src)
	//new /obj/item/shield/riot/tele(src)
	//new /obj/item/storage/belt/security/full(src)
	//new /obj/item/gun/energy/e_gun/hos(src)
	new /obj/item/flashlight/seclite(src)
	//new /obj/item/pinpointer/nuke(src)
	//new /obj/item/circuitboard/machine/techfab/department/security(src)
	//new /obj/item/storage/photo_album/HoS(src)

/obj/structure/closet/secure_closet/warden
	name = "\proper warden's locker"
	icon_state = "warden"

/obj/structure/closet/secure_closet/security
	name = "security officer's locker"
	icon_state = "sec"

/obj/structure/closet/secure_closet/detective
	name = "\improper detective's cabinet"
	icon_state = "cabinet"

/obj/structure/closet/secure_closet/injection
	name = "lethal injections"

/obj/structure/closet/secure_closet/brig
	name = "brig locker"
	req_access = list(ACCESS_BRIG)
	anchored = TRUE
	var/id = null

/obj/structure/closet/secure_closet/evidence
	anchored = TRUE
	name = "Secure Evidence Closet"

/obj/structure/closet/secure_closet/courtroom
	name = "courtroom locker"

/obj/structure/closet/secure_closet/contraband/armory
	anchored = TRUE
	name = "Contraband Locker"

/obj/structure/closet/secure_closet/contraband/heads
	anchored = TRUE
	name = "Contraband Locker"

/obj/structure/closet/secure_closet/armory1
	name = "armory armor locker"
	icon_state = "armory"

/obj/structure/closet/secure_closet/armory2
	name = "armory ballistics locker"
	icon_state = "armory"

/obj/structure/closet/secure_closet/armory3
	name = "armory energy gun locker"
	icon_state = "armory"

/obj/structure/closet/secure_closet/tac
	name = "armory tac locker"
	icon_state = "tac"

/obj/structure/closet/secure_closet/lethalshots
	name = "shotgun lethal rounds"
	icon_state = "tac"