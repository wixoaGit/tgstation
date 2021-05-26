/datum/plant_gene
	var/name

/datum/plant_gene/proc/get_name()
	return name

/datum/plant_gene/proc/can_add(obj/item/seeds/S)
	return !istype(S, /obj/item/seeds/sample)

/datum/plant_gene/proc/Copy()
	return new type

/datum/plant_gene/proc/apply_vars(obj/item/seeds/S)
	return

/datum/plant_gene/core
	var/value

/datum/plant_gene/core/get_name()
	return "[name] [value]"

/datum/plant_gene/core/proc/apply_stat(obj/item/seeds/S)
	return

/datum/plant_gene/core/New(var/i = null)
	..()
	if(!isnull(i))
		value = i

/datum/plant_gene/core/Copy()
	var/datum/plant_gene/core/C = ..()
	C.value = value
	return C

/datum/plant_gene/core/can_add(obj/item/seeds/S)
	if(!..())
		return FALSE
	return S.get_gene(src.type)

/datum/plant_gene/core/lifespan
	name = "Lifespan"
	value = 25

/datum/plant_gene/core/lifespan/apply_stat(obj/item/seeds/S)
	S.lifespan = value


/datum/plant_gene/core/endurance
	name = "Endurance"
	value = 15

/datum/plant_gene/core/endurance/apply_stat(obj/item/seeds/S)
	S.endurance = value


/datum/plant_gene/core/production
	name = "Production Speed"
	value = 6

/datum/plant_gene/core/production/apply_stat(obj/item/seeds/S)
	S.production = value


/datum/plant_gene/core/yield
	name = "Yield"
	value = 3

/datum/plant_gene/core/yield/apply_stat(obj/item/seeds/S)
	S.yield = value


/datum/plant_gene/core/potency
	name = "Potency"
	value = 10

/datum/plant_gene/core/potency/apply_stat(obj/item/seeds/S)
	S.potency = value


/datum/plant_gene/core/weed_rate
	name = "Weed Growth Rate"
	value = 1

/datum/plant_gene/core/weed_rate/apply_stat(obj/item/seeds/S)
	S.weed_rate = value


/datum/plant_gene/core/weed_chance
	name = "Weed Vulnerability"
	value = 5

/datum/plant_gene/core/weed_chance/apply_stat(obj/item/seeds/S)
	S.weed_chance = value

/datum/plant_gene/reagent
	name = "Nutriment"
	var/reagent_id = "nutriment"
	var/rate = 0.04

/datum/plant_gene/reagent/get_name()
	return "[name] production [rate*100]%"

/datum/plant_gene/reagent/proc/set_reagent(reag_id)
	reagent_id = reag_id
	name = "UNKNOWN"

	var/datum/reagent/R = GLOB.chemical_reagents_list[reag_id]
	if(R && R.id == reagent_id)
		name = R.name

/datum/plant_gene/reagent/New(reag_id = null, reag_rate = 0)
	..()
	if(reag_id && reag_rate)
		set_reagent(reag_id)
		rate = reag_rate

/datum/plant_gene/reagent/Copy()
	var/datum/plant_gene/reagent/G = ..()
	G.name = name
	G.reagent_id = reagent_id
	G.rate = rate
	return G

/datum/plant_gene/reagent/can_add(obj/item/seeds/S)
	if(!..())
		return FALSE
	for(var/datum/plant_gene/reagent/R in S.genes)
		if(R.reagent_id == reagent_id)
			return FALSE
	return TRUE

/datum/plant_gene/trait
	var/rate = 0.05
	var/examine_line = ""
	var/trait_id

/datum/plant_gene/trait/Copy()
	var/datum/plant_gene/trait/G = ..()
	G.rate = rate
	return G

/datum/plant_gene/trait/can_add(obj/item/seeds/S)
	if(!..())
		return FALSE

	for(var/datum/plant_gene/trait/R in S.genes)
		if(trait_id && R.trait_id == trait_id)
			return FALSE
		if(type == R.type)
			return FALSE
	return TRUE

/datum/plant_gene/trait/proc/on_new(obj/item/reagent_containers/food/snacks/grown/G, newloc)
	return

/datum/plant_gene/trait/proc/on_consume(obj/item/reagent_containers/food/snacks/grown/G, mob/living/carbon/target)
	return

/datum/plant_gene/trait/proc/on_slip(obj/item/reagent_containers/food/snacks/grown/G, mob/living/carbon/target)
	return

/datum/plant_gene/trait/proc/on_squash(obj/item/reagent_containers/food/snacks/grown/G, atom/target)
	return

/datum/plant_gene/trait/proc/on_attackby(obj/item/reagent_containers/food/snacks/grown/G, obj/item/I, mob/user)
	return

/datum/plant_gene/trait/proc/on_throw_impact(obj/item/reagent_containers/food/snacks/grown/G, atom/target)
	return

/datum/plant_gene/trait/maxchem
	name = "Densified Chemicals"
	rate = 2

/datum/plant_gene/trait/maxchem/on_new(obj/item/reagent_containers/food/snacks/grown/G, newloc)
	..()
	G.reagents.maximum_volume *= rate

/datum/plant_gene/trait/repeated_harvest
	name = "Perennial Growth"

/datum/plant_gene/trait/repeated_harvest/can_add(obj/item/seeds/S)
	if(!..())
		return FALSE
	//if(istype(S, /obj/item/seeds/replicapod))
	//	return FALSE
	return TRUE

/datum/plant_gene/trait/plant_type
	name = "you shouldn't see this"
	trait_id = "plant_type"

/datum/plant_gene/trait/plant_type/weed_hardy
	name = "Weed Adaptation"

/datum/plant_gene/trait/plant_type/fungal_metabolism
	name = "Fungal Vitality"

/datum/plant_gene/trait/plant_type/alien_properties
	name ="?????"