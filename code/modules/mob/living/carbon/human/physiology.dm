/datum/physiology
	var/brute_mod = 1
	var/burn_mod = 1
	var/tox_mod = 1
	var/oxy_mod = 1
	var/clone_mod = 1
	var/stamina_mod = 1
	var/brain_mod = 1

	var/pressure_mod = 1
	var/heat_mod = 1
	var/cold_mod = 1

	var/damage_resistance = 0

	var/siemens_coeff = 1

	var/stun_mod = 1
	var/bleed_mod = 1
	var/datum/armor/armor

	var/hunger_mod = 1

	var/do_after_speed = 1

/datum/physiology/New()
	//armor = new
	armor = new /datum/armor //not_actual
