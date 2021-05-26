/obj/item/gun/magic/wand
	name = "wand of nothing"
	desc = "It's not just a stick, it's a MAGIC stick!"
	ammo_type = /obj/item/ammo_casing/magic
	icon_state = "nothingwand"
	item_state = "wand"
	w_class = WEIGHT_CLASS_SMALL
	can_charge = 0
	max_charges = 100
	var/variable_charges = TRUE

/obj/item/gun/magic/wand/Initialize()
	if(prob(75) && variable_charges)
		if(prob(33))
			max_charges = CEILING(max_charges / 3, 1)
		else
			max_charges = CEILING(max_charges / 2, 1)
	return ..()

/obj/item/gun/magic/wand/examine(mob/user)
	..()
	to_chat(user, "Has [charges] charge\s remaining.")

/obj/item/gun/magic/wand/update_icon()
	icon_state = "[initial(icon_state)][charges ? "" : "-drained"]"

/obj/item/gun/magic/wand/attack(atom/target, mob/living/user)
	if(target == user)
		return
	..()

/obj/item/gun/magic/wand/afterattack(atom/target, mob/living/user)
	if(!charges)
		shoot_with_empty_chamber(user)
		return
	if(target == user)
		if(no_den_usage)
			var/area/A = get_area(user)
			if(istype(A, /area/wizard_station))
				to_chat(user, "<span class='warning'>You know better than to violate the security of The Den, best wait until you leave to use [src].</span>")
				return
			else
				no_den_usage = 0
		zap_self(user)
	else
		. = ..()
	update_icon()


/obj/item/gun/magic/wand/proc/zap_self(mob/living/user)
	user.visible_message("<span class='danger'>[user] zaps [user.p_them()]self with [src].</span>")
	playsound(user, fire_sound, 50, 1)
	//user.log_message("zapped [user.p_them()]self with a <b>[src]</b>", LOG_ATTACK)

/obj/item/gun/magic/wand/death
	name = "wand of death"
	desc = "This deadly wand overwhelms the victim's body with pure energy, slaying them without fail."
	fire_sound = 'sound/magic/wandodeath.ogg'
	ammo_type = /obj/item/ammo_casing/magic/death
	icon_state = "deathwand"
	max_charges = 3

/obj/item/gun/magic/wand/death/zap_self(mob/living/user)
	..()
	to_chat(user, "<span class='warning'>You irradiate yourself with pure energy! \
	[pick("Do not pass go. Do not collect 200 zorkmids.","You feel more confident in your spell casting skills.","You Die...","Do you want your possessions identified?")]\
	</span>")
	//user.adjustOxyLoss(500)
	user.AdjustUnconscious(10)
	charges--

/obj/item/gun/magic/wand/death/debug
	desc = "In some obscure circles, this is known as the 'cloning tester's friend'."
	max_charges = 500
	variable_charges = FALSE
	can_charge = TRUE
	recharge_rate = 1

/obj/item/gun/magic/wand/resurrection
	name = "wand of healing"
	desc = "This wand uses healing magics to heal and revive. They are rarely utilized within the Wizard Federation for some reason."
	ammo_type = /obj/item/ammo_casing/magic/heal
	fire_sound = 'sound/magic/staff_healing.ogg'
	icon_state = "revivewand"
	max_charges = 10

/obj/item/gun/magic/wand/resurrection/zap_self(mob/living/user)
	user.revive(full_heal = 1)
	//if(iscarbon(user))
	//	var/mob/living/carbon/C = user
	//	C.regenerate_limbs()
	//	C.regenerate_organs()
	to_chat(user, "<span class='notice'>You feel great!</span>")
	charges--
	..()

/obj/item/gun/magic/wand/resurrection/debug
	desc = "Is it possible for something to be even more powerful than regular magic? This wand is."
	max_charges = 500
	variable_charges = FALSE
	can_charge = TRUE
	recharge_rate = 1