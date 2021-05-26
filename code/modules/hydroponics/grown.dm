/obj/item/reagent_containers/food/snacks/grown
	icon = 'icons/obj/hydroponics/harvest.dmi'
	var/obj/item/seeds/seed = null
	var/plantname = ""
	var/bitesize_mod = 0
	//var/splat_type = /obj/effect/decal/cleanable/food/plant_smudge
	dried_type = -1
	resistance_flags = FLAMMABLE
	var/dry_grind = FALSE
	var/can_distill = TRUE
	var/distill_reagent
	var/wine_flavor
	var/wine_power = 10

/obj/item/reagent_containers/food/snacks/grown/Initialize(mapload, obj/item/seeds/new_seed)
	. = ..()
	if(!tastes)
		tastes = list("[name]" = 1)

	if(new_seed)
		seed = new_seed.Copy()
	else if(ispath(seed))
		seed = new seed()
		seed.adjust_potency(50-seed.potency)

	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

	if(dried_type == -1)
		dried_type = src.type

	if(seed)
		for(var/datum/plant_gene/trait/T in seed.genes)
			T.on_new(src, loc)
		seed.prepare_result(src)
		//transform *= TRANSFORM_USING_VARIABLE(seed.potency, 100) + 0.5
		add_juice()

/obj/item/reagent_containers/food/snacks/grown/proc/add_juice()
	if(reagents)
		if(bitesize_mod)
			bitesize = 1 + round(reagents.total_volume / bitesize_mod)
		return 1
	return 0

/obj/item/reagent_containers/food/snacks/grown/examine(user)
	..()
	if(seed)
		for(var/datum/plant_gene/trait/T in seed.genes)
			if(T.examine_line)
				to_chat(user, T.examine_line)

/obj/item/reagent_containers/food/snacks/grown/grind_requirements()
	if(dry_grind && !dry)
		to_chat(usr, "<span class='warning'>[src] needs to be dry before it can be ground up!</span>")
		return
	return TRUE

/obj/item/reagent_containers/food/snacks/grown/on_grind()
	var/nutriment = reagents.get_reagent_amount("nutriment")
	if(grind_results&&grind_results.len)
		for(var/i in 1 to grind_results.len)
			grind_results[grind_results[i]] = nutriment
		reagents.del_reagent("nutriment")
		reagents.del_reagent("vitamin")