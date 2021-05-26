/obj/structure/disposalconstruct
	name = "disposal pipe segment"
	desc = "A huge pipe segment used for constructing disposal systems."
	icon = 'icons/obj/atmospherics/pipes/disposal.dmi'
	icon_state = "conpipe"
	anchored = FALSE
	density = FALSE
	pressure_resistance = 5*ONE_ATMOSPHERE
	level = 2
	max_integrity = 200
	var/obj/pipe_type = /obj/structure/disposalpipe/segment
	var/pipename

/obj/structure/disposalconstruct/Initialize(loc, _pipe_type, _dir = SOUTH, flip = FALSE, obj/make_from)
	. = ..()
	if(make_from)
		pipe_type = make_from.type
		setDir(make_from.dir)
		anchored = TRUE

	else
		if(_pipe_type)
			pipe_type = _pipe_type
		setDir(_dir)

	pipename = initial(pipe_type.name)

	//if(flip)
	//	GET_COMPONENT(rotcomp,/datum/component/simple_rotation)
	//	rotcomp.BaseRot(null,ROTATION_FLIP)

	update_icon()

/obj/structure/disposalconstruct/Move()
	var/old_dir = dir
	..()
	setDir(old_dir)

/obj/structure/disposalconstruct/update_icon()
	icon_state = initial(pipe_type.icon_state)
	if(is_pipe())
		icon_state = "con[icon_state]"
		if(anchored)
			level = initial(pipe_type.level)
			layer = initial(pipe_type.layer)
		else
			level = initial(level)
			layer = initial(layer)

	else if(ispath(pipe_type, /obj/machinery/disposal/bin))
		if(anchored)
			icon_state = "disposal"
		else
			icon_state = "condisposal"

/obj/structure/disposalconstruct/hide(var/intact)
	invisibility = (intact && level==1) ? INVISIBILITY_MAXIMUM: 0
	update_icon()

/obj/structure/disposalconstruct/proc/is_pipe()
	return ispath(pipe_type, /obj/structure/disposalpipe)