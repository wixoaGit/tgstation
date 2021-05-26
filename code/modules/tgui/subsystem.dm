/datum/controller/subsystem/tgui/proc/try_update_ui(mob/user, datum/src_object, ui_key, datum/tgui/ui, force_open = FALSE)
	if(isnull(ui))
		ui = get_open_ui(user, src_object, ui_key)

	if(!isnull(ui))
		var/data = src_object.ui_data(user)
		if(!force_open)
			ui.push_data(data)
		else
			ui.reinitialize(null, data)
		return ui
	else
		return null

/datum/controller/subsystem/tgui/proc/get_open_ui(mob/user, datum/src_object, ui_key)
	var/src_object_key = "[REF(src_object)]"
	if(isnull(open_uis[src_object_key]) || !istype(open_uis[src_object_key], /list))
		return null
	//else if(isnull(open_uis[src_object_key][ui_key]) || !istype(open_uis[src_object_key][ui_key], /list))
	//	return null

	for(var/datum/tgui/ui in open_uis[src_object_key][ui_key])
		if(ui.user == user)
			return ui

	return null

/datum/controller/subsystem/tgui/proc/update_uis(datum/src_object)
	var/src_object_key = "[REF(src_object)]"
	if(isnull(open_uis[src_object_key]) || !istype(open_uis[src_object_key], /list))
		return 0

	var/update_count = 0
	for(var/ui_key in open_uis[src_object_key])
		for(var/datum/tgui/ui in open_uis[src_object_key][ui_key])
			if(ui && ui.src_object && ui.user && ui.src_object.ui_host(ui.user))
				ui.process(force = 1)
				update_count++
	return update_count

/datum/controller/subsystem/tgui/proc/close_uis(datum/src_object)
	var/src_object_key = "[REF(src_object)]"
	if(isnull(open_uis[src_object_key]) || !istype(open_uis[src_object_key], /list))
		return 0

	var/close_count = 0
	for(var/ui_key in open_uis[src_object_key])
		for(var/datum/tgui/ui in open_uis[src_object_key][ui_key])
			if(ui && ui.src_object && ui.user && ui.src_object.ui_host(ui.user))
				ui.close()
				close_count++
	return close_count

/datum/controller/subsystem/tgui/proc/close_all_uis()
	var/close_count = 0
	for(var/src_object_key in open_uis)
		for(var/ui_key in open_uis[src_object_key])
			for(var/datum/tgui/ui in open_uis[src_object_key][ui_key])
				if(ui && ui.src_object && ui.user && ui.src_object.ui_host(ui.user))
					ui.close()
					close_count++
	return close_count

/datum/controller/subsystem/tgui/proc/close_user_uis(mob/user, datum/src_object = null, ui_key = null)
	if(isnull(user.open_uis) || !istype(user.open_uis, /list) || open_uis.len == 0)
		return 0

	var/close_count = 0
	for(var/datum/tgui/ui in user.open_uis)
		if((isnull(src_object) || !isnull(src_object) && ui.src_object == src_object) && (isnull(ui_key) || !isnull(ui_key) && ui.ui_key == ui_key))
			ui.close()
			close_count++
	return close_count

/datum/controller/subsystem/tgui/proc/on_open(datum/tgui/ui)
	var/src_object_key = "[REF(ui.src_object)]"
	if(isnull(open_uis[src_object_key]) || !istype(open_uis[src_object_key], /list))
		open_uis[src_object_key] = list(ui.ui_key = list())
	else if(isnull(open_uis[src_object_key][ui.ui_key]) || !istype(open_uis[src_object_key][ui.ui_key], /list))
		open_uis[src_object_key][ui.ui_key] = list()

	ui.user.open_uis |= ui
	var/list/uis = open_uis[src_object_key][ui.ui_key]
	uis |= ui
	processing_uis |= ui

/datum/controller/subsystem/tgui/proc/on_close(datum/tgui/ui)
	if (ui.src_object == null) return//not_actual
	
	var/src_object_key = "[REF(ui.src_object)]"
	if(isnull(open_uis[src_object_key]) || !istype(open_uis[src_object_key], /list))
		return 0
	else if(isnull(open_uis[src_object_key][ui.ui_key]) || !istype(open_uis[src_object_key][ui.ui_key], /list))
		return 0

	processing_uis.Remove(ui)
	if(ui.user)
		ui.user.open_uis.Remove(ui)
	var/Ukey = ui.ui_key
	var/list/uis = open_uis[src_object_key][Ukey]
	uis.Remove(ui)
	if(!uis.len)
		var/list/uiobj = open_uis[src_object_key]
		uiobj.Remove(Ukey)
		if(!uiobj.len)
			open_uis.Remove(src_object_key)

	return 1

/datum/controller/subsystem/tgui/proc/on_logout(mob/user)
	return close_user_uis(user)

/datum/controller/subsystem/tgui/proc/on_transfer(mob/source, mob/target)
	if(!source || isnull(source.open_uis) || !istype(source.open_uis, /list) || open_uis.len == 0)
		return 0

	if(isnull(target.open_uis) || !istype(target.open_uis, /list))
		target.open_uis = list()

	for(var/datum/tgui/ui in source.open_uis)
		ui.user = target
		target.open_uis.Add(ui)

	source.open_uis.Cut()
	return 1