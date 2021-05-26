/datum/objective_item
	var/name = "A silly bike horn! Honk!"
	var/targetitem = /obj/item/bikehorn
	var/difficulty = 9001
	var/list/excludefromjob = list()
	var/list/altitems = list()
	var/list/special_equipment = list()

/datum/objective_item/proc/check_special_completion()
	return 1

/datum/objective_item/proc/TargetExists()
	return TRUE

/datum/objective_item/steal/New()
	..()
	if(TargetExists())
		GLOB.possible_items += src
	else
		qdel(src)

/datum/objective_item/steal/Destroy()
	GLOB.possible_items -= src
	return ..()

/datum/objective_item/steal/caplaser
	name = "the captain's antique laser gun."
	//targetitem = /obj/item/gun/energy/laser/captain
	targetitem = /obj/item/wrench//not_actual
	difficulty = 5
	excludefromjob = list("Captain")