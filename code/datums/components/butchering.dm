/datum/component/butchering
	var/speed = 80
	var/effectiveness = 100
	var/bonus_modifier = 0
	var/butcher_sound = 'sound/weapons/slice.ogg'
	var/butchering_enabled = TRUE

/datum/component/butchering/Initialize(_speed, _effectiveness, _bonus_modifier, _butcher_sound, disabled)
	if(_speed)
		speed = _speed
	if(_effectiveness)
		effectiveness = _effectiveness
	if(_bonus_modifier)
		bonus_modifier = _bonus_modifier
	if(_butcher_sound)
		butcher_sound = _butcher_sound
	if(disabled)
		butchering_enabled = FALSE