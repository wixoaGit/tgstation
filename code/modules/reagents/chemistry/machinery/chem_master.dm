#define PILL_STYLE_COUNT 22 //Update this if you add more pill icons or you die
#define RANDOM_PILL_STYLE 22

/obj/machinery/chem_master
	name = "ChemMaster 3000"
	desc = "Used to separate chemicals and distribute them in a variety of forms."
	density = TRUE
	layer = BELOW_OBJ_LAYER
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0"
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	resistance_flags = FIRE_PROOF | ACID_PROOF
	//circuit = /obj/item/circuitboard/machine/chem_master
	var/obj/item/reagent_containers/beaker = null
	//var/obj/item/storage/pill_bottle/bottle = null
	var/mode = 1
	var/condi = FALSE
	var/chosenPillStyle = 1
	var/screen = "home"
	//var/analyzeVars[0]
	var/analyzeVars = list()//not_actual
	var/useramount = 30

/obj/machinery/chem_master/Initialize()
	create_reagents(100)
	. = ..()

/obj/machinery/chem_master/Destroy()
	QDEL_NULL(beaker)
	//QDEL_NULL(bottle)
	return ..()

/obj/machinery/chem_master/RefreshParts()
	reagents.maximum_volume = 0
	for(var/obj/item/reagent_containers/glass/beaker/B in component_parts)
		reagents.maximum_volume += B.reagents.maximum_volume

/obj/machinery/chem_master/ex_act(severity, target)
	if(severity < 3)
		..()

/obj/machinery/chem_master/contents_explosion(severity, target)
	..()
	if(beaker)
		beaker.ex_act(severity, target)
	//if(bottle)
	//	bottle.ex_act(severity, target)

/obj/machinery/chem_master/handle_atom_del(atom/A)
	..()
	if(A == beaker)
		beaker = null
		reagents.clear_reagents()
		update_icon()
	//else if(A == bottle)
	//	bottle = null

/obj/machinery/chem_master/update_icon()
	cut_overlays()
	if (stat & BROKEN)
		add_overlay("waitlight")
	if(beaker)
		icon_state = "mixer1"
	else
		icon_state = "mixer0"

/obj/machinery/chem_master/attackby(obj/item/I, mob/user, params)
	//if(default_deconstruction_screwdriver(user, "mixer0_nopower", "mixer0", I))
	//	return

	//else if(default_deconstruction_crowbar(I))
	//	return

	//if(default_unfasten_wrench(user, I))
	//	return
	if(istype(I, /obj/item/reagent_containers) && !(I.item_flags & ABSTRACT) && I.is_open_container())
		. = TRUE
		if(panel_open)
			to_chat(user, "<span class='warning'>You can't use the [src.name] while its panel is opened!</span>")
			return
		var/obj/item/reagent_containers/B = I
		. = TRUE
		if(!user.transferItemToLoc(B, src))
			return
		replace_beaker(user, B)
		to_chat(user, "<span class='notice'>You add [B] to [src].</span>")
		updateUsrDialog()
		update_icon()
	//else if(!condi && istype(I, /obj/item/storage/pill_bottle))
	//	if(bottle)
	//		to_chat(user, "<span class='warning'>A pill bottle is already loaded into [src]!</span>")
	//		return
	//	if(!user.transferItemToLoc(I, src))
	//		return
	//	bottle = I
	//	to_chat(user, "<span class='notice'>You add [I] into the dispenser slot.</span>")
	//	updateUsrDialog()
	else
		return ..()

/obj/machinery/chem_master/AltClick(mob/living/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	replace_beaker(user)
	return

/obj/machinery/chem_master/proc/replace_beaker(mob/living/user, obj/item/reagent_containers/new_beaker)
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

/obj/machinery/chem_master/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
										datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		var/datum/asset/assets = get_asset_datum(/datum/asset/simple/pills)
		assets.send(user)

		ui = new(user, src, ui_key, "chem_master", name, 500, 550, master_ui, state)
		ui.open()

/obj/machinery/chem_master/ui_data(mob/user)
	var/list/data = list()
	data["isBeakerLoaded"] = beaker ? 1 : 0
	data["beakerCurrentVolume"] = beaker ? beaker.reagents.total_volume : null
	data["beakerMaxVolume"] = beaker ? beaker.volume : null
	data["mode"] = mode
	data["condi"] = condi
	data["screen"] = screen
	data["analyzeVars"] = analyzeVars
	data["chosenPillStyle"] = chosenPillStyle
	//data["isPillBottleLoaded"] = bottle ? 1 : 0
	data["isPillBottleLoaded"] = 0//not_actual
	//if(bottle)
	//	GET_COMPONENT_FROM(STRB, /datum/component/storage, bottle)
	//	data["pillBotContent"] = bottle.contents.len
	//	data["pillBotMaxContent"] = STRB.max_items

	//var/beakerContents[0]
	var/list/beakerContents = list()//not_actual
	if(beaker)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "id" = R.id, "volume" = R.volume)))
		data["beakerContents"] = beakerContents

	//var/bufferContents[0]
	var/list/bufferContents = list()//not_actual
	if(reagents.total_volume)
		for(var/datum/reagent/N in reagents.reagent_list)
			bufferContents.Add(list(list("name" = N.name, "id" = N.id, "volume" = N.volume)))
		data["bufferContents"] = bufferContents
	var/list/pillStyles = list()
	for (var/x in 1 to PILL_STYLE_COUNT)
		var/list/SL = list()
		SL["id"] = x
		pillStyles += list(SL)
	data["pillStyles"] = pillStyles
	return data

/obj/machinery/chem_master/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("eject")
			replace_beaker(usr)
			. = TRUE

		if("ejectp")
			//if(bottle)
			//	bottle.forceMove(drop_location())
			//	adjust_item_drop_location(bottle)
			//	bottle = null
			//	. = TRUE

		if("transferToBuffer")
			if(beaker)
				var/id = params["id"]
				var/amount = text2num(params["amount"])
				if (amount > 0)
					beaker.reagents.trans_id_to(src, id, amount)
					. = TRUE
				else if (amount == -1)
					useramount = input("Enter the Amount you want to transfer:", name, useramount) as num|null
					if (useramount > 0)
						beaker.reagents.trans_id_to(src, id, useramount)
						. = TRUE

		if("transferFromBuffer")
			var/id = params["id"]
			var/amount = text2num(params["amount"])
			if (amount > 0)
				if(mode)
					reagents.trans_id_to(beaker, id, amount)
					. = TRUE
				else
					reagents.remove_reagent(id, amount)
					. = TRUE

		if("toggleMode")
			mode = !mode
			. = TRUE

		if("createPill")
			var/many = params["many"]
			if(reagents.total_volume == 0)
				return
			//if(!condi)
			//	var/amount = 1
			//	var/vol_each = min(reagents.total_volume, 50)
			//	if(text2num(many))
			//		amount = CLAMP(round(input(usr, "Max 10. Buffer content will be split evenly.", "How many pills?", amount) as num|null), 0, 10)
			//		if(!amount)
			//			return
			//		vol_each = min(reagents.total_volume / amount, 50)
			//	var/name = stripped_input(usr,"Name:","Name your pill!", "[reagents.get_master_reagent_name()] ([vol_each]u)", MAX_NAME_LEN)
			//	if(!name || !reagents.total_volume || !src || QDELETED(src) || !usr.canUseTopic(src, !issilicon(usr)))
			//		return
			//	var/obj/item/reagent_containers/pill/P
			//	var/target_loc = drop_location()
			//	var/drop_threshold = INFINITY
			//	if(bottle)
			//		GET_COMPONENT_FROM(STRB, /datum/component/storage, bottle)
			//		if(STRB)
			//			drop_threshold = STRB.max_items - bottle.contents.len

			//	for(var/i = 0; i < amount; i++)
			//		if(i < drop_threshold)
			//			P = new(target_loc)
			//		else
			//			P = new(drop_location())
			//		P.name = trim("[name] pill")
			//		if(chosenPillStyle == RANDOM_PILL_STYLE)
			//			P.icon_state ="pill[rand(1,21)]"
			//		else
			//			P.icon_state = "pill[chosenPillStyle]"
			//		if(P.icon_state == "pill4")
			//			P.desc = "A tablet or capsule, but not just any, a red one, one taken by the ones not scared of knowledge, freedom, uncertainty and the brutal truths of reality."
			//		adjust_item_drop_location(P)
			//		reagents.trans_to(P,vol_each, transfered_by = usr)
			//else
			//	var/name = stripped_input(usr, "Name:", "Name your pack!", reagents.get_master_reagent_name(), MAX_NAME_LEN)
			//	if(!name || !reagents.total_volume || !src || QDELETED(src) || !usr.canUseTopic(src, !issilicon(usr)))
			//		return
			//	var/obj/item/reagent_containers/food/condiment/pack/P = new/obj/item/reagent_containers/food/condiment/pack(drop_location())

			//	P.originalname = name
			//	P.name = trim("[name] pack")
			//	P.desc = "A small condiment pack. The label says it contains [name]."
			//	reagents.trans_to(P,10, transfered_by = usr)
			. = TRUE

		if("pillStyle")
			var/id = text2num(params["id"])
			chosenPillStyle = id

		if("createPatch")
			var/many = params["many"]
			if(reagents.total_volume == 0)
				return
			//var/amount = 1
			//var/vol_each = min(reagents.total_volume, 40)
			//if(text2num(many))
			//	amount = CLAMP(round(input(usr, "Max 10. Buffer content will be split evenly.", "How many patches?", amount) as num|null), 0, 10)
			//	if(!amount)
			//		return
			//	vol_each = min(reagents.total_volume / amount, 40)
			//var/name = stripped_input(usr,"Name:","Name your patch!", "[reagents.get_master_reagent_name()] ([vol_each]u)", MAX_NAME_LEN)
			//if(!name || !reagents.total_volume || !src || QDELETED(src) || !usr.canUseTopic(src, !issilicon(usr)))
			//	return
			//var/obj/item/reagent_containers/pill/P

			//for(var/i = 0; i < amount; i++)
			//	P = new/obj/item/reagent_containers/pill/patch(drop_location())
			//	P.name = trim("[name] patch")
			//	adjust_item_drop_location(P)
			//	reagents.trans_to(P,vol_each, transfered_by = usr)
			. = TRUE

		if("createBottle")
			var/many = params["many"]
			if(reagents.total_volume == 0)
				return

			//if(condi)
			//	var/name = stripped_input(usr, "Name:","Name your bottle!", (reagents.total_volume ? reagents.get_master_reagent_name() : " "), MAX_NAME_LEN)
			//	if(!name || !reagents.total_volume || !src || QDELETED(src) || !usr.canUseTopic(src, !issilicon(usr)))
			//		return
			//	var/obj/item/reagent_containers/food/condiment/P = new(drop_location())
			//	P.originalname = name
			//	P.name = trim("[name] bottle")
			//	reagents.trans_to(P, P.volume, transfered_by = usr)
			//else
			//	var/amount_full = 0
			//	var/vol_part = min(reagents.total_volume, 30)
			//	if(text2num(many))
			//		amount_full = round(reagents.total_volume / 30)
			//		vol_part = reagents.total_volume % 30
			//	var/name = stripped_input(usr, "Name:","Name your bottle!", (reagents.total_volume ? reagents.get_master_reagent_name() : " "), MAX_NAME_LEN)
			//	if(!name || !reagents.total_volume || !src || QDELETED(src) || !usr.canUseTopic(src, !issilicon(usr)))
			//		return

			//	var/obj/item/reagent_containers/glass/bottle/P
			//	for(var/i = 0; i < amount_full; i++)
			//		P = new/obj/item/reagent_containers/glass/bottle(drop_location())
			//		P.name = trim("[name] bottle")
			//		adjust_item_drop_location(P)
			//		reagents.trans_to(P, 30, transfered_by = usr)

			//	if(vol_part)
			//		P = new/obj/item/reagent_containers/glass/bottle(drop_location())
			//		P.name = trim("[name] bottle")
			//		adjust_item_drop_location(P)
			//		reagents.trans_to(P, vol_part, transfered_by = usr)
			. = TRUE

		if("analyze")
			var/datum/reagent/R = GLOB.chemical_reagents_list[params["id"]]
			if(R)
				var/state = "Unknown"
				if(initial(R.reagent_state) == 1)
					state = "Solid"
				else if(initial(R.reagent_state) == 2)
					state = "Liquid"
				else if(initial(R.reagent_state) == 3)
					state = "Gas"
				var/const/P = 3 
				var/T = initial(R.metabolization_rate) * (60 / P)
				analyzeVars = list("name" = initial(R.name), "state" = state, "color" = initial(R.color), "description" = initial(R.description), "metaRate" = T, "overD" = initial(R.overdose_threshold), "addicD" = initial(R.addiction_threshold))
				screen = "analyze"
				return

		if("goScreen")
			screen = params["screen"]
			. = TRUE