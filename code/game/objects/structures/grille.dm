/obj/structure/grille
	desc = "A flimsy framework of metal rods."
	name = "grille"
	icon = 'icons/obj/structures.dmi'
	icon_state = "grille"
	density = TRUE
	anchored = TRUE
	flags_1 = CONDUCT_1
	pressure_resistance = 5*ONE_ATMOSPHERE
	layer = BELOW_OBJ_LAYER
	armor = list("melee" = 50, "bullet" = 70, "laser" = 70, "energy" = 100, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 0, "acid" = 0)
	max_integrity = 50
	integrity_failure = 20
	var/rods_type = /obj/item/stack/rods
	var/rods_amount = 2
	var/rods_broken = TRUE
	var/grille_type = null
	var/broken_type = /obj/structure/grille/broken
	//rad_flags = RAD_PROTECT_CONTENTS | RAD_NO_CONTAMINATE

/obj/structure/grille/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	update_icon()

/obj/structure/grille/update_icon()
	if(QDELETED(src) || broken)
		return

	var/ratio = obj_integrity / max_integrity
	ratio = CEILING(ratio*4, 1) * 25

	if(smooth)
		queue_smooth(src)

	if(ratio > 50)
		return
	icon_state = "grille50_[rand(0,3)]"

/obj/structure/grille/examine(mob/user)
	..()
	if(anchored)
		to_chat(user, "<span class='notice'>It's secured in place with <b>screws</b>. The rods look like they could be <b>cut</b> through.</span>")
	if(!anchored)
		to_chat(user, "<span class='notice'>The anchoring screws are <i>unscrewed</i>. The rods look like they could be <b>cut</b> through.</span>")

/obj/structure/grille/Bumped(atom/movable/AM)
	if(!ismob(AM))
		return
	var/mob/M = AM
	shock(M, 70)

/obj/structure/grille/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/grille/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src, ATTACK_EFFECT_KICK)
	user.visible_message("<span class='warning'>[user] hits [src].</span>", null, null, COMBAT_MESSAGE_RANGE)
	//log_combat(user, src, "hit")
	if(!shock(user, 70))
		take_damage(rand(5,10), BRUTE, "melee", 1)

/obj/structure/grille/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && (mover.pass_flags & PASSGRILLE))
		return TRUE
	else
		if(istype(mover, /obj/item/projectile) && density)
			return prob(30)
		else
			return !density

/obj/structure/grille/attackby(obj/item/W, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	add_fingerprint(user)
	if(W.tool_behaviour == TOOL_WIRECUTTER)
		if(!shock(user, 100))
			W.play_tool_sound(src, 100)
			deconstruct()
	else if((W.tool_behaviour == TOOL_SCREWDRIVER) && (isturf(loc) || anchored))
		if(!shock(user, 90))
			W.play_tool_sound(src, 100)
			setAnchored(!anchored)
			user.visible_message("<span class='notice'>[user] [anchored ? "fastens" : "unfastens"] [src].</span>", \
								 "<span class='notice'>You [anchored ? "fasten [src] to" : "unfasten [src] from"] the floor.</span>")
			return
	else if(istype(W, /obj/item/stack/rods) && broken)
		var/obj/item/stack/rods/R = W
		if(!shock(user, 90))
			user.visible_message("<span class='notice'>[user] rebuilds the broken grille.</span>", \
								 "<span class='notice'>You rebuild the broken grille.</span>")
			new grille_type(src.loc)
			R.use(1)
			qdel(src)
			return

	else if(is_glass_sheet(W))
		if (!broken)
			var/obj/item/stack/ST = W
			if (ST.get_amount() < 2)
				to_chat(user, "<span class='warning'>You need at least two sheets of glass for that!</span>")
				return
			var/dir_to_set = SOUTHWEST
			if(!anchored)
				to_chat(user, "<span class='warning'>[src] needs to be fastened to the floor first!</span>")
				return
			for(var/obj/structure/window/WINDOW in loc)
				to_chat(user, "<span class='warning'>There is already a window there!</span>")
				return
			to_chat(user, "<span class='notice'>You start placing the window...</span>")
			if(do_after(user,20, target = src))
				if(!src.loc || !anchored)
					return
				for(var/obj/structure/window/WINDOW in loc)
					return
				var/obj/structure/window/WD
				//if(istype(W, /obj/item/stack/sheet/plasmarglass))
				//	WD = new/obj/structure/window/plasma/reinforced/fulltile(drop_location())
				//else if(istype(W, /obj/item/stack/sheet/plasmaglass))
				//	WD = new/obj/structure/window/plasma/fulltile(drop_location())
				//else if(istype(W, /obj/item/stack/sheet/rglass))
				//	WD = new/obj/structure/window/reinforced/fulltile(drop_location())
				//else if(istype(W, /obj/item/stack/sheet/titaniumglass))
				//	WD = new/obj/structure/window/shuttle(drop_location())
				//else if(istype(W, /obj/item/stack/sheet/plastitaniumglass))
				//	WD = new/obj/structure/window/plastitanium(drop_location())
				//else
				//	WD = new/obj/structure/window/fulltile(drop_location())
				WD = new/obj/structure/window/fulltile(drop_location())//not_actual
				WD.setDir(dir_to_set)
				WD.ini_dir = dir_to_set
				WD.setAnchored(FALSE)
				WD.state = 0
				ST.use(2)
				to_chat(user, "<span class='notice'>You place [WD] on [src].</span>")
			return

	else if(istype(W, /obj/item/shard) || !shock(user, 70))
		return ..()

/obj/structure/grille/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/effects/grillehit.ogg', 80, 1)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 80, 1)

/obj/structure/grille/deconstruct(disassembled = TRUE)
	if(!loc)
		return
	if(!(flags_1&NODECONSTRUCT_1))
		var/obj/R = new rods_type(drop_location(), rods_amount)
		transfer_fingerprints_to(R)
		qdel(src)
	..()

/obj/structure/grille/obj_break()
	if(!broken && !(flags_1 & NODECONSTRUCT_1))
		new broken_type(src.loc)
		var/obj/R = new rods_type(drop_location(), rods_broken)
		transfer_fingerprints_to(R)
		qdel(src)

/obj/structure/grille/proc/shock(mob/user, prb)
	if(!anchored || broken)
		return FALSE
	if(!prob(prb))
		return FALSE
	if(!in_range(src, user))
		return FALSE
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	//if(C)
	//	if(electrocute_mob(user, C, src, 1, TRUE))
	//		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	//		s.set_up(3, 1, src)
	//		s.start()
	//		return TRUE
	//	else
	//		return FALSE
	return FALSE

/obj/structure/grille/get_dumping_location(datum/component/storage/source,mob/user)
	return null

/obj/structure/grille/broken
	icon_state = "brokengrille"
	density = FALSE
	obj_integrity = 20
	broken = TRUE
	rods_amount = 1
	rods_broken = FALSE
	grille_type = /obj/structure/grille
	broken_type = null