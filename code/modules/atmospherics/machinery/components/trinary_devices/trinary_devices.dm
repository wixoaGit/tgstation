/obj/machinery/atmospherics/components/trinary
	icon = 'icons/obj/atmospherics/components/trinary_devices.dmi'
	dir = SOUTH
	initialize_directions = SOUTH|NORTH|WEST
	use_power = IDLE_POWER_USE
	device_type = TRINARY
	layer = GAS_FILTER_LAYER
	pipe_flags = PIPING_ONE_PER_TURF

	var/flipped = FALSE

/obj/machinery/atmospherics/components/trinary/SetInitDirections()
	switch(dir)
		if(NORTH)
			initialize_directions = EAST|NORTH|SOUTH
		if(SOUTH)
			initialize_directions = SOUTH|WEST|NORTH
		if(EAST)
			initialize_directions = EAST|WEST|SOUTH
		if(WEST)
			initialize_directions = WEST|NORTH|EAST

/obj/machinery/atmospherics/components/trinary/getNodeConnects()
	var/node1_connect = turn(dir, -180)
	var/node2_connect = turn(dir, -90)
	var/node3_connect = dir

	if(flipped)
		node1_connect = turn(node1_connect, 180)
		node3_connect = turn(node3_connect, 180)

	return list(node1_connect, node2_connect, node3_connect)
