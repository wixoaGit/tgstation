/datum/config_entry/string/servername

/datum/config_entry/string/stationname

/datum/config_entry/number/lobby_countdown
	config_entry_value = 120
	integer = FALSE
	min_val = 0

/datum/config_entry/flag/log_admin
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/log_game

/datum/config_entry/flag/log_telecomms

/datum/config_entry/flag/log_manifest

/datum/config_entry/number/tick_limit_mc_init
	config_entry_value = TICK_LIMIT_MC_INIT_DEFAULT
	min_val = 0
	integer = FALSE