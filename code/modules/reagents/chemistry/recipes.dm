/datum/chemical_reaction
	var/name = null
	var/id = null
	var/list/results = new/list()
	var/list/required_reagents = new/list()
	var/list/required_catalysts = new/list()

	var/required_container = null
	var/required_other = 0

	var/mob_react = TRUE

	var/required_temp = 0
	var/is_cold_recipe = 0
	var/mix_message = "The solution begins to bubble."
	var/mix_sound = 'sound/effects/bubbles.ogg'

/datum/chemical_reaction/proc/on_reaction(datum/reagents/holder, created_volume)
	return