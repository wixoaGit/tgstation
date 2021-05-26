/proc/ReadRGB(rgb)
	if(!rgb)
		return

	//var/i=1,start=1
	//not_actual
	var/i=1
	var/start=1
	if(text2ascii(rgb) == 35) ++start
	//var/ch,which=0,r=0,g=0,b=0,alpha=0,usealpha
	//not_actual
	var/ch
	var/which=0
	var/r=0
	var/g=0
	var/b=0
	var/alpha=0
	var/usealpha
	var/digits=0
	for(i=start, i<=length(rgb), ++i)
		ch = text2ascii(rgb, i)
		if(ch < 48 || (ch > 57 && ch < 65) || (ch > 70 && ch < 97) || ch > 102)
			break
		++digits
		if(digits == 8)
			break

	var/single = digits < 6
	if(digits != 3 && digits != 4 && digits != 6 && digits != 8)
		return
	if(digits == 4 || digits == 8)
		usealpha = 1
	for(i=start, digits>0, ++i)
		ch = text2ascii(rgb, i)
		if(ch >= 48 && ch <= 57)
			ch -= 48
		else if(ch >= 65 && ch <= 70)
			ch -= 55
		else if(ch >= 97 && ch <= 102)
			ch -= 87
		else
			break
		--digits
		switch(which)
			if(0)
				r = (r << 4) | ch
				if(single)
					r |= r << 4
					++which
				else if(!(digits & 1))
					++which
			if(1)
				g = (g << 4) | ch
				if(single)
					g |= g << 4
					++which
				else if(!(digits & 1))
					++which
			if(2)
				b = (b << 4) | ch
				if(single)
					b |= b << 4
					++which
				else if(!(digits & 1))
					++which
			if(3)
				alpha = (alpha << 4) | ch
				if(single)
					alpha |= alpha << 4

	. = list(r, g, b)
	if(usealpha)
		. += alpha

/proc/BlendRGB(rgb1, rgb2, amount)
	var/list/RGB1 = ReadRGB(rgb1)
	var/list/RGB2 = ReadRGB(rgb2)

	if(RGB1.len < RGB2.len)
		RGB1 += 255
	else if(RGB2.len < RGB1.len)
		RGB2 += 255
	var/usealpha = RGB1.len > 3

	var/r = round(RGB1[1] + (RGB2[1] - RGB1[1]) * amount, 1)
	var/g = round(RGB1[2] + (RGB2[2] - RGB1[2]) * amount, 1)
	var/b = round(RGB1[3] + (RGB2[3] - RGB1[3]) * amount, 1)
	var/alpha = usealpha ? round(RGB1[4] + (RGB2[4] - RGB1[4]) * amount, 1) : null

	return isnull(alpha) ? rgb(r, g, b) : rgb(r, g, b, alpha)

/proc/icon2base64(icon/icon, iconKey = "misc")
	//if (!isicon(icon))
	//	return FALSE
	//WRITE_FILE(GLOB.iconCache[iconKey], icon)
	//var/iconData = GLOB.iconCache.ExportText(iconKey)
	//var/list/partial = splittext(iconData, "{")
	//return replacetext(copytext(partial[2], 3, -5), "\n", "")
	return ""//not_actual

/proc/icon2html(thing, target, icon_state, dir, frame = 1, moving = FALSE)
	if (!thing)
		return

	//var/key
	//var/icon/I = thing
	//if (!target)
	//	return
	//if (target == world)
	//	target = GLOB.clients

	//var/list/targets
	//if (!islist(target))
	//	targets = list(target)
	//else
	//	targets = target
	//	if (!targets.len)
	//		return
	//if (!isicon(I))
	//	if (isfile(thing))
	//		var/name = sanitize_filename("[generate_asset_name(thing)].png")
	//		register_asset(name, thing)
	//		for (var/thing2 in targets)
	//			send_asset(thing2, key, FALSE)
	//		return "<img class='icon icon-misc' src=\"[url_encode(name)]\">"
	//	var/atom/A = thing
	//	if (isnull(dir))
	//		dir = A.dir
	//	if (isnull(icon_state))
	//		icon_state = A.icon_state
	//	I = A.icon
	//	if (ishuman(thing))
	//		var/icon/temp = I
	//		I = icon()
	//		I.Insert(temp, dir = SOUTH)
	//		dir = SOUTH
	//else
	//	if (isnull(dir))
	//		dir = SOUTH
	//	if (isnull(icon_state))
	//		icon_state = ""

	//I = icon(I, icon_state, dir, frame, moving)

	//key = "[generate_asset_name(I)].png"
	//register_asset(key, I)
	//for (var/thing2 in targets)
	//	send_asset(thing2, key, FALSE)

	//return "<img class='icon icon-[icon_state]' src=\"[url_encode(key)]\">"
	return "(icon)"//not_actual