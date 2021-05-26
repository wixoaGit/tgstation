/datum/dna
	var/unique_enzymes
	var/uni_identity
	var/blood_type
	var/datum/species/species = new /datum/species/human
	var/list/features = list("FFF")
	var/real_name
	var/list/mutations = list()
	var/list/temporary_mutations = list()
	var/list/previous = list()
	var/mob/living/holder
	var/delete_species = TRUE
	//var/mutation_index[DNA_MUTATION_BLOCKS]
	var/stability = 100
	var/scrambled = FALSE

/datum/dna/New(mob/living/new_holder)
	if(istype(new_holder))
		holder = new_holder

/datum/dna/Destroy()
	if(iscarbon(holder))
		var/mob/living/carbon/cholder = holder
		if(cholder.dna == src)
			cholder.dna = null
	holder = null

	if(delete_species)
		QDEL_NULL(species)

	mutations.Cut()
	temporary_mutations.Cut()
	previous.Cut()

	return ..()

/datum/dna/proc/generate_unique_enzymes()
	. = ""
	if(istype(holder))
		real_name = holder.real_name
		//. += md5(holder.real_name)
		. += random_string(DNA_UNIQUE_ENZYMES_LEN, GLOB.hex_characters)//not_actual
	else
		. += random_string(DNA_UNIQUE_ENZYMES_LEN, GLOB.hex_characters)
	return .

/datum/dna/proc/initialize_dna(newblood_type)
	if(newblood_type)
		blood_type = newblood_type
	unique_enzymes = generate_unique_enzymes()
	//uni_identity = generate_uni_identity()
	//generate_dna_blocks()
	//features = random_features()

/mob/proc/set_species(datum/species/mrace, icon_update = 1)
	return

/mob/living/carbon/set_species(datum/species/mrace, icon_update = TRUE, pref_load = FALSE)
	if(mrace && has_dna())
		var/datum/species/new_race
		if(ispath(mrace))
			new_race = new mrace
		else if(istype(mrace))
			new_race = mrace
		else
			return
		//deathsound = new_race.deathsound
		//dna.species.on_species_loss(src, new_race, pref_load)
		//var/datum/species/old_species = dna.species
		//dna.species = new_race
		//dna.species.on_species_gain(src, old_species, pref_load)

/mob/living/carbon/human/set_species(datum/species/mrace, icon_update = TRUE, pref_load = FALSE)
	..()
	if(icon_update)
		update_body()
		update_hair()
		update_body_parts()
		//update_mutations_overlay()

/mob/proc/has_dna()
	return

/mob/living/carbon/has_dna()
	return dna

/mob/living/carbon/proc/create_dna()
	dna = new /datum/dna(src)
	//if(!dna.species)
	//	var/rando_race = pick(GLOB.roundstart_races)
	//	dna.species = new rando_race()