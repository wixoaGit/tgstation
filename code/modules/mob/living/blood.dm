/mob/living/proc/transfer_blood_to(atom/movable/AM, amount, forced)
	if(!blood_volume || !AM.reagents)
		return 0
	if(blood_volume < BLOOD_VOLUME_BAD && !forced)
		return 0

	if(blood_volume < amount)
		amount = blood_volume

	var/blood_id = get_blood_id()
	if(!blood_id)
		return 0

	blood_volume -= amount

	var/list/blood_data = get_blood_data(blood_id)

	if(iscarbon(AM))
		var/mob/living/carbon/C = AM
		if(blood_id == C.get_blood_id())
			if(blood_id == "blood")
				//if(blood_data["viruses"])
				//	for(var/thing in blood_data["viruses"])
				//		var/datum/disease/D = thing
				//		if((D.spread_flags & DISEASE_SPREAD_SPECIAL) || (D.spread_flags & DISEASE_SPREAD_NON_CONTAGIOUS))
				//			continue
				//		C.ForceContractDisease(D)
				if(!(blood_data["blood_type"] in get_safe_blood(C.dna.blood_type)))
					C.reagents.add_reagent("toxin", amount * 0.5)
					return 1

			C.blood_volume = min(C.blood_volume + round(amount, 0.1), BLOOD_VOLUME_MAXIMUM)
			return 1

	AM.reagents.add_reagent(blood_id, amount, blood_data, bodytemperature)
	return 1

/mob/proc/get_blood_id()
	return

/mob/living/proc/get_blood_data(blood_id)
	return

/mob/living/carbon/get_blood_data(blood_id)
	if(blood_id == "blood")
		var/blood_data = list()

		blood_data["donor"] = src
		blood_data["viruses"] = list()

		//for(var/thing in diseases)
		//	var/datum/disease/D = thing
		//	blood_data["viruses"] += D.Copy()

		blood_data["blood_DNA"] = copytext(dna.unique_enzymes,1,0)
		//if(disease_resistances && disease_resistances.len)
		//	blood_data["resistances"] = disease_resistances.Copy()
		var/list/temp_chem = list()
		for(var/datum/reagent/R in reagents.reagent_list)
			temp_chem[R.id] = R.volume
		//blood_data["trace_chem"] = list2params(temp_chem)
		if(mind)
			blood_data["mind"] = mind
		else if(last_mind)
			blood_data["mind"] = last_mind
		if(ckey)
			blood_data["ckey"] = ckey
		else if(last_mind)
			blood_data["ckey"] = ckey(last_mind.key)

		if(!suiciding)
			blood_data["cloneable"] = 1
		blood_data["blood_type"] = copytext(dna.blood_type,1,0)
		blood_data["gender"] = gender
		blood_data["real_name"] = real_name
		blood_data["features"] = dna.features
		blood_data["factions"] = faction
		blood_data["quirks"] = list()
		//for(var/V in roundstart_quirks)
		//	var/datum/quirk/T = V
		//	blood_data["quirks"] += T.type
		return blood_data

/mob/living/simple_animal/get_blood_id()
	if(blood_volume)
		return "blood"

/mob/living/carbon/human/get_blood_id()
	if(has_trait(TRAIT_HUSK))
		return
	//if(dna.species.exotic_blood)
	//	return dna.species.exotic_blood
	//else if((NOBLOOD in dna.species.species_traits))
	//	return
	return "blood"

/proc/get_safe_blood(bloodtype)
	. = list()
	if(!bloodtype)
		return

	var/static/list/bloodtypes_safe = list(
		"A-" = list("A-", "O-"),
		"A+" = list("A-", "A+", "O-", "O+"),
		"B-" = list("B-", "O-"),
		"B+" = list("B-", "B+", "O-", "O+"),
		"AB-" = list("A-", "B-", "O-", "AB-"),
		"AB+" = list("A-", "A+", "B-", "B+", "O-", "O+", "AB-", "AB+"),
		"O-" = list("O-"),
		"O+" = list("O-", "O+"),
		"L" = list("L"),
		"U" = list("A-", "A+", "B-", "B+", "O-", "O+", "AB-", "AB+", "L", "U")
	)

	var/safe = bloodtypes_safe[bloodtype]
	if(safe)
		. = safe

/mob/living/proc/add_splatter_floor(turf/T, small_drip)
	if(get_blood_id() != "blood")
		return
	if(!T)
		T = get_turf(src)

	var/list/temp_blood_DNA
	if(small_drip)
		var/obj/effect/decal/cleanable/blood/drip/drop = locate() in T
		if(drop)
			if(drop.drips < 5)
				drop.drips++
				drop.add_overlay(pick(drop.random_icon_states))
				drop.transfer_mob_blood_dna(src)
				return
			else
				//temp_blood_DNA = drop.return_blood_DNA()
				qdel(drop)
		else
			drop = new(T, get_static_viruses())
			drop.transfer_mob_blood_dna(src)
			return

	var/obj/effect/decal/cleanable/blood/B = locate() in T
	if(!B)
		B = new /obj/effect/decal/cleanable/blood/splatter(T, get_static_viruses())
	if (B.bloodiness < MAX_SHOE_BLOODINESS)
		B.bloodiness += BLOOD_AMOUNT_PER_DECAL
	B.transfer_mob_blood_dna(src)
	if(temp_blood_DNA)
		B.add_blood_DNA(temp_blood_DNA)

/mob/living/carbon/human/add_splatter_floor(turf/T, small_drip)
	//if(!(NOBLOOD in dna.species.species_traits))
	if(TRUE)//not_actual
		..()

///mob/living/carbon/alien/add_splatter_floor(turf/T, small_drip)
//	if(!T)
//		T = get_turf(src)
//	var/obj/effect/decal/cleanable/xenoblood/B = locate() in T.contents
//	if(!B)
//		B = new(T)
//	B.add_blood_DNA(list("UNKNOWN DNA" = "X*"))

///mob/living/silicon/robot/add_splatter_floor(turf/T, small_drip)
//	if(!T)
//		T = get_turf(src)
//	var/obj/effect/decal/cleanable/oil/B = locate() in T.contents
//	if(!B)
//		B = new(T)
