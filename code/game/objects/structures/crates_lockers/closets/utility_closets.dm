/obj/structure/closet/emcloset
	name = "emergency closet"
	desc = "It's a storage unit for emergency breath masks and O2 tanks."
	icon_state = "emergency"

/obj/structure/closet/emcloset/anchored
	anchored = TRUE

/obj/structure/closet/emcloset/PopulateContents()
	..()

	if (prob(40))
		new /obj/item/storage/toolbox/emergency(src)

	switch (pickweight(list("small" = 40, "aid" = 25, "tank" = 20, "both" = 10, "nothing" = 4, "delete" = 1)))
		if ("small")
			new /obj/item/tank/internals/emergency_oxygen(src)
			new /obj/item/tank/internals/emergency_oxygen(src)
			new /obj/item/clothing/mask/breath(src)
			new /obj/item/clothing/mask/breath(src)

		if ("aid")
			new /obj/item/tank/internals/emergency_oxygen(src)
			//new /obj/item/storage/firstaid/o2(src)
			new /obj/item/clothing/mask/breath(src)

		if ("tank")
			//new /obj/item/tank/internals/air(src)
			new /obj/item/clothing/mask/breath(src)

		if ("both")
			new /obj/item/tank/internals/emergency_oxygen(src)
			new /obj/item/clothing/mask/breath(src)

		if ("nothing")

		if ("delete")
			qdel(src)

/obj/structure/closet/firecloset
	name = "fire-safety closet"
	desc = "It's a storage unit for fire-fighting supplies."
	icon_state = "fire"

/obj/structure/closet/firecloset/PopulateContents()
	..()

	new /obj/item/clothing/suit/fire/firefighter(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/tank/internals/oxygen/red(src)
	new /obj/item/extinguisher(src)
	new /obj/item/clothing/head/hardhat/red(src)

/obj/structure/closet/firecloset/full/PopulateContents()
	new /obj/item/clothing/suit/fire/firefighter(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/flashlight(src)
	new /obj/item/tank/internals/oxygen/red(src)
	new /obj/item/extinguisher(src)
	new /obj/item/clothing/head/hardhat/red(src)

/obj/structure/closet/radiation
	name = "radiation suit closet"
	desc = "It's a storage unit for rad-protective suits."
	icon_state = "eng"
	icon_door = "eng_rad"

/obj/structure/closet/radiation/PopulateContents()
	..()
	//new /obj/item/geiger_counter(src)
	//new /obj/item/clothing/suit/radiation(src)
	//new /obj/item/clothing/head/radiation(src)