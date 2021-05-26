/obj/item/ammo_casing
	name = "bullet casing"
	desc = "A bullet casing."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "s-casing"
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	materials = list(MAT_METAL = 500)
	var/fire_sound = null
	var/caliber = null
	var/projectile_type = null
	var/obj/item/projectile/BB = null
	var/pellets = 1
	var/variance = 0
	var/randomspread = 0
	var/delay = 0
	var/click_cooldown_override = 0
	var/firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect
	var/heavy_metal = TRUE
	var/harmful = TRUE

/obj/item/ammo_casing/Initialize()
	. = ..()
	if(projectile_type)
		BB = new projectile_type(src)
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, 10)
	setDir(pick(GLOB.alldirs))
	update_icon()

/obj/item/ammo_casing/update_icon()
	..()
	icon_state = "[initial(icon_state)][BB ? "-live" : ""]"
	desc = "[initial(desc)][BB ? "" : " This one is spent."]"

/obj/item/ammo_casing/proc/newshot()
	if(!BB)
		BB = new projectile_type(src, src)

/obj/item/ammo_casing/proc/bounce_away(still_warm = FALSE, bounce_delay = 3)
	update_icon()
	//SpinAnimation(10, 1)
	var/turf/T = get_turf(src)
	if(still_warm && T && T.bullet_sizzle)
		addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, src, 'sound/items/welder.ogg', 20, 1), bounce_delay)
	else if(T && T.bullet_bounce_sound)
		addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, src, T.bullet_bounce_sound, 60, 1), bounce_delay)