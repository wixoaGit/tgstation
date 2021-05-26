/datum/martial_art
	var/name = "Martial Art"
	var/id = ""
	var/streak = ""
	var/max_streak_length = 6
	var/current_target
	var/datum/martial_art/base
	var/deflection_chance = 0
	var/block_chance = 0
	var/restraining = 0
	var/help_verb
	var/no_guns = FALSE
	var/allow_temp_override = TRUE