#define PIPE_VISIBLE_LEVEL 2
#define PIPE_HIDDEN_LEVEL 1

/obj/machinery/atmospherics
	anchored = TRUE
	move_resist = INFINITY
	idle_power_usage = 0
	active_power_usage = 0
	power_channel = ENVIRON
	layer = GAS_PIPE_HIDDEN_LAYER
	resistance_flags = FIRE_PROOF
	max_integrity = 200
	obj_flags = CAN_BE_HIT | ON_BLUEPRINTS
	var/can_unwrench = 0
	var/initialize_directions = 0
	var/pipe_color
	var/piping_layer = PIPING_LAYER_DEFAULT
	var/pipe_flags = NONE

	var/global/list/iconsetids = list()
	var/global/list/pipeimages = list()

	var/image/pipe_vision_img = null

	var/device_type = 0
	var/list/obj/machinery/atmospherics/nodes

	var/construction_type
	var/pipe_state
	var/on = FALSE

/obj/machinery/atmospherics/examine(mob/user)
	..()
	//if(is_type_in_list(src, GLOB.ventcrawl_machinery) && isliving(user))
	//	var/mob/living/L = user
	//	if(L.ventcrawler)
	//		to_chat(L, "<span class='notice'>Alt-click to crawl through it.</span>")

/obj/machinery/atmospherics/New(loc, process = TRUE, setdir)
	if(!isnull(setdir))
		setDir(setdir)
	if(pipe_flags & PIPING_CARDINAL_AUTONORMALIZE)
		normalize_cardinal_directions()
	nodes = new(device_type)
	if (!armor)
		armor = list("melee" = 25, "bullet" = 10, "laser" = 10, "energy" = 100, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 70)
	..()
	if(process)
		SSair.atmos_machinery += src
	SetInitDirections()

/obj/machinery/atmospherics/Destroy()
	for(var/i in 1 to device_type)
		nullifyNode(i)

	SSair.atmos_machinery -= src

	dropContents()
	if(pipe_vision_img)
		qdel(pipe_vision_img)

	return ..()

/obj/machinery/atmospherics/proc/destroy_network()
	return

/obj/machinery/atmospherics/proc/build_network()
	return

/obj/machinery/atmospherics/proc/nullifyNode(i)
	if(nodes[i])
		var/obj/machinery/atmospherics/N = nodes[i]
		N.disconnect(src)
		nodes[i] = null

/obj/machinery/atmospherics/proc/getNodeConnects()
	var/list/node_connects = list()
	node_connects.len = device_type

	for(var/i in 1 to device_type)
		for(var/D in GLOB.cardinals)
			if(D & GetInitDirections())
				if(D in node_connects)
					continue
				node_connects[i] = D
				break
	return node_connects

/obj/machinery/atmospherics/proc/normalize_cardinal_directions()
	switch(dir)
		if(SOUTH)
			setDir(NORTH)
		if(WEST)
			setDir(EAST)

/obj/machinery/atmospherics/proc/atmosinit(list/node_connects)
	if(!node_connects)
		node_connects = getNodeConnects()

	for(var/i in 1 to device_type)
		for(var/obj/machinery/atmospherics/target in get_step(src,node_connects[i]))
			if(can_be_node(target, i))
				nodes[i] = target
				break
	update_icon()

/obj/machinery/atmospherics/proc/setPipingLayer(new_layer)
	piping_layer = (pipe_flags & PIPING_DEFAULT_LAYER_ONLY) ? PIPING_LAYER_DEFAULT : new_layer
	update_icon()

/obj/machinery/atmospherics/proc/can_be_node(obj/machinery/atmospherics/target, iteration)
	return connection_check(target, piping_layer)

/obj/machinery/atmospherics/proc/findConnecting(direction, prompted_layer)
	for(var/obj/machinery/atmospherics/target in get_step(src, direction))
		if(target.initialize_directions & get_dir(target,src))
			if(connection_check(target, prompted_layer))
				return target

/obj/machinery/atmospherics/proc/connection_check(obj/machinery/atmospherics/target, given_layer)
	if(isConnectable(target, given_layer) && target.isConnectable(src, given_layer) && (target.initialize_directions & get_dir(target,src)))
		return TRUE
	return FALSE

/obj/machinery/atmospherics/proc/isConnectable(obj/machinery/atmospherics/target, given_layer)
	if(isnull(given_layer))
		given_layer = piping_layer
	if((target.piping_layer == given_layer) || (target.pipe_flags & PIPING_ALL_LAYER))
		return TRUE
	return FALSE

/obj/machinery/atmospherics/proc/pipeline_expansion()
	return nodes

/obj/machinery/atmospherics/proc/SetInitDirections()
	return

/obj/machinery/atmospherics/proc/GetInitDirections()
	return initialize_directions

/obj/machinery/atmospherics/proc/returnPipenetAir()
	return

/obj/machinery/atmospherics/proc/setPipenet()
	return

/obj/machinery/atmospherics/proc/disconnect(obj/machinery/atmospherics/reference)
	if(istype(reference, /obj/machinery/atmospherics/pipe))
		var/obj/machinery/atmospherics/pipe/P = reference
		P.destroy_network()
	nodes[nodes.Find(reference)] = null
	update_icon()

/obj/machinery/atmospherics/attackby(obj/item/W, mob/user, params)
	//if(istype(W, /obj/item/pipe))
	if(FALSE)//not_actual
		//var/obj/item/pipe/pipe = W
		//if(user.dropItemToGround(pipe))
		//	pipe.setPipingLayer(piping_layer)
		//	return TRUE
	else
		return ..()

/obj/machinery/atmospherics/proc/can_unwrench(mob/user)
	return can_unwrench

/obj/machinery/atmospherics/deconstruct(disassembled = TRUE)
	//if(!(flags_1 & NODECONSTRUCT_1))
	//	if(can_unwrench)
	//		var/obj/item/pipe/stored = new construction_type(loc, null, dir, src)
	//		stored.setPipingLayer(piping_layer)
	//		if(!disassembled)
	//			stored.obj_integrity = stored.max_integrity * 0.5
	//		transfer_fingerprints_to(stored)
	..()

/obj/machinery/atmospherics/proc/getpipeimage(iconset, iconstate, direction, col=rgb(255,255,255), piping_layer=2)
	if(iconsetids[iconset] == null)
		iconsetids[iconset] = num2text(iconsetids.len + 1)

	var/identifier = iconsetids[iconset] + "_[iconstate]_[direction]_[col]_[piping_layer]"

	if((!(. = pipeimages[identifier])))
		var/image/pipe_overlay
		pipe_overlay = . = pipeimages[identifier] = image(iconset, iconstate, dir = direction)
		pipe_overlay.color = col
		PIPING_LAYER_SHIFT(pipe_overlay, piping_layer)

/obj/machinery/atmospherics/proc/update_layer()
	layer = initial(layer) + (piping_layer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_LCHANGE