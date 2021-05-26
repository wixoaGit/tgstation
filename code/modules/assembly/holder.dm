/obj/item/assembly_holder
	name = "Assembly"
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = "holder"
	item_state = "assembly"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	flags_1 = CONDUCT_1
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 2
	throw_range = 7

	var/obj/item/assembly/a_left = null
	var/obj/item/assembly/a_right = null

/obj/item/assembly_holder/update_icon()
	//cut_overlays()
	//if(a_left)
	//	add_overlay("[a_left.icon_state]_left")
	//	for(var/O in a_left.attached_overlays)
	//		add_overlay("[O]_l")

	//if(a_right)
	//	if(a_right.is_position_sensitive)
	//		add_overlay("[a_right.icon_state]_right")
	//		for(var/O in a_right.attached_overlays)
	//			add_overlay("[O]_r")
	//	else
	//		var/mutable_appearance/right = mutable_appearance(icon, "[a_right.icon_state]_left")
	//		right.transform = matrix(-1, 0, 0, 0, 1, 0)
	//		for(var/O in a_right.attached_overlays)
	//			right.add_overlay("[O]_l")
	//		add_overlay(right)

	//if(master)
	//	master.update_icon()