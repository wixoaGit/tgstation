/obj/machinery/power/terminal
	name = "terminal"
	icon_state = "term"
	desc = "It's an underfloor wiring terminal for power equipment."
	level = 1
	layer = WIRE_TERMINAL_LAYER
	var/obj/machinery/power/master = null


/obj/machinery/power/terminal/Initialize()
	. = ..()
	var/turf/T = get_turf(src)
	if(level == 1)
		hide(T.intact)

/obj/machinery/power/terminal/Destroy()
	if(master)
		master.disconnect_terminal()
		master = null
	return ..()

/obj/machinery/power/terminal/hide(i)
	if(i)
		invisibility = INVISIBILITY_MAXIMUM
		icon_state = "term-f"
	else
		invisibility = 0
		icon_state = "term"

/obj/machinery/power/proc/can_terminal_dismantle()
	. = 0

/obj/machinery/power/apc/can_terminal_dismantle()
	. = 0
	if(opened)
		. = 1

/obj/machinery/power/smes/can_terminal_dismantle()
	. = 0
	if(panel_open)
		. = 1

/obj/machinery/power/terminal/proc/dismantle(mob/living/user, obj/item/I)
	if(isturf(loc))
		var/turf/T = loc
		if(T.intact)
			to_chat(user, "<span class='warning'>You must first expose the power terminal!</span>")
			return

	if(master && !master.can_terminal_dismantle())
		return

	user.visible_message("[user.name] dismantles the power terminal from [master].",
		"<span class='notice'>You begin to cut the cables...</span>")

	playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
	if(I.use_tool(src, user, 50))
		if(master && !master.can_terminal_dismantle())
			return

		//if(prob(50) && electrocute_mob(user, powernet, src, 1, TRUE))
		//	do_sparks(5, TRUE, master)
		//	return

		new /obj/item/stack/cable_coil(drop_location(), 10)
		to_chat(user, "<span class='notice'>You cut the cables and dismantle the power terminal.</span>")
		qdel(src)

/obj/machinery/power/terminal/wirecutter_act(mob/living/user, obj/item/I)
	dismantle(user, I)
	return TRUE