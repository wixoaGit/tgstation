/proc/do_sparks(n, c, source)
	var/datum/effect_system/spark_spread/sparks = new
	sparks.set_up(n, c, source)
	sparks.autocleanup = TRUE
	sparks.start()


/obj/effect/particle_effect/sparks
	name = "sparks"
	icon_state = "sparks"
	anchored = TRUE
	light_power = 1.3
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	light_color = LIGHT_COLOR_FIRE

/obj/effect/particle_effect/sparks/Initialize()
	. = ..()
	//flick("sparks", src)
	playsound(src, "sparks", 100, TRUE)
	var/turf/T = loc
	//if(isturf(T))
	//	T.hotspot_expose(1000,100)
	QDEL_IN(src, 20)

/obj/effect/particle_effect/sparks/Destroy()
	var/turf/T = loc
	//if(isturf(T))
	//	T.hotspot_expose(1000,100)
	return ..()

/obj/effect/particle_effect/sparks/Move()
	..()
	//var/turf/T = loc
	//if(isturf(T))
	//	T.hotspot_expose(1000,100)

/datum/effect_system/spark_spread
	effect_type = /obj/effect/particle_effect/sparks

/obj/effect/particle_effect/sparks/electricity
	name = "lightning"
	icon_state = "electricity"

/datum/effect_system/lightning_spread
	effect_type = /obj/effect/particle_effect/sparks/electricity
