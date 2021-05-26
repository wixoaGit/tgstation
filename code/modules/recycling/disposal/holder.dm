/obj/structure/disposalholder
	invisibility = INVISIBILITY_MAXIMUM
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	dir = NONE
	//rad_flags = RAD_PROTECT_CONTENTS | RAD_NO_CONTAMINATE
	var/datum/gas_mixture/gas
	var/active = FALSE
	var/count = 1000
	var/destinationTag = NONE
	var/tomail = FALSE
	var/hasmob = FALSE

/obj/structure/disposalholder/Destroy()
	QDEL_NULL(gas)
	active = FALSE
	return ..()

/obj/structure/disposalholder/proc/init(obj/machinery/disposal/D)
	gas = D.air_contents

	for(var/mob/living/M in D)
		//if(M.client)
		//	M.reset_perspective(src)
		hasmob = TRUE

	for(var/obj/O in D)
		if(locate(/mob/living) in O)
			hasmob = TRUE
			break

	for(var/A in D)
		var/atom/movable/AM = A
		if(AM == src)
			continue
		SEND_SIGNAL(AM, COMSIG_MOVABLE_DISPOSING, src, D)
		AM.forceMove(src)
		//if(istype(AM, /obj/structure/bigDelivery) && !hasmob)
		//	var/obj/structure/bigDelivery/T = AM
		//	src.destinationTag = T.sortTag
		//else if(istype(AM, /obj/item/smallDelivery) && !hasmob)
		//	var/obj/item/smallDelivery/T = AM
		//	src.destinationTag = T.sortTag
		//else if(istype(AM, /mob/living/silicon/robot))
		//	var/obj/item/destTagger/borg/tagger = locate() in AM
		//	if (tagger)
		//		src.destinationTag = tagger.currTag

/obj/structure/disposalholder/proc/start(obj/machinery/disposal/D)
	if(!D.trunk)
		D.expel(src)
		return
	forceMove(D.trunk)
	active = TRUE
	setDir(DOWN)
	//move()

/obj/structure/disposalholder/relaymove(mob/user)
	if(user.incapacitated())
		return
	for(var/mob/M in range(5, get_turf(src)))
		M.show_message("<FONT size=[max(0, 5 - get_dist(src, M))]>CLONG, clong!</FONT>", 2)
	playsound(src.loc, 'sound/effects/clang.ogg', 50, 0, 0)

/obj/structure/disposalholder/proc/vent_gas(turf/T)
	T.assume_air(gas)
	T.air_update_turf()

/obj/structure/disposalholder/AllowDrop()
	return TRUE

/obj/structure/disposalholder/ex_act(severity, target)
	return