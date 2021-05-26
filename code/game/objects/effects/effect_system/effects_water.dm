/obj/effect/particle_effect/water
	name = "water"
	icon_state = "extinguish"
	var/life = 15
	//mouse_opacity = MOUSE_OPACITY_TRANSPARENT


/obj/effect/particle_effect/water/Initialize()
	. = ..()
	QDEL_IN(src, 70)

/obj/effect/particle_effect/water/Move(turf/newloc)
	if (--src.life < 1)
		qdel(src)
		return 0
	if(newloc.density)
		return 0
	.=..()

/obj/effect/particle_effect/water/Bump(atom/A)
	if(reagents)
		reagents.reaction(A)
	return ..()