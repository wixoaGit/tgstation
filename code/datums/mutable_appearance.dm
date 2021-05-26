/proc/mutable_appearance(icon, icon_state = "", layer = FLOAT_LAYER, plane = FLOAT_PLANE)
	var/mutable_appearance/MA = new()
	MA.icon = icon
	MA.icon_state = icon_state
	MA.layer = layer
	//MA.plane = plane
	return MA