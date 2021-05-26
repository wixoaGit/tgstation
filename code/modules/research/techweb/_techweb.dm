/datum/techweb
	var/list/researched_nodes = list()
	var/list/visible_nodes = list()
	var/list/available_nodes = list()
	var/list/researched_designs = list()
	var/list/custom_designs = list()
	var/list/boosted_nodes = list()
	var/list/hidden_nodes = list()
	var/list/deconstructed_items = list()
	var/list/research_points = list()
	var/list/obj/machinery/computer/rdconsole/consoles_accessing = list()
	var/id = "generic"
	var/list/research_logs = list()
	var/largest_bomb_value = 0
	var/organization = "Third-Party"
	var/list/last_bitcoins = list()
	var/list/discovered_mutations = list()
	var/list/tiers = list()

/datum/techweb/New()
	SSresearch.techwebs += src
	for(var/i in SSresearch.techweb_nodes_starting)
		var/datum/techweb_node/DN = SSresearch.techweb_node_by_id(i)
		research_node(DN, TRUE, FALSE, FALSE)
	hidden_nodes = SSresearch.techweb_nodes_hidden.Copy()
	return ..()

/datum/techweb/admin
	id = "ADMIN"
	organization = "CentCom"

/datum/techweb/admin/New()
	. = ..()
	for(var/i in SSresearch.techweb_nodes)
		var/datum/techweb_node/TN = SSresearch.techweb_nodes[i]
		research_node(TN, TRUE, TRUE, FALSE)
	for(var/i in SSresearch.point_types)
		research_points[i] = INFINITY
	hidden_nodes = list()

/datum/techweb/science
	id = "SCIENCE"
	organization = "Nanotrasen"

/datum/techweb/Destroy()
	researched_nodes = null
	researched_designs = null
	available_nodes = null
	visible_nodes = null
	custom_designs = null
	SSresearch.techwebs -= src
	return ..()

/datum/techweb/proc/recalculate_nodes(recalculate_designs = FALSE, wipe_custom_designs = FALSE)
	var/list/datum/techweb_node/processing = list()
	for(var/id in researched_nodes)
		processing[id] = TRUE
	for(var/id in visible_nodes)
		processing[id] = TRUE
	for(var/id in available_nodes)
		processing[id] = TRUE
	if(recalculate_designs)
		researched_designs = custom_designs.Copy()
		if(wipe_custom_designs)
			custom_designs = list()
	for(var/id in processing)
		update_node_status(SSresearch.techweb_node_by_id(id), FALSE)
		CHECK_TICK
	for(var/v in consoles_accessing)
		var/obj/machinery/computer/rdconsole/V = v
		V.rescan_views()
		V.updateUsrDialog()

/datum/techweb/proc/add_point_list(list/pointlist)
	for(var/i in pointlist)
		if(SSresearch.point_types[i] && pointlist[i] > 0)
			research_points[i] += pointlist[i]

/datum/techweb/proc/remove_point_list(list/pointlist)
	for(var/i in pointlist)
		if(SSresearch.point_types[i] && pointlist[i] > 0)
			research_points[i] = max(0, research_points[i] - pointlist[i])

/datum/techweb/proc/copy_research_to(datum/techweb/receiver, unlock_hidden = TRUE)
	for(var/i in researched_nodes)
		CHECK_TICK
		receiver.research_node_id(i, TRUE, FALSE, FALSE)
	for(var/i in researched_designs)
		CHECK_TICK
		receiver.add_design_by_id(i)
	if(unlock_hidden)
		for(var/i in receiver.hidden_nodes)
			CHECK_TICK
			if(!hidden_nodes[i])
				receiver.hidden_nodes -= i
	receiver.recalculate_nodes()

/datum/techweb/proc/add_design_by_id(id, custom = FALSE)
	return add_design(SSresearch.techweb_design_by_id(id), custom)

/datum/techweb/proc/add_design(datum/design/design, custom = FALSE)
	if(!istype(design))
		return FALSE
	researched_designs[design.id] = TRUE
	if(custom)
		custom_designs[design.id] = TRUE
	return TRUE

/datum/techweb/proc/remove_design(datum/design/design, custom = FALSE)
	if(!istype(design))
		return FALSE
	if(custom_designs[design.id] && !custom)
		return FALSE
	custom_designs -= design.id
	researched_designs -= design.id
	return TRUE

/datum/techweb/proc/can_afford(list/pointlist)
	for(var/i in pointlist)
		if(research_points[i] < pointlist[i])
			return FALSE
	return TRUE

/datum/techweb/proc/research_node_id(id, force, auto_update_points, get_that_dosh_id)
	return research_node(SSresearch.techweb_node_by_id(id), force, auto_update_points, get_that_dosh_id)

/datum/techweb/proc/research_node(datum/techweb_node/node, force = FALSE, auto_adjust_cost = TRUE, get_that_dosh = TRUE)
	if(!istype(node))
		return FALSE
	update_node_status(node)
	if(!force)
		if(!available_nodes[node.id] || (auto_adjust_cost && (!can_afford(node.get_price(src)))))
			return FALSE
	if(auto_adjust_cost)
		remove_point_list(node.get_price(src))
	researched_nodes[node.id] = TRUE
	for(var/id in node.unlock_ids)
		visible_nodes[id] = TRUE
		update_node_status(SSresearch.techweb_node_by_id(id))
	for(var/id in node.design_ids)
		add_design_by_id(id)
	update_node_status(node)
	//if(get_that_dosh)
	//	var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_SCI)
	//	if(D)
	//		D.adjust_money(SSeconomy.techweb_bounty)
	return TRUE

/datum/techweb/proc/update_tiers(datum/techweb_node/base)
	var/list/current = list(base)
	while (current.len)
		var/list/next = list()
		for (var/node_ in current)
			var/datum/techweb_node/node = node_
			var/tier = 0
			if (!researched_nodes[node.id])
				for (var/id in node.prereq_ids)
					var/prereq_tier = tiers[id]
					tier = max(tier, prereq_tier + 1)

			if (tier != tiers[node.id])
				tiers[node.id] = tier
				for (var/id in node.unlock_ids)
					next += SSresearch.techweb_node_by_id(id)
		current = next

/datum/techweb/proc/update_node_status(datum/techweb_node/node, autoupdate_consoles = TRUE)
	var/researched = FALSE
	var/available = FALSE
	var/visible = FALSE
	if(researched_nodes[node.id])
		researched = TRUE
	var/needed = node.prereq_ids.len
	for(var/id in node.prereq_ids)
		if(researched_nodes[id])
			visible = TRUE
			needed--
	if(!needed)
		available = TRUE
	researched_nodes -= node.id
	available_nodes -= node.id
	visible_nodes -= node.id
	if(hidden_nodes[node.id])
		return
	if(researched)
		researched_nodes[node.id] = TRUE
		for(var/id in node.design_ids)
			add_design(SSresearch.techweb_design_by_id(id))
	else
		if(available)
			available_nodes[node.id] = TRUE
		else
			if(visible)
				visible_nodes[node.id] = TRUE
	update_tiers(node)
	if(autoupdate_consoles)
		for(var/v in consoles_accessing)
			var/obj/machinery/computer/rdconsole/V = v
			V.rescan_views()
			V.updateUsrDialog()

/datum/techweb/proc/isDesignResearchedID(id)
	return researched_designs[id]? SSresearch.techweb_design_by_id(id) : FALSE

/datum/techweb/specialized
	var/allowed_buildtypes = ALL

/datum/techweb/specialized/add_design(datum/design/D)
	if(!(D.build_type & allowed_buildtypes))
		return FALSE
	return ..()

/datum/techweb/specialized/autounlocking
	var/design_autounlock_buildtypes = NONE
	var/design_autounlock_categories = list("initial")
	var/node_autounlock_ids = list()

/datum/techweb/specialized/autounlocking/New()
	..()
	autounlock()

/datum/techweb/specialized/autounlocking/proc/autounlock()
	for(var/id in node_autounlock_ids)
		research_node_id(id, TRUE, FALSE, FALSE)
	for(var/id in SSresearch.techweb_designs)
		var/datum/design/D = SSresearch.techweb_design_by_id(id)
		if(D.build_type & design_autounlock_buildtypes)
			for(var/i in D.category)
				if(i in design_autounlock_categories)
					add_design_by_id(D.id)
					break

/datum/techweb/specialized/autounlocking/autolathe
	design_autounlock_buildtypes = AUTOLATHE
	allowed_buildtypes = AUTOLATHE