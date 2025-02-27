/obj/machinery/reagentgrinder
	name = "\improper All-In-One Grinder"
	desc = "From BlenderTech. Will It Blend? Let's test it out!"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "juicer1"
	layer = BELOW_OBJ_LAYER
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 100
	circuit = /obj/item/circuitboard/machine/reagentgrinder
	pass_flags = PASSTABLE
	resistance_flags = ACID_PROOF
	var/operating = FALSE
	var/obj/item/reagent_containers/beaker = null
	var/limit = 10
	var/speed = 1
	var/list/holdingitems

	//var/static/radial_examine = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_examine")
	//var/static/radial_eject = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_eject")
	//var/static/radial_grind = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_grind")
	//var/static/radial_juice = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_juice")
	//var/static/radial_mix = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_mix")
	//not_actual
	var/radial_examine
	var/radial_eject
	var/radial_grind
	var/radial_juice
	var/radial_mix

//not_actual compiler currently ignores arguments passed to created objects in object definitions
/obj/machinery/reagentgrinder/New()
	..()
	radial_examine = new /image(icon = 'icons/mob/radial.dmi', icon_state = "radial_examine")
	radial_eject = new /image(icon = 'icons/mob/radial.dmi', icon_state = "radial_eject")
	radial_grind = new /image(icon = 'icons/mob/radial.dmi', icon_state = "radial_grind")
	radial_juice = new /image(icon = 'icons/mob/radial.dmi', icon_state = "radial_juice")
	radial_mix = new /image(icon = 'icons/mob/radial.dmi', icon_state = "radial_mix")

/obj/machinery/reagentgrinder/Initialize()
	. = ..()
	holdingitems = list()
	beaker = new /obj/item/reagent_containers/glass/beaker/large(src)
	beaker.desc += " May contain blended dust. Don't breathe this in!"

/obj/machinery/reagentgrinder/constructed/Initialize()
	. = ..()
	holdingitems = list()
	QDEL_NULL(beaker)
	update_icon()

/obj/machinery/reagentgrinder/Destroy()
	if(beaker)
		beaker.forceMove(drop_location())
	drop_all_items()
	return ..()


/obj/machinery/reagentgrinder/contents_explosion(severity, target)
	if(beaker)
		beaker.ex_act(severity, target)

/obj/machinery/reagentgrinder/RefreshParts()
	speed = 1
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		speed = M.rating

/obj/machinery/reagentgrinder/examine(mob/user)
	..()
	if(!in_range(user, src) && !issilicon(user) && !isobserver(user))
		to_chat(user, "<span class='warning'>You're too far away to examine [src]'s contents and display!</span>")
		return

	if(operating)
		to_chat(user, "<span class='warning'>\The [src] is operating.</span>")
		return

	if(beaker || length(holdingitems))
		to_chat(user, "<span class='notice'>\The [src] contains:</span>")
		if(beaker)
			to_chat(user, "<span class='notice'>- \A [beaker].</span>")
		for(var/i in holdingitems)
			var/obj/item/O = i
			to_chat(user, "<span class='notice'>- \A [O.name].</span>")

	if(!(stat & (NOPOWER|BROKEN)))
		to_chat(user, "<span class='notice'>The status display reads:</span>")
		to_chat(user, "<span class='notice'>- Grinding reagents at <b>[speed*100]%</b>.<span>")
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			to_chat(user, "<span class='notice'>- [R.volume] units of [R.name].</span>")

/obj/machinery/reagentgrinder/handle_atom_del(atom/A)
	. = ..()
	if(A == beaker)
		beaker = null
		update_icon()
	if(holdingitems[A])
		holdingitems -= A

/obj/machinery/reagentgrinder/proc/drop_all_items()
	for(var/i in holdingitems)
		var/atom/movable/AM = i
		AM.forceMove(drop_location())
	holdingitems = list()

/obj/machinery/reagentgrinder/update_icon()
	if(beaker)
		icon_state = "juicer1"
	else
		icon_state = "juicer0"

/obj/machinery/reagentgrinder/proc/replace_beaker(mob/living/user, obj/item/reagent_containers/new_beaker)
	if(beaker)
		beaker.forceMove(drop_location())
		if(user && Adjacent(user) && !issiliconoradminghost(user))
			user.put_in_hands(beaker)
	if(new_beaker)
		beaker = new_beaker
	else
		beaker = null
	update_icon()
	return TRUE

/obj/machinery/reagentgrinder/attackby(obj/item/I, mob/user, params)
	if(!beaker && !length(holdingitems) && default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		return

	if(default_deconstruction_crowbar(I))
		return

	if(default_unfasten_wrench(user, I))
		return

	if(panel_open)
		return TRUE

	if (istype(I, /obj/item/reagent_containers) && !(I.item_flags & ABSTRACT) && I.is_open_container())
		var/obj/item/reagent_containers/B = I
		. = TRUE
		if(!user.transferItemToLoc(B, src))
			return
		replace_beaker(user, B)
		to_chat(user, "<span class='notice'>You add [B] to [src].</span>")
		updateUsrDialog()
		update_icon()
		return TRUE

	if(holdingitems.len >= limit)
		to_chat(user, "<span class='warning'>[src] is filled to capacity!</span>")
		return TRUE

	//if(istype(I, /obj/item/storage/bag))
	//	var/list/inserted = list()
	//	if(SEND_SIGNAL(I, COMSIG_TRY_STORAGE_TAKE_TYPE, /obj/item/reagent_containers/food/snacks/grown, src, limit - length(holdingitems), null, null, user, inserted))
	//		for(var/i in inserted)
	//			holdingitems[i] = TRUE
	//		if(!I.contents.len)
	//			to_chat(user, "<span class='notice'>You empty [I] into [src].</span>")
	//		else
	//			to_chat(user, "<span class='notice'>You fill [src] to the brim.</span>")
	//	return TRUE

	if(!I.grind_results && !I.juice_results)
		if(user.a_intent == INTENT_HARM)
			return ..()
		else
			to_chat(user, "<span class='warning'>You cannot grind [I] into reagents!</span>")
			return TRUE

	if(!I.grind_requirements(src))
		return

	if(user.transferItemToLoc(I, src))
		to_chat(user, "<span class='notice'>You add [I] to [src].</span>")
		holdingitems[I] = TRUE
		return FALSE

/obj/machinery/reagentgrinder/ui_interact(mob/user)
	. = ..()

	if(operating || !user.canUseTopic(src))
		return

	var/list/options = list()

	if(beaker || length(holdingitems))
	options["eject"] = radial_eject

	if(isAI(user))
		if(stat & NOPOWER)
			return
		options["examine"] = radial_examine

	if(length(holdingitems))
		options["grind"] = radial_grind
		options["juice"] = radial_juice
	else if(beaker?.reagents.total_volume)
		options["mix"] = radial_mix

	var/choice

	if(length(options) < 1)
		return
	if(length(options) == 1)
		for(var/key in options)
			choice = key
	else
		choice = show_radial_menu(user, src, options, require_near = !issilicon(user))

	if(operating || (isAI(user) && stat & NOPOWER) || !user.canUseTopic(src))
		return

	switch(choice)
		if("eject")
			eject(user)
		if("grind")
			grind(user)
		//if("juice")
		//	juice(user)
		//if("mix")
		//	mix(user)
		if("examine")
			examine(user)

/obj/machinery/reagentgrinder/proc/eject(mob/user)
	for(var/i in holdingitems)
		var/obj/item/O = i
		O.forceMove(drop_location())
		holdingitems -= O
	if(beaker)
		replace_beaker(user)

/obj/machinery/reagentgrinder/proc/remove_object(obj/item/O)
	holdingitems -= O
	qdel(O)

/obj/machinery/reagentgrinder/proc/shake_for(duration)
	var/offset = prob(50) ? -2 : 2
	var/old_pixel_x = pixel_x
	animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = -1)
	addtimer(CALLBACK(src, .proc/stop_shaking, old_pixel_x), duration)

/obj/machinery/reagentgrinder/proc/stop_shaking(old_px)
	animate(src)
	pixel_x = old_px

/obj/machinery/reagentgrinder/proc/operate_for(time, silent = FALSE, juicing = FALSE)
	shake_for(time / speed)
	operating = TRUE
	if(!silent)
		if(!juicing)
			playsound(src, 'sound/machines/blender.ogg', 50, 1)
		else
			playsound(src, 'sound/machines/juicer.ogg', 20, 1)
	addtimer(CALLBACK(src, .proc/stop_operating), time / speed)

/obj/machinery/reagentgrinder/proc/stop_operating()
	operating = FALSE

/obj/machinery/reagentgrinder/proc/grind(mob/user)
	power_change()
	if(!beaker || stat & (NOPOWER|BROKEN) || beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
		return
	operate_for(60)
	for(var/i in holdingitems)
		if(beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		var/obj/item/I = i
		if(I.grind_results)
			grind_item(i, user)

/obj/machinery/reagentgrinder/proc/grind_item(obj/item/I, mob/user)
	if(I.on_grind(src) == -1)
		to_chat(usr, "<span class='danger'>[src] shorts out as it tries to grind up [I], and transfers it back to storage.</span>")
		return
	beaker.reagents.add_reagent_list(I.grind_results)
	if(I.reagents)
		I.reagents.trans_to(beaker, I.reagents.total_volume, transfered_by = user)
	remove_object(I)