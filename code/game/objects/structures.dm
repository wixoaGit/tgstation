/obj/structure
	icon = 'icons/obj/structures.dmi'
	pressure_resistance = 8
	max_integrity = 300
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND | INTERACT_ATOM_UI_INTERACT
	var/climb_time = 20
	var/climb_stun = 20
	var/climbable = FALSE
	var/mob/living/structureclimber
	var/broken = 0

/obj/structure/Initialize()
	if (!armor)
		armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	. = ..()
	if(smooth)
		queue_smooth(src)
		queue_smooth_neighbors(src)
		icon_state = ""
	//GLOB.cameranet.updateVisibility(src)

/obj/structure/Destroy()
	//GLOB.cameranet.updateVisibility(src)
	if(smooth)
		queue_smooth_neighbors(src)
	return ..()

/obj/structure/ui_act(action, params)
	..()
	add_fingerprint(usr)

/obj/structure/examine(mob/user)
	..()
	if(!(resistance_flags & INDESTRUCTIBLE))
		if(resistance_flags & ON_FIRE)
			to_chat(user, "<span class='warning'>It's on fire!</span>")
		if(broken)
			to_chat(user, "<span class='notice'>It appears to be broken.</span>")
		var/examine_status = examine_status(user)
		if(examine_status)
			to_chat(user, examine_status)

/obj/structure/proc/examine_status(mob/user)
	var/healthpercent = (obj_integrity/max_integrity) * 100
	switch(healthpercent)
		if(50 to 99)
			return  "It looks slightly damaged."
		if(25 to 50)
			return  "It appears heavily damaged."
		if(0 to 25)
			if(!broken)
				return  "<span class='warning'>It's falling apart!</span>"