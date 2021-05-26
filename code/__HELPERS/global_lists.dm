GLOBAL_LIST_EMPTY(emote_list)//not_actual

/proc/make_datum_references_lists()
	init_sprite_accessory_subtypes(/datum/sprite_accessory/hair, GLOB.hair_styles_list, GLOB.hair_styles_male_list, GLOB.hair_styles_female_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/facial_hair, GLOB.facial_hair_styles_list, GLOB.facial_hair_styles_male_list, GLOB.facial_hair_styles_female_list)
	//init_sprite_accessory_subtypes(/datum/sprite_accessory/underwear, GLOB.underwear_list, GLOB.underwear_m, GLOB.underwear_f)
	//init_sprite_accessory_subtypes(/datum/sprite_accessory/undershirt, GLOB.undershirt_list, GLOB.undershirt_m, GLOB.undershirt_f)
	//init_sprite_accessory_subtypes(/datum/sprite_accessory/socks, GLOB.socks_list)
	//init_sprite_accessory_subtypes(/datum/sprite_accessory/body_markings, GLOB.body_markings_list)
	//init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/lizard, GLOB.tails_list_lizard)
	//init_sprite_accessory_subtypes(/datum/sprite_accessory/tails_animated/lizard, GLOB.animated_tails_list_lizard)
	//init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/human, GLOB.tails_list_human)
	//init_sprite_accessory_subtypes(/datum/sprite_accessory/tails_animated/human, GLOB.animated_tails_list_human)
	//init_sprite_accessory_subtypes(/datum/sprite_accessory/snouts, GLOB.snouts_list)
	//init_sprite_accessory_subtypes(/datum/sprite_accessory/horns,GLOB.horns_list)
	//init_sprite_accessory_subtypes(/datum/sprite_accessory/ears, GLOB.ears_list)
	//init_sprite_accessory_subtypes(/datum/sprite_accessory/wings, GLOB.wings_list)
	//init_sprite_accessory_subtypes(/datum/sprite_accessory/wings_open, GLOB.wings_open_list)
	//init_sprite_accessory_subtypes(/datum/sprite_accessory/frills, GLOB.frills_list)
	//init_sprite_accessory_subtypes(/datum/sprite_accessory/spines, GLOB.spines_list)
	//init_sprite_accessory_subtypes(/datum/sprite_accessory/spines_animated, GLOB.animated_spines_list)
	//init_sprite_accessory_subtypes(/datum/sprite_accessory/legs, GLOB.legs_list)
	//init_sprite_accessory_subtypes(/datum/sprite_accessory/wings, GLOB.r_wings_list,roundstart = TRUE)
	//init_sprite_accessory_subtypes(/datum/sprite_accessory/caps, GLOB.caps_list)
	//init_sprite_accessory_subtypes(/datum/sprite_accessory/moth_wings, GLOB.moth_wings_list)


	for(var/spath in subtypesof(/datum/species))
		var/datum/species/S = new spath()
		GLOB.species_list[S.id] = spath

	//for(var/path in subtypesof(/datum/surgery))
	//	GLOB.surgeries_list += new path()

	for(var/path in subtypesof(/datum/material))
		var/datum/material/D = new path()
		GLOB.materials_list[D.id] = D

	for(var/path in subtypesof(/datum/emote))
		var/datum/emote/E = new path()
		//E.emote_list[E.key] = E
		GLOB.emote_list[E.key] = E//not_actual

	//init_subtypes(/datum/crafting_recipe, GLOB.crafting_recipes)

/proc/init_subtypes(prototype, list/L)
	if(!istype(L))
		L = list()
	for(var/path in subtypesof(prototype))
		L += new path()
	return L