/obj/item/reagent_containers/food/snacks/meat
	var/subjectname = ""
	var/subjectjob = null

/obj/item/reagent_containers/food/snacks/meat/slab
	name = "meat"
	desc = "A slab of meat."
	icon_state = "meat"
	//dried_type = /obj/item/reagent_containers/food/snacks/sosjerky/healthy
	bitesize = 3
	list_reagents = list("nutriment" = 3, "cooking_oil" = 2)
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/steak/plain
	slice_path = /obj/item/reagent_containers/food/snacks/meat/rawcutlet/plain
	slices_num = 3
	filling_color = "#FF0000"
	tastes = list("meat" = 1)
	foodtype = MEAT | RAW

/obj/item/reagent_containers/food/snacks/meat/slab/initialize_slice(obj/item/reagent_containers/food/snacks/meat/rawcutlet/slice, reagents_per_slice)
	..()
	var/mutable_appearance/filling = mutable_appearance(icon, "rawcutlet_coloration")
	filling.color = filling_color
	slice.add_overlay(filling)
	slice.filling_color = filling_color
	slice.name = "raw [name] cutlet"
	slice.meat_type = name

/obj/item/reagent_containers/food/snacks/meat/slab/monkey
	name = "monkey meat"
	foodtype = RAW | MEAT

/obj/item/reagent_containers/food/snacks/meat/slab/meatwheat
	name = "meatwheat clump"
	desc = "This doesn't look like meat, but your standards aren't <i>that</i> high to begin with."
	list_reagents = list("nutriment" = 3, "vitamin" = 2, "blood" = 5, "cooking_oil" = 1)
	//filling_color = rgb(150, 0, 0)
	filling_color = "#960000"//not_actual
	icon_state = "meatwheat_clump"
	bitesize = 4
	tastes = list("meat" = 1, "wheat" = 1)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/meat/steak
	name = "steak"
	desc = "A piece of hot spicy meat."
	icon_state = "meatsteak"
	list_reagents = list("nutriment" = 5)
	bonus_reagents = list("nutriment" = 2, "vitamin" = 1)
	//trash = /obj/item/trash/plate
	filling_color = "#B22222"
	foodtype = MEAT
	tastes = list("meat" = 1)

/obj/item/reagent_containers/food/snacks/meat/steak/plain
    foodtype = MEAT

/obj/item/reagent_containers/food/snacks/meat/rawcutlet
	name = "raw cutlet"
	desc = "A raw meat cutlet."
	icon_state = "rawcutlet"
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/cutlet/plain
	bitesize = 2
	list_reagents = list("nutriment" = 1)
	filling_color = "#B22222"
	tastes = list("meat" = 1)
	var/meat_type = "meat"
	foodtype = MEAT | RAW

/obj/item/reagent_containers/food/snacks/meat/rawcutlet/initialize_cooked_food(obj/item/reagent_containers/food/snacks/S, cooking_efficiency)
	..()
	S.name = "[meat_type] cutlet"


/obj/item/reagent_containers/food/snacks/meat/rawcutlet/plain
    foodtype = MEAT

/obj/item/reagent_containers/food/snacks/meat/cutlet
	name = "cutlet"
	desc = "A cooked meat cutlet."
	icon_state = "cutlet"
	bitesize = 2
	list_reagents = list("nutriment" = 2)
	bonus_reagents = list("nutriment" = 1, "vitamin" = 1)
	filling_color = "#B22222"
	tastes = list("meat" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/meat/cutlet/plain