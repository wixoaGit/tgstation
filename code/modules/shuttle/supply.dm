/obj/docking_port/mobile/supply
	name = "supply shuttle"
	id = "supply"
	callTime = 600

	dir = WEST
	port_direction = EAST
	width = 12
	dwidth = 5
	height = 7
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)


	var/export_categories = EXPORT_CARGO

/obj/docking_port/mobile/supply/register()
	. = ..()
	SSshuttle.supply = src

/obj/docking_port/mobile/supply/canMove()
	if(is_station_level(z))
		return check_blacklist(shuttle_areas)
	return ..()

/obj/docking_port/mobile/supply/proc/check_blacklist(areaInstances)
	//for(var/place in areaInstances)
	//	var/area/shuttle/shuttle_area = place
	//	for(var/trf in shuttle_area)
	//		var/turf/T = trf
	//		for(var/a in T.GetAllContents())
	//			if(is_type_in_typecache(a, GLOB.blacklisted_cargo_types))
	//				return FALSE
	return TRUE

/obj/docking_port/mobile/supply/request(obj/docking_port/stationary/S)
	if(mode != SHUTTLE_IDLE)
		return 2
	return ..()

/obj/docking_port/mobile/supply/initiate_docking()
	if(getDockedId() == "supply_away")
		buy()
	. = ..()
	if(. != DOCKING_SUCCESS)
		return
	if(getDockedId() == "supply_away")
		sell()

/obj/docking_port/mobile/supply/proc/buy()
	if(!SSshuttle.shoppinglist.len)
		return

	var/list/empty_turfs = list()
	//for(var/place in shuttle_areas)
	//	var/area/shuttle/shuttle_area = place
	//	for(var/turf/open/floor/T in shuttle_area)
	//		if(is_blocked_turf(T))
	//			continue
	//		empty_turfs += T
	//not_actual
	for(var/turf/open/floor/T in return_ordered_turfs(x, y, z, dir))
		if(is_blocked_turf(T) || !isfloorturf(T))
			continue
		empty_turfs += T

	var/value = 0
	var/purchases = 0
	for(var/datum/supply_order/SO in SSshuttle.shoppinglist)
		if(!empty_turfs.len)
			break
		var/price = SO.pack.cost
		var/datum/bank_account/D
		if(SO.paying_account)
			D = SO.paying_account
			price *= 1.1
		else
			D = SSeconomy.get_dep_account(ACCOUNT_CAR)
		if(D)
			if(!D.adjust_money(-price))
				if(SO.paying_account)
					D.bank_card_talk("Cargo order #[SO.id] rejected due to lack of funds. Credits required: [price]")
				continue

		if(SO.paying_account)
			D.bank_card_talk("Cargo order #[SO.id] has shipped. [price] credits have been charged to your bank account.")
			var/datum/bank_account/department/cargo = SSeconomy.get_dep_account(ACCOUNT_CAR)
			cargo.adjust_money(price - SO.pack.cost)
		value += SO.pack.cost
		SSshuttle.shoppinglist -= SO
		SSshuttle.orderhistory += SO

		SO.generate(pick_n_take(empty_turfs))
		//SSblackbox.record_feedback("nested tally", "cargo_imports", 1, list("[SO.pack.cost]", "[SO.pack.name]"))
		//investigate_log("Order #[SO.id] ([SO.pack.name], placed by [key_name(SO.orderer_ckey)]), paid by [D.account_holder] has shipped.", INVESTIGATE_CARGO)
		//if(SO.pack.dangerous)
		//	message_admins("\A [SO.pack.name] ordered by [ADMIN_LOOKUPFLW(SO.orderer_ckey)], paid by [D.account_holder] has shipped.")
		purchases++

	var/datum/bank_account/cargo_budget = SSeconomy.get_dep_account(ACCOUNT_CAR)
	//investigate_log("[purchases] orders in this shipment, worth [value] credits. [cargo_budget.account_balance] credits left.", INVESTIGATE_CARGO)

/obj/docking_port/mobile/supply/proc/sell()
	var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
	var/presale_points = D.account_balance

	if(!GLOB.exports_list.len)
		setupExports()

	var/msg = ""
	var/matched_bounty = FALSE

	var/datum/export_report/ex = new

	//for(var/place in shuttle_areas)
	//	var/area/shuttle/shuttle_area = place
	//	for(var/atom/movable/AM in shuttle_area)
	//		if(iscameramob(AM))
	//			continue
	//		if(bounty_ship_item_and_contents(AM, dry_run = FALSE))
	//			matched_bounty = TRUE
	//		if(!AM.anchored || istype(AM, /obj/mecha))
	//			export_item_and_contents(AM, export_categories , dry_run = FALSE, external_report = ex)
	//not_actual
	for(var/turf/open/floor/T in return_ordered_turfs(x, y, z, dir))
		for (var/atom/movable/AM in T)
			if(iscameramob(AM))
				continue
			//if(bounty_ship_item_and_contents(AM, dry_run = FALSE))
			//	matched_bounty = TRUE
			//if(!AM.anchored || istype(AM, /obj/mecha))
			if(!AM.anchored)//not_actual
				export_item_and_contents(AM, export_categories , dry_run = FALSE, external_report = ex)

	if(ex.exported_atoms)
		ex.exported_atoms += "."

	if(matched_bounty)
		msg += "Bounty items received. An update has been sent to all bounty consoles. "

	for(var/datum/export/E in ex.total_amount)
		var/export_text = E.total_printout(ex)
		if(!export_text)
			continue

		msg += export_text + "\n"
		D.adjust_money(ex.total_value[E])

	SSshuttle.centcom_message = msg
	//investigate_log("Shuttle contents sold for [D.account_balance - presale_points] credits. Contents: [ex.exported_atoms ? ex.exported_atoms.Join(",") + "." : "none."] Message: [SSshuttle.centcom_message || "none."]", INVESTIGATE_CARGO)