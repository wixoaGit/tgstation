/datum/tgui
	var/mob/user
	var/datum/src_object
	var/title
	var/ui_key
	var/window_id
	var/width = 0
	var/height = 0
	var/window_options = list(
	  "focus" = FALSE,
	  "titlebar" = TRUE,
	  "can_resize" = TRUE,
	  "can_minimize" = TRUE,
	  "can_maximize" = FALSE,
	  "can_close" = TRUE,
	  "auto_format" = FALSE
	)
	var/style = "nanotrasen"
	var/interface
	var/autoupdate = TRUE
	var/initialized = FALSE
	var/list/initial_data
	var/status = UI_INTERACTIVE
	var/datum/ui_state/state = null
	var/datum/tgui/master_ui
	var/list/datum/tgui/children = list()
	var/titlebar = TRUE
	var/custom_browser_id = FALSE
	var/ui_screen = "home"

/datum/tgui/New(mob/user, datum/src_object, ui_key, interface, title, width = 0, height = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state, browser_id = null)
	src.user = user
	src.src_object = src_object
	src.ui_key = ui_key
	src.window_id = browser_id ? browser_id : "[REF(src_object)]-[ui_key]"
	src.custom_browser_id = browser_id ? TRUE : FALSE

	set_interface(interface)

	if(title)
		//src.title = sanitize(title)
		src.title = title//not_actual
	if(width)
		src.width = width
	if(height)
		src.height = height

	src.master_ui = master_ui
	if(master_ui)
		master_ui.children += src
	src.state = state

	var/datum/asset/assets = get_asset_datum(/datum/asset/simple/tgui)
	assets.send(user)

/datum/tgui/proc/open()
	if(!user.client)
		return

	update_status(push = 0)
	if(status < UI_UPDATE)
		return

	if(!initial_data)
		set_initial_data(src_object.ui_data(user))

	var/window_size = ""
	if(width && height)
		window_size = "size=[width]x[height];"

	//var/debugable = check_rights_for(user.client, R_DEBUG)
	var/debugable = 0//not_actual
	//user << browse(get_html(debugable), "window=[window_id];[window_size][list2params(window_options)]")
	user << browse(get_html(debugable), "window=[window_id];[window_size]")//not_actual
	//if (!custom_browser_id)
	//	winset(user, window_id, "on-close=\"uiclose [REF(src)]\"")
	SStgui.on_open(src)

/datum/tgui/proc/reinitialize(interface, list/data)
	if(interface)
		set_interface(interface)
	if(data)
		set_initial_data(data)
	open()

/datum/tgui/proc/close()
	user << browse(null, "window=[window_id]")
	src_object.ui_close()
	SStgui.on_close(src)
	for(var/datum/tgui/child in children)
		child.close()
	children.Cut()
	state = null
	master_ui = null
	qdel(src)

/datum/tgui/proc/set_style(style)
	src.style = lowertext(style)

/datum/tgui/proc/set_interface(interface)
	src.interface = lowertext(interface)

/datum/tgui/proc/set_autoupdate(state = 1)
	autoupdate = state

/datum/tgui/proc/set_initial_data(list/data)
	initial_data = data

/datum/tgui/proc/get_html(var/inline)
	var/html
	if(inline)
		html = replacetextEx(SStgui.basehtml, "{}", get_json(initial_data))
	else
		html = SStgui.basehtml
	//html = replacetextEx(html, "\[ref]", "[REF(src)]")
	//html = replacetextEx(html, "\[style]", style)
	//not_actual
	html = replacetext(html, "\[ref\]", "[REF(src)]")
	html = replacetext(html, "\[style\]", style)
	return html

/datum/tgui/proc/get_config_data()
	var/list/config_data = list(
			"title"     = title,
			"status"    = status,
			"screen"	= ui_screen,
			"style"     = style,
			"interface" = interface,
			//"fancy"     = user.client.prefs.tgui_fancy,
			"fancy" = 0,//not_actual
			//"locked"    = user.client.prefs.tgui_lock && !custom_browser_id,
			"locked" = 0,//not_actual
			"window"    = window_id,
			"ref"       = "[REF(src)]",
			"user"      = list(
				"name"  = user.name,
				"ref"   = "[REF(user)]"
			),
			"srcObject" = list(
				"name" = "[src_object]",
				"ref"  = "[REF(src_object)]"
			),
			"titlebar" = titlebar
		)
	return config_data

/datum/tgui/proc/get_json(list/data)
	var/list/json_data = list()

	json_data["config"] = get_config_data()
	if(!isnull(data))
		json_data["data"] = data

	var/json = json_encode(json_data)
	//json = replacetext(json, "\proper", "")
	//json = replacetext(json, "\improper", "")
	return json

/datum/tgui/Topic(href, href_list)
	if(user != usr)
		return

	var/action = href_list["action"]
	var/params = href_list; params -= "action"

	switch(action)
		if("tgui:initialize")
			user << output(url_encode(get_json(initial_data)), "[custom_browser_id ? window_id : "[window_id].browser"]:initialize")
			initialized = TRUE
		if("tgui:view")
			if(params["screen"])
				ui_screen = params["screen"]
			SStgui.update_uis(src_object)
		if("tgui:link")
			//user << link(params["url"])
		if("tgui:fancy")
			//user.client.prefs.tgui_fancy = TRUE
		if("tgui:nofrills")
			//user.client.prefs.tgui_fancy = FALSE
		else
			update_status(push = 0)
			if(src_object.ui_act(action, params, src, state))
				SStgui.update_uis(src_object)

/datum/tgui/process(force = 0)
	var/datum/host = src_object.ui_host(user)
	if(!src_object || !host || !user)
		close()
		return

	if(status && (force || autoupdate))
		update()
	else
		update_status(push = 1)

/datum/tgui/proc/push_data(data, force = 0)
	update_status(push = 0)
	if(!initialized)
		return
	if(status <= UI_DISABLED && !force)
		return

	user << output(url_encode(get_json(data)), "[custom_browser_id ? window_id : "[window_id].browser"]:update")

/datum/tgui/proc/update(force_open = FALSE)
	src_object.ui_interact(user, ui_key, src, force_open, master_ui, state)

/datum/tgui/proc/update_status(push = 0)
	var/status = src_object.ui_status(user, state)
	if(master_ui)
		status = min(status, master_ui.status)

	set_status(status, push)
	if(status == UI_CLOSE)
		close()

/datum/tgui/proc/set_status(status, push = 0)
	if(src.status != status)
		if(src.status == UI_DISABLED)
			src.status = status
			if(push)
				update()
		else
			src.status = status
			if(status == UI_DISABLED || push)
				push_data(null, force = 1)