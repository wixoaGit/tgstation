/obj/item/reagent_containers/food/snacks/store/bread
	icon = 'icons/obj/food/burgerbread.dmi'
	volume = 80
	slices_num = 5
	tastes = list("bread" = 10)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/breadslice
	icon = 'icons/obj/food/burgerbread.dmi'
	bitesize = 2
	//custom_food_type = /obj/item/reagent_containers/food/snacks/customizable/sandwich
	filling_color = "#FFA500"
	list_reagents = list("nutriment" = 2)
	slot_flags = ITEM_SLOT_HEAD
	customfoodfilling = 0
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/store/bread/plain
	name = "bread"
	desc = "Some plain old earthen bread."
	icon_state = "bread"
	bonus_reagents = list("nutriment" = 7)
	list_reagents = list("nutriment" = 10)
	//custom_food_type = /obj/item/reagent_containers/food/snacks/customizable/bread
	slice_path = /obj/item/reagent_containers/food/snacks/breadslice/plain
	tastes = list("bread" = 10)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/breadslice/plain
	name = "bread slice"
	desc = "A slice of home."
	icon_state = "breadslice"
	customfoodfilling = 1
	foodtype = GRAIN