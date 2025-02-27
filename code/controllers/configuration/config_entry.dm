#define VALUE_MODE_NUM 0
#define VALUE_MODE_TEXT 1
#define VALUE_MODE_FLAG 2

#define KEY_MODE_TEXT 0
#define KEY_MODE_TYPE 1

/datum/config_entry
	var/name
	var/config_entry_value
	var/default

	var/resident_file
	var/modified = FALSE

	var/deprecated_by

	var/protection = NONE
	var/abstract_type = /datum/config_entry

	var/vv_VAS = TRUE

	var/dupes_allowed = FALSE

/datum/config_entry/New()
	if(type == abstract_type)
		CRASH("Abstract config entry [type] instatiated!")
	name = lowertext(type2top(type))
	if(islist(config_entry_value))
		var/list/L = config_entry_value
		default = L.Copy()
	else
		default = config_entry_value

/datum/config_entry/proc/ValidateAndSet(str_val)
	//VASProcCallGuard(str_val)
	CRASH("Invalid config entry type!")

/datum/config_entry/proc/ValidateListEntry(key_name, key_value)
	return TRUE

/datum/config_entry/proc/DeprecationUpdate(value)
	return

/datum/config_entry/string
	config_entry_value = ""
	abstract_type = /datum/config_entry/string
	var/auto_trim = TRUE

/datum/config_entry/string/ValidateAndSet(str_val)
	//if(!VASProcCallGuard(str_val))
	//	return FALSE
	config_entry_value = auto_trim ? trim(str_val) : str_val
	return TRUE

/datum/config_entry/number
	config_entry_value = 0
	abstract_type = /datum/config_entry/number
	var/integer = TRUE
	var/max_val = INFINITY
	var/min_val = -INFINITY

/datum/config_entry/number/ValidateAndSet(str_val)
	//if(!VASProcCallGuard(str_val))
	//	return FALSE
	var/temp = text2num(trim(str_val))
	if(!isnull(temp))
		config_entry_value = CLAMP(integer ? round(temp) : temp, min_val, max_val)
		if(config_entry_value != temp && !(datum_flags & DF_VAR_EDITED))
			log_config("Changing [name] from [temp] to [config_entry_value]!")
		return TRUE
	return FALSE

/datum/config_entry/flag
	config_entry_value = FALSE
	abstract_type = /datum/config_entry/flag

/datum/config_entry/flag/ValidateAndSet(str_val)
	//if(!VASProcCallGuard(str_val))
	//	return FALSE
	config_entry_value = text2num(trim(str_val)) != 0
	return TRUE

/datum/config_entry/keyed_list
	abstract_type = /datum/config_entry/keyed_list
	config_entry_value = list()
	dupes_allowed = TRUE
	vv_VAS = FALSE
	var/key_mode
	var/value_mode
	var/splitter = " "

/datum/config_entry/keyed_list/New()
	. = ..()
	if(isnull(key_mode) || isnull(value_mode))
		CRASH("Keyed list of type [type] created with null key or value mode!")

/datum/config_entry/keyed_list/ValidateAndSet(str_val)
	//if(!VASProcCallGuard(str_val))
	//	return FALSE

	str_val = trim(str_val)
	var/key_pos = findtext(str_val, splitter)
	var/key_name = null
	var/key_value = null

	if(key_pos || value_mode == VALUE_MODE_FLAG)
		key_name = lowertext(copytext(str_val, 1, key_pos))
		key_value = copytext(str_val, key_pos + 1)
		var/new_key
		var/new_value
		var/continue_check_value
		var/continue_check_key
		switch(key_mode)
			if(KEY_MODE_TEXT)
				new_key = key_name
				continue_check_key = new_key
			if(KEY_MODE_TYPE)
				new_key = key_name
				if(!ispath(new_key))
					new_key = text2path(new_key)
				continue_check_key = ispath(new_key)
		switch(value_mode)
			if(VALUE_MODE_FLAG)
				new_value = TRUE
				continue_check_value = TRUE
			if(VALUE_MODE_NUM)
				new_value = text2num(key_value)
				continue_check_value = !isnull(new_value)
			if(VALUE_MODE_TEXT)
				new_value = key_value
				continue_check_value = new_value
		if(continue_check_value && continue_check_key && ValidateListEntry(new_key, new_value))
			config_entry_value[new_key] = new_value
			return TRUE
	return FALSE