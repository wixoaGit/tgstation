/proc/hex2num(hex, safe=FALSE)
	. = 0
	var/place = 1
	for(var/i in length(hex) to 1 step -1)
		var/num = text2ascii(hex, i)
		//switch(num)
		//	if(48 to 57)
		//		num -= 48
		//	if(97 to 102)
		//		num -= 87
		//	if(65 to 70)
		//		num -= 55
		//	if(45)
		//		return . * -1
		//	else
		//		if(safe)
		//			return null
		//		else
		//			CRASH("Malformed hex number")
		//not_actual
		if (num >= 48 && num <= 57)
			num -= 48
		else if (num >= 97 && num <= 102)
			num -= 87
		else if (num >= 65 && num <= 70)
			num -= 55
		else if (num == 45)
			return . * -1
		else
			if(safe)
				return null
			else
				CRASH("Malformed hex number")

		. += num * place
		place *= 16

/proc/num2hex(num, len=2)
	if(!isnum(num))
		num = 0
	num = round(abs(num))
	. = ""
	var/i=0
	while(1)
		if(len<=0)
			if(!num)
				break
		else
			if(i>=len)
				break
		var/remainder = num/16
		num = round(remainder)
		remainder = (remainder - num) * 16
		switch(remainder)
			if(9,8,7,6,5,4,3,2,1)
				. = "[remainder]" + .
			if(10,11,12,13,14,15)
				. = ascii2text(remainder+87) + .
			else
				. = "0" + .
		i++
	return .

/world/proc/file2list(filename, seperator="\n", trim = TRUE)
	if (trim)
		return splittext(trim(file2text(filename)),seperator)
	return splittext(file2text(filename),seperator)

/proc/dir2text(direction)
	switch(direction)
		if(1)
			return "north"
		if(2)
			return "south"
		if(4)
			return "east"
		if(8)
			return "west"
		if(5)
			return "northeast"
		if(6)
			return "southeast"
		if(9)
			return "northwest"
		if(10)
			return "southwest"
		else
	return

/proc/angle2dir(degree)
	degree = SIMPLIFY_DEGREES(degree)
	//switch(degree)
	//	if(0 to 22.5)
	//		return NORTH
	//	if(22.5 to 67.5)
	//		return NORTHEAST
	//	if(67.5 to 112.5)
	//		return EAST
	//	if(112.5 to 157.5)
	//		return SOUTHEAST
	//	if(157.5 to 202.5)
	//		return SOUTH
	//	if(202.5 to 247.5)
	//		return SOUTHWEST
	//	if(247.5 to 292.5)
	//		return WEST
	//	if(292.5 to 337.5)
	//		return NORTHWEST
	//	if(337.5 to 360)
	//		return NORTH
	//not_actual
	if (degree <= 22.5)
		return NORTH
	else if (degree <= 67.5)
		return NORTHEAST
	else if (degree <= 112.5)
		return EAST
	else if (degree <= 157.5)
		return SOUTHEAST
	else if (degree <= 202.5)
		return SOUTH
	else if (degree <= 247.5)
		return SOUTHWEST
	else if (degree <= 292.5)
		return WEST
	else if (degree <= 337.5)
		return NORTHWEST
	else if (degree <= 360)
		return NORTH

/proc/dir2angle(D)
	switch(D)
		if(NORTH)
			return 0
		if(SOUTH)
			return 180
		if(EAST)
			return 90
		if(WEST)
			return 270
		if(NORTHEAST)
			return 45
		if(SOUTHEAST)
			return 135
		if(NORTHWEST)
			return 315
		if(SOUTHWEST)
			return 225
		else
			return null

/proc/rights2text(rights, seperator="", prefix = "+")
	seperator += prefix
	if(rights & R_BUILD)
		. += "[seperator]BUILDMODE"
	if(rights & R_ADMIN)
		. += "[seperator]ADMIN"
	if(rights & R_BAN)
		. += "[seperator]BAN"
	if(rights & R_FUN)
		. += "[seperator]FUN"
	if(rights & R_SERVER)
		. += "[seperator]SERVER"
	if(rights & R_DEBUG)
		. += "[seperator]DEBUG"
	if(rights & R_POSSESS)
		. += "[seperator]POSSESS"
	if(rights & R_PERMISSIONS)
		. += "[seperator]PERMISSIONS"
	if(rights & R_STEALTH)
		. += "[seperator]STEALTH"
	if(rights & R_POLL)
		. += "[seperator]POLL"
	if(rights & R_VAREDIT)
		. += "[seperator]VAREDIT"
	if(rights & R_SOUND)
		. += "[seperator]SOUND"
	if(rights & R_SPAWN)
		. += "[seperator]SPAWN"
	if(rights & R_AUTOADMIN)
		. += "[seperator]AUTOLOGIN"
	if(rights & R_DBRANKS)
		. += "[seperator]DBRANKS"
	if(!.)
		. = "NONE"
	return .

/proc/fusionpower2text(power)
	//switch(power)
	//	if(0 to 5)
	//		return "low"
	//	if(5 to 20)
	//		return "mid"
	//	if(20 to 50)
	//		return "high"
	//	if(50 to INFINITY)
	//		return "super"
	//not_actual
	if (power <= 5) return "low"
	else if (power <= 20) return "mid"
	else if (power <= 50) return "high"
	else return "super"

/proc/type2parent(child)
	var/string_type = "[child]"
	var/last_slash = findlasttext(string_type, "/")
	if(last_slash == 1)
		switch(child)
			if(/datum)
				return null
			//if(/obj || /mob)
			//not_actual
			if(/obj)
				return /atom/movable
			//not_actual
			if(/mob)
				return /atom/movable
			//if(/area || /turf)
			//not_actual
			if(/area)
				return /atom
			//not_actual
			if(/turf)
				return /atom
			else
				return /datum
	return text2path(copytext(string_type, 1, last_slash))

/proc/type2top(the_type)
	if(!ispath(the_type))
		return
	switch(the_type)
		if(/datum)
			return "datum"
		if(/atom)
			return "atom"
		if(/obj)
			return "obj"
		if(/mob)
			return "mob"
		if(/area)
			return "area"
		if(/turf)
			return "turf"
		else
			return lowertext(replacetext("[the_type]", "[type2parent(the_type)]/", ""))