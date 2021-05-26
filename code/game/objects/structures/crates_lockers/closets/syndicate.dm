/obj/structure/closet/syndicate
	name = "armory closet"
	desc = "Why is this here?"
	icon_state = "syndicate"

/obj/structure/closet/syndicate/resources
	desc = "An old, dusty locker."

/obj/structure/closet/syndicate/resources/PopulateContents()
	..()
	var/common_min = 30
	var/common_max = 50
	var/rare_min = 5
	var/rare_max = 20


	var/pickednum = rand(1, 50)

	//if(pickednum == 1)
	//	var/obj/item/paper/P = new /obj/item/paper(src)
	//	P.name = "\improper IOU"
	//	P.info = "Sorry man, we needed the money so we sold your stash. It's ok, we'll double our money for sure this time!"

	if(pickednum >= 2)
		new /obj/item/stack/sheet/metal(src, rand(common_min, common_max))

	if(pickednum >= 5)
		new /obj/item/stack/sheet/glass(src, rand(common_min, common_max))

	if(pickednum >= 10)
		new /obj/item/stack/sheet/plasteel(src, rand(common_min, common_max))

	//if(pickednum >= 15)
	//	new /obj/item/stack/sheet/mineral/plasma(src, rand(rare_min, rare_max))

	//if(pickednum >= 20)
	//	new /obj/item/stack/sheet/mineral/silver(src, rand(rare_min, rare_max))

	//if(pickednum >= 30)
	//	new /obj/item/stack/sheet/mineral/gold(src, rand(rare_min, rare_max))

	//if(pickednum >= 40)
	//	new /obj/item/stack/sheet/mineral/uranium(src, rand(rare_min, rare_max))

	//if(pickednum >= 40)
	//	new /obj/item/stack/sheet/mineral/titanium(src, rand(rare_min, rare_max))

	//if(pickednum >= 40)
	//	new /obj/item/stack/sheet/mineral/plastitanium(src, rand(rare_min, rare_max))

	//if(pickednum >= 45)
	//	new /obj/item/stack/sheet/mineral/diamond(src, rand(rare_min, rare_max))

	//if(pickednum == 50)
	//	new /obj/item/tank/jetpack/carbondioxide(src)

/obj/structure/closet/syndicate/resources/everything
	desc = "It's an emergency storage closet for repairs."

/obj/structure/closet/syndicate/resources/everything/PopulateContents()
	var/list/resources = list(
	/obj/item/stack/sheet/metal,
	/obj/item/stack/sheet/glass,
	///obj/item/stack/sheet/mineral/gold,
	///obj/item/stack/sheet/mineral/silver,
	///obj/item/stack/sheet/mineral/plasma,
	///obj/item/stack/sheet/mineral/uranium,
	///obj/item/stack/sheet/mineral/diamond,
	///obj/item/stack/sheet/mineral/bananium,
	/obj/item/stack/sheet/plasteel,
	///obj/item/stack/sheet/mineral/titanium,
	///obj/item/stack/sheet/mineral/plastitanium,
	///obj/item/stack/rods,
	///obj/item/stack/sheet/bluespace_crystal,
	///obj/item/stack/sheet/mineral/abductor,
	///obj/item/stack/sheet/plastic,
	/obj/item/stack/sheet/mineral/wood
	)

	for(var/i = 0, i<2, i++)
		for(var/res in resources)
			var/obj/item/stack/R = res
			new res(src, initial(R.max_amount))