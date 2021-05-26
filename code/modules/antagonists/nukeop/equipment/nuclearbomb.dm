/obj/item/disk
	icon = 'icons/obj/module.dmi'
	w_class = WEIGHT_CLASS_TINY
	item_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	icon_state = "datadisk0"

/obj/item/disk/nuclear
	name = "nuclear authentication disk"
	desc = "Better keep this safe."
	icon_state = "nucleardisk"
	//persistence_replacement = /obj/item/disk/nuclear/fake
	max_integrity = 250
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 30, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/fake = FALSE
	var/turf/lastlocation
	var/last_disk_move

/obj/item/disk/nuclear/Initialize()
	. = ..()
	if(!fake)
		GLOB.poi_list |= src
		last_disk_move = world.time
		START_PROCESSING(SSobj, src)

/obj/item/disk/nuclear/ComponentInitialize()
	. = ..()
	//AddComponent(/datum/component/stationloving, !fake)

/obj/item/disk/nuclear/process()
	if(fake)
		STOP_PROCESSING(SSobj, src)
		CRASH("A fake nuke disk tried to call process(). Who the fuck and how the fuck")
	//var/turf/newturf = get_turf(src)
	//if(newturf && lastlocation == newturf)
	//	if(last_disk_move < world.time - 5000 && prob((world.time - 5000 - last_disk_move)*0.0001))
	//		var/datum/round_event_control/operative/loneop = locate(/datum/round_event_control/operative) in SSevents.control
	//		if(istype(loneop))
	//			loneop.weight += 1
	//			if(loneop.weight % 5 == 0)
	//				message_admins("[src] is stationary in [ADMIN_VERBOSEJMP(newturf)]. The weight of Lone Operative is now [loneop.weight].")
	//			log_game("[src] is stationary for too long in [loc_name(newturf)], and has increased the weight of the Lone Operative event to [loneop.weight].")

	//else
	//	lastlocation = newturf
	//	last_disk_move = world.time
	//	var/datum/round_event_control/operative/loneop = locate(/datum/round_event_control/operative) in SSevents.control
	//	if(istype(loneop) && prob(loneop.weight))
	//		loneop.weight = max(loneop.weight - 1, 0)
	//		if(loneop.weight % 5 == 0)
	//			message_admins("[src] is on the move (currently in [ADMIN_VERBOSEJMP(newturf)]). The weight of Lone Operative is now [loneop.weight].")
	//		log_game("[src] being on the move has reduced the weight of the Lone Operative event to [loneop.weight].")

/obj/item/disk/nuclear/examine(mob/user)
	. = ..()
	if(!fake)
		return

	if(isobserver(user) || user.has_trait(TRAIT_DISK_VERIFIER))
		to_chat(user, "<span class='warning'>The serial numbers on [src] are incorrect.</span>")

/obj/item/disk/nuclear/attackby(obj/item/I, mob/living/user, params)
	//if(istype(I, /obj/item/claymore/highlander) && !fake)
	//	var/obj/item/claymore/highlander/H = I
	//	if(H.nuke_disk)
	//		to_chat(user, "<span class='notice'>Wait... what?</span>")
	//		qdel(H.nuke_disk)
	//		H.nuke_disk = null
	//		return
	//	user.visible_message("<span class='warning'>[user] captures [src]!</span>", "<span class='userdanger'>You've got the disk! Defend it with your life!</span>")
	//	forceMove(H)
	//	H.nuke_disk = src
	//	return TRUE
	return ..()

/obj/item/disk/nuclear/Destroy(force=FALSE)
	if(force)
		GLOB.poi_list -= src
	. = ..()

/obj/item/disk/nuclear/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is going delta! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(src, 'sound/machines/alarm.ogg', 50, -1, 1)
	for(var/i in 1 to 100)
		addtimer(CALLBACK(user, /atom/proc/add_atom_colour, (i % 2)? "#00FF00" : "#FF0000", ADMIN_COLOUR_PRIORITY), i)
	addtimer(CALLBACK(src, .proc/manual_suicide, user), 101)
	return MANUAL_SUICIDE

/obj/item/disk/nuclear/proc/manual_suicide(mob/living/user)
	user.remove_atom_colour(ADMIN_COLOUR_PRIORITY)
	user.visible_message("<span class='suicide'>[user] was destroyed by the nuclear blast!</span>")
	user.adjustOxyLoss(200)
	user.death(0)

/obj/item/disk/nuclear/fake
	fake = TRUE

/obj/item/disk/nuclear/fake/obvious
	name = "cheap plastic imitation of the nuclear authentication disk"
	desc = "How anyone could mistake this for the real thing is beyond you."