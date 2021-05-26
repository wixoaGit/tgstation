/obj/proc/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, armour_penetration = 0)
	if(QDELETED(src))
		stack_trace("[src] taking damage after deletion")
		return
	if(sound_effect)
		play_attack_sound(damage_amount, damage_type, damage_flag)
	if(!(resistance_flags & INDESTRUCTIBLE) && obj_integrity > 0)
		damage_amount = run_obj_armor(damage_amount, damage_type, damage_flag, attack_dir, armour_penetration)
		if(damage_amount >= DAMAGE_PRECISION)
			. = damage_amount
			var/old_integ = obj_integrity
			obj_integrity = max(old_integ - damage_amount, 0)
			if(obj_integrity <= 0)
				var/int_fail = integrity_failure
				if(int_fail && old_integ > int_fail)
					obj_break(damage_flag)
				obj_destruction(damage_flag)
			else if(integrity_failure)
				if(obj_integrity <= integrity_failure)
					obj_break(damage_flag)

/obj/proc/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir, armour_penetration = 0)
	switch(damage_type)
		if(BRUTE)
		if(BURN)
		else
			return 0
	var/armor_protection = 0
	//if(damage_flag)
	//	armor_protection = armor.getRating(damage_flag)
	//if(armor_protection)
	//	armor_protection = CLAMP(armor_protection - armour_penetration, 0, 100)
	//return round(damage_amount * (100 - armor_protection)*0.01, DAMAGE_PRECISION)
	return round(damage_amount, DAMAGE_PRECISION)//not_actual

/obj/proc/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/weapons/smash.ogg', 50, 1)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, 1)

/obj/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	..()
	take_damage(AM.throwforce, BRUTE, "melee", 1, get_dir(src, AM))

/obj/ex_act(severity, target)
	if(resistance_flags & INDESTRUCTIBLE)
		return
	..()
	if(target == src)
		obj_integrity = 0
		qdel(src)
		return
	switch(severity)
		if(1)
			obj_integrity = 0
			qdel(src)
		if(2)
			take_damage(rand(100, 250), BRUTE, "bomb", 0)
		if(3)
			take_damage(rand(10, 90), BRUTE, "bomb", 0)

/obj/bullet_act(obj/item/projectile/P)
	. = ..()
	playsound(src, P.hitsound, 50, 1)
	visible_message("<span class='danger'>[src] is hit by \a [P]!</span>", null, null, COMBAT_MESSAGE_RANGE)
	if(!QDELETED(src))
		take_damage(P.damage, P.damage_type, P.flag, 0, turn(P.dir, 180), P.armour_penetration)

/obj/proc/acid_melt()
	//SSacid.processing -= src
	deconstruct(FALSE)

/obj/proc/burn()
	//if(resistance_flags & ON_FIRE)
	//	SSfire_burning.processing -= src
	deconstruct(FALSE)

/obj/proc/extinguish()
	if(resistance_flags & ON_FIRE)
		resistance_flags &= ~ON_FIRE
		//cut_overlay(GLOB.fire_overlay, TRUE)
		//SSfire_burning.processing -= src

/obj/proc/deconstruct(disassembled = TRUE)
	SEND_SIGNAL(src, COMSIG_OBJ_DECONSTRUCT, disassembled)
	qdel(src)

/obj/proc/obj_break(damage_flag)
	return

/obj/proc/obj_destruction(damage_flag)
	if(damage_flag == "acid")
		acid_melt()
	else if(damage_flag == "fire")
		burn()
	else
		deconstruct(FALSE)

/obj/proc/modify_max_integrity(new_max, can_break = TRUE, damage_type = BRUTE, new_failure_integrity = null)
	var/current_integrity = obj_integrity
	var/current_max = max_integrity

	if(current_integrity != 0 && current_max != 0)
		var/percentage = current_integrity / current_max
		current_integrity = max(1, round(percentage * new_max))
		obj_integrity = current_integrity

	max_integrity = new_max

	if(new_failure_integrity != null)
		integrity_failure = new_failure_integrity

	if(can_break && integrity_failure && current_integrity <= integrity_failure)
		obj_break(damage_type)
		return TRUE
	return FALSE

/obj/proc/GetExplosionBlock()
	CRASH("Unimplemented GetExplosionBlock()")