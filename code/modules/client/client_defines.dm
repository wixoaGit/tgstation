/client
	//parent_type = /datum

	var/datum/admins/holder = null

	var/datum/preferences/prefs = null
	var/move_delay = 0

	var/ambience_playing= null
	var/played			= 0

	var/inprefs = FALSE

	var/datum/chatOutput/chatOutput