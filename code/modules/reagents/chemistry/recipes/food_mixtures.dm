/datum/chemical_reaction/dough
	name = "Dough"
	id = "dough"
	required_reagents = list("water" = 10, "flour" = 15)
	mix_message = "The ingredients form a dough."

/datum/chemical_reaction/dough/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/dough(location)