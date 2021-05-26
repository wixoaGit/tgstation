/obj/item/pipe_meter
	name = "meter"
	desc = "A meter that can be laid on pipes."
	icon = 'icons/obj/atmospherics/pipes/pipe_item.dmi'
	icon_state = "meter"
	item_state = "buildpipe"
	w_class = WEIGHT_CLASS_BULKY
	var/piping_layer = PIPING_LAYER_DEFAULT

/obj/item/pipe_meter/wrench_act(mob/living/user, obj/item/wrench/W)

	var/obj/machinery/atmospherics/pipe/pipe
	for(var/obj/machinery/atmospherics/pipe/P in loc)
		if(P.piping_layer == piping_layer)
			pipe = P
			break
	if(!pipe)
		to_chat(user, "<span class='warning'>You need to fasten it to a pipe!</span>")
		return TRUE
	new /obj/machinery/meter(loc, piping_layer)
	W.play_tool_sound(src)
	to_chat(user, "<span class='notice'>You fasten the meter to the pipe.</span>")
	qdel(src)

/obj/item/pipe_meter/screwdriver_act(mob/living/user, obj/item/S)
	. = ..()
	if(.)
		return TRUE

	if(!isturf(loc))
		to_chat(user, "<span class='warning'>You need to fasten it to the floor!</span>")
		return TRUE

	new /obj/machinery/meter/turf(loc, piping_layer)
	S.play_tool_sound(src)
	to_chat(user, "<span class='notice'>You fasten the meter to the [loc.name].</span>")
	qdel(src)

/obj/item/pipe_meter/dropped()
	. = ..()
	if(loc)
		setAttachLayer(piping_layer)

/obj/item/pipe_meter/proc/setAttachLayer(new_layer = PIPING_LAYER_DEFAULT)
	piping_layer = new_layer
	PIPING_LAYER_DOUBLE_SHIFT(src, piping_layer)