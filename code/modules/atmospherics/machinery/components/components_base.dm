/obj/machinery/atmospherics/components
	var/welded = FALSE
	var/showpipe = FALSE
	var/shift_underlay_only = TRUE

	var/list/datum/pipeline/parents
	var/list/datum/gas_mixture/airs

/obj/machinery/atmospherics/components/New()
	parents = new(device_type)
	airs = new(device_type)

	..()

	for(var/i in 1 to device_type)
		var/datum/gas_mixture/A = new
		A.volume = 200
		airs[i] = A

/obj/machinery/atmospherics/components/proc/update_icon_nopipes()
	return

/obj/machinery/atmospherics/components/update_icon()
	update_icon_nopipes()

	underlays.Cut()

	var/turf/T = loc
	if(level == 2 || !T.intact)
		showpipe = TRUE
		//plane = GAME_PLANE
	else
		showpipe = FALSE
		//plane = FLOOR_PLANE

	if(!showpipe)
		return

	var/connected = 0

	for(var/i in 1 to device_type)
		if(nodes[i])
			var/obj/machinery/atmospherics/node = nodes[i]
			var/image/img = get_pipe_underlay("pipe_intact", get_dir(src, node), node.pipe_color)
			underlays += img
			connected |= img.dir

	for(var/direction in GLOB.cardinals)
		if((initialize_directions & direction) && !(connected & direction))
			underlays += get_pipe_underlay("pipe_exposed", direction)

	if(!shift_underlay_only)
		PIPING_LAYER_SHIFT(src, piping_layer)

/obj/machinery/atmospherics/components/proc/get_pipe_underlay(state, dir, color = null)
	if(color)
		. = getpipeimage('icons/obj/atmospherics/components/binary_devices.dmi', state, dir, color, piping_layer = shift_underlay_only ? piping_layer : 2)
	else
		. = getpipeimage('icons/obj/atmospherics/components/binary_devices.dmi', state, dir, piping_layer = shift_underlay_only ? piping_layer : 2)

/obj/machinery/atmospherics/components/nullifyNode(i)
	if(nodes[i])
		nullifyPipenet(parents[i])
		QDEL_NULL(airs[i])
	..()

/obj/machinery/atmospherics/components/on_construction()
	..()
	update_parents()

/obj/machinery/atmospherics/components/build_network()
	for(var/i in 1 to device_type)
		if(!parents[i])
			parents[i] = new /datum/pipeline()
			var/datum/pipeline/P = parents[i]
			P.build_pipeline(src)

/obj/machinery/atmospherics/components/proc/nullifyPipenet(datum/pipeline/reference)
	if(!reference)
		CRASH("nullifyPipenet(null) called by [type] on [COORD(src)]")
		return
	var/i = parents.Find(reference)
	reference.other_airs -= airs[i]
	reference.other_atmosmch -= src
	parents[i] = null

/obj/machinery/atmospherics/components/returnPipenetAir(datum/pipeline/reference)
	return airs[parents.Find(reference)]

/obj/machinery/atmospherics/components/pipeline_expansion(datum/pipeline/reference)
	if(reference)
		return list(nodes[parents.Find(reference)])
	return ..()

/obj/machinery/atmospherics/components/setPipenet(datum/pipeline/reference, obj/machinery/atmospherics/A)
	parents[nodes.Find(A)] = reference

/obj/machinery/atmospherics/components/proc/update_parents()
	for(var/i in 1 to device_type)
		var/datum/pipeline/parent = parents[i]
		if(!parent)
			//throw EXCEPTION("Component is missing a pipenet! Rebuilding...")
			CRASH("Component is missing a pipenet! Rebuilding...")//not_actual
			build_network()
		parent.update = 1

/obj/machinery/atmospherics/components/ui_status(mob/user)
	if(allowed(user))
		return ..()
	to_chat(user, "<span class='danger'>Access denied.</span>")
	return UI_CLOSE

/obj/machinery/atmospherics/components/analyzer_act(mob/living/user, obj/item/I)
	atmosanalyzer_scan(airs, user, src)