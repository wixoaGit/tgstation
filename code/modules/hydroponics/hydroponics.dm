/obj/machinery/hydroponics
	name = "hydroponics tray"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "hydrotray"
	density = TRUE
	pixel_z = 8
	obj_flags = CAN_BE_HIT | UNIQUE_RENAME
	circuit = /obj/item/circuitboard/machine/hydroponics
	var/waterlevel = 100
	var/maxwater = 100
	var/nutrilevel = 10
	var/maxnutri = 10
	var/pestlevel = 0
	var/weedlevel = 0
	var/yieldmod = 1
	var/mutmod = 1
	var/toxic = 0
	var/age = 0
	var/dead = 0
	var/plant_health
	var/lastproduce = 0
	var/lastcycle = 0
	var/cycledelay = 200
	var/harvest = 0
	var/obj/item/seeds/myseed = null
	var/rating = 1
	var/unwrenchable = 1
	var/recent_bee_visit = FALSE
	var/using_irrigation = FALSE
	var/self_sufficiency_req = 20
	var/self_sufficiency_progress = 0
	var/self_sustaining = FALSE

/obj/machinery/hydroponics/constructable
	name = "hydroponics tray"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "hydrotray3"

/obj/machinery/hydroponics/constructable/RefreshParts()
	var/tmp_capacity = 0
	for (var/obj/item/stock_parts/matter_bin/M in component_parts)
		tmp_capacity += M.rating
	for (var/obj/item/stock_parts/manipulator/M in component_parts)
		rating = M.rating
	maxwater = tmp_capacity * 50
	maxnutri = tmp_capacity * 5

/obj/machinery/hydroponics/constructable/examine(mob/user)
	..()
	if(in_range(user, src) || isobserver(user))
		to_chat(user, "<span class='notice'>The status display reads: Tray efficiency at <b>[rating*100]%</b>.<span>")


/obj/machinery/hydroponics/Destroy()
	if(myseed)
		qdel(myseed)
		myseed = null
	return ..()

/obj/machinery/hydroponics/constructable/attackby(obj/item/I, mob/user, params)
	if (user.a_intent != INTENT_HARM)
		if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
			return

		if(I.tool_behaviour == TOOL_CROWBAR && using_irrigation)
			to_chat(user, "<span class='warning'>Disconnect the hoses first!</span>")
			return
		else if(default_deconstruction_crowbar(I))
			return

	return ..()

/obj/machinery/hydroponics/bullet_act(obj/item/projectile/Proj)
	if(!myseed)
		return ..()
	//if(istype(Proj , /obj/item/projectile/energy/floramut))
	if(FALSE)//not_actual
		mutate()
	//else if(istype(Proj , /obj/item/projectile/energy/florayield))
	//	return myseed.bullet_act(Proj)
	else
		return ..()

/obj/machinery/hydroponics/process()
	var/needs_update = 0

	if(myseed && (myseed.loc != src))
		myseed.forceMove(src)

	if(self_sustaining)
		adjustNutri(1)
		adjustWater(rand(3,5))
		adjustWeeds(-2)
		adjustPests(-2)
		adjustToxic(-2)

	if(world.time > (lastcycle + cycledelay))
		lastcycle = world.time
		if(myseed && !dead)
			age++
			if(age < myseed.maturation)
				lastproduce = age

			needs_update = 1

			if(prob(50))
				adjustNutri(-1 / rating)

			if(nutrilevel <= 0 && !myseed.get_gene(/datum/plant_gene/trait/plant_type/weed_hardy))
				adjustHealth(-rand(1,3))

			//if(isturf(loc))
			//	var/turf/currentTurf = loc
			//	var/lightAmt = currentTurf.get_lumcount()
			//	if(myseed.get_gene(/datum/plant_gene/trait/plant_type/fungal_metabolism))
			//		if(lightAmt < 0.2)
			//			adjustHealth(-1 / rating)
			//	else
			//		if(lightAmt < 0.4)
			//			adjustHealth(-2 / rating)

			adjustWater(-rand(1,6) / rating)

			if(waterlevel <= 10 && !myseed.get_gene(/datum/plant_gene/trait/plant_type/fungal_metabolism))
				adjustHealth(-rand(0,1) / rating)
				if(waterlevel <= 0)
					adjustHealth(-rand(0,2) / rating)

			else if(waterlevel > 10 && nutrilevel > 0)
				adjustHealth(rand(1,2) / rating)
				if(myseed && prob(myseed.weed_chance))
					adjustWeeds(myseed.weed_rate)
				else if(prob(5))
					adjustWeeds(1 / rating)

			if(toxic >= 40 && toxic < 80)
				adjustHealth(-1 / rating)
				adjustToxic(-rand(1,10) / rating)
			else if(toxic >= 80)
				adjustHealth(-3)
				adjustToxic(-rand(1,10) / rating)

			else if(pestlevel >= 5)
				adjustHealth(-1 / rating)

			if(weedlevel >= 5 && !myseed.get_gene(/datum/plant_gene/trait/plant_type/weed_hardy))
				adjustHealth(-1 / rating)

			if(plant_health <= 0)
				plantdies()
				adjustWeeds(1 / rating)

			if(age > myseed.lifespan)
				adjustHealth(-rand(1,5) / rating)

			if(age > myseed.production && (age - lastproduce) > myseed.production && (!harvest && !dead))
				nutrimentMutation()
				if(myseed && myseed.yield != -1)
					harvest = 1
				else
					lastproduce = age
			if(prob(5))
				adjustPests(1 / rating)
		else
			if(waterlevel > 10 && nutrilevel > 0 && prob(10))
				adjustWeeds(1 / rating)

		if(weedlevel >= 10 && prob(50))
			if(myseed)
				if(!myseed.get_gene(/datum/plant_gene/trait/plant_type/weed_hardy) && !myseed.get_gene(/datum/plant_gene/trait/plant_type/fungal_metabolism))
					weedinvasion()
			else
				weedinvasion()
			needs_update = 1
		if (needs_update)
			update_icon()
	return

/obj/machinery/hydroponics/proc/nutrimentMutation()
	if (mutmod == 0)
		return
	if (mutmod == 1)
		if(prob(80))
			mutate()
		else if(prob(75))
			hardmutate()
		return
	if (mutmod == 2)
		if(prob(50))
			mutate()
		else if(prob(50))
			hardmutate()
		else if(prob(50))
			mutatespecie()
		return
	return

/obj/machinery/hydroponics/update_icon()
	cut_overlays()

	if(self_sustaining)
		if(istype(src, /obj/machinery/hydroponics/soil))
			add_atom_colour(rgb(255, 175, 0), FIXED_COLOUR_PRIORITY)
		else
			add_overlay(mutable_appearance('icons/obj/hydroponics/equipment.dmi', "gaia_blessing"))
		set_light(3)

	update_icon_hoses()

	if(myseed)
		update_icon_plant()
		update_icon_lights()

	if(!self_sustaining)
		//if(myseed && myseed.get_gene(/datum/plant_gene/trait/glow))
		if(FALSE)//not_actual
			//var/datum/plant_gene/trait/glow/G = myseed.get_gene(/datum/plant_gene/trait/glow)
			//set_light(G.glow_range(myseed), G.glow_power(myseed), G.glow_color)
		else
			set_light(0)

	return

/obj/machinery/hydroponics/proc/update_icon_hoses()
	var/n = 0
	for(var/Dir in GLOB.cardinals)
		var/obj/machinery/hydroponics/t = locate() in get_step(src,Dir)
		if(t && t.using_irrigation && using_irrigation)
			n += Dir

	icon_state = "hoses-[n]"

/obj/machinery/hydroponics/proc/update_icon_plant()
	var/mutable_appearance/plant_overlay = mutable_appearance(myseed.growing_icon, layer = OBJ_LAYER + 0.01)
	if(dead)
		plant_overlay.icon_state = myseed.icon_dead
	else if(harvest)
		if(!myseed.icon_harvest)
			plant_overlay.icon_state = "[myseed.icon_grow][myseed.growthstages]"
		else
			plant_overlay.icon_state = myseed.icon_harvest
	else
		var/t_growthstate = min(round((age / myseed.maturation) * myseed.growthstages), myseed.growthstages)
		plant_overlay.icon_state = "[myseed.icon_grow][t_growthstate]"
	add_overlay(plant_overlay)

/obj/machinery/hydroponics/proc/update_icon_lights()
	if(waterlevel <= 10)
		add_overlay(mutable_appearance('icons/obj/hydroponics/equipment.dmi', "over_lowwater3"))
	if(nutrilevel <= 2)
		add_overlay(mutable_appearance('icons/obj/hydroponics/equipment.dmi', "over_lownutri3"))
	if(plant_health <= (myseed.endurance / 2))
		add_overlay(mutable_appearance('icons/obj/hydroponics/equipment.dmi', "over_lowhealth3"))
	if(weedlevel >= 5 || pestlevel >= 5 || toxic >= 40)
		add_overlay(mutable_appearance('icons/obj/hydroponics/equipment.dmi', "over_alert3"))
	if(harvest)
		add_overlay(mutable_appearance('icons/obj/hydroponics/equipment.dmi', "over_harvest3"))


/obj/machinery/hydroponics/examine(user)
	..()
	if(myseed)
		to_chat(user, "<span class='info'>It has <span class='name'>[myseed.plantname]</span> planted.</span>")
		if (dead)
			to_chat(user, "<span class='warning'>It's dead!</span>")
		else if (harvest)
			to_chat(user, "<span class='info'>It's ready to harvest.</span>")
		else if (plant_health <= (myseed.endurance / 2))
			to_chat(user, "<span class='warning'>It looks unhealthy.</span>")
	else
		to_chat(user, "<span class='info'>It's empty.</span>")

	if(!self_sustaining)
		to_chat(user, "<span class='info'>Water: [waterlevel]/[maxwater].</span>")
		to_chat(user, "<span class='info'>Nutrient: [nutrilevel]/[maxnutri].</span>")
		if(self_sufficiency_progress > 0)
			var/percent_progress = round(self_sufficiency_progress * 100 / self_sufficiency_req)
			to_chat(user, "<span class='info'>Treatment for self-sustenance are [percent_progress]% complete.</span>")
	else
		to_chat(user, "<span class='info'>It doesn't require any water or nutrients.</span>")

	if(weedlevel >= 5)
		to_chat(user, "<span class='warning'>It's filled with weeds!</span>")
	if(pestlevel >= 5)
		to_chat(user, "<span class='warning'>It's filled with tiny worms!</span>")
	to_chat(user, "" )

/obj/machinery/hydroponics/proc/weedinvasion()
	dead = 0
	var/oldPlantName
	if(myseed)
		oldPlantName = myseed.plantname
		qdel(myseed)
		myseed = null
	else
		oldPlantName = "empty tray"
	//switch(rand(1,18))
	//	if(16 to 18)
	//		myseed = new /obj/item/seeds/reishi(src)
	//	if(14 to 15)
	//		myseed = new /obj/item/seeds/nettle(src)
	//	if(12 to 13)
	//		myseed = new /obj/item/seeds/harebell(src)
	//	if(10 to 11)
	//		myseed = new /obj/item/seeds/amanita(src)
	//	if(8 to 9)
	//		myseed = new /obj/item/seeds/chanter(src)
	//	if(6 to 7)
	//		myseed = new /obj/item/seeds/tower(src)
	//	if(4 to 5)
	//		myseed = new /obj/item/seeds/plump(src)
	//	else
	//		myseed = new /obj/item/seeds/starthistle(src)
	myseed = new /obj/item/seeds/starthistle(src)//not_actual
	age = 0
	plant_health = myseed.endurance
	lastcycle = world.time
	harvest = 0
	weedlevel = 0
	pestlevel = 0
	update_icon()
	visible_message("<span class='warning'>The [oldPlantName] is overtaken by some [myseed.plantname]!</span>")

/obj/machinery/hydroponics/proc/mutate(lifemut = 2, endmut = 5, productmut = 1, yieldmut = 2, potmut = 25, wrmut = 2, wcmut = 5, traitmut = 0)
	if(!myseed)
		return
	myseed.mutate(lifemut, endmut, productmut, yieldmut, potmut, wrmut, wcmut, traitmut)

/obj/machinery/hydroponics/proc/hardmutate()
	mutate(4, 10, 2, 4, 50, 4, 10, 3)


/obj/machinery/hydroponics/proc/mutatespecie()
	if(!myseed || dead)
		return

	var/oldPlantName = myseed.plantname
	if(myseed.mutatelist.len > 0)
		var/mutantseed = pick(myseed.mutatelist)
		qdel(myseed)
		myseed = null
		myseed = new mutantseed
	else
		return

	hardmutate()
	age = 0
	plant_health = myseed.endurance
	lastcycle = world.time
	harvest = 0
	weedlevel = 0

	sleep(5)
	update_icon()
	visible_message("<span class='warning'>[oldPlantName] suddenly mutates into [myseed.plantname]!</span>")

/obj/machinery/hydroponics/proc/mutateweed()
	if( weedlevel > 5 )
		if(myseed)
			qdel(myseed)
			myseed = null
		//var/newWeed = pick(/obj/item/seeds/liberty, /obj/item/seeds/angel, /obj/item/seeds/nettle/death, /obj/item/seeds/kudzu)
		var/newWeed = pick(/obj/item/seeds/liberty)//not_actual
		myseed = new newWeed
		dead = 0
		hardmutate()
		age = 0
		plant_health = myseed.endurance
		lastcycle = world.time
		harvest = 0
		weedlevel = 0

		sleep(5)
		update_icon()
		visible_message("<span class='warning'>The mutated weeds in [src] spawn some [myseed.plantname]!</span>")
	else
		to_chat(usr, "<span class='warning'>The few weeds in [src] seem to react, but only for a moment...</span>")

/obj/machinery/hydroponics/proc/plantdies()
	plant_health = 0
	harvest = 0
	pestlevel = 0
	if(!dead)
		update_icon()
		dead = 1

/obj/machinery/hydroponics/proc/mutatepest(mob/user)
	if(pestlevel > 5)
		//message_admins("[ADMIN_LOOKUPFLW(user)] caused spiderling pests to spawn in a hydro tray")
		log_game("[key_name(user)] caused spiderling pests to spawn in a hydro tray")
		visible_message("<span class='warning'>The pests seem to behave oddly...</span>")
		//spawn_atom_to_turf(/obj/structure/spider/spiderling/hunter, src, 3, FALSE)
	else
		to_chat(user, "<span class='warning'>The pests seem to behave oddly, but quickly settle down...</span>")

/obj/machinery/hydroponics/proc/applyChemicals(datum/reagents/S, mob/user)
	if(myseed)
		myseed.on_chem_reaction(S)

	if(S.has_reagent("mutagen", 5) || S.has_reagent("radium", 10) || S.has_reagent("uranium", 10))
		//switch(rand(100))
		//	if(91 to 100)
		//		adjustHealth(-10)
		//		to_chat(user, "<span class='warning'>The plant shrivels and burns.</span>")
		//	if(81 to 90)
		//		mutatespecie()
		//	if(66 to 80)
		//		hardmutate()
		//	if(41 to 65)
		//		mutate()
		//	if(21 to 41)
		//		to_chat(user, "<span class='notice'>The plants don't seem to react...</span>")
		//	if(11 to 20)
		//		mutateweed()
		//	if(1 to 10)
		//		mutatepest(user)
		//	else
		//		to_chat(user, "<span class='notice'>Nothing happens...</span>")
		//not_actual
		var/r = rand(1, 100)
		if (r <= 10)
			mutatepest(user)
		else if (r <= 20)
			mutateweed()
		else if (r <= 41)
			to_chat(user, "<span class='notice'>The plants don't seem to react...</span>")
		else if (r <= 65)
			mutate()
		else if (r <= 80)
			hardmutate()
		else if (r <= 90)
			mutatespecie()
		else
			adjustHealth(-10)
			to_chat(user, "<span class='warning'>The plant shrivels and burns.</span>")

	else if(S.has_reagent("mutagen", 2) || S.has_reagent("radium", 5) || S.has_reagent("uranium", 5))
		hardmutate()
	else if(S.has_reagent("mutagen", 1) || S.has_reagent("radium", 2) || S.has_reagent("uranium", 2))
		mutate()

	if(S.has_reagent("uranium", 1))
		adjustHealth(-round(S.get_reagent_amount("uranium") * 1))
		adjustToxic(round(S.get_reagent_amount("uranium") * 2))
	if(S.has_reagent("radium", 1))
		adjustHealth(-round(S.get_reagent_amount("radium") * 1))
		adjustToxic(round(S.get_reagent_amount("radium") * 3))

	if(S.has_reagent("eznutriment", 1))
		yieldmod = 1
		mutmod = 1
		adjustNutri(round(S.get_reagent_amount("eznutriment") * 1))

	//if(S.has_reagent("left4zednutriment", 1))
	//	yieldmod = 0
	//	mutmod = 2
	//	adjustNutri(round(S.get_reagent_amount("left4zednutriment") * 1))

	//if(S.has_reagent("robustharvestnutriment", 1))
	//	yieldmod = 1.3
	//	mutmod = 0
	//	adjustNutri(round(S.get_reagent_amount("robustharvestnutriment") *1 ))

	//if(S.has_reagent("earthsblood"))
	//	self_sufficiency_progress += S.get_reagent_amount("earthsblood")
	//	if(self_sufficiency_progress >= self_sufficiency_req)
	//		become_self_sufficient()
	//	else if(!self_sustaining)
	//		to_chat(user, "<span class='notice'>[src] warms as it might on a spring day under a genuine Sun.</span>")

	if(S.has_reagent("charcoal", 1))
		adjustToxic(-round(S.get_reagent_amount("charcoal") * 2))

	if(S.has_reagent("toxin", 1))
		adjustToxic(round(S.get_reagent_amount("toxin") * 2))

	//if(S.has_reagent("milk", 1))
	//	adjustNutri(round(S.get_reagent_amount("milk") * 0.1))
	//	adjustWater(round(S.get_reagent_amount("milk") * 0.9))

	//if(S.has_reagent("beer", 1))
	//	adjustHealth(-round(S.get_reagent_amount("beer") * 0.05))
	//	adjustNutri(round(S.get_reagent_amount("beer") * 0.25))
	//	adjustWater(round(S.get_reagent_amount("beer") * 0.7))

	if(S.has_reagent("fluorine", 1))
		adjustHealth(-round(S.get_reagent_amount("fluorine") * 2))
		adjustToxic(round(S.get_reagent_amount("fluorine") * 2.5))
		adjustWater(-round(S.get_reagent_amount("fluorine") * 0.5))
		adjustWeeds(-rand(1,4))

	if(S.has_reagent("chlorine", 1))
		adjustHealth(-round(S.get_reagent_amount("chlorine") * 1))
		adjustToxic(round(S.get_reagent_amount("chlorine") * 1.5))
		adjustWater(-round(S.get_reagent_amount("chlorine") * 0.5))
		adjustWeeds(-rand(1,3))

	if(S.has_reagent("phosphorus", 1))
		adjustHealth(-round(S.get_reagent_amount("phosphorus") * 0.75))
		adjustNutri(round(S.get_reagent_amount("phosphorus") * 0.1))
		adjustWater(-round(S.get_reagent_amount("phosphorus") * 0.5))
		adjustWeeds(-rand(1,2))

	if(S.has_reagent("sugar", 1))
		adjustWeeds(rand(1,2))
		adjustPests(rand(1,2))
		adjustNutri(round(S.get_reagent_amount("sugar") * 0.1))

	if(S.has_reagent("water", 1))
		adjustWater(round(S.get_reagent_amount("water") * 1))

	//if(S.has_reagent("holywater", 1))
	//	adjustWater(round(S.get_reagent_amount("holywater") * 1))
	//	adjustHealth(round(S.get_reagent_amount("holywater") * 0.1))

	//if(S.has_reagent("sodawater", 1))
	//	adjustWater(round(S.get_reagent_amount("sodawater") * 1))
	//	adjustHealth(round(S.get_reagent_amount("sodawater") * 0.1))
	//	adjustNutri(round(S.get_reagent_amount("sodawater") * 0.1))

	if(S.has_reagent("sacid", 1))
		adjustHealth(-round(S.get_reagent_amount("sacid") * 1))
		adjustToxic(round(S.get_reagent_amount("sacid") * 1.5))
		adjustWeeds(-rand(1,2))

	if(S.has_reagent("facid", 1))
		adjustHealth(-round(S.get_reagent_amount("facid") * 2))
		adjustToxic(round(S.get_reagent_amount("facid") * 3))
		adjustWeeds(-rand(1,4))

	//if(S.has_reagent("plantbgone", 1))
	//	adjustHealth(-round(S.get_reagent_amount("plantbgone") * 5))
	//	adjustToxic(round(S.get_reagent_amount("plantbgone") * 6))
	//	adjustWeeds(-rand(4,8))

	//if(S.has_reagent("napalm", 1))
	//	if(!(myseed.resistance_flags & FIRE_PROOF))
	//		adjustHealth(-round(S.get_reagent_amount("napalm") * 6))
	//		adjustToxic(round(S.get_reagent_amount("napalm") * 7))
	//		adjustWeeds(-rand(5,9))

	//if(S.has_reagent("weedkiller", 1))
	//	adjustToxic(round(S.get_reagent_amount("weedkiller") * 0.5))
	//	adjustWeeds(-rand(1,2))

	//if(S.has_reagent("pestkiller", 1))
	//	adjustToxic(round(S.get_reagent_amount("pestkiller") * 0.5))
	//	adjustPests(-rand(1,2))

	//if(S.has_reagent("cryoxadone", 1))
	//	adjustHealth(round(S.get_reagent_amount("cryoxadone") * 3))
	//	adjustToxic(-round(S.get_reagent_amount("cryoxadone") * 3))

	if(S.has_reagent("ammonia", 1))
		adjustHealth(round(S.get_reagent_amount("ammonia") * 0.5))
		adjustNutri(round(S.get_reagent_amount("ammonia") * 1))
		if(myseed)
			myseed.adjust_yield(round(S.get_reagent_amount("ammonia") * 0.01))

	if(S.has_reagent("saltpetre", 1))
		var/salt = S.get_reagent_amount("saltpetre")
		adjustHealth(round(salt * 0.25))
		if (myseed)
			myseed.adjust_production(-round(salt/100)-prob(salt%100))
			myseed.adjust_potency(round(salt*0.5))
	
	if(S.has_reagent("ash", 1))
		adjustHealth(round(S.get_reagent_amount("ash") * 0.25))
		adjustNutri(round(S.get_reagent_amount("ash") * 0.5))
		adjustWeeds(-1)

	if(S.has_reagent("diethylamine", 1))
		adjustHealth(round(S.get_reagent_amount("diethylamine") * 1))
		adjustNutri(round(S.get_reagent_amount("diethylamine") * 2))
		if(myseed)
			myseed.adjust_yield(round(S.get_reagent_amount("diethylamine") * 0.02))
		adjustPests(-rand(1,2))

	if(S.has_reagent("nutriment", 1))
		adjustHealth(round(S.get_reagent_amount("nutriment") * 0.5))
		adjustNutri(round(S.get_reagent_amount("nutriment") * 1))

	//if(S.has_reagent("virusfood", 1))
	//	adjustNutri(round(S.get_reagent_amount("virusfood") * 0.5))
	//	adjustHealth(-round(S.get_reagent_amount("virusfood") * 0.5))

	if(S.has_reagent("blood", 1))
		adjustNutri(round(S.get_reagent_amount("blood") * 1))
		adjustPests(rand(2,4))

	//if(S.has_reagent("strangereagent", 1))
	//	spawnplant()

	//if(S.has_reagent("adminordrazine", 1))
	//	adjustWater(round(S.get_reagent_amount("adminordrazine") * 1))
	//	adjustHealth(round(S.get_reagent_amount("adminordrazine") * 1))
	//	adjustNutri(round(S.get_reagent_amount("adminordrazine") * 1))
	//	adjustPests(-rand(1,5))
	//	adjustWeeds(-rand(1,5))
	//if(S.has_reagent("adminordrazine", 5))
	//	switch(rand(100))
	//		if(66  to 100)
	//			mutatespecie()
	//		if(33	to 65)
	//			mutateweed()
	//		if(1   to 32)
	//			mutatepest(user)
	//		else
	//			to_chat(user, "<span class='warning'>Nothing happens...</span>")

/obj/machinery/hydroponics/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/reagent_containers) )
		var/obj/item/reagent_containers/reagent_source = O

		if(istype(reagent_source, /obj/item/reagent_containers/syringe))
			var/obj/item/reagent_containers/syringe/syr = reagent_source
			if(syr.mode != 1)
				to_chat(user, "<span class='warning'>You can't get any extract out of this plant.</span>"		)
				return

		if(!reagent_source.reagents.total_volume)
			to_chat(user, "<span class='notice'>[reagent_source] is empty.</span>")
			return 1

		var/list/trays = list(src)
		var/target = myseed ? myseed.plantname : src
		var/visi_msg = ""
		var/irrigate = 0
		var/transfer_amount

		//if(istype(reagent_source, /obj/item/reagent_containers/food/snacks) || istype(reagent_source, /obj/item/reagent_containers/pill))
		if(istype(reagent_source, /obj/item/reagent_containers/food/snacks))//not_actual
			visi_msg="[user] composts [reagent_source], spreading it through [target]"
			transfer_amount = reagent_source.reagents.total_volume
		else
			transfer_amount = reagent_source.amount_per_transfer_from_this
			if(istype(reagent_source, /obj/item/reagent_containers/syringe/))
				var/obj/item/reagent_containers/syringe/syr = reagent_source
				visi_msg="[user] injects [target] with [syr]"
				if(syr.reagents.total_volume <= syr.amount_per_transfer_from_this)
					syr.mode = 0
			//else if(istype(reagent_source, /obj/item/reagent_containers/spray/))
			//	visi_msg="[user] sprays [target] with [reagent_source]"
			//	playsound(loc, 'sound/effects/spray3.ogg', 50, 1, -6)
			//	irrigate = 1
			else if(transfer_amount)
				visi_msg="[user] uses [reagent_source] on [target]"
				irrigate = 1
			if(reagent_source.is_drainable())
				playsound(loc, 'sound/effects/slosh.ogg', 25, 1)

		//if(irrigate && transfer_amount > 30 && reagent_source.reagents.total_volume >= 30 && using_irrigation)
		//	trays = FindConnected()
		//	if (trays.len > 1)
		//		visi_msg += ", setting off the irrigation system"

		if(visi_msg)
			visible_message("<span class='notice'>[visi_msg].</span>")

		var/split = round(transfer_amount/trays.len)

		for(var/obj/machinery/hydroponics/H in trays)

			var/datum/reagents/S = new /datum/reagents()
			S.my_atom = H

			reagent_source.reagents.trans_to(S,split, transfered_by = user)
			//if(istype(reagent_source, /obj/item/reagent_containers/food/snacks) || istype(reagent_source, /obj/item/reagent_containers/pill))
			if(istype(reagent_source, /obj/item/reagent_containers/food/snacks))//not_actual
				qdel(reagent_source)

			H.applyChemicals(S, user)

			S.clear_reagents()
			qdel(S)
			H.update_icon()
		if(reagent_source)
			reagent_source.update_icon()
		return 1

	else if(istype(O, /obj/item/seeds) && !istype(O, /obj/item/seeds/sample))
		if(!myseed)
			//if(istype(O, /obj/item/seeds/kudzu))
			//	investigate_log("had Kudzu planted in it by [key_name(user)] at [AREACOORD(src)]","kudzu")
			if(!user.transferItemToLoc(O, src))
				return
			to_chat(user, "<span class='notice'>You plant [O].</span>")
			dead = 0
			myseed = O
			age = 1
			plant_health = myseed.endurance
			lastcycle = world.time
			update_icon()
		else
			to_chat(user, "<span class='warning'>[src] already has seeds in it!</span>")

	else if(istype(O, /obj/item/plant_analyzer))
		if(myseed)
			to_chat(user, "*** <B>[myseed.plantname]</B> ***" )
			to_chat(user, "- Plant Age: <span class='notice'>[age]</span>")
			var/list/text_string = myseed.get_analyzer_text()
			if(text_string)
				to_chat(user, text_string)
		else
			to_chat(user, "<B>No plant found.</B>")
		to_chat(user, "- Weed level: <span class='notice'>[weedlevel] / 10</span>")
		to_chat(user, "- Pest level: <span class='notice'>[pestlevel] / 10</span>")
		to_chat(user, "- Toxicity level: <span class='notice'>[toxic] / 100</span>")
		to_chat(user, "- Water level: <span class='notice'>[waterlevel] / [maxwater]</span>")
		to_chat(user, "- Nutrition level: <span class='notice'>[nutrilevel] / [maxnutri]</span>")
		to_chat(user, "")

	else if(istype(O, /obj/item/cultivator))
		if(weedlevel > 0)
			user.visible_message("[user] uproots the weeds.", "<span class='notice'>You remove the weeds from [src].</span>")
			weedlevel = 0
			update_icon()
		else
			to_chat(user, "<span class='warning'>This plot is completely devoid of weeds! It doesn't need uprooting.</span>")

	//else if(istype(O, /obj/item/storage/bag/plants))
	//	attack_hand(user)
	//	for(var/obj/item/reagent_containers/food/snacks/grown/G in locate(user.x,user.y,user.z))
	//		SEND_SIGNAL(O, COMSIG_TRY_STORAGE_INSERT, G, user, TRUE)

	else if(default_unfasten_wrench(user, O))
		return

	else if((O.tool_behaviour == TOOL_WIRECUTTER) && unwrenchable)
		if (!anchored)
			to_chat(user, "<span class='warning'>Anchor the tray first!</span>")
			return
		using_irrigation = !using_irrigation
		O.play_tool_sound(src)
		user.visible_message("<span class='notice'>[user] [using_irrigation ? "" : "dis"]connects [src]'s irrigation hoses.</span>", \
		"<span class='notice'>You [using_irrigation ? "" : "dis"]connect [src]'s irrigation hoses.</span>")
		for(var/obj/machinery/hydroponics/h in range(1,src))
			h.update_icon()

	//else if(istype(O, /obj/item/shovel/spade))
	//	if(!myseed && !weedlevel)
	//		to_chat(user, "<span class='warning'>[src] doesn't have any plants or weeds!</span>")
	//		return
	//	user.visible_message("<span class='notice'>[user] starts digging out [src]'s plants...</span>",
	//		"<span class='notice'>You start digging out [src]'s plants...</span>")
	//	if(O.use_tool(src, user, 50, volume=50) || (!myseed && !weedlevel))
	//		user.visible_message("<span class='notice'>[user] digs out the plants in [src]!</span>", "<span class='notice'>You dig out all of [src]'s plants!</span>")
	//		if(myseed)
	//			age = 0
	//			plant_health = 0
	//			if(harvest)
	//				harvest = FALSE
	//			qdel(myseed)
	//			myseed = null
	//		weedlevel = 0
	//		update_icon()

	else
		return ..()

/obj/machinery/hydroponics/can_be_unfasten_wrench(mob/user, silent)
	if (!unwrenchable)
		return CANT_UNFASTEN

	if (using_irrigation)
		if (!silent)
			to_chat(user, "<span class='warning'>Disconnect the hoses first!</span>")
		return FAILED_UNFASTEN

	return ..()

/obj/machinery/hydroponics/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(issilicon(user))
		return
	if(harvest)
		return myseed.harvest(user)

	else if(dead)
		dead = 0
		to_chat(user, "<span class='notice'>You remove the dead plant from [src].</span>")
		qdel(myseed)
		myseed = null
		update_icon()
	else
		if(user)
			examine(user)

/obj/machinery/hydroponics/proc/update_tray(mob/user)
	harvest = 0
	lastproduce = age
	//if(istype(myseed, /obj/item/seeds/replicapod))
	if(FALSE)//not_actual
		to_chat(user, "<span class='notice'>You harvest from the [myseed.plantname].</span>")
	else if(myseed.getYield() <= 0)
		to_chat(user, "<span class='warning'>You fail to harvest anything useful!</span>")
	else
		to_chat(user, "<span class='notice'>You harvest [myseed.getYield()] items from the [myseed.plantname].</span>")
	if(!myseed.get_gene(/datum/plant_gene/trait/repeated_harvest))
		qdel(myseed)
		myseed = null
		dead = 0
	update_icon()

obj/machinery/hydroponics/proc/adjustNutri(adjustamt)
	nutrilevel = CLAMP(nutrilevel + adjustamt, 0, maxnutri)

/obj/machinery/hydroponics/proc/adjustWater(adjustamt)
	waterlevel = CLAMP(waterlevel + adjustamt, 0, maxwater)

	if(adjustamt>0)
		adjustToxic(-round(adjustamt/4))

/obj/machinery/hydroponics/proc/adjustHealth(adjustamt)
	if(myseed && !dead)
		plant_health = CLAMP(plant_health + adjustamt, 0, myseed.endurance)

/obj/machinery/hydroponics/proc/adjustToxic(adjustamt)
	toxic = CLAMP(toxic + adjustamt, 0, 100)

/obj/machinery/hydroponics/proc/adjustPests(adjustamt)
	pestlevel = CLAMP(pestlevel + adjustamt, 0, 10)

/obj/machinery/hydroponics/proc/adjustWeeds(adjustamt)
	weedlevel = CLAMP(weedlevel + adjustamt, 0, 10)

/obj/machinery/hydroponics/soil
	name = "soil"
	desc = "A patch of dirt."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "soil"
	circuit = null
	density = FALSE
	use_power = NO_POWER_USE
	flags_1 = NODECONSTRUCT_1
	unwrenchable = FALSE

/obj/machinery/hydroponics/soil/update_icon_hoses()
	return

/obj/machinery/hydroponics/soil/update_icon_lights()
	return

///obj/machinery/hydroponics/soil/attackby(obj/item/O, mob/user, params)
//	if(O.tool_behaviour == TOOL_SHOVEL && !istype(O, /obj/item/shovel/spade))
//		to_chat(user, "<span class='notice'>You clear up [src]!</span>")
//		qdel(src)
//	else
//		return ..()