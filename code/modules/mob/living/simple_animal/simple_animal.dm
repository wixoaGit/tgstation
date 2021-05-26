/mob/living/simple_animal
	name = "animal"
	icon = 'icons/mob/animal.dmi'
	health = 20
	maxHealth = 20
	gender = PLURAL

	status_flags = CANPUSH

	var/icon_living = ""
	var/icon_dead = ""
	var/icon_gib = null

	var/list/speak = list()
	var/list/speak_emote = list()
	var/speak_chance = 0
	var/list/emote_hear = list()
	var/list/emote_see = list()

	var/turns_per_move = 1
	var/turns_since_move = 0
	var/stop_automated_movement = 0
	var/wander = 1
	var/stop_automated_movement_when_pulled = 1

	var/response_help   = "pokes"
	var/response_disarm = "shoves"
	var/response_harm   = "hits"
	var/harm_intent_damage = 3
	var/force_threshold = 0

	var/minbodytemp = 250
	var/maxbodytemp = 350

	var/healable = 1

	var/melee_damage_lower = 0
	var/melee_damage_upper = 0
	var/obj_damage = 0
	var/armour_penetration = 0
	var/melee_damage_type = BRUTE
	//var/list/damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	var/attacktext = "attacks"
	var/attack_sound = null
	var/friendly = "nuzzles"
	var/environment_smash = ENVIRONMENT_SMASH_NONE

	var/speed = 1

	var/list/childtype = null
	var/next_scan_time = 0
	var/animal_species

	var/gold_core_spawnable = NO_SPAWN

	var/list/loot = list()
	var/del_on_death = 0
	var/deathmessage = ""

	var/allow_movement_on_non_turfs = FALSE

	var/dextrous = FALSE

	var/AIStatus = AI_ON

	var/do_footstep = FALSE

/mob/living/simple_animal/Initialize()
	. = ..()
	GLOB.simple_animals[AIStatus] += src
	//handcrafting = new()
	if(gender == PLURAL)
		gender = pick(MALE,FEMALE)
	if(!real_name)
		real_name = name
	if(!loc)
		stack_trace("Simple animal being instantiated in nullspace")
	update_simplemob_varspeed()


/mob/living/simple_animal/Destroy()
	GLOB.simple_animals[AIStatus] -= src
	if (SSnpcpool.state == SS_PAUSED && LAZYLEN(SSnpcpool.currentrun))
		SSnpcpool.currentrun -= src

	//if(nest)
	//	nest.spawned_mobs -= src
	//	nest = null

	//var/turf/T = get_turf(src)
	//if (T && AIStatus == AI_Z_OFF)
	//	SSidlenpcpool.idle_mobs_by_zlevel[T.z] -= src

	return ..()

/mob/living/simple_animal/updatehealth()
	..()
	health = CLAMP(health, 0, maxHealth)

/mob/living/simple_animal/update_stat()
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(health <= 0)
			death()
		else
			stat = CONSCIOUS
	//med_hud_set_status()

/mob/living/simple_animal/proc/handle_automated_action()
	set waitfor = FALSE
	return

/mob/living/simple_animal/proc/handle_automated_movement()
	set waitfor = FALSE
	if(!stop_automated_movement && wander)
		if((isturf(loc) || allow_movement_on_non_turfs) && (mobility_flags & MOBILITY_MOVE))
			turns_since_move++
			if(turns_since_move >= turns_per_move)
				if(!(stop_automated_movement_when_pulled && pulledby))
					var/anydir = pick(GLOB.cardinals)
					if(Process_Spacemove(anydir))
						Move(get_step(src, anydir), anydir)
						turns_since_move = 0
			return 1

/mob/living/simple_animal/proc/handle_automated_speech(var/override)
	set waitfor = FALSE
	if(speak_chance)
		if(prob(speak_chance) || override)
			if(speak && speak.len)
				if((emote_hear && emote_hear.len) || (emote_see && emote_see.len))
					var/length = speak.len
					if(emote_hear && emote_hear.len)
						length += emote_hear.len
					if(emote_see && emote_see.len)
						length += emote_see.len
					var/randomValue = rand(1,length)
					if(randomValue <= speak.len)
						say(pick(speak), forced = "poly")
					else
						randomValue -= speak.len
						if(emote_see && randomValue <= emote_see.len)
							emote("me [pick(emote_see)]", 1)
						else
							emote("me [pick(emote_hear)]", 2)
				else
					say(pick(speak), forced = "poly")
			else
				if(!(emote_hear && emote_hear.len) && (emote_see && emote_see.len))
					emote("me", 1, pick(emote_see))
				if((emote_hear && emote_hear.len) && !(emote_see && emote_see.len))
					emote("me", 2, pick(emote_hear))
				if((emote_hear && emote_hear.len) && (emote_see && emote_see.len))
					var/length = emote_hear.len + emote_see.len
					var/pick = rand(1,length)
					if(pick <= emote_see.len)
						emote("me", 1, pick(emote_see))
					else
						emote("me", 2, pick(emote_hear))

/mob/living/simple_animal/emote(act, m_type=1, message = null, intentional = FALSE)
	if(stat)
		return
	if(act == "scream")
		message = "makes a loud and pained whimper."
		act = "me"
	..(act, m_type, message)

/mob/living/simple_animal/proc/update_simplemob_varspeed()
	if(speed == 0)
		remove_movespeed_modifier(MOVESPEED_ID_SIMPLEMOB_VARSPEED, TRUE)
	add_movespeed_modifier(MOVESPEED_ID_SIMPLEMOB_VARSPEED, TRUE, 100, multiplicative_slowdown = speed, override = TRUE)

/mob/living/simple_animal/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Health: [round((health / maxHealth) * 100)]%")
		return 1

/mob/living/simple_animal/proc/drop_loot()
	if(loot.len)
		for(var/i in loot)
			new i(loc)

/mob/living/simple_animal/death(gibbed)
	movement_type &= ~FLYING
	//if(nest)
	//	nest.spawned_mobs -= src
	//	nest = null
	drop_loot()
	if(dextrous)
		drop_all_held_items()
	if(!gibbed && !del_on_death)
		if(deathsound || deathmessage)
			emote("deathgasp")
	if(del_on_death)
		..()
		del_on_death = FALSE
		qdel(src)
	else
		health = 0
		icon_state = icon_dead
		density = FALSE
		..()

/mob/living/simple_animal/proc/make_babies()
	if(gender != FEMALE || stat || next_scan_time > world.time || !childtype || !animal_species || !SSticker.IsRoundInProgress())
		return
	next_scan_time = world.time + 400
	var/alone = 1
	var/mob/living/simple_animal/partner
	var/children = 0
	for(var/mob/M in view(7, src))
		if(M.stat != CONSCIOUS)
			continue
		else if(istype(M, childtype))
			children++
		else if(istype(M, animal_species))
			if(M.ckey)
				continue
			else if(!istype(M, childtype) && M.gender == MALE)
				partner = M

		//else if(isliving(M) && !faction_check_mob(M))
		else if(FALSE)//not_actual
			return

	if(alone && partner && children < 3)
		var/childspawn = pickweight(childtype)
		var/turf/target = get_turf(loc)
		if(target)
			return new childspawn(target)

/mob/living/simple_animal/canUseTopic(atom/movable/M, be_close=FALSE, no_dextery=FALSE, no_tk=FALSE)
	if(incapacitated())
		to_chat(src, "<span class='warning'>You can't do that right now!</span>")
		return FALSE
	if(be_close && !in_range(M, src))
		to_chat(src, "<span class='warning'>You are too far away!</span>")
		return FALSE
	if(!(no_dextery || dextrous))
		to_chat(src, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return FALSE
	return TRUE