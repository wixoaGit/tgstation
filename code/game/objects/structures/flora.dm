/obj/item/twohanded/required/kirbyplants
	name = "potted plant"
	icon = 'icons/obj/flora/plants.dmi'
	icon_state = "plant-01"
	desc = "A little bit of nature contained in a pot."
	layer = ABOVE_MOB_LAYER
	w_class = WEIGHT_CLASS_HUGE
	force = 10
	throwforce = 13
	throw_speed = 2
	throw_range = 4


/obj/item/twohanded/required/kirbyplants/equipped(mob/living/user)
	//var/image/I = image(icon = 'icons/obj/flora/plants.dmi' , icon_state = src.icon_state, loc = user)
	//I.copy_overlays(src)
	//I.override = 1
	//add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/everyone, "sneaking_mission", I)
	//I.layer = ABOVE_MOB_LAYER
	..()

/obj/item/twohanded/required/kirbyplants/dropped(mob/living/user)
	..()
	//user.remove_alt_appearance("sneaking_mission")

/obj/item/twohanded/required/kirbyplants/random
	icon = 'icons/obj/flora/_flora.dmi'
	icon_state = "random_plant"
	//var/list/static/states
	var/list/states //not_actual

/obj/item/twohanded/required/kirbyplants/random/Initialize()
	. = ..()
	icon = 'icons/obj/flora/plants.dmi'
	if(!states)
		generate_states()
	icon_state = pick(states)

/obj/item/twohanded/required/kirbyplants/random/proc/generate_states()
	states = list()
	for(var/i in 1 to 25)
		var/number
		if(i < 10)
			number = "0[i]"
		else
			number = "[i]"
		states += "plant-[number]"
	states += "applebush"


/obj/item/twohanded/required/kirbyplants/dead
	name = "RD's potted plant"
	desc = "A gift from the botanical staff, presented after the RD's reassignment. There's a tag on it that says \"Y'all come back now, y'hear?\"\nIt doesn't look very healthy..."
	icon_state = "plant-25"

/obj/item/twohanded/required/kirbyplants/photosynthetic
	name = "photosynthetic potted plant"
	desc = "A bioluminescent plant."
	icon_state = "plant-09"
	light_color = "#2cb2e8"
	light_range = 3