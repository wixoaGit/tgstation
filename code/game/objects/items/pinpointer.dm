/obj/item/pinpointer
	name = "pinpointer"
	desc = "A handheld tracking device that locks onto certain signals."
	icon = 'icons/obj/device.dmi'
	icon_state = "pinpointer"
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL = 500, MAT_GLASS = 250)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/active = FALSE
	var/atom/movable/target
	var/minimum_range = 0
	var/alert = FALSE

/obj/item/pinpointer/Initialize()
	. = ..()
	GLOB.pinpointer_list += src

/obj/item/pinpointer/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	GLOB.pinpointer_list -= src
	target = null
	return ..()

/obj/item/pinpointer/attack_self(mob/living/user)
	toggle_on()
	user.visible_message("<span class='notice'>[user] [active ? "" : "de"]activates [user.p_their()] pinpointer.</span>", "<span class='notice'>You [active ? "" : "de"]activate your pinpointer.</span>")

/obj/item/pinpointer/proc/toggle_on()
	active = !active
	playsound(src, 'sound/items/screwdriver2.ogg', 50, 1)
	if(active)
		START_PROCESSING(SSfastprocess, src)
	else
		target = null
		STOP_PROCESSING(SSfastprocess, src)
	update_icon()

/obj/item/pinpointer/process()
	if(!active)
		return PROCESS_KILL
	scan_for_target()
	update_icon()

/obj/item/pinpointer/proc/scan_for_target()
	return

/obj/item/pinpointer/update_icon()
	cut_overlays()
	if(!active)
		return
	if(!target)
		add_overlay("pinon[alert ? "alert" : ""]null")
		return
	var/turf/here = get_turf(src)
	var/turf/there = get_turf(target)
	if(here.z != there.z)
		add_overlay("pinon[alert ? "alert" : ""]null")
		return
	if(get_dist_euclidian(here,there) <= minimum_range)
		add_overlay("pinon[alert ? "alert" : ""]direct")
	else
		setDir(get_dir(here, there))
		switch(get_dist(here, there))
			if(1 to 8)
				add_overlay("pinon[alert ? "alert" : "close"]")
			if(9 to 16)
				add_overlay("pinon[alert ? "alert" : "medium"]")
			if(16 to INFINITY)
				add_overlay("pinon[alert ? "alert" : "far"]")