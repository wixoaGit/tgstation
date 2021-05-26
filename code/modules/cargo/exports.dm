/datum/export_report
	var/list/exported_atoms = list()
	var/list/total_amount = list()
	var/list/total_value = list()

/proc/export_item_and_contents(atom/movable/AM, allowed_categories = EXPORT_CARGO, apply_elastic = TRUE, delete_unsold = TRUE, dry_run=FALSE, datum/export_report/external_report)
	if(!GLOB.exports_list.len)
		setupExports()

	var/list/contents = AM.GetAllContents()
	
	var/datum/export_report/report = external_report
	if(!report)
		report = new

	for(var/i in reverseRange(contents))
		var/atom/movable/thing = i
		var/sold = FALSE
		for(var/datum/export/E in GLOB.exports_list)
			if(!E)
				continue
			if(E.applies_to(thing, allowed_categories, apply_elastic))
				sold = E.sell_object(thing, report, dry_run, allowed_categories , apply_elastic)
				report.exported_atoms += " [thing.name]"
				break
		if(!dry_run && (sold || delete_unsold))
			//if(ismob(thing))
			//	thing.investigate_log("deleted through cargo export",INVESTIGATE_CARGO)
			qdel(thing)

	return report

/datum/export
	var/unit_name = ""
	var/message = ""
	var/cost = 100
	var/k_elasticity = 1/30
	var/list/export_types = list()
	var/include_subtypes = TRUE
	var/list/exclude_types = list()

	var/init_cost

	var/export_category = EXPORT_CARGO

/datum/export/New()
	..()
	SSprocessing.processing += src
	init_cost = cost
	export_types = typecacheof(export_types)
	exclude_types = typecacheof(exclude_types)

/datum/export/Destroy()
	SSprocessing.processing -= src
	return ..()

/datum/export/process()
	..()
	cost *= NUM_E**(k_elasticity * (1/30))
	if(cost > init_cost)
		cost = init_cost

/datum/export/proc/get_cost(obj/O, allowed_categories = NONE, apply_elastic = TRUE)
	var/amount = get_amount(O)
	if(apply_elastic)
		if(k_elasticity!=0)
			return round((cost/k_elasticity) * (1 - NUM_E**(-1 * k_elasticity * amount)))
		else
			return round(cost * amount)
	else
		return round(init_cost * amount)

/datum/export/proc/get_amount(obj/O)
	return 1

/datum/export/proc/applies_to(obj/O, allowed_categories = NONE, apply_elastic = TRUE)
	if((allowed_categories & export_category) != export_category)
		return FALSE
	if(!include_subtypes && !(O.type in export_types))
		return FALSE
	if(include_subtypes && (!is_type_in_typecache(O, export_types) || is_type_in_typecache(O, exclude_types)))
		return FALSE
	if(!get_cost(O, allowed_categories , apply_elastic))
		return FALSE
	if(O.flags_1 & HOLOGRAM_1)
		return FALSE
	return TRUE

/datum/export/proc/sell_object(obj/O, datum/export_report/report, dry_run = TRUE, allowed_categories = EXPORT_CARGO , apply_elastic = TRUE)
	var/the_cost = get_cost(O, allowed_categories , apply_elastic)
	var/amount = get_amount(O)

	if(amount <=0 || the_cost <=0)
		return FALSE
	
	report.total_value[src] += the_cost
	
	if(istype(O, /datum/export/material))
		report.total_amount[src] += amount*MINERAL_MATERIAL_AMOUNT
	else
		report.total_amount[src] += amount

	if(!dry_run)
		if(apply_elastic)
			cost *= NUM_E**(-1*k_elasticity*amount)
		//SSblackbox.record_feedback("nested tally", "export_sold_cost", 1, list("[O.type]", "[the_cost]"))
	return TRUE

/datum/export/proc/total_printout(datum/export_report/ex, notes = TRUE)
	if(!ex.total_amount[src] || !ex.total_value[src])
		return ""

	var/total_value = ex.total_value[src]
	var/total_amount = ex.total_amount[src]
	
	var/msg = "[total_value] credits: Received [total_amount] "
	if(total_value > 0)
		msg = "+" + msg

	if(unit_name)
		msg += unit_name
		if(total_amount > 1)
			msg += "s"
		if(message)
			msg += " "

	if(message)
		msg += message

	msg += "."
	return msg

GLOBAL_LIST_EMPTY(exports_list)

/proc/setupExports()
	for(var/subtype in subtypesof(/datum/export))
		var/datum/export/E = new subtype
		if(E.export_types && E.export_types.len)
			GLOB.exports_list += E