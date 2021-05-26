/datum/reagent/consumable
	name = "Consumable"
	id = "consumable"
	taste_description = "generic food"
	taste_mult = 4
	var/nutriment_factor = 1 * REAGENTS_METABOLISM
	var/quality = 0

/datum/reagent/consumable/nutriment
	name = "Nutriment"
	id = "nutriment"
	description = "All the vitamins, minerals, and carbohydrates the body needs in pure form."
	reagent_state = SOLID
	nutriment_factor = 15 * REAGENTS_METABOLISM
	color = "#664330"

	var/brute_heal = 1
	var/burn_heal = 0

/datum/reagent/consumable/nutriment/vitamin
	name = "Vitamin"
	id = "vitamin"
	description = "All the best vitamins, minerals, and carbohydrates the body needs in pure form."

	brute_heal = 1
	burn_heal = 1

///datum/reagent/consumable/nutriment/vitamin/on_mob_life(mob/living/carbon/M)
//	if(M.satiety < 600)
//		M.satiety += 30
//	. = ..()

/datum/reagent/consumable/cooking_oil
	name = "Cooking Oil"
	id = "cooking_oil"
	description = "A variety of cooking oil derived from fat or plants. Used in food preparation and frying."
	color = "#EADD6B"
	taste_mult = 0.8
	taste_description = "oil"
	nutriment_factor = 7 * REAGENTS_METABOLISM 
	metabolization_rate = 10 * REAGENTS_METABOLISM
	var/fry_temperature = 450
	var/boiling

///datum/reagent/consumable/cooking_oil/reaction_obj(obj/O, reac_volume)
//	if(holder && holder.chem_temp >= fry_temperature)
//		if(isitem(O) && !istype(O, /obj/item/reagent_containers/food/snacks/deepfryholder))
//			O.loc.visible_message("<span class='warning'>[O] rapidly fries as it's splashed with hot oil! Somehow.</span>")
//			var/obj/item/reagent_containers/food/snacks/deepfryholder/F = new(O.drop_location(), O)
//			F.fry(volume)
//			F.reagents.add_reagent("cooking_oil", reac_volume)

///datum/reagent/consumable/cooking_oil/reaction_mob(mob/living/M, method = TOUCH, reac_volume, show_message = 1, touch_protection = 0)
//	if(!istype(M))
//		return
//	if(holder && holder.chem_temp >= fry_temperature)
//		boiling = TRUE
//	if(method == VAPOR || method == TOUCH)
//		if(boiling)
//			M.visible_message("<span class='warning'>The boiling oil sizzles as it covers [M]!</span>", \
//			"<span class='userdanger'>You're covered in boiling oil!</span>")
//			M.emote("scream")
//			playsound(M, 'sound/machines/fryer/deep_fryer_emerge.ogg', 25, TRUE)
//			var/oil_damage = (holder.chem_temp / fry_temperature) * 0.33
//			M.adjustFireLoss(min(35, oil_damage * reac_volume))
//	else
//		..()
//	return TRUE

///datum/reagent/consumable/cooking_oil/reaction_turf(turf/open/T, reac_volume)
//	if(!istype(T) || isgroundlessturf(T))
//		return
//	if(reac_volume >= 5)
//		T.MakeSlippery(TURF_WET_LUBE, min_wet_time = 10 SECONDS, wet_time_to_add = reac_volume * 1.5 SECONDS)
//		T.name = "deep-fried [initial(T.name)]"
//		T.add_atom_colour(color, TEMPORARY_COLOUR_PRIORITY)

/datum/reagent/consumable/sugar
	name = "Sugar"
	id = "sugar"
	description = "The organic compound commonly known as table sugar and sometimes called saccharose. This white, odorless, crystalline powder has a pleasing, sweet taste."
	reagent_state = SOLID
	color = "#FFFFFF"
	taste_mult = 1.5
	nutriment_factor = 10 * REAGENTS_METABOLISM
	metabolization_rate = 2 * REAGENTS_METABOLISM
	overdose_threshold = 200
	taste_description = "sweetness"

/datum/reagent/consumable/sodiumchloride
	name = "Table Salt"
	id = "sodiumchloride"
	description = "A salt made of sodium chloride. Commonly used to season food."
	reagent_state = SOLID
	color = "#FFFFFF"
	taste_description = "salt"

/datum/reagent/consumable/flour
	name = "Flour"
	id = "flour"
	description = "This is what you rub all over yourself to pretend to be a ghost."
	reagent_state = SOLID
	color = "#FFFFFF"
	taste_description = "chalky wheat"

///datum/reagent/consumable/flour/reaction_turf(turf/T, reac_volume)
//	if(!isspaceturf(T))
//		var/obj/effect/decal/cleanable/food/flour/reagentdecal = new(T)
//		reagentdecal = locate() in T
//		if(reagentdecal)
//			reagentdecal.reagents.add_reagent("flour", reac_volume)