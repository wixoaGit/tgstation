/datum/techweb_node
	var/id
	var/display_name = "Errored Node"
	var/description = "Why are you seeing this?"
	var/hidden = FALSE
	var/starting_node = FALSE
	var/list/prereq_ids = list()
	var/list/design_ids = list()
	var/list/unlock_ids = list()
	var/list/boost_item_paths = list()
	var/autounlock_by_boost = TRUE
	var/export_price = 0
	var/list/research_costs = list()
	var/category = "Misc"

/datum/techweb_node/error_node
	id = "ERROR"
	display_name = "ERROR"
	description = "This usually means something in the database has corrupted. If it doesn't go away automatically, inform Central Command for their techs to fix it ASAP(tm)"

/datum/techweb_node/proc/Initialize()
	for(var/id in prereq_ids)
		prereq_ids[id] = TRUE
	for(var/id in design_ids)
		design_ids[id] = TRUE
	for(var/id in unlock_ids)
		unlock_ids[id] = TRUE

/datum/techweb_node/Destroy()
	SSresearch.techweb_nodes -= id
	return ..()

/datum/techweb_node/proc/get_price(datum/techweb/host)
	if(host)
		var/list/actual_costs = research_costs
		if(host.boosted_nodes[id])
			var/list/L = host.boosted_nodes[id]
			for(var/i in L)
				if(actual_costs[i])
					actual_costs[i] -= L[i]
		return actual_costs
	else
		return research_costs

/datum/techweb_node/proc/price_display(datum/techweb/TN)
	return techweb_point_display_generic(get_price(TN))