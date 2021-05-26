/datum/position
	var/x = 0
	var/y = 0
	var/z = 0
	var/pixel_x = 0
	var/pixel_y = 0

/datum/point
	var/x = 0
	var/y = 0
	var/z = 0

/datum/position/New(_x = 0, _y = 0, _z = 0, _pixel_x = 0, _pixel_y = 0)
	if(istype(_x, /datum/point))
		var/datum/point/P = _x
		var/turf/T = P.return_turf()
		_x = T.x
		_y = T.y
		_z = T.z
		_pixel_x = P.return_px()
		_pixel_y = P.return_py()
	else if(isatom(_x))
		var/atom/A = _x
		_x = A.x
		_y = A.y
		_z = A.z
		_pixel_x = A.pixel_x
		_pixel_y = A.pixel_y
	x = _x
	y = _y
	z = _z
	pixel_x = _pixel_x
	pixel_y = _pixel_y

/datum/point/proc/copy_to(datum/point/p = new /datum/point)
	p.x = x
	p.y = y
	p.z = z
	return p

/datum/point/New(_x, _y, _z, _pixel_x = 0, _pixel_y = 0)
	if(istype(_x, /datum/position))
		var/datum/position/P = _x
		_x = P.x
		_y = P.y
		_z = P.z
		_pixel_x = P.pixel_x
		_pixel_y = P.pixel_y
	else if(istype(_x, /atom))
		var/atom/A = _x
		_x = A.x
		_y = A.y
		_z = A.z
		_pixel_x = A.pixel_x
		_pixel_y = A.pixel_y
	initialize_location(_x, _y, _z, _pixel_x, _pixel_y)

/datum/point/proc/initialize_location(tile_x, tile_y, tile_z, p_x = 0, p_y = 0)
	if(!isnull(tile_x))
		x = ((tile_x - 1) * world.icon_size) + world.icon_size / 2 + p_x + 1
	if(!isnull(tile_y))
		y = ((tile_y - 1) * world.icon_size) + world.icon_size / 2 + p_y + 1
	if(!isnull(tile_z))
		z = tile_z

/datum/point/proc/move_atom_to_src(atom/movable/AM)
	AM.forceMove(return_turf())
	AM.pixel_x = return_px()
	AM.pixel_y = return_py()

/datum/point/proc/return_turf()
	return locate(CEILING(x / world.icon_size, 1), CEILING(y / world.icon_size, 1), z)

/datum/point/proc/return_px()
	return MODULUS(x, world.icon_size) - 16 - 1

/datum/point/proc/return_py()
	return MODULUS(y, world.icon_size) - 16 - 1

/datum/point/vector
	var/speed = 32
	var/iteration = 0
	var/angle = 0
	var/mpx = 0
	var/mpy = 0
	var/starting_x = 0
	var/starting_y = 0
	var/starting_z = 0

/datum/point/vector/New(_x, _y, _z, _pixel_x = 0, _pixel_y = 0, _angle, _speed, initial_increment = 0)
	..()
	initialize_trajectory(_speed, _angle)
	if(initial_increment)
		increment(initial_increment)

/datum/point/vector/initialize_location(tile_x, tile_y, tile_z, p_x = 0, p_y = 0)
	. = ..()
	starting_x = x
	starting_y = y
	starting_z = z

/datum/point/vector/copy_to(datum/point/vector/v = new)
	..(v)
	v.speed = speed
	v.iteration = iteration
	v.angle = angle
	v.mpx = mpx
	v.mpy = mpy
	v.starting_x = starting_x
	v.starting_y = starting_y
	v.starting_z = starting_z
	return v

/datum/point/vector/proc/initialize_trajectory(pixel_speed, new_angle)
	if(!isnull(pixel_speed))
		speed = pixel_speed
	set_angle(new_angle)

/datum/point/vector/proc/set_angle(new_angle)
	if(isnull(angle))
		return
	angle = new_angle
	update_offsets()

/datum/point/vector/proc/update_offsets()
	mpx = sin(angle) * speed
	mpy = cos(angle) * speed

/datum/point/vector/proc/set_speed(new_speed)
	if(isnull(new_speed) || speed == new_speed)
		return
	speed = new_speed
	update_offsets()

/datum/point/vector/proc/increment(multiplier = 1)
	iteration++
	x += mpx * (multiplier)
	y += mpy * (multiplier)