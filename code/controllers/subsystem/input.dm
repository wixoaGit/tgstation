SUBSYSTEM_DEF(input)
	name = "Input"
	wait = 1
	init_order = INIT_ORDER_INPUT
	flags = SS_TICKER
	priority = FIRE_PRIORITY_INPUT
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY

	var/list/macro_sets
	var/list/movement_keys

/datum/controller/subsystem/input/Initialize()
	setup_default_macro_sets()

	setup_default_movement_keys()

	initialized = TRUE

	refresh_client_macro_sets()

	return ..()

/datum/controller/subsystem/input/proc/setup_default_macro_sets()
	//var/list/static/default_macro_sets
	var/list/default_macro_sets //not_actual
	
	if(default_macro_sets)
		macro_sets = default_macro_sets
		return

	default_macro_sets = list(
		"default" = list(
			"Tab" = "\".winset \\\"input.focus=true?map.focus=true input.background-color=[COLOR_INPUT_DISABLED]:input.focus=true input.background-color=[COLOR_INPUT_ENABLED]\\\"\"",
			"O" = "ooc",
			"T" = "say",
			"M" = "me",
			"Back" = "\".winset \\\"input.text=\\\"\\\"\\\"\"",
			"Any" = "\"KeyDown \[\[*\]\]\"",
			"Any+UP" = "\"KeyUp \[\[*\]\]\"",
			),
		"old_default" = list(
			"Tab" = "\".winset \\\"mainwindow.macro=old_hotkeys map.focus=true input.background-color=[COLOR_INPUT_DISABLED]\\\"\"",
			"Ctrl+T" = "say",
			"Ctrl+O" = "ooc",
			),
		"old_hotkeys" = list(
			"Tab" = "\".winset \\\"mainwindow.macro=old_default input.focus=true input.background-color=[COLOR_INPUT_ENABLED]\\\"\"",
			"O" = "ooc",
			"T" = "say",
			"M" = "me",
			"Back" = "\".winset \\\"input.text=\\\"\\\"\\\"\"",
			"Any" = "\"KeyDown \[\[*\]\]\"",
			"Any+UP" = "\"KeyUp \[\[*\]\]\"",
			),
		)

	var/list/old_default = default_macro_sets["old_default"]

	//var/list/static/oldmode_keys = list(
	var/list/oldmode_keys = list(//not_actual
		"North", "East", "South", "West",
		"Northeast", "Southeast", "Northwest", "Southwest",
		"Insert", "Delete", "Ctrl", "Alt",
		"F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12",
		)

	for(var/i in 1 to oldmode_keys.len)
		var/key = oldmode_keys[i]
		old_default[key] = "\"KeyDown [key]\""
		old_default["[key]+UP"] = "\"KeyUp [key]\""

	//var/list/static/oldmode_ctrl_override_keys = list(
	var/list/oldmode_ctrl_override_keys = list(//not_actual
		"W" = "W", "A" = "A", "S" = "S", "D" = "D",
		"1" = "1", "2" = "2", "3" = "3", "4" = "4",
		"B" = "B",
		"E" = "E",
		"F" = "F",
		"G" = "G",
		"H" = "H",
		"Q" = "Q",
		"R" = "R",
		"X" = "X",
		"Y" = "Y",
		"Z" = "Z",
		)

	for(var/i in 1 to oldmode_ctrl_override_keys.len)
		var/key = oldmode_ctrl_override_keys[i]
		var/override = oldmode_ctrl_override_keys[key]
		old_default["Ctrl+[key]"] = "\"KeyDown [override]\""
		old_default["Ctrl+[key]+UP"] = "\"KeyUp [override]\""

	macro_sets = default_macro_sets

/datum/controller/subsystem/input/proc/setup_default_movement_keys()
	var/static/list/default_movement_keys = list(
		"W" = NORTH, "A" = WEST, "S" = SOUTH, "D" = EAST,
		"North" = NORTH, "West" = WEST, "South" = SOUTH, "East" = EAST,
		)

	movement_keys = default_movement_keys.Copy()

/datum/controller/subsystem/input/proc/refresh_client_macro_sets()
	var/list/clients = GLOB.clients
	for(var/i in 1 to clients.len)
		var/client/user = clients[i]
		user.set_macros()

/datum/controller/subsystem/input/fire()
	//var/list/clients = GLOB.clients
	//for(var/i in 1 to clients.len)
	//	var/client/C = clients[i]
	//	C.keyLoop()