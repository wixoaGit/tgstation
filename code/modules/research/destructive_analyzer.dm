/obj/machinery/rnd/destructive_analyzer
	name = "destructive analyzer"
	desc = "Learn science by destroying things!"
	icon_state = "d_analyzer"
	circuit = /obj/item/circuitboard/machine/destructive_analyzer
	var/decon_mod = 0

/obj/machinery/rnd/destructive_analyzer/RefreshParts()
	var/T = 0
	for(var/obj/item/stock_parts/S in component_parts)
		T += S.rating
	decon_mod = T

/obj/machinery/rnd/destructive_analyzer/disconnect_console()
	linked_console.linked_destroy = null
	..()

/obj/machinery/rnd/destructive_analyzer/Insert_Item(obj/item/O, mob/user)
	if(user.a_intent != INTENT_HARM)
		. = 1
		if(!is_insertion_ready(user))
			return
		if(!user.transferItemToLoc(O, src))
			to_chat(user, "<span class='warning'>\The [O] is stuck to your hand, you cannot put it in the [src.name]!</span>")
			return
		busy = TRUE
		loaded_item = O
		to_chat(user, "<span class='notice'>You add the [O.name] to the [src.name]!</span>")
		//flick("d_analyzer_la", src)
		addtimer(CALLBACK(src, .proc/finish_loading), 10)
		if (linked_console)
			linked_console.updateUsrDialog()

/obj/machinery/rnd/destructive_analyzer/proc/finish_loading()
	update_icon()
	reset_busy()

/obj/machinery/rnd/destructive_analyzer/update_icon()
	if(loaded_item)
		icon_state = "d_analyzer_l"
	else
		icon_state = initial(icon_state)

/obj/machinery/rnd/destructive_analyzer/proc/unload_item()
	if(!loaded_item)
		return FALSE
	loaded_item.forceMove(get_turf(src))
	loaded_item = null
	update_icon()
	return TRUE