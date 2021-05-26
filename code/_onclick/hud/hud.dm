GLOBAL_LIST_INIT(available_ui_styles, list(
	"Midnight" = 'icons/mob/screen_midnight.dmi',
	"Retro" = 'icons/mob/screen_retro.dmi',
	"Plasmafire" = 'icons/mob/screen_plasmafire.dmi',
	"Slimecore" = 'icons/mob/screen_slimecore.dmi',
	"Operative" = 'icons/mob/screen_operative.dmi',
	"Clockwork" = 'icons/mob/screen_clockwork.dmi'
))

/datum/hud
	var/mob/mymob
	
	var/hud_shown = TRUE
	var/hud_version = HUD_STYLE_STANDARD
	var/inventory_shown = FALSE
	var/hotkey_ui_hidden = FALSE
	
	var/obj/screen/action_intent
	var/obj/screen/zone_select
	var/obj/screen/pull_icon
	var/obj/screen/rest_icon
	var/obj/screen/throw_icon
	
	var/list/static_inventory = list()
	var/list/toggleable_inventory = list()
	var/list/obj/screen/hotkeybuttons = list()
	var/list/infodisplay = list()
	//var/list/inv_slots[SLOTS_AMT]
	var/list/inv_slots = new /list(SLOTS_AMT)//not_actual
	var/list/hand_slots

	var/obj/screen/movable/action_button/hide_toggle/hide_actions_toggle
	var/action_buttons_hidden = FALSE
	
	var/obj/screen/healths
	var/obj/screen/healthdoll
	var/obj/screen/internals
	
	var/ui_style

/datum/hud/New(mob/owner)
	mymob = owner
	
	if (!ui_style)
		//ui_style = ui_style2icon(owner.client && owner.client.prefs && owner.client.prefs.UI_style)
		ui_style = GLOB.available_ui_styles["Midnight"]//not_actual

	hide_actions_toggle = new
	hide_actions_toggle.InitialiseIcon(src)
	//if(mymob.client)
	//	hide_actions_toggle.locked = mymob.client.prefs.buttons_locked

	hand_slots = list()

	//for(var/mytype in subtypesof(/obj/screen/plane_master))
	//	var/obj/screen/plane_master/instance = new mytype()
	//	plane_masters["[instance.plane]"] = instance
	//	instance.backdrop(mymob)

/datum/hud/Destroy()
	if(mymob.hud_used == src)
		mymob.hud_used = null

	QDEL_NULL(hide_actions_toggle)
	//QDEL_NULL(module_store_icon)
	QDEL_LIST(static_inventory)

	inv_slots.Cut()
	action_intent = null
	zone_select = null
	pull_icon = null

	QDEL_LIST(toggleable_inventory)
	QDEL_LIST(hotkeybuttons)
	throw_icon = null
	QDEL_LIST(infodisplay)

	healths = null
	healthdoll = null
	internals = null
	//lingchemdisplay = null
	//devilsouldisplay = null
	//lingstingdisplay = null
	//blobpwrdisplay = null
	//alien_plasma_display = null
	//alien_queen_finder = null

	//QDEL_LIST_ASSOC_VAL(plane_masters)
	//QDEL_LIST(screenoverlays)
	mymob = null

	return ..()

/mob
	var/hud_type = /datum/hud

/mob/proc/create_mob_hud()
	if (!client || hud_used)
		return
	hud_used = new hud_type(src)
	//update_sight()
	SEND_SIGNAL(src, COMSIG_MOB_HUD_CREATED)

/datum/hud/proc/show_hud(version = 0, mob/viewmob)
	if (!ismob(mymob))
		return FALSE
	var/mob/screenmob = mymob || viewmob
	if (!screenmob.client)
		return FALSE
	
	screenmob.client.screen = list()
	//screenmob.client.apply_clickcatcher()

	var/display_hud_version = version
	if(!display_hud_version)
		display_hud_version = hud_version + 1
	if(display_hud_version > HUD_VERSIONS)
		display_hud_version = 1
	
	switch(display_hud_version)
		if (HUD_STYLE_STANDARD)
			hud_shown = TRUE
			if (static_inventory.len)
				screenmob.client.screen += static_inventory
			if(toggleable_inventory.len && screenmob.hud_used && screenmob.hud_used.inventory_shown)
				screenmob.client.screen += toggleable_inventory
			if(hotkeybuttons.len && !hotkey_ui_hidden)
				screenmob.client.screen += hotkeybuttons
			if(infodisplay.len)
				screenmob.client.screen += infodisplay
			
			screenmob.client.screen += hide_actions_toggle

			if(action_intent)
				action_intent.screen_loc = initial(action_intent.screen_loc)
		
		if(HUD_STYLE_REDUCED)
			hud_shown = FALSE
			if(static_inventory.len)
				screenmob.client.screen -= static_inventory
			if(toggleable_inventory.len)
				screenmob.client.screen -= toggleable_inventory
			if(hotkeybuttons.len)
				screenmob.client.screen -= hotkeybuttons
			if(infodisplay.len)
				screenmob.client.screen += infodisplay

			for(var/h in hand_slots)
				var/obj/screen/hand = hand_slots[h]
				if(hand)
					screenmob.client.screen += hand
			if(action_intent)
				screenmob.client.screen += action_intent
				action_intent.screen_loc = ui_acti_alt

		if(HUD_STYLE_NOHUD)
			hud_shown = FALSE
			if(static_inventory.len)
				screenmob.client.screen -= static_inventory
			if(toggleable_inventory.len)
				screenmob.client.screen -= toggleable_inventory
			if(hotkeybuttons.len)
				screenmob.client.screen -= hotkeybuttons
			if(infodisplay.len)
				screenmob.client.screen -= infodisplay
	
	hud_version = display_hud_version
	persistent_inventory_update(screenmob)
	screenmob.update_action_buttons(1)
	//reorganize_alerts()
	screenmob.reload_fullscreen()
	//update_parallax_pref(screenmob)

	//if (!viewmob)
	//	plane_masters_update()
	//	for(var/M in mymob.observers)
	//		show_hud(hud_version, M)
	//else if (viewmob.hud_used)
	//	viewmob.hud_used.plane_masters_update()
	
	return TRUE

/datum/hud/proc/hidden_inventory_update()
	return

/datum/hud/proc/persistent_inventory_update(mob/viewer)
	if(!mymob)
		return

/datum/hud/proc/build_hand_slots()
	for(var/h in hand_slots)
		var/obj/screen/inventory/hand/H = hand_slots[h]
		if(H)
			static_inventory -= H
	hand_slots = list()
	var/obj/screen/inventory/hand/hand_box
	for(var/i in 1 to mymob.held_items.len)
		hand_box = new /obj/screen/inventory/hand()
		hand_box.name = mymob.get_held_index_name(i)
		hand_box.icon = ui_style
		hand_box.icon_state = "hand_[mymob.held_index_to_dir(i)]"
		hand_box.screen_loc = ui_hand_position(i)
		hand_box.held_index = i
		hand_slots["[i]"] = hand_box
		hand_box.hud = src
		static_inventory += hand_box
		hand_box.update_icon()

	var/i = 1
	for(var/obj/screen/swap_hand/SH in static_inventory)
		SH.screen_loc = ui_swaphand_position(mymob,!(i % 2) ? 2: 1)
		i++
	for(var/obj/screen/human/equip/E in static_inventory)
		E.screen_loc = ui_equip_position(mymob)

	if(ismob(mymob) && mymob.hud_used == src)
		show_hud(hud_version)

/datum/hud/proc/update_locked_slots()
	return