/matrix/proc/TurnTo(old_angle, new_angle)
	. = new_angle - old_angle
	Turn(.)

/matrix/proc/get_x_shift()
	. = c

/matrix/proc/get_y_shift()
	. = f

/matrix/proc/get_x_skew()
	. = b

/matrix/proc/get_y_skew()
	. = d