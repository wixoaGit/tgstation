/obj/machinery/suit_storage_unit
	name = "suit storage unit"
	desc = "An industrial unit made to hold and decontaminate irradiated equipment. It comes with a built-in UV cauterization mechanism. A small warning label advises that organic matter should not be placed into the unit."
	icon = 'icons/obj/machines/suit_storage.dmi'
	icon_state = "close"
	density = TRUE
	max_integrity = 250

	var/obj/item/clothing/suit/space/suit = null
	var/obj/item/clothing/head/helmet/space/helmet = null
	var/obj/item/clothing/mask/mask = null
	var/obj/item/storage = null

	var/suit_type = null
	var/helmet_type = null
	var/mask_type = null
	var/storage_type = null

	state_open = FALSE
	var/locked = FALSE
	panel_open = FALSE
	var/safeties = TRUE

	var/uv = FALSE
	var/uv_super = FALSE
	var/uv_cycles = 6
	var/message_cooldown
	var/breakout_time = 300

/obj/machinery/suit_storage_unit/captain
	suit_type = /obj/item/clothing/suit/space/hardsuit/swat/captain
	mask_type = /obj/item/clothing/mask/gas/sechailer
	//storage_type = /obj/item/tank/jetpack/oxygen/captain

/obj/machinery/suit_storage_unit/ce
	suit_type = /obj/item/clothing/suit/space/hardsuit/engine/elite
	mask_type = /obj/item/clothing/mask/breath
	//storage_type= /obj/item/clothing/shoes/magboots/advance

/obj/machinery/suit_storage_unit/open
	state_open = TRUE
	density = FALSE

/obj/machinery/suit_storage_unit/Initialize()
	. = ..()
	//wires = new /datum/wires/suit_storage_unit(src)
	if(suit_type)
		suit = new suit_type(src)
	if(helmet_type)
		helmet = new helmet_type(src)
	if(mask_type)
		mask = new mask_type(src)
	if(storage_type)
		storage = new storage_type(src)
	update_icon()

/obj/machinery/suit_storage_unit/Destroy()
	QDEL_NULL(suit)
	QDEL_NULL(helmet)
	QDEL_NULL(mask)
	QDEL_NULL(storage)
	return ..()

/obj/machinery/suit_storage_unit/update_icon()
	cut_overlays()

	if(uv)
		if(uv_super)
			add_overlay("super")
		else if(occupant)
			add_overlay("uvhuman")
		else
			add_overlay("uv")
	else if(state_open)
		if(stat & BROKEN)
			add_overlay("broken")
		else
			add_overlay("open")
			if(suit)
				add_overlay("suit")
			if(helmet)
				add_overlay("helm")
			if(storage)
				add_overlay("storage")
	else if(occupant)
		add_overlay("human")

/obj/machinery/suit_storage_unit/power_change()
	..()
	if(!is_operational() && state_open)
		open_machine()
		dump_contents()
	update_icon()

/obj/machinery/suit_storage_unit/proc/dump_contents()
	dropContents()
	helmet = null
	suit = null
	mask = null
	storage = null
	occupant = null

/obj/machinery/suit_storage_unit/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		open_machine()
		dump_contents()
		new /obj/item/stack/sheet/metal (loc, 2)
	qdel(src)

/obj/machinery/suit_storage_unit/proc/cook()
	//if(uv_cycles)
	//	uv_cycles--
	//	uv = TRUE
	//	locked = TRUE
	//	update_icon()
	//	if(occupant)
	//		var/mob/living/mob_occupant = occupant
	//		if(uv_super)
	//			mob_occupant.adjustFireLoss(rand(20, 36))
	//		else
	//			mob_occupant.adjustFireLoss(rand(10, 16))
	//		mob_occupant.emote("scream")
	//	addtimer(CALLBACK(src, .proc/cook), 50)
	//else
	//	uv_cycles = initial(uv_cycles)
	//	uv = FALSE
	//	locked = FALSE
	//	if(uv_super)
	//		visible_message("<span class='warning'>[src]'s door creaks open with a loud whining noise. A cloud of foul black smoke escapes from its chamber.</span>")
	//		playsound(src, 'sound/machines/airlock_alien_prying.ogg', 50, 1)
	//		helmet = null
	//		qdel(helmet)
	//		suit = null
	//		qdel(suit)
	//		mask = null
	//		qdel(mask)
	//		storage = null
	//		qdel(storage)
	//		wires.cut_all()
	//	else
	//		if(!occupant)
	//			visible_message("<span class='notice'>[src]'s door slides open. The glowing yellow lights dim to a gentle green.</span>")
	//		else
	//			visible_message("<span class='warning'>[src]'s door slides open, barraging you with the nauseating smell of charred flesh.</span>")
	//		playsound(src, 'sound/machines/airlockclose.ogg', 25, 1)
	//		for(var/obj/item/I in src)
	//			SEND_SIGNAL(I, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRONG)
	//			var/datum/component/radioactive/contamination = I.GetComponent(/datum/component/radioactive)
	//			if(contamination)
	//				qdel(contamination)
	//	open_machine(FALSE)
	//	if(occupant)
	//		dump_contents()

/obj/machinery/suit_storage_unit/relaymove(mob/user)
	if(locked)
		if(message_cooldown <= world.time)
			message_cooldown = world.time + 50
			to_chat(user, "<span class='warning'>[src]'s door won't budge!</span>")
		return
	open_machine()
	dump_contents()

/obj/machinery/suit_storage_unit/attackby(obj/item/I, mob/user, params)
	if(state_open && is_operational())
		if(istype(I, /obj/item/clothing/suit))
			if(suit)
				to_chat(user, "<span class='warning'>The unit already contains a suit!.</span>")
				return
			if(!user.transferItemToLoc(I, src))
				return
			suit = I
		else if(istype(I, /obj/item/clothing/head))
			if(helmet)
				to_chat(user, "<span class='warning'>The unit already contains a helmet!</span>")
				return
			if(!user.transferItemToLoc(I, src))
				return
			helmet = I
		else if(istype(I, /obj/item/clothing/mask))
			if(mask)
				to_chat(user, "<span class='warning'>The unit already contains a mask!</span>")
				return
			if(!user.transferItemToLoc(I, src))
				return
			mask = I
		else
			if(storage)
				to_chat(user, "<span class='warning'>The auxiliary storage compartment is full!</span>")
				return
			if(!user.transferItemToLoc(I, src))
				return
			storage = I

		visible_message("<span class='notice'>[user] inserts [I] into [src]</span>", "<span class='notice'>You load [I] into [src].</span>")
		update_icon()
		return

	//if(panel_open && is_wire_tool(I))
	//	wires.interact(user)
	//	return
	if(!state_open)
		if(default_deconstruction_screwdriver(user, "panel", "close", I))
			return
	if(default_pry_open(I))
		dump_contents()
		return

	return ..()

/obj/machinery/suit_storage_unit/default_pry_open(obj/item/I)
	. = !(state_open || panel_open || is_operational() || locked || (flags_1 & NODECONSTRUCT_1)) && I.tool_behaviour == TOOL_CROWBAR
	if(.)
		I.play_tool_sound(src, 50)
		visible_message("<span class='notice'>[usr] pries open \the [src].</span>", "<span class='notice'>You pry open \the [src].</span>")
		open_machine()

/obj/machinery/suit_storage_unit/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
										datum/tgui/master_ui = null, datum/ui_state/state = GLOB.notcontained_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "suit_storage_unit", name, 400, 305, master_ui, state)
		ui.open()

/obj/machinery/suit_storage_unit/ui_data()
	var/list/data = list()
	data["locked"] = locked
	data["open"] = state_open
	data["safeties"] = safeties
	data["uv_active"] = uv
	data["uv_super"] = uv_super
	if(helmet)
		data["helmet"] = helmet.name
	if(suit)
		data["suit"] = suit.name
	if(mask)
		data["mask"] = mask.name
	if(storage)
		data["storage"] = storage.name
	if(occupant)
		data["occupied"] = 1
	return data

/obj/machinery/suit_storage_unit/ui_act(action, params)
	if(..() || uv)
		return
	switch(action)
		if("door")
			if(state_open)
				close_machine()
			else
				open_machine(0)
				if(occupant)
					dump_contents()
			. = TRUE
		if("lock")
			if(state_open)
				return
			locked = !locked
			. = TRUE
		if("uv")
			if(occupant && safeties)
				return
			else if(!helmet && !mask && !suit && !storage && !occupant)
				return
			else
				if(occupant)
					var/mob/living/mob_occupant = occupant
					to_chat(mob_occupant, "<span class='userdanger'>[src]'s confines grow warm, then hot, then scorching. You're being burned [!mob_occupant.stat ? "alive" : "away"]!</span>")
				cook()
				. = TRUE
		if("dispense")
			if(!state_open)
				return

			//var/static/list/valid_items = list("helmet", "suit", "mask", "storage")
			var/list/valid_items = list("helmet", "suit", "mask", "storage")//not_actual
			var/item_name = params["item"]
			if(item_name in valid_items)
				var/obj/item/I = vars[item_name]
				vars[item_name] = null
				if(I)
					I.forceMove(loc)
			. = TRUE
	update_icon()