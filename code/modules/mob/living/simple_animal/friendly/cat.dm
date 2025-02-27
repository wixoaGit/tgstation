/mob/living/simple_animal/pet/cat
	name = "cat"
	desc = "Kitty!!"
	icon = 'icons/mob/pets.dmi'
	icon_state = "cat2"
	icon_living = "cat2"
	icon_dead = "cat2_dead"
	gender = MALE
	speak = list("Meow!", "Esp!", "Purr!", "HSSSSS")
	speak_emote = list("purrs", "meows")
	emote_hear = list("meows.", "mews.")
	emote_see = list("shakes its head.", "shivers.")
	speak_chance = 1
	turns_per_move = 5
	//see_in_dark = 6
	//ventcrawler = VENTCRAWLER_ALWAYS
	pass_flags = PASSTABLE
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	minbodytemp = 200
	maxbodytemp = 400
	//unsuitable_atmos_damage = 1
	animal_species = /mob/living/simple_animal/pet/cat
	childtype = list(/mob/living/simple_animal/pet/cat/kitten)
	//butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 2, /obj/item/organ/ears/cat = 1, /obj/item/organ/tail/cat = 1)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	var/turns_since_scan = 0
	//var/mob/living/simple_animal/mouse/movement_target
	var/mob/living/movement_target //not_actual
	gold_core_spawnable = FRIENDLY_SPAWN
	collar_type = "cat"

	do_footstep = TRUE

/mob/living/simple_animal/pet/cat/Initialize()
	. = ..()
	//verbs += /mob/living/proc/lay_down

/mob/living/simple_animal/pet/cat/update_mobility()
	..()
	if(client && stat != DEAD)
		if (resting)
			icon_state = "[icon_living]_rest"
			collar_type = "[initial(collar_type)]_rest"
		else
			icon_state = "[icon_living]"
			collar_type = "[initial(collar_type)]"
	regenerate_icons()

/mob/living/simple_animal/pet/cat/space
	name = "space cat"
	desc = "It's a cat... in space!"
	icon_state = "spacecat"
	icon_living = "spacecat"
	icon_dead = "spacecat_dead"
	//unsuitable_atmos_damage = 0
	minbodytemp = TCMB
	maxbodytemp = T0C + 40

/mob/living/simple_animal/pet/cat/original
	name = "Batsy"
	desc = "The product of alien DNA and bored geneticists."
	gender = FEMALE
	icon_state = "original"
	icon_living = "original"
	icon_dead = "original_dead"
	collar_type = null
	unique_pet = TRUE

/mob/living/simple_animal/pet/cat/kitten
	name = "kitten"
	desc = "D'aaawwww."
	icon_state = "kitten"
	icon_living = "kitten"
	icon_dead = "kitten_dead"
	density = FALSE
	pass_flags = PASSMOB
	mob_size = MOB_SIZE_SMALL
	collar_type = "kitten"

/mob/living/simple_animal/pet/cat/Runtime
	name = "Runtime"
	desc = "GCAT"
	icon_state = "cat"
	icon_living = "cat"
	icon_dead = "cat_dead"
	gender = FEMALE
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
	var/list/family = list()
	var/list/children = list()
	var/cats_deployed = 0
	var/memory_saved = FALSE

/mob/living/simple_animal/pet/cat/Runtime/Initialize()
	if(prob(5))
		icon_state = "original"
		icon_living = "original"
		icon_dead = "original_dead"
	Read_Memory()
	. = ..()

/mob/living/simple_animal/pet/cat/Runtime/Life()
	if(!cats_deployed && SSticker.current_state >= GAME_STATE_SETTING_UP)
		Deploy_The_Cats()
	if(!stat && SSticker.current_state == GAME_STATE_FINISHED && !memory_saved)
		Write_Memory()
		memory_saved = TRUE
	..()

/mob/living/simple_animal/pet/cat/Runtime/make_babies()
	var/mob/baby = ..()
	if(baby)
		children += baby
		return baby

/mob/living/simple_animal/pet/cat/Runtime/death()
	if(!memory_saved)
		Write_Memory(TRUE)
	..()

/mob/living/simple_animal/pet/cat/Runtime/proc/Read_Memory()
	if(fexists("data/npc_saves/Runtime.sav"))
		//var/savefile/S = new /savefile("data/npc_saves/Runtime.sav")
		//S["family"] >> family
		fdel("data/npc_saves/Runtime.sav")
	else
		var/json_file = file("data/npc_saves/Runtime.json")
		if(!fexists(json_file))
			return
		var/list/json = json_decode(file2text(json_file))
		family = json["family"]
	if(isnull(family))
		family = list()

/mob/living/simple_animal/pet/cat/Runtime/proc/Write_Memory(dead)
	var/json_file = file("data/npc_saves/Runtime.json")
	var/list/file_data = list()
	family = list()
	if(!dead)
		for(var/mob/living/simple_animal/pet/cat/kitten/C in children)
			//if(istype(C,type) || C.stat || !C.z || !C.butcher_results)
			if(istype(C,type) || C.stat || !C.z)//not_actual
				continue
			if(C.type in family)
				family[C.type] += 1
			else
				family[C.type] = 1
	file_data["family"] = family
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

/mob/living/simple_animal/pet/cat/Runtime/proc/Deploy_The_Cats()
	cats_deployed = 1
	for(var/cat_type in family)
		if(family[cat_type] > 0)
			for(var/i in 1 to min(family[cat_type],100))
				new cat_type(loc)

/mob/living/simple_animal/pet/cat/Proc
	name = "Proc"
	gender = MALE
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

/mob/living/simple_animal/pet/cat/Life()
	if(!stat && !buckled && !client)
		if(prob(1))
			emote("me", 1, pick("stretches out for a belly rub.", "wags its tail.", "lies down."))
			icon_state = "[icon_living]_rest"
			collar_type = "[initial(collar_type)]_rest"
			set_resting(TRUE)
		else if (prob(1))
			emote("me", 1, pick("sits down.", "crouches on its hind legs.", "looks alert."))
			icon_state = "[icon_living]_sit"
			collar_type = "[initial(collar_type)]_sit"
			set_resting(TRUE)
		else if (prob(1))
			if (resting)
				emote("me", 1, pick("gets up and meows.", "walks around.", "stops resting."))
				icon_state = "[icon_living]"
				collar_type = "[initial(collar_type)]"
				set_resting(FALSE)
			else
				emote("me", 1, pick("grooms its fur.", "twitches its whiskers.", "shakes out its coat."))

	//if((src.loc) && isturf(src.loc))
	//	if(!stat && !resting && !buckled)
	//		for(var/mob/living/simple_animal/mouse/M in view(1,src))
	//			if(!M.stat && Adjacent(M))
	//				emote("me", 1, "splats \the [M]!")
	//				M.splat()
	//				movement_target = null
	//				stop_automated_movement = 0
	//				break
	//		for(var/obj/item/toy/cattoy/T in view(1,src))
	//			if (T.cooldown < (world.time - 400))
	//				emote("me", 1, "bats \the [T] around with its paw!")
	//				T.cooldown = world.time

	..()

	make_babies()

	if(!stat && !resting && !buckled)
		turns_since_scan++
		if(turns_since_scan > 5)
			walk_to(src,0)
			turns_since_scan = 0
			if((movement_target) && !(isturf(movement_target.loc) || ishuman(movement_target.loc) ))
				movement_target = null
				stop_automated_movement = 0
			if( !movement_target || !(movement_target.loc in oview(src, 3)) )
				movement_target = null
				stop_automated_movement = 0
				//for(var/mob/living/simple_animal/mouse/snack in oview(src,3))
				//	if(isturf(snack.loc) && !snack.stat)
				//		movement_target = snack
				//		break
			if(movement_target)
				stop_automated_movement = 1
				walk_to(src,movement_target,0,3)

/mob/living/simple_animal/pet/cat/attack_hand(mob/living/carbon/human/M)
	. = ..()
	switch(M.a_intent)
		if("help")
			wuv(1, M)
		if("harm")
			wuv(-1, M)

/mob/living/simple_animal/pet/cat/proc/wuv(change, mob/M)
	if(change)
		if(change > 0)
			if(M && stat != DEAD)
				new /obj/effect/temp_visual/heart(loc)
				emote("me", 1, "purrs!")
		else
			if(M && stat != DEAD)
				emote("me", 1, "hisses!")