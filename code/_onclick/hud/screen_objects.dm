/obj/screen
	name = ""
	icon = 'icons/mob/screen_gen.dmi'
	layer = HUD_LAYER
	var/obj/master = null
	var/datum/hud/hud = null

/obj/screen/swap_hand
	layer = HUD_LAYER
	name = "swap hand"

/obj/screen/swap_hand/Click()
	if(world.time <= usr.next_move)
		return 1

	if(usr.incapacitated())
		return 1

	if(ismob(usr))
		var/mob/M = usr
		M.swap_hand()
	return 1

/obj/screen/craft
	name = "crafting menu"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "craft"
	screen_loc = ui_crafting

/obj/screen/area_creator
	name = "create new area"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "area_edit"
	screen_loc = ui_building

/obj/screen/language_menu
	name = "language menu"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "talk_wheel"
	screen_loc = ui_language_menu

/obj/screen/inventory
	var/slot_id
	var/icon_empty
	var/icon_full
	var/list/object_overlays = list()
	layer = HUD_LAYER

/obj/screen/inventory/Click(location, control, params)
	if(world.time <= usr.next_move)
		return 1

	if(usr.incapacitated())
		return 1
	if(ismecha(usr.loc))
		return 1

	if(hud && hud.mymob && slot_id)
		var/obj/item/inv_item = hud.mymob.get_item_by_slot(slot_id)
		if(inv_item)
			return inv_item.Click(location, control, params)

	if(usr.attack_ui(slot_id))
		usr.update_inv_hands()
	return 1

/obj/screen/inventory/update_icon()
	if(!icon_empty)
		icon_empty = icon_state

	if(hud && hud.mymob && slot_id && icon_full)
		if(hud.mymob.get_item_by_slot(slot_id))
			icon_state = icon_full
		else
			icon_state = icon_empty

/obj/screen/inventory/hand
	//var/mutable_appearance/handcuff_overlay
	//var/static/mutable_appearance/blocked_overlay = mutable_appearance('icons/mob/screen_gen.dmi', "blocked")
	var/held_index = 0

/obj/screen/inventory/hand/update_icon()
	..()

	//if(!handcuff_overlay)
	//	var/state = (!(held_index % 2)) ? "markus" : "gabrielle"
	//	handcuff_overlay = mutable_appearance('icons/mob/screen_gen.dmi', state)

	cut_overlays()

	if(hud && hud.mymob)
		//if(iscarbon(hud.mymob))
			//var/mob/living/carbon/C = hud.mymob
			//if(C.handcuffed)
			//	add_overlay(handcuff_overlay)

			//if(held_index)
			//	if(!C.has_hand_for_held_index(held_index))
			//		add_overlay(blocked_overlay)

		if(held_index == hud.mymob.active_hand_index)
			add_overlay("hand_active")

/obj/screen/close
	name = "close"
	layer = ABOVE_HUD_LAYER
	plane = ABOVE_HUD_PLANE
	icon_state = "backpack_close"

/obj/screen/close/Initialize(mapload, new_master)
	. = ..()
	master = new_master

/obj/screen/close/Click()
	var/datum/component/storage/S = master
	S.hide_from(usr)
	return TRUE

/obj/screen/drop
	name = "drop"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "act_drop"
	layer = HUD_LAYER

/obj/screen/drop/Click()
	if(usr.stat == CONSCIOUS)
		usr.dropItemToGround(usr.get_active_held_item())

/obj/screen/act_intent
	name = "intent"
	icon_state = "help"
	screen_loc = ui_acti

/obj/screen/act_intent/segmented/Click(location, control, params)
	//if(usr.client.prefs.toggles & INTENT_STYLE)
	if(TRUE)//not_actual
		var/_x = text2num(params2list(params)["icon-x"])
		var/_y = text2num(params2list(params)["icon-y"])

		if(_x<=16 && _y<=16)
			usr.a_intent_change(INTENT_HARM)

		else if(_x<=16 && _y>=17)
			usr.a_intent_change(INTENT_HELP)

		else if(_x>=17 && _y<=16)
			usr.a_intent_change(INTENT_GRAB)

		else if(_x>=17 && _y>=17)
			usr.a_intent_change(INTENT_DISARM)
	else
		return ..()

/obj/screen/internals
	name = "toggle internals"
	icon_state = "internal0"
	screen_loc = ui_internal

/obj/screen/mov_intent
	name = "run/walk toggle"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "running"

/obj/screen/pull
	name = "stop pulling"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "pull"

/obj/screen/pull/Click()
	if(isobserver(usr))
		return
	usr.stop_pulling()

/obj/screen/pull/update_icon(mob/mymob)
	if(!mymob)
		return
	if(mymob.pulling)
		icon_state = "pull"
	else
		icon_state = "pull0"

/obj/screen/resist
	name = "resist"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "act_resist"
	layer = HUD_LAYER

/obj/screen/rest
	name = "rest"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "act_rest"
	layer = HUD_LAYER

/obj/screen/storage
	name = "storage"
	icon_state = "block"
	screen_loc = "7,7 to 10,8"
	layer = HUD_LAYER
	plane = HUD_PLANE

/obj/screen/storage/Initialize(mapload, new_master)
	. = ..()
	master = new_master

/obj/screen/storage/Click(location, control, params)
	if(world.time <= usr.next_move)
		return TRUE
	if(usr.incapacitated())
		return TRUE
	if (ismecha(usr.loc))
		return TRUE
	if(master)
		var/obj/item/I = usr.get_active_held_item()
		if(I)
			master.attackby(null, I, usr, params)
	return TRUE

/obj/screen/throw_catch
	name = "throw/catch"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "act_throw_off"

/obj/screen/throw_catch/Click()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		C.toggle_throw_mode()

/obj/screen/zone_sel
	name = "damage zone"
	icon_state = "zone_sel"
	screen_loc = ui_zonesel
	var/selecting = BODY_ZONE_CHEST
	//var/static/list/hover_overlays_cache = list()
	var/hovering

/obj/screen/zone_sel/Click(location, control,params)
	if(isobserver(usr))
		return

	var/list/PL = params2list(params)
	var/icon_x = text2num(PL["icon-x"])
	var/icon_y = text2num(PL["icon-y"])
	var/choice = get_zone_at(icon_x, icon_y)
	if (!choice)
		return 1

	return set_selected_zone(choice, usr)

/obj/screen/zone_sel/proc/get_zone_at(icon_x, icon_y)
	switch(icon_y)
		if(1 to 9)
			switch(icon_x)
				if(10 to 15)
					return BODY_ZONE_R_LEG
				if(17 to 22)
					return BODY_ZONE_L_LEG
		if(10 to 13)
			switch(icon_x)
				if(8 to 11)
					return BODY_ZONE_R_ARM
				if(12 to 20)
					return BODY_ZONE_PRECISE_GROIN
				if(21 to 24)
					return BODY_ZONE_L_ARM
		if(14 to 22)
			switch(icon_x)
				if(8 to 11)
					return BODY_ZONE_R_ARM
				if(12 to 20)
					return BODY_ZONE_CHEST
				if(21 to 24)
					return BODY_ZONE_L_ARM
		if(23 to 30)
			//if(icon_x in 12 to 20)
			if(icon_x >= 12 && icon_x <= 20) //not_actual
				switch(icon_y)
					if(23 to 24)
						//if(icon_x in 15 to 17)
						if (icon_x >= 15 && icon_x <= 17) //not_actual
							return BODY_ZONE_PRECISE_MOUTH
					if(26)
						//if(icon_x in 14 to 18)
						if (icon_x >= 14 && icon_x <= 18) //not_actual
							return BODY_ZONE_PRECISE_EYES
					if(25 to 27)
						//if(icon_x in 15 to 17)
						if (icon_x >= 15 && icon_x <= 17) //not_actual
							return BODY_ZONE_PRECISE_EYES
				return BODY_ZONE_HEAD

/obj/screen/zone_sel/proc/set_selected_zone(choice, mob/user)
	if(isobserver(user))
		return

	if(choice != selecting)
		selecting = choice
		update_icon(usr)
	return 1

/obj/screen/zone_sel/update_icon(mob/user)
	cut_overlays()
	add_overlay(mutable_appearance('icons/mob/screen_gen.dmi', "[selecting]"))
	user.zone_selected = selecting

/obj/screen/healths
	name = "health"
	icon_state = "health0"
	screen_loc = ui_health

/obj/screen/healthdoll
	name = "health doll"
	screen_loc = ui_healthdoll

/obj/screen/healthdoll/Click()
	if (ishuman(usr))
		var/mob/living/carbon/human/H = usr
		H.check_self_for_injuries()

/obj/screen/splash
	//icon = 'icons/blank_title.png'
	icon_state = ""
	screen_loc = "1,1"
	layer = SPLASHSCREEN_LAYER
	var/client/holder

/obj/screen/splash/New(client/C, visible, use_previous_title)
	holder = C

	icon = SStitle.icon

	holder.screen += src
	return ..()

/obj/screen/splash/proc/Fade(out, qdel_after = TRUE)
	if(QDELETED(src))
		return
	//if(out)
	//	animate(src, alpha = 0, time = 30)
	//else
	//	alpha = 0
	//	animate(src, alpha = 255, time = 30)
	if(qdel_after)
		QDEL_IN(src, 30)

/obj/screen/splash/Destroy()
	if (holder)
		holder.screen -= src
		holder = null
	return ..()