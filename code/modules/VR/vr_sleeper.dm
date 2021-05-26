/obj/machinery/vr_sleeper
	name = "virtual reality sleeper"
	desc = "A sleeper modified to alter the subconscious state of the user, allowing them to visit virtual worlds."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	state_open = TRUE
	//occupant_typecache = list(/mob/living/carbon/human)
	circuit = /obj/item/circuitboard/machine/vr_sleeper
	var/you_die_in_the_game_you_die_for_real = FALSE
	var/datum/effect_system/spark_spread/sparks
	//var/mob/living/carbon/human/virtual_reality/vr_human
	var/vr_category = "default"
	var/allow_creating_vr_humans = TRUE
	var/only_current_user_can_interact = FALSE

/obj/machinery/vr_sleeper/Initialize()
	. = ..()
	sparks = new /datum/effect_system/spark_spread()
	sparks.set_up(2,0)
	sparks.attach(src)
	update_icon()

/obj/machinery/vr_sleeper/attackby(obj/item/I, mob/user, params)
	if(!state_open && !occupant)
		if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", initial(icon_state), I))
			return
	if(default_change_direction_wrench(user, I))
		return
	if(default_pry_open(I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/vr_sleeper/relaymove(mob/user)
	open_machine()

/obj/machinery/vr_sleeper/container_resist(mob/living/user)
	open_machine()

/obj/machinery/vr_sleeper/Destroy()
	open_machine()
	//cleanup_vr_human()
	QDEL_NULL(sparks)
	return ..()

/obj/machinery/vr_sleeper/emag_act(mob/user)
	you_die_in_the_game_you_die_for_real = TRUE
	//sparks.start()
	addtimer(CALLBACK(src, .proc/emagNotify), 150)

/obj/machinery/vr_sleeper/update_icon()
	icon_state = "[initial(icon_state)][state_open ? "-open" : ""]"

/obj/machinery/vr_sleeper/proc/emagNotify()
	//if(vr_human)
	//	vr_human.Dizzy(10)