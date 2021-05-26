/obj/item/seeds/starthistle
	name = "pack of starthistle seeds"
	desc = "A robust species of weed that often springs up in-between the cracks of spaceship parking lots."
	icon_state = "seed-starthistle"
	species = "starthistle"
	plantname = "Starthistle"
	lifespan = 70
	endurance = 50
	maturation = 5
	production = 1
	yield = 2
	potency = 10
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'
	genes = list(/datum/plant_gene/trait/plant_type/weed_hardy)
	//mutatelist = list(/obj/item/seeds/harebell)

/obj/item/seeds/starthistle/harvest(mob/user)
	var/obj/machinery/hydroponics/parent = loc
	var/seed_count = yield
	if(prob(getYield() * 20))
		seed_count++
		var/output_loc = parent.Adjacent(user) ? user.loc : parent.loc
		for(var/i in 1 to seed_count)
			var/obj/item/seeds/starthistle/harvestseeds = Copy()
			harvestseeds.forceMove(output_loc)

	parent.update_tray()