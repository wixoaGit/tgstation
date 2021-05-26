/obj/item/flashlight
	name = "flashlight"
	desc = "A hand-held emergency light."
	custom_price = 10
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flashlight"
	item_state = "flashlight"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	materials = list(MAT_METAL=50, MAT_GLASS=20)
	actions_types = list(/datum/action/item_action/toggle_light)
	var/on = FALSE
	var/brightness_on = 4
	var/flashlight_power = 1

/obj/item/flashlight/Initialize()
	. = ..()
	if(icon_state == "[initial(icon_state)]-on")
		on = TRUE
	update_brightness()

/obj/item/flashlight/proc/update_brightness(mob/user = null)
	if(on)
		icon_state = "[initial(icon_state)]-on"
		if(flashlight_power)
			set_light(l_range = brightness_on, l_power = flashlight_power)
		else
			set_light(brightness_on)
	else
		icon_state = initial(icon_state)
		set_light(0)

/obj/item/flashlight/attack_self(mob/user)
	on = !on
	update_brightness(user)
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()
	return 1

/obj/item/flashlight/suicide_act(mob/living/carbon/human/user)
	if (user.eye_blind)
		user.visible_message("<span class='suicide'>[user] is putting [src] close to [user.p_their()] eyes and turning it on... but [user.p_theyre()] blind!</span>")
		return SHAME
	user.visible_message("<span class='suicide'>[user] is putting [src] close to [user.p_their()] eyes and turning it on! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (FIRELOSS)

/obj/item/flashlight/seclite
	name = "seclite"
	desc = "A robust flashlight used by security."
	icon_state = "seclite"
	item_state = "seclite"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	force = 9
	brightness_on = 5
	hitsound = 'sound/weapons/genhit1.ogg'

/obj/item/flashlight/lamp
	name = "desk lamp"
	desc = "A desk lamp with an adjustable mount."
	icon_state = "lamp"
	item_state = "lamp"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	force = 10
	brightness_on = 5
	w_class = WEIGHT_CLASS_BULKY
	flags_1 = CONDUCT_1
	materials = list()
	on = TRUE


/obj/item/flashlight/lamp/green
	desc = "A classic green-shaded desk lamp."
	icon_state = "lampgreen"
	item_state = "lampgreen"

/obj/item/flashlight/emp
	var/emp_max_charges = 4
	var/emp_cur_charges = 4
	var/charge_tick = 0

/obj/item/flashlight/emp/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/flashlight/emp/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/flashlight/emp/process()
	charge_tick++
	if(charge_tick < 10)
		return FALSE
	charge_tick = 0
	emp_cur_charges = min(emp_cur_charges+1, emp_max_charges)
	return TRUE

/obj/item/flashlight/emp/attack(mob/living/M, mob/living/user)
	if(on && user.zone_selected in list(BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH))
		..()
	return

/obj/item/flashlight/emp/afterattack(atom/movable/A, mob/user, proximity)
	. = ..()
	if(!proximity)
		return

	if(emp_cur_charges > 0)
		emp_cur_charges -= 1

		if(ismob(A))
			var/mob/M = A
			log_combat(user, M, "attacked", "EMP-light")
			M.visible_message("<span class='danger'>[user] blinks \the [src] at \the [A].", \
								"<span class='userdanger'>[user] blinks \the [src] at you.")
		else
			A.visible_message("<span class='danger'>[user] blinks \the [src] at \the [A].")
		to_chat(user, "\The [src] now has [emp_cur_charges] charge\s.")
		A.emp_act(EMP_HEAVY)
	else
		to_chat(user, "<span class='warning'>\The [src] needs time to recharge!</span>")
	return

/obj/item/flashlight/emp/debug
	name = "debug EMP flashlight"
	emp_max_charges = 100
	emp_cur_charges = 100

/obj/item/flashlight/glowstick
	name = "glowstick"
	desc = "A military-grade glowstick."
	custom_price = 10
	w_class = WEIGHT_CLASS_SMALL
	brightness_on = 4
	color = LIGHT_COLOR_GREEN
	icon_state = "glowstick"
	item_state = "glowstick"
	grind_results = list("phenol" = 15, "hydrogen" = 10, "oxygen" = 5)
	var/fuel = 0

/obj/item/flashlight/glowstick/Initialize()
	fuel = rand(1600, 2000)
	light_color = color
	. = ..()

/obj/item/flashlight/glowstick/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/flashlight/glowstick/process()
	fuel = max(fuel - 1, 0)
	if(!fuel)
		turn_off()
		STOP_PROCESSING(SSobj, src)
		update_icon()

/obj/item/flashlight/glowstick/proc/turn_off()
	on = FALSE
	update_icon()

/obj/item/flashlight/glowstick/update_icon()
	item_state = "glowstick"
	cut_overlays()
	if(!fuel)
		icon_state = "glowstick-empty"
		cut_overlays()
		set_light(0)
	else if(on)
		var/mutable_appearance/glowstick_overlay = mutable_appearance(icon, "glowstick-glow")
		glowstick_overlay.color = color
		add_overlay(glowstick_overlay)
		item_state = "glowstick-on"
		set_light(brightness_on)
	else
		icon_state = "glowstick"
		cut_overlays()

/obj/item/flashlight/glowstick/attack_self(mob/user)
	if(!fuel)
		to_chat(user, "<span class='notice'>[src] is spent.</span>")
		return
	if(on)
		to_chat(user, "<span class='notice'>[src] is already lit.</span>")
		return

	. = ..()
	if(.)
		user.visible_message("<span class='notice'>[user] cracks and shakes [src].</span>", "<span class='notice'>You crack and shake [src], turning it on!</span>")
		START_PROCESSING(SSobj, src)

/obj/item/flashlight/glowstick/suicide_act(mob/living/carbon/human/user)
	if(!fuel)
		user.visible_message("<span class='suicide'>[user] is trying to squirt [src]'s fluids into [user.p_their()] eyes... but it's empty!</span>")
		return SHAME
	//var/obj/item/organ/eyes/eyes = user.getorganslot(ORGAN_SLOT_EYES)
	//if(!eyes)
	//	user.visible_message("<span class='suicide'>[user] is trying to squirt [src]'s fluids into [user.p_their()] eyes... but [user.p_they()] don't have any!</span>")
	//	return SHAME
	user.visible_message("<span class='suicide'>[user] is squirting [src]'s fluids into [user.p_their()] eyes! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	fuel = 0
	return (FIRELOSS)

/obj/item/flashlight/glowstick/red
	name = "red glowstick"
	color = LIGHT_COLOR_RED

/obj/item/flashlight/glowstick/blue
	name = "blue glowstick"
	color = LIGHT_COLOR_BLUE

/obj/item/flashlight/glowstick/cyan
	name = "cyan glowstick"
	color = LIGHT_COLOR_CYAN

/obj/item/flashlight/glowstick/orange
	name = "orange glowstick"
	color = LIGHT_COLOR_ORANGE

/obj/item/flashlight/glowstick/yellow
	name = "yellow glowstick"
	color = LIGHT_COLOR_YELLOW

/obj/item/flashlight/glowstick/pink
	name = "pink glowstick"
	color = LIGHT_COLOR_PINK