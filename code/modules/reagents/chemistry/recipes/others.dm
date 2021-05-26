/datum/chemical_reaction/lube
	name = "Space Lube"
	id = "lube"
	results = list("lube" = 4)
	required_reagents = list("water" = 1, "silicon" = 1, "oxygen" = 1)

/datum/chemical_reaction/sodiumchloride
	name = "Sodium Chloride"
	id = "sodiumchloride"
	results = list("sodiumchloride" = 3)
	required_reagents = list("water" = 1, "sodium" = 1, "chlorine" = 1)

/datum/chemical_reaction/surfactant
	name = "Foam surfactant"
	id = "foam surfactant"
	results = list("fluorosurfactant" = 5)
	required_reagents = list("fluorine" = 2, "carbon" = 2, "sacid" = 1)

/datum/chemical_reaction/foam
	name = "Foam"
	id = "foam"
	required_reagents = list("fluorosurfactant" = 1, "water" = 1)
	mob_react = FALSE

/datum/chemical_reaction/foam/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/mob/M in viewers(5, location))
		to_chat(M, "<span class='danger'>The solution spews out foam!</span>")
	var/datum/effect_system/foam_spread/s = new()
	s.set_up(created_volume*2, location, holder)
	s.start()
	holder.clear_reagents()
	return

/datum/chemical_reaction/metalfoam
	name = "Metal Foam"
	id = "metalfoam"
	required_reagents = list("aluminium" = 3, "foaming_agent" = 1, "facid" = 1)
	mob_react = FALSE

/datum/chemical_reaction/metalfoam/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)

	for(var/mob/M in viewers(5, location))
		to_chat(M, "<span class='danger'>The solution spews out a metallic foam!</span>")

	var/datum/effect_system/foam_spread/metal/s = new()
	s.set_up(created_volume*5, location, holder, 1)
	s.start()
	holder.clear_reagents()

/datum/chemical_reaction/foaming_agent
	name = "Foaming Agent"
	id = "foaming_agent"
	results = list("foaming_agent" = 1)
	required_reagents = list("lithium" = 1, "hydrogen" = 1)

/datum/chemical_reaction/oil
	name = "Oil"
	id = "oil"
	results = list("oil" = 3)
	required_reagents = list("welding_fuel" = 1, "carbon" = 1, "hydrogen" = 1)

/datum/chemical_reaction/ash
	name = "Ash"
	id = "ash"
	results = list("ash" = 1)
	required_reagents = list("oil" = 1)
	required_temp = 480

/datum/chemical_reaction/saltpetre
	name = "saltpetre"
	id = "saltpetre"
	results = list("saltpetre" = 3)
	required_reagents = list("potassium" = 1, "nitrogen" = 1, "oxygen" = 3)