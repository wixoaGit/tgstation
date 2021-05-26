/turf/open/floor/plating
	name = "plating"
	icon_state = "plating"
	intact = FALSE
	baseturfs = /turf/baseturf_bottom
	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

	var/attachment_holes = TRUE

/turf/open/floor/plating/Initialize()
	if (!broken_states)
		broken_states = list("platingdmg1", "platingdmg2", "platingdmg3")
	if (!burnt_states)
		burnt_states = list("panelscorched")
	. = ..()
	if(!attachment_holes || (!broken && !burnt))
		icon_plating = icon_state
	else
		icon_plating = initial(icon_state)

/turf/open/floor/plating/examine(mob/user)
	..()
	if(broken || burnt)
		to_chat(user, "<span class='notice'>It looks like the dents could be <i>welded</i> smooth.</span>")
		return
	if(attachment_holes)
		to_chat(user, "<span class='notice'>There are a few attachment holes for a new <i>tile</i> or reinforcement <i>rods</i>.</span>")
	else
		to_chat(user, "<span class='notice'>You might be able to build ontop of it with some <i>tiles</i>...</span>")

/turf/open/floor/plating/update_icon()
	if(!..())
		return
	if(!broken && !burnt)
		icon_state = icon_plating

/turf/open/floor/plating/attackby(obj/item/C, mob/user, params)
	if(..())
		return

	if(istype(C, /obj/item/stack/rods) && attachment_holes)
		if(broken || burnt)
			to_chat(user, "<span class='warning'>Repair the plating first!</span>")
			return
		var/obj/item/stack/rods/R = C
		if (R.get_amount() < 2)
			to_chat(user, "<span class='warning'>You need two rods to make a reinforced floor!</span>")
			return
		else
			to_chat(user, "<span class='notice'>You begin reinforcing the floor...</span>")
			if(do_after(user, 30, target = src))
				if (R.get_amount() >= 2 && !istype(src, /turf/open/floor/engine))
					PlaceOnTop(/turf/open/floor/engine)
					playsound(src, 'sound/items/deconstruct.ogg', 80, 1)
					R.use(2)
					to_chat(user, "<span class='notice'>You reinforce the floor.</span>")
				return
	if(istype(C, /obj/item/stack/tile))
		if(!broken && !burnt)
			//for(var/obj/O in src)
			//	if(O.level == 1)
			//		for(var/M in O.buckled_mobs)
			//			to_chat(user, "<span class='warning'>Someone is buckled to \the [O]! Unbuckle [M] to move \him out of the way.</span>")
			//			return
			var/obj/item/stack/tile/W = C
			if(!W.use(1))
				return
			//var/turf/open/floor/T = PlaceOnTop(W.turf_type)
			PlaceOnTop(W.turf_type)//not_actual
			//if(istype(W, /obj/item/stack/tile/light))
			//	var/obj/item/stack/tile/light/L = W
			//	var/turf/open/floor/light/F = T
			//	F.state = L.state
			playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
		else
			to_chat(user, "<span class='warning'>This section is too damaged to support a tile! Use a welder to fix the damage.</span>")

/turf/open/floor/plating/welder_act(mob/living/user, obj/item/I)
	if((broken || burnt) && I.use_tool(src, user, 0, volume=80))
		to_chat(user, "<span class='danger'>You fix some dents on the broken plating.</span>")
		icon_state = icon_plating
		burnt = FALSE
		broken = FALSE

	return TRUE

/turf/open/floor/plating/make_plating()
	return