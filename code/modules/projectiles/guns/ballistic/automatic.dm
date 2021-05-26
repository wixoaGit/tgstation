/obj/item/gun/ballistic/automatic
	w_class = WEIGHT_CLASS_NORMAL
	var/alarmed = 0
	var/select = 1
	can_suppress = TRUE
	burst_size = 3
	fire_delay = 2
	//actions_types = list(/datum/action/item_action/toggle_firemode)

/obj/item/gun/ballistic/automatic/update_icon()
	..()
	if(!select)
		add_overlay("[initial(icon_state)]semi")
	if(select == 1)
		add_overlay("[initial(icon_state)]burst")
	icon_state = "[initial(icon_state)][magazine ? "-[magazine.max_ammo]" : ""][chambered ? "" : "-e"][suppressed ? "-suppressed" : ""]"