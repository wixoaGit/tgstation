/obj/item/projectile/magic
	name = "bolt of nothing"
	icon_state = "energy"
	damage = 0
	damage_type = OXY
	nodamage = 1
	armour_penetration = 100
	flag = "magic"

/obj/item/projectile/magic/death
	name = "bolt of death"
	icon_state = "pulse1_bl"

/obj/item/projectile/magic/death/on_hit(target)
	. = ..()
	if(ismob(target))
		var/mob/M = target
		//if(M.anti_magic_check())
		//	M.visible_message("<span class='warning'>[src] vanishes on contact with [target]!</span>")
		//	return
		M.death(0)

/obj/item/projectile/magic/resurrection
	name = "bolt of resurrection"
	icon_state = "ion"
	damage = 0
	damage_type = OXY
	nodamage = 1

/obj/item/projectile/magic/resurrection/on_hit(mob/living/carbon/target)
	. = ..()
	if(isliving(target))
		if(target.hellbound)
			return
		//if(target.anti_magic_check())
		//	target.visible_message("<span class='warning'>[src] vanishes on contact with [target]!</span>")
		//	return
		//if(iscarbon(target))
		//	var/mob/living/carbon/C = target
		//	C.regenerate_limbs()
		//	C.regenerate_organs()
		if(target.revive(full_heal = 1))
			//target.grab_ghost(force = TRUE)
			to_chat(target, "<span class='notice'>You rise with a start, you're alive!!!</span>")
		else if(target.stat != DEAD)
			to_chat(target, "<span class='notice'>You feel great!</span>")