/obj/item/clothing
	name = "clothing"
	resistance_flags = FLAMMABLE
	max_integrity = 200
	integrity_failure = 80
	var/damaged_clothes = 0
	var/flash_protect = 0
	var/tint = 0
	var/up = 0
	var/visor_flags = 0
	var/visor_flags_inv = 0
	var/visor_flags_cover = 0
	var/visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT | VISOR_VISIONFLAGS | VISOR_DARKNESSVIEW | VISOR_INVISVIEW
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'
	var/alt_desc = null
	var/toggle_message = null
	var/alt_toggle_message = null
	var/active_sound = null
	var/toggle_cooldown = null
	var/cooldown = 0
	var/scan_reagents = 0

	var/clothing_flags = NONE

	var/list/user_vars_to_edit
	var/list/user_vars_remembered

	var/pocket_storage_component_path

	var/dynamic_hair_suffix = ""
	var/dynamic_fhair_suffix = ""

/obj/item/clothing/Initialize()
	. = ..()
	//if(ispath(pocket_storage_component_path))
	//	LoadComponent(pocket_storage_component_path)

/obj/item/clothing/Destroy()
	user_vars_remembered = null
	return ..()

/obj/item/clothing/examine(mob/user)
	..()
	clothing_resistance_flag_examine_message(user)
	if(damaged_clothes)
		to_chat(user,  "<span class='warning'>It looks damaged!</span>")
	//GET_COMPONENT(pockets, /datum/component/storage)
	//if(pockets)
	//	var/list/how_cool_are_your_threads = list("<span class='notice'>")
	//	if(pockets.attack_hand_interact)
	//		how_cool_are_your_threads += "[src]'s storage opens when clicked.\n"
	//	else
	//		how_cool_are_your_threads += "[src]'s storage opens when dragged to yourself.\n"
	//	how_cool_are_your_threads += "[src] can store [pockets.max_items] item\s.\n"
	//	how_cool_are_your_threads += "[src] can store items that are [weightclass2text(pockets.max_w_class)] or smaller.\n"
	//	if(pockets.quickdraw)
	//		how_cool_are_your_threads += "You can quickly remove an item from [src] using Alt-Click.\n"
	//	if(pockets.silent)
	//		how_cool_are_your_threads += "Adding or removing items from [src] makes no noise.\n"
	//	how_cool_are_your_threads += "</span>"
	//	to_chat(user, how_cool_are_your_threads.Join())

/obj/item/clothing/obj_break(damage_flag)
	if(!damaged_clothes)
		update_clothes_damaged_state(TRUE)
	if(ismob(loc))
		var/mob/M = loc
		M.visible_message("<span class='warning'>[M]'s [name] starts to fall apart!", "<span class='warning'>Your [name] starts to fall apart!</span>")

/obj/item/clothing/proc/update_clothes_damaged_state(damaging = TRUE)
	//var/index = "[REF(initial(icon))]-[initial(icon_state)]"
	//var/static/list/damaged_clothes_icons = list()
	//if(damaging)
	//	damaged_clothes = 1
	//	var/icon/damaged_clothes_icon = damaged_clothes_icons[index]
	//	if(!damaged_clothes_icon)
	//		damaged_clothes_icon = icon(initial(icon), initial(icon_state), , 1)
	//		damaged_clothes_icon.Blend("#fff", ICON_ADD)
	//		damaged_clothes_icon.Blend(icon('icons/effects/item_damage.dmi', "itemdamaged"), ICON_MULTIPLY)
	//		damaged_clothes_icon = fcopy_rsc(damaged_clothes_icon)
	//		damaged_clothes_icons[index] = damaged_clothes_icon
	//	add_overlay(damaged_clothes_icon, 1)
	//else
	//	damaged_clothes = 0
	//	cut_overlay(damaged_clothes_icons[index], TRUE)