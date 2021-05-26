GLOBAL_LIST_EMPTY(uplinks)

#define PEN_ROTATIONS 2

/datum/component/uplink
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/name = "syndicate uplink"
	var/active = FALSE
	var/lockable = TRUE
	var/locked = TRUE
	var/allow_restricted = TRUE
	var/telecrystals
	var/selected_cat
	var/owner = null
	var/datum/game_mode/gamemode
	//var/datum/uplink_purchase_log/purchase_log
	var/list/uplink_items
	var/hidden_crystals = 0
	var/unlock_note
	var/unlock_code
	var/failsafe_code

	var/list/previous_attempts

/datum/component/uplink/Initialize(_owner, _lockable = TRUE, _enabled = FALSE, datum/game_mode/_gamemode, starting_tc = 20)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE


	//RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/OnAttackBy)
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, .proc/interact)
	//if(istype(parent, /obj/item/implant))
	//	RegisterSignal(parent, COMSIG_IMPLANT_ACTIVATED, .proc/implant_activation)
	//	RegisterSignal(parent, COMSIG_IMPLANT_IMPLANTING, .proc/implanting)
	//	RegisterSignal(parent, COMSIG_IMPLANT_OTHER, .proc/old_implant)
	//	RegisterSignal(parent, COMSIG_IMPLANT_EXISTING_UPLINK, .proc/new_implant)
	//else if(istype(parent, /obj/item/pda))
	//	RegisterSignal(parent, COMSIG_PDA_CHANGE_RINGTONE, .proc/new_ringtone)
	//else if(istype(parent, /obj/item/radio))
	//	RegisterSignal(parent, COMSIG_RADIO_NEW_FREQUENCY, .proc/new_frequency)
	//else if(istype(parent, /obj/item/pen))
	//	RegisterSignal(parent, COMSIG_PEN_ROTATED, .proc/pen_rotation)

	GLOB.uplinks += src
	//uplink_items = get_uplink_items(gamemode, TRUE, allow_restricted)

	//if(_owner)
	//	owner = _owner
	//	LAZYINITLIST(GLOB.uplink_purchase_logs_by_key)
	//	if(GLOB.uplink_purchase_logs_by_key[owner])
	//		purchase_log = GLOB.uplink_purchase_logs_by_key[owner]
	//	else
	//		purchase_log = new(owner, src)
	lockable = _lockable
	active = _enabled
	gamemode = _gamemode
	telecrystals = starting_tc
	if(!lockable)
		active = TRUE
		locked = FALSE

	previous_attempts = list()

/datum/component/uplink/proc/interact(datum/source, mob/user)
	if(locked)
		return
	active = TRUE
	if(user)
		ui_interact(user)
	return COMPONENT_NO_INTERACT

/datum/component/uplink/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
									datum/tgui/master_ui = null, datum/ui_state/state = GLOB.inventory_state)
	active = TRUE
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "uplink", name, 450, 750, master_ui, state)
		ui.set_autoupdate(FALSE)
		ui.set_style("syndicate")
		ui.open()

/datum/component/uplink/ui_data(mob/user)
	if(!user.mind)
		return
	var/list/data = list()
	data["telecrystals"] = telecrystals
	data["lockable"] = lockable

	data["categories"] = list()
	for(var/category in uplink_items)
		var/list/cat = list(
			"name" = category,
			"items" = (category == selected_cat ? list() : null))
		if(category == selected_cat)
			for(var/item in uplink_items[category])
				var/datum/uplink_item/I = uplink_items[category][item]
				if(I.limited_stock == 0)
					continue
				if(I.restricted_roles.len)
					var/is_inaccessible = 1
					for(var/R in I.restricted_roles)
						if(R == user.mind.assigned_role)
							is_inaccessible = 0
					if(is_inaccessible)
						continue
				if(I.restricted_species)
					if(ishuman(user))
						var/is_inaccessible = TRUE
						var/mob/living/carbon/human/H = user
						for(var/F in I.restricted_species)
							if(F == H.dna.species.id)
								is_inaccessible = FALSE
								break
						if(is_inaccessible)
							continue
				cat["items"] += list(list(
					"name" = I.name,
					"cost" = I.cost,
					"desc" = I.desc,
				))
		data["categories"] += list(cat)
	return data

/datum/component/uplink/ui_act(action, params)
	if(!active)
		return

	switch(action)
		if("buy")
			var/item = params["item"]

			var/list/buyable_items = list()
			for(var/category in uplink_items)
				buyable_items += uplink_items[category]

			if(item in buyable_items)
				var/datum/uplink_item/I = buyable_items[item]
				MakePurchase(usr, I)
				. = TRUE
		if("lock")
			active = FALSE
			locked = TRUE
			telecrystals += hidden_crystals
			hidden_crystals = 0
			SStgui.close_uis(src)
		if("select")
			selected_cat = params["category"]
	return TRUE

/datum/component/uplink/proc/MakePurchase(mob/user, datum/uplink_item/U)
	if(!istype(U))
		return
	if (!user || user.incapacitated())
		return

	if(telecrystals < U.cost || U.limited_stock == 0)
		return
	telecrystals -= U.cost

	U.purchase(user, src)

	if(U.limited_stock > 0)
		U.limited_stock -= 1

	//SSblackbox.record_feedback("nested tally", "traitor_uplink_items_bought", 1, list("[initial(U.name)]", "[U.cost]"))
	return TRUE