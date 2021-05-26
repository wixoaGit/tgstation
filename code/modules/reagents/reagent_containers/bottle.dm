/obj/item/reagent_containers/glass/bottle
	name = "bottle"
	desc = "A small bottle."
	icon_state = "bottle"
	item_state = "atoxinbottle"
	possible_transfer_amounts = list(5,10,15,25,30)
	volume = 30


/obj/item/reagent_containers/glass/bottle/Initialize()
	. = ..()
	if(!icon_state)
		icon_state = "bottle"
	update_icon()

/obj/item/reagent_containers/glass/bottle/on_reagent_change(changetype)
	update_icon()

/obj/item/reagent_containers/glass/bottle/update_icon()
	cut_overlays()
	if(reagents.total_volume)
		var/mutable_appearance/filling = mutable_appearance('icons/obj/reagentfillings.dmi', "[icon_state]-10")

		var/percent = round((reagents.total_volume / volume) * 100)
		//switch(percent)
		//	if(0 to 9)
		//		filling.icon_state = "[icon_state]-10"
		//	if(10 to 29)
		//		filling.icon_state = "[icon_state]25"
		//	if(30 to 49)
		//		filling.icon_state = "[icon_state]50"
		//	if(50 to 69)
		//		filling.icon_state = "[icon_state]75"
		//	if(70 to INFINITY)
		//		filling.icon_state = "[icon_state]100"
		//not_actual
		if (percent < 10)
			filling.icon_state = "[icon_state]-10"
		else if (percent < 30)
			filling.icon_state = "[icon_state]25"
		else if (percent < 50)
			filling.icon_state = "[icon_state]50"
		else if (percent < 70)
			filling.icon_state = "[icon_state]75"
		else
			filling.icon_state = "[icon_state]100"

		filling.color = mix_color_from_reagents(reagents.reagent_list)
		add_overlay(filling)