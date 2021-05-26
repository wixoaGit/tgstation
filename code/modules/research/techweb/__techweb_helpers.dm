/proc/node_boost_error(id, message)
	//WARNING("Invalid boost information for node \[[id]\]: [message]")
	WARNING("Invalid boost information for node ([id]): [message]")//not_actual
	SSresearch.invalid_node_boost[id] = message

/proc/techweb_item_boost_check(obj/item/I)
	if(SSresearch.techweb_boost_items[I.type])
		return SSresearch.techweb_boost_items[I.type]

/proc/techweb_item_point_check(obj/item/I)
	if(SSresearch.techweb_point_items[I.type])
		return SSresearch.techweb_point_items[I.type]

/proc/techweb_point_display_generic(pointlist)
	var/list/ret = list()
	for(var/i in pointlist)
		if(SSresearch.point_types[i])
			ret += "[SSresearch.point_types[i]]: [pointlist[i]]"
		else
			ret += "ERRORED POINT TYPE: [pointlist[i]]"
	return ret.Join("<BR>")

/proc/techweb_point_display_rdconsole(pointlist, last_pointlist)
	var/list/ret = list()
	for(var/i in pointlist)
		ret += "[SSresearch.point_types[i] || "ERRORED POINT TYPE"]: [pointlist[i]] (+[(last_pointlist[i]) * ((SSresearch.flags & SS_TICKER)? (600 / (world.tick_lag * SSresearch.wait)) : (600 / SSresearch.wait))]/ minute)"
	return ret.Join("<BR>")