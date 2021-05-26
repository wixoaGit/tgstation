/datum/config_entry/keyed_list/probability
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_NUM

/datum/config_entry/keyed_list/probability/ValidateListEntry(key_name)
	return key_name in config.modes

/datum/config_entry/flag/jobs_have_minimal_access

/datum/config_entry/flag/assistants_have_maint_access

/datum/config_entry/flag/security_has_maint_access

/datum/config_entry/flag/everyone_has_maint_access

/datum/config_entry/number/shuttle_refuel_delay
	config_entry_value = 12000
	integer = FALSE
	min_val = 0

/datum/config_entry/flag/randomize_shift_time

/datum/config_entry/number/arrivals_shuttle_dock_window
	config_entry_value = 55
	integer = FALSE
	min_val = 30

/datum/config_entry/flag/shift_time_realtime