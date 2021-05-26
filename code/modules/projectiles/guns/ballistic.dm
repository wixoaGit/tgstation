/obj/item/gun/ballistic
	desc = "Now comes in flavors like GUN. Uses 10mm ammo, for some reason."
	name = "projectile gun"
	icon_state = "pistol"
	w_class = WEIGHT_CLASS_NORMAL
	var/spawnwithmagazine = TRUE
	var/mag_type = /obj/item/ammo_box/magazine/m10mm
	var/obj/item/ammo_box/magazine/magazine
	var/casing_ejector = TRUE
	var/magazine_wording = "magazine"

/obj/item/gun/ballistic/Initialize()
	. = ..()
	if(!spawnwithmagazine)
		update_icon()
		return
	if (!magazine)
		magazine = new mag_type(src)
	chamber_round()
	update_icon()

/obj/item/gun/ballistic/update_icon()
	..()
	//if(current_skin)
	if(FALSE)//not_actual
		//icon_state = "[unique_reskin[current_skin]][suppressed ? "-suppressed" : ""][sawn_off ? "-sawn" : ""]"
	else
		icon_state = "[initial(icon_state)][suppressed ? "-suppressed" : ""][sawn_off ? "-sawn" : ""]"

/obj/item/gun/ballistic/process_chamber(empty_chamber = 1)
	var/obj/item/ammo_casing/AC = chambered
	if(istype(AC))
		if(casing_ejector)
			AC.forceMove(drop_location())
			AC.bounce_away(TRUE)
			chambered = null
		else if(empty_chamber)
			chambered = null
	chamber_round()

/obj/item/gun/ballistic/proc/chamber_round()
	if (chambered || !magazine)
		return
	else if (magazine.ammo_count())
		chambered = magazine.get_round()
		chambered.forceMove(src)