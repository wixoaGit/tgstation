#define AB_CHECK_RESTRAINED 1
#define AB_CHECK_STUN 2
#define AB_CHECK_LYING 4
#define AB_CHECK_CONSCIOUS 8

/datum/action
	var/name = "Generic Action"
	var/desc = null
	var/obj/target = null
	var/check_flags = NONE
	var/processing = FALSE
	var/obj/screen/movable/action_button/button = null
	var/buttontooltipstyle = ""
	var/transparent_when_unavailable = TRUE

	var/button_icon = 'icons/mob/actions/backgrounds.dmi'
	var/background_icon_state = ACTION_BUTTON_DEFAULT_BACKGROUND

	var/icon_icon = 'icons/mob/actions.dmi'
	var/button_icon_state = "default"
	var/mob/owner

/datum/action/New(Target)
	link_to(Target)
	button = new
	button.linked_action = src
	button.name = name
	button.actiontooltipstyle = buttontooltipstyle
	if(desc)
		button.desc = desc

/datum/action/proc/link_to(Target)
	target = Target

/datum/action/Destroy()
	if(owner)
		Remove(owner)
	target = null
	qdel(button)
	button = null
	return ..()

/datum/action/proc/Grant(mob/M)
	if(M)
		if(owner)
			if(owner == M)
				return
			Remove(owner)
		owner = M

		var/counter = 0
		var/bitfield = 0
		for(var/datum/action/A in M.actions)
			if(A.name == name && A.button.id)
				counter += 1
				bitfield |= A.button.id
		bitfield = ~bitfield
		var/bitflag = 1
		for(var/i in 1 to (counter + 1))
			if(bitfield & bitflag)
				button.id = bitflag
				break
			bitflag *= 2

		M.actions += src
		if(M.client)
			M.client.screen += button
			//button.locked = M.client.prefs.buttons_locked || button.id ? M.client.prefs.action_buttons_screen_locs["[name]_[button.id]"] : FALSE
			button.locked = FALSE//not_actual
			//button.moved = button.id ? M.client.prefs.action_buttons_screen_locs["[name]_[button.id]"] : FALSE
			button.moved = FALSE//not_actual
		M.update_action_buttons()
	else
		Remove(owner)

/datum/action/proc/Remove(mob/M)
	if(M)
		if(M.client)
			M.client.screen -= button
		M.actions -= src
		M.update_action_buttons()
	owner = null
	button.moved = FALSE
	button.locked = FALSE
	button.id = null

/datum/action/proc/Trigger()
	if(!IsAvailable())
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_ACTION_TRIGGER, src) & COMPONENT_ACTION_BLOCK_TRIGGER)
		return FALSE
	return TRUE

/datum/action/proc/Process()
	return

/datum/action/proc/IsAvailable()
	if(!owner)
		return FALSE
	if(check_flags & AB_CHECK_RESTRAINED)
		if(owner.restrained())
			return FALSE
	if(check_flags & AB_CHECK_STUN)
		if(isliving(owner))
			var/mob/living/L = owner
			if(L.IsParalyzed() || L.IsStun())
				return FALSE
	if(check_flags & AB_CHECK_LYING)
		if(isliving(owner))
			var/mob/living/L = owner
			if(!(L.mobility_flags & MOBILITY_STAND))
				return FALSE
	if(check_flags & AB_CHECK_CONSCIOUS)
		if(owner.stat)
			return FALSE
	return TRUE

/datum/action/proc/UpdateButtonIcon(status_only = FALSE, force = FALSE)
	if(button)
		if(!status_only)
			button.name = name
			button.desc = desc
			if(owner && owner.hud_used && background_icon_state == ACTION_BUTTON_DEFAULT_BACKGROUND)
				var/list/settings = owner.hud_used.get_action_buttons_icons()
				if(button.icon != settings["bg_icon"])
					button.icon = settings["bg_icon"]
				if(button.icon_state != settings["bg_state"])
					button.icon_state = settings["bg_state"]
			else
				if(button.icon != button_icon)
					button.icon = button_icon
				if(button.icon_state != background_icon_state)
					button.icon_state = background_icon_state

			ApplyIcon(button, force)

		if(!IsAvailable())
			button.color = transparent_when_unavailable ? rgb(128,0,0,128) : rgb(128,0,0)
		else
			button.color = rgb(255,255,255,255)
			return 1

/datum/action/proc/ApplyIcon(obj/screen/movable/action_button/current_button, force = FALSE)
	if(icon_icon && button_icon_state && ((current_button.button_icon_state != button_icon_state) || force))
		current_button.cut_overlays(TRUE)
		current_button.add_overlay(mutable_appearance(icon_icon, button_icon_state))
		current_button.button_icon_state = button_icon_state

/datum/action/item_action
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUN|AB_CHECK_LYING|AB_CHECK_CONSCIOUS
	button_icon_state = null

/datum/action/item_action/New(Target)
	..()
	var/obj/item/I = target
	LAZYINITLIST(I.actions)
	I.actions += src

/datum/action/item_action/Destroy()
	var/obj/item/I = target
	I.actions -= src
	UNSETEMPTY(I.actions)
	return ..()

/datum/action/item_action/Trigger()
	if(!..())
		return 0
	if(target)
		var/obj/item/I = target
		I.ui_action_click(owner, src)
	return 1

/datum/action/item_action/ApplyIcon(obj/screen/movable/action_button/current_button, force)
	if(button_icon && button_icon_state)
		..()
	//else if(target && current_button.appearance_cache != target.appearance)
	else//not_actual
		var/obj/item/I = target
		var/old_layer = I.layer
		var/old_plane = I.plane
		I.layer = FLOAT_LAYER
		I.plane = FLOAT_PLANE
		current_button.cut_overlays()
		current_button.add_overlay(I)
		I.layer = old_layer
		I.plane = old_plane
		//current_button.appearance_cache = I.appearance

/datum/action/item_action/toggle_light
	name = "Toggle Light"

/datum/action/item_action/adjust

/datum/action/item_action/adjust/New(Target)
	..()
	name = "Adjust [target.name]"
	button.name = name

/datum/action/item_action/toggle_helmet
	name = "Toggle Helmet"

/datum/action/item_action/toggle_research_scanner
	name = "Toggle Research Scanner"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "scan_mode"
	var/active = FALSE

/datum/action/item_action/toggle_research_scanner/Trigger()
	if(IsAvailable())
		active = !active
		if(active)
			owner.research_scanner++
		else
			owner.research_scanner--
		to_chat(owner, "<span class='notice'>[target] research scanner has been [active ? "activated" : "deactivated"].</span>")
		return 1

/datum/action/item_action/toggle_research_scanner/Remove(mob/M)
	if(owner && active)
		owner.research_scanner--
		active = FALSE
	..()