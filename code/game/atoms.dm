/atom
	layer = TURF_LAYER
	var/level = 2
	var/article

	var/flags_1 = NONE
	var/interaction_flags_atom = NONE
	var/datum/reagents/reagents = null

	var/list/image/hud_list = null

	var/explosion_block = 0

	var/list/atom_colours

	var/custom_price
	var/custom_premium_price

/atom/New(loc, ...)
	if(GLOB.use_preloader && (src.type == GLOB._preloader.target_path))
		GLOB._preloader.load(src)

	//if(datum_flags & DF_USE_TAG)
	//	GenerateTag()

	var/do_initialize = SSatoms.initialized
	if(do_initialize != INITIALIZATION_INSSATOMS)
		args[1] = do_initialize == INITIALIZATION_INNEW_MAPLOAD
		if(SSatoms.InitAtom(src, args))
			return

/atom/proc/Initialize(mapload, ...)
	if(flags_1 & INITIALIZED_1)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	flags_1 |= INITIALIZED_1

	if(color)
		add_atom_colour(color, FIXED_COLOUR_PRIORITY)

	if (light_power && light_range)
		update_light()

	//if (opacity && isturf(loc))
	//	var/turf/T = loc
	//	T.has_opaque_atom = TRUE

	if (canSmoothWith)
		canSmoothWith = typelist("canSmoothWith", canSmoothWith)

	ComponentInitialize()

	return INITIALIZE_HINT_NORMAL

/atom/proc/LateInitialize()
	return

/atom/proc/ComponentInitialize()
	return

/atom/Destroy()
	//if(alternate_appearances)
	//	for(var/K in alternate_appearances)
	//		var/datum/atom_hud/alternate_appearance/AA = alternate_appearances[K]
	//		AA.remove_from_hud(src)

	if(reagents)
		qdel(reagents)

	//orbiters = null

	LAZYCLEARLIST(overlays)
	//LAZYCLEARLIST(priority_overlays)

	QDEL_NULL(light)

	return ..()

/atom/proc/handle_ricochet(obj/item/projectile/P)
	return

/atom/proc/CanPass(atom/movable/mover, turf/target)
	return !density

/atom/proc/onCentCom()
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE

	//if(is_reserved_level(T.z))
	//	for(var/A in SSshuttle.mobile)
	//		var/obj/docking_port/mobile/M = A
	//		if(M.launch_status == ENDGAME_TRANSIT)
	//			for(var/place in M.shuttle_areas)
	//				var/area/shuttle/shuttle_area = place
	//				if(T in shuttle_area)
	//					return TRUE

	if(!is_centcom_level(T.z))
		return FALSE

	if(istype(T.loc, /area/centcom))
		return TRUE

	//for(var/A in SSshuttle.mobile)
	//	var/obj/docking_port/mobile/M = A
	//	if(M.launch_status == ENDGAME_LAUNCHED)
	//		for(var/place in M.shuttle_areas)
	//			var/area/shuttle/shuttle_area = place
	//			if(T in shuttle_area)
	//				return TRUE

/atom/proc/onSyndieBase()
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE

	if(!is_centcom_level(T.z))
		return FALSE

	if(istype(T.loc, /area/shuttle/syndicate) || istype(T.loc, /area/syndicate_mothership) || istype(T.loc, /area/shuttle/assault_pod))
		return TRUE

	return FALSE

/atom/proc/assume_air(datum/gas_mixture/giver)
	qdel(giver)
	return null

/atom/proc/remove_air(amount)
	return null

/atom/proc/return_air()
	if(loc)
		return loc.return_air()
	else
		return null

/atom/proc/Bumped(atom/movable/AM)
	set waitfor = FALSE

/atom/proc/is_open_container()
	return is_refillable() && is_drainable()

/atom/proc/is_injectable(mob/user, allowmobs = TRUE)
	return reagents && (reagents.flags & (INJECTABLE | REFILLABLE))

/atom/proc/is_drawable(mob/user, allowmobs = TRUE)
	return reagents && (reagents.flags & (DRAWABLE | DRAINABLE))

/atom/proc/is_refillable()
	return reagents && (reagents.flags & REFILLABLE)

/atom/proc/is_drainable()
	return reagents && (reagents.flags & DRAINABLE)

/atom/proc/AllowDrop()
	return FALSE

/atom/proc/CheckExit()
	return 1

/atom/proc/emp_act(severity)
	var/protection = SEND_SIGNAL(src, COMSIG_ATOM_EMP_ACT, severity)
	//if(!(protection & EMP_PROTECT_WIRES) && istype(wires))
	//	wires.emp_pulse()
	return protection

/atom/proc/bullet_act(obj/item/projectile/P, def_zone)
	//SEND_SIGNAL(src, COMSIG_ATOM_BULLET_ACT, P, def_zone)
	. = P.on_hit(src, 0, def_zone)

/atom/proc/get_examine_name(mob/user)
	. = "\a [src]"
	//var/list/override = list(gender == PLURAL ? "some" : "a", " ", "[name]")
	if(article)
		. = "[article] [src]"
		//override[EXAMINE_POSITION_ARTICLE] = article
	//if(SEND_SIGNAL(src, COMSIG_ATOM_GET_EXAMINE_NAME, user, override) & COMPONENT_EXNAME_CHANGED)
	//	. = override.Join("")

/atom/proc/get_examine_string(mob/user, thats = FALSE)
	. = "[icon2html(src, user)] [thats? "That's ":""][get_examine_name(user)]"

/atom/proc/examine(mob/user)
	to_chat(user, get_examine_string(user, TRUE))

	if (desc)
		to_chat(user, desc)
	
	if(reagents)
		if(reagents.flags & TRANSPARENT)
			to_chat(user, "It contains:")
			if(reagents.reagent_list.len)
				//if(user.can_see_reagents())
				if(TRUE)//not_actual
					for(var/datum/reagent/R in reagents.reagent_list)
						to_chat(user, "[R.volume] units of [R.name]")
				else
					var/total_volume = 0
					for(var/datum/reagent/R in reagents.reagent_list)
						total_volume += R.volume
					to_chat(user, "[total_volume] units of various reagents")
			else
				to_chat(user, "Nothing.")
		else if(reagents.flags & AMOUNT_VISIBLE)
			if(reagents.total_volume)
				to_chat(user, "<span class='notice'>It has [reagents.total_volume] unit\s left.</span>")
			else
				to_chat(user, "<span class='danger'>It's empty.</span>")
	
	SEND_SIGNAL(src, COMSIG_PARENT_EXAMINE, user)

/atom/proc/relaymove(mob/user)
	return

/atom/proc/prevent_content_explosion()
	return FALSE

/atom/proc/contents_explosion(severity, target)
	return

/atom/proc/ex_act(severity, target)
	set waitfor = FALSE
	contents_explosion(severity, target)
	SEND_SIGNAL(src, COMSIG_ATOM_EX_ACT, severity, target)

/atom/proc/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(density && !has_gravity(AM))
		addtimer(CALLBACK(src, .proc/hitby_react, AM), 2)

/atom/proc/hitby_react(atom/movable/AM)
	if(AM && isturf(AM.loc))
		step(AM, turn(AM.dir, 180))

/atom/proc/transfer_mob_blood_dna(mob/living/L)
	//var/new_blood_dna = L.get_blood_dna_list()
	//if(!new_blood_dna)
	//	return FALSE
	//var/old_length = blood_DNA_length()
	//add_blood_DNA(new_blood_dna)
	//if(blood_DNA_length() == old_length)
	//	return FALSE
	return TRUE

/atom/proc/emag_act()
	SEND_SIGNAL(src, COMSIG_ATOM_EMAG_ACT)

/atom/proc/get_dumping_location(obj/item/storage/source,mob/user)
	return null

/atom/proc/handle_atom_del(atom/A)
	SEND_SIGNAL(src, COMSIG_ATOM_CONTENTS_DEL, A)

/atom/proc/setDir(newdir)
	dir = newdir

/atom/proc/on_log(login)
	if(loc)
		loc.on_log(login)

/atom/proc/add_atom_colour(coloration, colour_priority)
	if(!atom_colours || !atom_colours.len)
		atom_colours = list()
		atom_colours.len = COLOUR_PRIORITY_AMOUNT
	if(!coloration)
		return
	if(colour_priority > atom_colours.len)
		return
	atom_colours[colour_priority] = coloration
	update_atom_colour()

/atom/proc/remove_atom_colour(colour_priority, coloration)
	if(!atom_colours)
		atom_colours = list()
		atom_colours.len = COLOUR_PRIORITY_AMOUNT
	if(colour_priority > atom_colours.len)
		return
	if(coloration && atom_colours[colour_priority] != coloration)
		return
	atom_colours[colour_priority] = null
	update_atom_colour()

/atom/proc/update_atom_colour()
	if(!atom_colours)
		atom_colours = list()
		atom_colours.len = COLOUR_PRIORITY_AMOUNT
	color = null
	for(var/C in atom_colours)
		if(islist(C))
			var/list/L = C
			if(L.len)
				color = L
				return
		else if(C)
			color = C
			return

/atom/proc/drop_location()
	var/atom/L = loc
	if(!L)
		return null
	return L.AllowDrop() ? L : L.drop_location()

/atom/Entered(atom/movable/AM, atom/oldLoc)
	SEND_SIGNAL(src, COMSIG_ATOM_ENTERED, AM, oldLoc)

/atom/Exit(atom/movable/AM, atom/newLoc)
	. = ..()
	if(SEND_SIGNAL(src, COMSIG_ATOM_EXIT, AM, newLoc) & COMPONENT_ATOM_BLOCK_EXIT)
		return FALSE

/atom/Exited(atom/movable/AM, atom/newLoc)
	SEND_SIGNAL(src, COMSIG_ATOM_EXITED, AM, newLoc)

/atom/proc/tool_act(mob/living/user, obj/item/I, tool_type)
	switch(tool_type)
		if(TOOL_CROWBAR)
			return crowbar_act(user, I)
		if(TOOL_MULTITOOL)
			return multitool_act(user, I)
		if(TOOL_SCREWDRIVER)
			return screwdriver_act(user, I)
		if(TOOL_WRENCH)
			return wrench_act(user, I)
		if(TOOL_WIRECUTTER)
			return wirecutter_act(user, I)
		if(TOOL_WELDER)
			return welder_act(user, I)
		if(TOOL_ANALYZER)
			return analyzer_act(user, I)

/atom/proc/crowbar_act(mob/living/user, obj/item/I)
	return

/atom/proc/multitool_act(mob/living/user, obj/item/I)
	return

/atom/proc/screwdriver_act(mob/living/user, obj/item/I)
	SEND_SIGNAL(src, COMSIG_ATOM_SCREWDRIVER_ACT, user, I)

/atom/proc/wrench_act(mob/living/user, obj/item/I)
	return

/atom/proc/wirecutter_act(mob/living/user, obj/item/I)
	return

/atom/proc/welder_act(mob/living/user, obj/item/I)
	return

/atom/proc/analyzer_act(mob/living/user, obj/item/I)
	return

/atom/proc/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	return

/proc/log_combat(atom/user, atom/target, what_done, atom/object=null, addition=null)
	//var/ssource = key_name(user)
	//var/starget = key_name(target)

	//var/mob/living/living_target = target
	//var/hp = istype(living_target) ? " (NEWHP: [living_target.health]) " : ""

	//var/sobject = ""
	//if(object)
	//	sobject = " with [key_name(object)]"
	//var/saddition = ""
	//if(addition)
	//	saddition = " [addition]"

	//var/postfix = "[sobject][saddition][hp]"

	//var/message = "has [what_done] [starget][postfix]"
	//user.log_message(message, LOG_ATTACK, color="red")

	//if(user != target)
	//	var/reverse_message = "has been [what_done] by [ssource][postfix]"
	//	target.log_message(reverse_message, LOG_ATTACK, color="orange", log_globally=FALSE)