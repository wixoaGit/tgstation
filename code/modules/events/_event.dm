/datum/round_event
	var/processing = TRUE
	var/datum/round_event_control/control

	var/startWhen		= 0
	var/announceWhen	= 0
	var/endWhen			= 0

	var/activeFor		= 0
	var/current_players	= 0
	var/fakeable = TRUE