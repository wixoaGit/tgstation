/atom/proc/shuttleRotate(rotation, params=ROTATE_DIR|ROTATE_SMOOTH|ROTATE_OFFSET)
	if(params & ROTATE_DIR)
		setDir(angle2dir(rotation+dir2angle(dir)))

	if(smooth && (params & ROTATE_SMOOTH))
		queue_smooth(src)

	if((pixel_x || pixel_y) && (params & ROTATE_OFFSET))
		if(rotation < 0)
			rotation += 360
		for(var/turntimes=rotation/90;turntimes>0;turntimes--)
			var/oldPX = pixel_x
			var/oldPY = pixel_y
			pixel_x = oldPY
			pixel_y = (oldPX*(-1))