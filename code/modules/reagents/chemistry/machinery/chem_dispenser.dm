/obj/machinery/chem_dispenser
	name = "chem dispenser"
	desc = "Creates and dispenses chemicals."
	density = TRUE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dispenser"
	use_power = IDLE_POWER_USE
	idle_power_usage = 40
	interaction_flags_machine = INTERACT_MACHINE_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OFFLINE
	var/cell_type = /obj/item/stock_parts/cell/high
	var/obj/item/stock_parts/cell/cell
	var/powerefficiency = 0.1
	var/amount = 30
	var/recharge_amount = 10
	var/recharge_counter = 0
	var/mutable_appearance/beaker_overlay
	var/working_state = "dispenser_working"
	var/has_panel_overlay = TRUE
	var/macroresolution = 1
	var/obj/item/reagent_containers/beaker = null
	var/list/dispensable_reagents = list(
		"hydrogen",
		"lithium",
		"carbon",
		"nitrogen",
		"oxygen",
		"fluorine",
		"sodium",
		"aluminium",
		"silicon",
		"phosphorus",
		"sulfur",
		"chlorine",
		"potassium",
		"iron",
		"copper",
		"mercury",
		"radium",
		"water",
		"ethanol",
		"sugar",
		"sacid",
		"welding_fuel",
		"silver",
		"iodine",
		"bromine",
		"stable_plasma"
	)
	var/list/upgrade_reagents = list(
		"oil",
		"ash",
		"acetone",
		"saltpetre",
		"ammonia",
		"diethylamine"
	)
	var/list/emagged_reagents = list(
		//"space_drugs",
		//"morphine",
		//"carpotoxin",
		//"mine_salve",
		//"toxin"
	)

	var/list/saved_recipes = list()

/obj/machinery/chem_dispenser/Initialize()
	. = ..()
	cell = new cell_type
	dispensable_reagents = sortList(dispensable_reagents)
	update_icon()

/obj/machinery/chem_dispenser/Destroy()
	QDEL_NULL(beaker)
	QDEL_NULL(cell)
	return ..()

/obj/machinery/chem_dispenser/examine(mob/user)
	..()
	if(panel_open)
		to_chat(user, "<span class='notice'>[src]'s maintenance hatch is open!</span>")
	if(in_range(user, src) || isobserver(user))
		to_chat(user, "<span class='notice'>The status display reads: <br>Recharging <b>[recharge_amount]</b> power units per interval.<br>Power efficiency increased by <b>[round((powerefficiency*1000)-100, 1)]%</b>.<br>Macro granularity at <b>[macroresolution]u</b>.<span>")

/obj/machinery/chem_dispenser/process()
	if (recharge_counter >= 4)
		if(!is_operational())
			return
		var/usedpower = cell.give(recharge_amount)
		if(usedpower)
			use_power(250*recharge_amount)
		recharge_counter = 0
		return
	recharge_counter++

/obj/machinery/chem_dispenser/proc/display_beaker()
	//..() There is no super proc?
	var/mutable_appearance/b_o = beaker_overlay || mutable_appearance(icon, "disp_beaker")
	b_o.pixel_y = -4
	b_o.pixel_x = -7
	return b_o

/obj/machinery/chem_dispenser/proc/work_animation()
	//if(working_state)
	//	flick(working_state,src)

/obj/machinery/chem_dispenser/update_icon()
	cut_overlays()
	if(has_panel_overlay && panel_open)
		add_overlay(mutable_appearance(icon, "[initial(icon_state)]_panel-o"))

	if(beaker)
		beaker_overlay = display_beaker()
		add_overlay(beaker_overlay)

/obj/machinery/chem_dispenser/contents_explosion(severity, target)
	..()
	if(beaker)
		beaker.ex_act(severity, target)

/obj/machinery/chem_dispenser/handle_atom_del(atom/A)
	..()
	if(A == beaker)
		beaker = null
		cut_overlays()

/obj/machinery/chem_dispenser/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
											datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "chem_dispenser", name, 565, 550, master_ui, state)
		//if(user.hallucinating())
		//	ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/chem_dispenser/ui_data(mob/user)
	var/data = list()
	data["amount"] = amount
	data["energy"] = cell.charge ? cell.charge * powerefficiency : "0"
	data["maxEnergy"] = cell.maxcharge * powerefficiency
	data["isBeakerLoaded"] = beaker ? 1 : 0

	//var/beakerContents[0]
	var/list/beakerContents = list()//not_actual
	var/beakerCurrentVolume = 0
	if(beaker && beaker.reagents && beaker.reagents.reagent_list.len)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "volume" = R.volume)))
			beakerCurrentVolume += R.volume
	data["beakerContents"] = beakerContents

	if (beaker)
		data["beakerCurrentVolume"] = beakerCurrentVolume
		data["beakerMaxVolume"] = beaker.volume
		data["beakerTransferAmounts"] = beaker.possible_transfer_amounts
	else
		data["beakerCurrentVolume"] = null
		data["beakerMaxVolume"] = null
		data["beakerTransferAmounts"] = null

	//var/chemicals[0]
	var/list/chemicals = list()//not_actual
	//var/recipes[0]
	var/list/recipes = list()//not_actual
	var/is_hallucinating = FALSE
	//if(user.hallucinating())
	//	is_hallucinating = TRUE
	for(var/re in dispensable_reagents)
		var/datum/reagent/temp = GLOB.chemical_reagents_list[re]
		if(temp)
			var/chemname = temp.name
			//if(is_hallucinating && prob(5))
			//	chemname = "[pick_list_replacements("hallucination.json", "chemicals")]"
			chemicals.Add(list(list("title" = chemname, "id" = temp.id)))
	for(var/recipe in saved_recipes)
		recipes.Add(list(recipe))
	data["chemicals"] = chemicals
	data["recipes"] = recipes
	return data

/obj/machinery/chem_dispenser/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("amount")
			if(!is_operational() || QDELETED(beaker))
				return
			var/target = text2num(params["target"])
			if(target in beaker.possible_transfer_amounts)
				amount = target
				work_animation()
				. = TRUE
		if("dispense")
			//if(!is_operational() || QDELETED(cell))
			//	return
			var/reagent = params["reagent"]
			if(beaker && dispensable_reagents.Find(reagent))
				var/datum/reagents/R = beaker.reagents
				var/free = R.maximum_volume - R.total_volume
				//var/actual = min(amount, (cell.charge * powerefficiency)*10, free)
				var/actual = amount//not_actual

				if(!cell.use(actual / powerefficiency))
					say("Not enough energy to complete operation!")
					return
				R.add_reagent(reagent, actual)

				work_animation()
				. = TRUE
		if("remove")
			if(!is_operational())
				return
			var/amount = text2num(params["amount"])
			if(beaker && amount in beaker.possible_transfer_amounts)
				beaker.reagents.remove_all(amount)
				work_animation()
				. = TRUE
		if("eject")
			replace_beaker(usr)
			. = TRUE
		//if("dispense_recipe")
		//	if(!is_operational() || QDELETED(cell))
		//		return
		//	var/recipe_to_use = params["recipe"]
		//	var/list/chemicals_to_dispense = process_recipe_list(recipe_to_use)
		//	var/res = macroresolution
		//	for(var/key in chemicals_to_dispense)
		//		var/list/keysplit = splittext(key," ")
		//		var/r_id = keysplit[1]
		//		if(beaker && dispensable_reagents.Find(r_id))
		//			var/datum/reagents/R = beaker.reagents
		//			var/free = R.maximum_volume - R.total_volume
		//			var/actual = min(max(chemicals_to_dispense[key], res), (cell.charge * powerefficiency)*10, free)
		//			if(actual)
		//				if(!cell.use(actual / powerefficiency))
		//					say("Not enough energy to complete operation!")
		//					return
		//				R.add_reagent(r_id, actual)
		//				work_animation()
		//if("clear_recipes")
		//	if(!is_operational())
		//		return
		//	var/yesno = alert("Clear all recipes?",, "Yes","No")
		//	if(yesno == "Yes")
		//		saved_recipes = list()
		//if("add_recipe")
		//	if(!is_operational())
		//		return
		//	var/name = stripped_input(usr,"Name","What do you want to name this recipe?", "Recipe", MAX_NAME_LEN)
		//	var/recipe = stripped_input(usr,"Recipe","Insert recipe with chem IDs")
		//	if(!usr.canUseTopic(src, !issilicon(usr)))
		//		return
		//	if(name && recipe)
		//		var/list/first_process = splittext(recipe, ";")
		//		if(!LAZYLEN(first_process))
		//			return
		//		var/res = macroresolution
		//		var/resmismatch = FALSE
		//		for(var/reagents in first_process)
		//			var/list/reagent = splittext(reagents, "=")
		//			if(dispensable_reagents.Find(reagent[1]))
		//				if (!resmismatch && !check_macro_part(reagents, res))
		//					resmismatch = TRUE
		//				continue
		//			else
		//				var/chemid = reagent[1]
		//				visible_message("<span class='warning'>[src] buzzes.</span>", "<span class='italics'>You hear a faint buzz.</span>")
		//				to_chat(usr, "<span class ='danger'>[src] cannot find Chemical ID: <b>[chemid]</b>!</span>")
		//				playsound(src, 'sound/machines/buzz-two.ogg', 50, 1)
		//				return
		//		if (resmismatch && alert("[src] is not yet capable of replicating this recipe with the precision it needs, do you want to save it anyway?",, "Yes","No") == "No")
		//			return
		//		saved_recipes += list(list("recipe_name" = name, "contents" = recipe))

/obj/machinery/chem_dispenser/attackby(obj/item/I, mob/user, params)
	//if(default_unfasten_wrench(user, I))
	//	return
	//if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
	//	update_icon()
	//	return
	//if(default_deconstruction_crowbar(I))
	//	return
	if(istype(I, /obj/item/reagent_containers) && !(I.item_flags & ABSTRACT) && I.is_open_container())
		var/obj/item/reagent_containers/B = I
		. = TRUE
		if(!user.transferItemToLoc(B, src))
			return
		replace_beaker(user, B)
		to_chat(user, "<span class='notice'>You add [B] to [src].</span>")
		updateUsrDialog()
		update_icon()
	//else if(user.a_intent != INTENT_HARM && !istype(I, /obj/item/card/emag))
	else if(user.a_intent != INTENT_HARM)//not_actual
		to_chat(user, "<span class='warning'>You can't load [I] into [src]!</span>")
		return ..()
	else
		return ..()

/obj/machinery/chem_dispenser/proc/replace_beaker(mob/living/user, obj/item/reagent_containers/new_beaker)
	if(beaker)
		beaker.forceMove(drop_location())
		if(user && Adjacent(user) && !issiliconoradminghost(user))
			user.put_in_hands(beaker)
	if(new_beaker)
		beaker = new_beaker
	else
		beaker = null
	update_icon()
	return TRUE

/obj/machinery/chem_dispenser/fullupgrade
	desc = "Creates and dispenses chemicals. This model has had its safeties shorted out."
	obj_flags = CAN_BE_HIT | EMAGGED
	flags_1 = NODECONSTRUCT_1

/obj/machinery/chem_dispenser/fullupgrade/Initialize()
	. = ..()
	dispensable_reagents |= emagged_reagents
	//component_parts = list()
	//component_parts += new /obj/item/circuitboard/machine/chem_dispenser(null)
	//component_parts += new /obj/item/stock_parts/matter_bin/bluespace(null)
	//component_parts += new /obj/item/stock_parts/matter_bin/bluespace(null)
	//component_parts += new /obj/item/stock_parts/capacitor/quadratic(null)
	//component_parts += new /obj/item/stock_parts/manipulator/femto(null)
	//component_parts += new /obj/item/stack/sheet/glass(null)
	//component_parts += new /obj/item/stock_parts/cell/bluespace(null)
	RefreshParts()
