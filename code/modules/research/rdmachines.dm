obj/machinery/rnd
	name = "R&D Device"
	icon = 'icons/obj/machines/research.dmi'
	density = TRUE
	use_power = IDLE_POWER_USE
	var/busy = FALSE
	var/hacked = FALSE
	var/console_link = TRUE
	var/requires_console = TRUE
	var/disabled = FALSE
	var/obj/machinery/computer/rdconsole/linked_console
	var/obj/item/loaded_item = null

/obj/machinery/rnd/proc/reset_busy()
	busy = FALSE

/obj/machinery/rnd/Initialize()
	. = ..()
	//wires = new /datum/wires/rnd(src)

/obj/machinery/rnd/Destroy()
	//QDEL_NULL(wires)
	return ..()

/obj/machinery/rnd/attackby(obj/item/O, mob/user, params)
	if (default_deconstruction_screwdriver(user, "[initial(icon_state)]_t", initial(icon_state), O))
		if(linked_console)
			disconnect_console()
		return
	if(default_deconstruction_crowbar(O))
		return
	//if(panel_open && is_wire_tool(O))
	//	wires.interact(user)
	//	return TRUE
	if(is_refillable() && O.is_drainable())
		return FALSE
	if(Insert_Item(O, user))
		return TRUE
	else
		return ..()

/obj/machinery/rnd/proc/disconnect_console()
	linked_console = null

/obj/machinery/rnd/proc/Insert_Item(obj/item/I, mob/user)
	return

/obj/machinery/rnd/proc/is_insertion_ready(mob/user)
	if(panel_open)
		to_chat(user, "<span class='warning'>You can't load [src] while it's opened!</span>")
		return FALSE
	if(disabled)
		to_chat(user, "<span class='warning'>The insertion belts of [src] won't engage!</span>")
		return FALSE
	if(requires_console && !linked_console)
		to_chat(user, "<span class='warning'>[src] must be linked to an R&D console first!</span>")
		return FALSE
	if(busy)
		to_chat(user, "<span class='warning'>[src] is busy right now.</span>")
		return FALSE
	if(stat & BROKEN)
		to_chat(user, "<span class='warning'>[src] is broken.</span>")
		return FALSE
	if(stat & NOPOWER)
		to_chat(user, "<span class='warning'>[src] has no power.</span>")
		return FALSE
	if(loaded_item)
		to_chat(user, "<span class='warning'>[src] is already loaded.</span>")
		return FALSE
	return TRUE

/obj/machinery/rnd/on_deconstruction()
	if(loaded_item)
		loaded_item.forceMove(loc)
	..()