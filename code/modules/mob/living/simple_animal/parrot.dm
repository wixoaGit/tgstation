#define PARROT_PERCH	(1<<0)
#define PARROT_SWOOP	(1<<1)
#define PARROT_WANDER	(1<<2)

#define PARROT_STEAL	(1<<3)
#define PARROT_ATTACK	(1<<4)
#define PARROT_RETURN	(1<<5)
#define PARROT_FLEE		(1<<6)

/mob/living/simple_animal/parrot
	name = "parrot"
	desc = "The parrot squaks, \"It's a Parrot! BAWWK!\""
	icon = 'icons/mob/animal.dmi'
	icon_state = "parrot_fly"
	icon_living = "parrot_fly"
	icon_dead = "parrot_dead"
	var/icon_sit = "parrot_sit"
	density = FALSE
	health = 80
	maxHealth = 80
	pass_flags = PASSTABLE | PASSMOB

	speak = list("Hi!","Hello!","Cracker?","BAWWWWK george mellons griffing me!")
	speak_emote = list("squawks","says","yells")
	emote_hear = list("squawks.","bawks!")
	emote_see = list("flutters its wings.")

	speak_chance = 1
	turns_per_move = 5
	//butcher_results = list(/obj/item/reagent_containers/food/snacks/cracker/ = 1)
	melee_damage_upper = 10
	melee_damage_lower = 5

	response_help  = "pets"
	response_disarm = "gently moves aside"
	response_harm   = "swats"
	stop_automated_movement = 1
	a_intent = INTENT_HARM
	attacktext = "chomps"
	friendly = "grooms"
	mob_size = MOB_SIZE_SMALL
	movement_type = FLYING
	gold_core_spawnable = FRIENDLY_SPAWN

	var/parrot_damage_upper = 10
	var/parrot_state = PARROT_WANDER
	var/parrot_sleep_max = 25
	var/parrot_sleep_dur = 25
	var/parrot_dam_zone = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD, BODY_ZONE_L_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_ARM, BODY_ZONE_R_LEG)

	var/parrot_speed = 5
	var/parrot_lastmove = null
	var/parrot_stuck = 0
	var/parrot_stuck_threshold = 10

	var/list/speech_buffer = list()
	var/speech_shuffle_rate = 20
	var/list/available_channels = list()

	var/obj/item/radio/headset/ears = null

	var/atom/movable/parrot_interest = null

	var/obj/parrot_perch = null
	//var/obj/desired_perches = list(/obj/structure/frame/computer, 		/obj/structure/displaycase, \
	//								/obj/structure/filingcabinet,		/obj/machinery/teleport, \
	//								/obj/machinery/computer,			/obj/machinery/clonepod, \
	//								/obj/machinery/dna_scannernew,		/obj/machinery/telecomms, \
	//								/obj/machinery/nuclearbomb,			/obj/machinery/particle_accelerator, \
	//								/obj/machinery/recharge_station,	/obj/machinery/smartfridge, \
	//								/obj/machinery/suit_storage_unit)
	var/obj/desired_perches = list(/obj/machinery/computer)//not_actual

	var/obj/item/held_item = null

/mob/living/simple_animal/parrot/Initialize()
	. = ..()
	if(!ears)
		var/headset = pick(/obj/item/radio/headset/headset_sec, \
						/obj/item/radio/headset/headset_eng, \
						/obj/item/radio/headset/headset_med, \
						/obj/item/radio/headset/headset_sci, \
						/obj/item/radio/headset/headset_cargo)
		ears = new headset(src)

	parrot_sleep_dur = parrot_sleep_max

	//verbs.Add(/mob/living/simple_animal/parrot/proc/steal_from_ground, \
	//		  /mob/living/simple_animal/parrot/proc/steal_from_mob, \
	//		  /mob/living/simple_animal/parrot/verb/drop_held_item_player, \
	//		  /mob/living/simple_animal/parrot/proc/perch_player, \
	//		  /mob/living/simple_animal/parrot/proc/toggle_mode,
	//		  /mob/living/simple_animal/parrot/proc/perch_mob_player)

/mob/living/simple_animal/parrot/examine(mob/user)
	..()
	if(stat)
		to_chat(user, pick("This parrot is no more.", "This is a late parrot.", "This is an ex-parrot."))

/mob/living/simple_animal/parrot/death(gibbed)
	if(held_item)
		held_item.forceMove(drop_location())
		held_item = null
	walk(src,0)

	//if(buckled)
	//	buckled.unbuckle_mob(src,force=1)
	buckled = null
	pixel_x = initial(pixel_x)
	pixel_y = initial(pixel_y)

	..(gibbed)

/mob/living/simple_animal/parrot/Stat()
	..()
	if(statpanel("Status"))
		stat("Held Item", held_item)
		stat("Mode",a_intent)

/mob/living/simple_animal/parrot/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, list/spans, message_mode)
	. = ..()
	if(speaker != src && prob(50))
		if(!radio_freq || prob(10))
			if(speech_buffer.len >= 500)
				speech_buffer -= pick(speech_buffer)
			speech_buffer |= html_decode(raw_message)
	if(speaker == src && !client)
		return message

/mob/living/simple_animal/parrot/radio(message, message_mode, list/spans, language)
	. = ..()
	if(. != 0)
		return .

	switch(message_mode)
		if(MODE_HEADSET)
			if (ears)
				ears.talk_into(src, message, , spans, language)
			return ITALICS | REDUCE_RANGE

		if(MODE_DEPARTMENT)
			if (ears)
				ears.talk_into(src, message, message_mode, spans, language)
			return ITALICS | REDUCE_RANGE

	if(message_mode in GLOB.radiochannels)
		if(ears)
			ears.talk_into(src, message, message_mode, spans, language)
			return ITALICS | REDUCE_RANGE

	return 0

/mob/living/simple_animal/parrot/show_inv(mob/user)
	user.set_machine(src)

	var/dat = 	"<div align='center'><b>Inventory of [name]</b></div><p>"
	dat += "<br><B>Headset:</B> <A href='?src=[REF(src)];[ears ? "remove_inv=ears'>[ears]" : "add_inv=ears'>Nothing"]</A>"

	user << browse(dat, "window=mob[REF(src)];size=325x500")
	onclose(user, "window=mob[REF(src)]")

/mob/living/simple_animal/parrot/Topic(href, href_list)
	if(!(iscarbon(usr) || iscyborg(usr)) || !usr.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		usr << browse(null, "window=mob[REF(src)]")
		usr.unset_machine()
		return

	if(href_list["remove_inv"])
		var/remove_from = href_list["remove_inv"]
		switch(remove_from)
			if("ears")
				if(!ears)
					to_chat(usr, "<span class='warning'>There is nothing to remove from its [remove_from]!</span>")
					return
				if(!stat)
					say("[available_channels.len ? "[pick(available_channels)] " : null]BAWWWWWK LEAVE THE HEADSET BAWKKKKK!")
				ears.forceMove(drop_location())
				ears = null
				for(var/possible_phrase in speak)
					if(copytext(possible_phrase,1,3) in GLOB.department_radio_keys)
						possible_phrase = copytext(possible_phrase,3)

	else if(href_list["add_inv"])
		var/add_to = href_list["add_inv"]
		if(!usr.get_active_held_item())
			to_chat(usr, "<span class='warning'>You have nothing in your hand to put on its [add_to]!</span>")
			return
		switch(add_to)
			if("ears")
				if(ears)
					to_chat(usr, "<span class='warning'>It's already wearing something!</span>")
					return
				else
					var/obj/item/item_to_add = usr.get_active_held_item()
					if(!item_to_add)
						return

					if( !istype(item_to_add,  /obj/item/radio/headset) )
						to_chat(usr, "<span class='warning'>This object won't fit!</span>")
						return

					var/obj/item/radio/headset/headset_to_add = item_to_add

					if(!usr.transferItemToLoc(headset_to_add, src))
						return
					ears = headset_to_add
					to_chat(usr, "<span class='notice'>You fit the headset onto [src].</span>")

					clearlist(available_channels)
					for(var/ch in headset_to_add.channels)
						switch(ch)
							if(RADIO_CHANNEL_ENGINEERING)
								available_channels.Add(RADIO_TOKEN_ENGINEERING)
							if(RADIO_CHANNEL_COMMAND)
								available_channels.Add(RADIO_TOKEN_COMMAND)
							if(RADIO_CHANNEL_SECURITY)
								available_channels.Add(RADIO_TOKEN_SECURITY)
							if(RADIO_CHANNEL_SCIENCE)
								available_channels.Add(RADIO_TOKEN_SCIENCE)
							if(RADIO_CHANNEL_MEDICAL)
								available_channels.Add(RADIO_TOKEN_MEDICAL)
							if(RADIO_CHANNEL_SUPPLY)
								available_channels.Add(RADIO_TOKEN_SUPPLY)
							if(RADIO_CHANNEL_SERVICE)
								available_channels.Add(RADIO_TOKEN_SERVICE)

					if(headset_to_add.translate_binary)
						available_channels.Add(MODE_TOKEN_BINARY)
	else
		return ..()

/mob/living/simple_animal/parrot/attack_hand(mob/living/carbon/M)
	..()
	if(client)
		return
	if(!stat && M.a_intent == INTENT_HARM)

		icon_state = icon_living

		if(parrot_state == PARROT_PERCH)
			parrot_sleep_dur = parrot_sleep_max

		parrot_interest = M
		parrot_state = PARROT_SWOOP

		if(health > 30)
			parrot_state |= PARROT_ATTACK
		else
			parrot_state |= PARROT_FLEE
			drop_held_item(0)
	if(stat != DEAD && M.a_intent == INTENT_HELP)
		handle_automated_speech(1)
	return

///mob/living/simple_animal/parrot/attack_paw(mob/living/carbon/monkey/M)
//	return attack_hand(M)

///mob/living/simple_animal/parrot/attack_alien(mob/living/carbon/alien/M)
//	return attack_hand(M)

///mob/living/simple_animal/parrot/attack_animal(mob/living/simple_animal/M)
//	. = ..()
//
//	if(client)
//		return
//
//	if(parrot_state == PARROT_PERCH)
//		parrot_sleep_dur = parrot_sleep_max
//
//	if(M.melee_damage_upper > 0 && !stat)
//		parrot_interest = M
//		parrot_state = PARROT_SWOOP | PARROT_ATTACK
//		icon_state = icon_living

/mob/living/simple_animal/parrot/attackby(obj/item/O, mob/living/user, params)
	//if(!stat && !client && !istype(O, /obj/item/stack/medical) && !istype(O, /obj/item/reagent_containers/food/snacks/cracker))
	if(!stat && !client && !istype(O, /obj/item/stack/medical))//not_actual
		if(O.force)
			if(parrot_state == PARROT_PERCH)
				parrot_sleep_dur = parrot_sleep_max

			parrot_interest = user
			parrot_state = PARROT_SWOOP
			if(health > 30)
				parrot_state |= PARROT_ATTACK
			else
				parrot_state |= PARROT_FLEE
			icon_state = icon_living
			drop_held_item(0)
	//else if(istype(O, /obj/item/reagent_containers/food/snacks/cracker))
	//	qdel(O)
	//	if(health < maxHealth)
	//		adjustBruteLoss(-10)
	//	speak_chance *= 1.27
	//	speech_shuffle_rate += 10
	//	to_chat(user, "<span class='notice'>[src] eagerly devours the cracker.</span>")
	..()
	return

/mob/living/simple_animal/parrot/bullet_act(obj/item/projectile/Proj)
	..()
	if(!stat && !client)
		if(parrot_state == PARROT_PERCH)
			parrot_sleep_dur = parrot_sleep_max

		parrot_interest = null
		parrot_state = PARROT_WANDER | PARROT_FLEE
		icon_state = icon_living
		drop_held_item(0)
	return

/mob/living/simple_animal/parrot/Life()
	..()

	if(pulledby && !stat && parrot_state != PARROT_WANDER)
		//if(buckled)
		//	buckled.unbuckle_mob(src, TRUE)
		//	buckled = null
		icon_state = icon_living
		parrot_state = PARROT_WANDER
		pixel_x = initial(pixel_x)
		pixel_y = initial(pixel_y)
		return

/mob/living/simple_animal/parrot/handle_automated_speech()
	..()
	if(speech_buffer.len && prob(speech_shuffle_rate))
		if(speak.len)
			speak.Remove(pick(speak))

		speak.Add(pick(speech_buffer))

/mob/living/simple_animal/parrot/handle_automated_movement()
	//if(!isturf(src.loc) || !(mobility_flags & MOBILITY_MOVE) || buckled)
	if(!isturf(src.loc) || !(mobility_flags & MOBILITY_MOVE))//not_actual
		return

	if(client && stat == CONSCIOUS && parrot_state != icon_living)
		icon_state = icon_living

	if(parrot_state == PARROT_PERCH)
		if(parrot_perch && parrot_perch.loc != src.loc)
			if(parrot_perch in view(src))
				parrot_state = PARROT_SWOOP | PARROT_RETURN
				icon_state = icon_living
				return
			else
				parrot_state = PARROT_WANDER
				icon_state = icon_living
				return

		if(--parrot_sleep_dur)
			return

		else
			parrot_sleep_dur = parrot_sleep_max

			/*if(speak.len)
				var/list/newspeak = list()

				if(available_channels.len && src.ears)
					for(var/possible_phrase in speak)

						var/useradio = 0
						if(prob(50))
							useradio = 1

						if((copytext(possible_phrase,1,2) in GLOB.department_radio_prefixes) && (copytext(possible_phrase,2,3) in GLOB.department_radio_keys))
							possible_phrase = "[useradio?pick(available_channels):""][copytext(possible_phrase,3)]"
						else
							possible_phrase = "[useradio?pick(available_channels):""][possible_phrase]"

						newspeak.Add(possible_phrase)

				else
					for(var/possible_phrase in speak)
						if((copytext(possible_phrase,1,2) in GLOB.department_radio_prefixes) && (copytext(possible_phrase,2,3) in GLOB.department_radio_keys))
							possible_phrase = copytext(possible_phrase,3)
						newspeak.Add(possible_phrase)
				speak = newspeak*/

			parrot_interest = search_for_item()
			if(parrot_interest)
				emote("me", 1, "looks in [parrot_interest]'s direction and takes flight.")
				parrot_state = PARROT_SWOOP | PARROT_STEAL
				icon_state = icon_living
			return

	else if(parrot_state == PARROT_WANDER)
		walk(src, 0)
		parrot_interest = null

		if(prob(90))
			step(src, pick(GLOB.cardinals))
			return

		if(!held_item && !parrot_perch)
			var/atom/movable/AM = search_for_perch_and_item()
			if(AM)
				if(istype(AM, /obj/item) || isliving(AM))
					parrot_interest = AM
					emote("me", 1, "turns and flies towards [parrot_interest].")
					parrot_state = PARROT_SWOOP | PARROT_STEAL
					return
				else
					parrot_perch = AM
					parrot_state = PARROT_SWOOP | PARROT_RETURN
					return
			return

		if(parrot_interest && parrot_interest in view(src))
			parrot_state = PARROT_SWOOP | PARROT_STEAL
			return

		if(parrot_perch && parrot_perch in view(src))
			parrot_state = PARROT_SWOOP | PARROT_RETURN
			return

		else
			parrot_perch = search_for_perch()
			if(parrot_perch)
				parrot_state = PARROT_SWOOP | PARROT_RETURN
				return
	else if(parrot_state == (PARROT_SWOOP | PARROT_STEAL))
		walk(src,0)
		if(!parrot_interest || held_item)
			parrot_state = PARROT_SWOOP | PARROT_RETURN
			return

		if(!(parrot_interest in view(src)))
			parrot_state = PARROT_SWOOP | PARROT_RETURN
			return

		if(Adjacent(parrot_interest))

			if(isliving(parrot_interest))
				steal_from_mob()

			else
				if(!parrot_perch || parrot_interest.loc != parrot_perch.loc)
					held_item = parrot_interest
					parrot_interest.forceMove(src)
					visible_message("[src] grabs [held_item]!", "<span class='notice'>You grab [held_item]!</span>", "<span class='italics'>You hear the sounds of wings flapping furiously.</span>")

			parrot_interest = null
			parrot_state = PARROT_SWOOP | PARROT_RETURN
			return

		walk_to(src, parrot_interest, 1, parrot_speed)
		//if(isStuck())
		//	return

		return

	else if(parrot_state == (PARROT_SWOOP | PARROT_RETURN))
		walk(src, 0)
		if(!parrot_perch || !isturf(parrot_perch.loc))
			parrot_perch = null
			parrot_state = PARROT_WANDER
			return

		if(Adjacent(parrot_perch))
			forceMove(parrot_perch.loc)
			drop_held_item()
			parrot_state = PARROT_PERCH
			icon_state = icon_sit
			return

		walk_to(src, parrot_perch, 1, parrot_speed)
		//if(isStuck())
		//	return

		return

	/*else if(parrot_state == (PARROT_SWOOP | PARROT_FLEE))
		walk(src,0)
		if(!parrot_interest || !isliving(parrot_interest))
			parrot_state = PARROT_WANDER

		walk_away(src, parrot_interest, 1, parrot_speed)
		if(isStuck())
			return

		return

	else if(parrot_state == (PARROT_SWOOP | PARROT_ATTACK))

		if(!parrot_interest || !isliving(parrot_interest))
			parrot_interest = null
			parrot_state = PARROT_WANDER
			return

		var/mob/living/L = parrot_interest
		if(melee_damage_upper == 0)
			melee_damage_upper = parrot_damage_upper
			a_intent = INTENT_HARM

		if(Adjacent(parrot_interest))

			if(L.stat)
				parrot_interest = null
				if(!held_item)
					held_item = steal_from_ground()
					if(!held_item)
						held_item = steal_from_mob()
				if(parrot_perch in view(src))
					parrot_state = PARROT_SWOOP | PARROT_RETURN
				else
					parrot_state = PARROT_WANDER
				return

			attacktext = pick("claws at", "chomps")
			L.attack_animal(src)
		else
			walk_to(src, parrot_interest, 1, parrot_speed)
			if(isStuck())
				return

		return*/
	else
		walk(src,0)
		parrot_interest = null
		parrot_perch = null
		drop_held_item()
		parrot_state = PARROT_WANDER
		return

/mob/living/simple_animal/parrot/proc/search_for_item()
	var/item
	for(var/atom/movable/AM in view(src))
		if(parrot_perch && AM.loc == parrot_perch.loc || AM.loc == src)
			continue
		if(istype(AM, /obj/item))
			var/obj/item/I = AM
			if(I.w_class < WEIGHT_CLASS_SMALL)
				item = I
		else if(iscarbon(AM))
			var/mob/living/carbon/C = AM
			for(var/obj/item/I in C.held_items)
				if(I.w_class <= WEIGHT_CLASS_SMALL)
					item = I
					break
		if(item)
			//if(!AStar(src, get_turf(item), /turf/proc/Distance_cardinal))
			//	item = null
			//	continue
			return item

	return null

/mob/living/simple_animal/parrot/proc/search_for_perch()
	for(var/obj/O in view(src))
		for(var/path in desired_perches)
			if(istype(O, path))
				return O
	return null

/mob/living/simple_animal/parrot/proc/search_for_perch_and_item()
	for(var/atom/movable/AM in view(src))
		for(var/perch_path in desired_perches)
			if(istype(AM, perch_path))
				return AM

		if(parrot_perch && AM.loc == parrot_perch.loc || AM.loc == src)
			continue

		if(istype(AM, /obj/item))
			var/obj/item/I = AM
			if(I.w_class <= WEIGHT_CLASS_SMALL)
				return I

		if(iscarbon(AM))
			var/mob/living/carbon/C = AM
			for(var/obj/item/I in C.held_items)
				if(I.w_class <= WEIGHT_CLASS_SMALL)
					return C
	return null

/mob/living/simple_animal/parrot/proc/steal_from_mob()
	//set name = "Steal from mob"
	//set category = "Parrot"
	//set desc = "Steals an item right out of a person's hand!"

	if(stat)
		return -1

	if(held_item)
		to_chat(src, "<span class='warning'>You are already holding [held_item]!</span>")
		return 1

	var/obj/item/stolen_item = null

	for(var/mob/living/carbon/C in view(1,src))
		for(var/obj/item/I in C.held_items)
			if(I.w_class <= WEIGHT_CLASS_SMALL)
				stolen_item = I
				break

		if(stolen_item)
			C.transferItemToLoc(stolen_item, src, TRUE)
			held_item = stolen_item
			visible_message("[src] grabs [held_item] out of [C]'s hand!", "<span class='notice'>You snag [held_item] out of [C]'s hand!</span>", "<span class='italics'>You hear the sounds of wings flapping furiously.</span>")
			return held_item

	to_chat(src, "<span class='warning'>There is nothing of interest to take!</span>")
	return 0

/mob/living/simple_animal/parrot/proc/drop_held_item(drop_gently = 1)
	//set name = "Drop held item"
	//set category = "Parrot"
	//set desc = "Drop the item you're holding."

	if(stat)
		return -1

	if(!held_item)
		//if(src == usr)
		//	to_chat(src, "<span class='danger'>You have nothing to drop!</span>")
		return 0


	//if(istype(held_item, /obj/item/reagent_containers/food/snacks/cracker) && (drop_gently))
	//	qdel(held_item)
	//	held_item = null
	//	if(health < maxHealth)
	//		adjustBruteLoss(-10)
	//	emote("me", 1, "[src] eagerly downs the cracker.")
	//	return 1


	//if(!drop_gently)
	//	if(istype(held_item, /obj/item/grenade))
	//		var/obj/item/grenade/G = held_item
	//		G.forceMove(drop_location())
	//		G.prime()
	//		to_chat(src, "You let go of [held_item]!")
	//		held_item = null
	//		return 1

	//to_chat(src, "You drop [held_item].")

	held_item.forceMove(drop_location())
	held_item = null
	return 1

/mob/living/simple_animal/parrot/Poly
	name = "Poly"
	desc = "Poly the Parrot. An expert on quantum cracker theory."
	speak = list("Poly wanna cracker!", ":e Check the crystal, you chucklefucks!",":e Wire the solars, you lazy bums!",":e WHO TOOK THE DAMN HARDSUITS?",":e OH GOD ITS ABOUT TO DELAMINATE CALL THE SHUTTLE")
	gold_core_spawnable = NO_SPAWN
	speak_chance = 3
	var/memory_saved = FALSE
	var/rounds_survived = 0
	var/longest_survival = 0
	var/longest_deathstreak = 0

/mob/living/simple_animal/parrot/Poly/Initialize()
	ears = new /obj/item/radio/headset/headset_eng(src)
	available_channels = list(":e")
	Read_Memory()
	if(rounds_survived == longest_survival)
		speak += pick("...[longest_survival].", "The things I've seen!", "I have lived many lives!", "What are you before me?")
		desc += " Old as sin, and just as loud. Claimed to be [rounds_survived]."
		speak_chance = 20
		add_atom_colour("#EEEE22", FIXED_COLOUR_PRIORITY)
	else if(rounds_survived == longest_deathstreak)
		speak += pick("What are you waiting for!", "Violence breeds violence!", "Blood! Blood!", "Strike me down if you dare!")
		desc += " The squawks of [-rounds_survived] dead parrots ring out in your ears..."
		add_atom_colour("#BB7777", FIXED_COLOUR_PRIORITY)
	else if(rounds_survived > 0)
		speak += pick("...again?", "No, It was over!", "Let me out!", "It never ends!")
		desc += " Over [rounds_survived] shifts without a \"terrible\" \"accident\"!"
	else
		speak += pick("...alive?", "This isn't parrot heaven!", "I live, I die, I live again!", "The void fades!")

	. = ..()

/mob/living/simple_animal/parrot/Poly/Life()
	if(!stat && SSticker.current_state == GAME_STATE_FINISHED && !memory_saved)
		Write_Memory(FALSE)
		memory_saved = TRUE
	..()

/mob/living/simple_animal/parrot/Poly/proc/Read_Memory()
	if(fexists("data/npc_saves/Poly.sav"))
		//var/savefile/S = new /savefile("data/npc_saves/Poly.sav")
		//S["phrases"] 			>> speech_buffer
		//S["roundssurvived"]		>> rounds_survived
		//S["longestsurvival"]	>> longest_survival
		//S["longestdeathstreak"] >> longest_deathstreak
		fdel("data/npc_saves/Poly.sav")
	else
		var/json_file = file("data/npc_saves/Poly.json")
		if(!fexists(json_file))
			return
		var/list/json = json_decode(file2text(json_file))
		speech_buffer = json["phrases"]
		rounds_survived = json["roundssurvived"]
		longest_survival = json["longestsurvival"]
		longest_deathstreak = json["longestdeathstreak"]
	if(!islist(speech_buffer))
		speech_buffer = list()

/mob/living/simple_animal/parrot/Poly/proc/Write_Memory(dead)
	var/json_file = file("data/npc_saves/Poly.json")
	var/list/file_data = list()
	if(islist(speech_buffer))
		file_data["phrases"] = speech_buffer
	if(dead)
		file_data["roundssurvived"] = min(rounds_survived - 1, 0)
		file_data["longestsurvival"] = longest_survival
		if(rounds_survived - 1 < longest_deathstreak)
			file_data["longestdeathstreak"] = rounds_survived - 1
		else
			file_data["longestdeathstreak"] = longest_deathstreak
	else
		file_data["roundssurvived"] = rounds_survived + 1
		if(rounds_survived + 1 > longest_survival)
			file_data["longestsurvival"] = rounds_survived + 1
		else
			file_data["longestsurvival"] = longest_survival
		file_data["longestdeathstreak"] = longest_deathstreak
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

///mob/living/simple_animal/parrot/Poly/ratvar_act()
//	playsound(src, 'sound/magic/clockwork/fellowship_armory.ogg', 75, TRUE)
//	var/mob/living/simple_animal/parrot/clock_hawk/H = new(loc)
//	H.setDir(dir)
//	qdel(src)