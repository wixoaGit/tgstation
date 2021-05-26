GLOBAL_LIST_EMPTY(ghost_images_default)
GLOBAL_LIST_EMPTY(ghost_images_simple)

GLOBAL_VAR_INIT(observer_default_invisibility, INVISIBILITY_OBSERVER)

/mob/dead/observer
	name = "ghost"
	desc = "It's a g-g-g-g-ghooooost!"
	icon = 'icons/mob/mob.dmi'
	icon_state = "ghost"
	layer = GHOST_LAYER
	stat = DEAD
	density = FALSE
	//see_invisible = SEE_INVISIBLE_OBSERVER
	//see_in_dark = 100
	invisibility = INVISIBILITY_OBSERVER
	//hud_type = /datum/hud/ghost
	movement_type = GROUND | FLYING
	var/can_reenter_corpse
	var/do_not_resuscitate
	var/datum/hud/living/carbon/hud = null
	var/bootime = 0
	var/started_as_observer
	var/atom/movable/following = null
	var/fun_verbs = 0
	var/image/ghostimage_default = null
	var/image/ghostimage_simple = null
	var/ghostvision = 1
	var/mob/observetarget = null
	var/ghost_hud_enabled = 1
	var/data_huds_on = 0
	var/health_scan = FALSE
	//var/list/datahuds = list(DATA_HUD_SECURITY_ADVANCED, DATA_HUD_MEDICAL_ADVANCED, DATA_HUD_DIAGNOSTIC_ADVANCED)
	var/ghost_orbit = GHOST_ORBIT_CIRCLE

	var/hair_style
	var/hair_color
	var/mutable_appearance/hair_overlay
	var/facial_hair_style
	var/facial_hair_color
	var/mutable_appearance/facial_hair_overlay

	var/updatedir = 1
	var/lastsetting = null

	var/ghost_accs = GHOST_ACCS_DEFAULT_OPTION
	var/ghost_others = GHOST_OTHERS_DEFAULT_OPTION
	var/deadchat_name
	//var/datum/spawners_menu/spawners_menu

/mob/dead/observer/Initialize()
	set_invisibility(GLOB.observer_default_invisibility)

	//verbs += list(
	//	/mob/dead/observer/proc/dead_tele,
	//	/mob/dead/observer/proc/open_spawners_menu,
	//	/mob/dead/observer/proc/view_gas,
	//	/mob/dead/observer/proc/tray_view)

	if(icon_state in GLOB.ghost_forms_with_directions_list)
		ghostimage_default = image(src.icon,src,src.icon_state + "_nodir")
	else
		ghostimage_default = image(src.icon,src,src.icon_state)
	//ghostimage_default.override = TRUE
	GLOB.ghost_images_default |= ghostimage_default

	ghostimage_simple = image(src.icon,src,"ghost_nodir")
	//ghostimage_simple.override = TRUE
	GLOB.ghost_images_simple |= ghostimage_simple

	//updateallghostimages()

	var/turf/T
	var/mob/body = loc
	if(ismob(body))
		T = get_turf(body)

		gender = body.gender
		if(body.mind && body.mind.name)
			name = body.mind.name
		else
			if(body.real_name)
				name = body.real_name
			else
				name = random_unique_name(gender)

		mind = body.mind

		set_suicide(body.suiciding)

		//if(ishuman(body))
		//	var/mob/living/carbon/human/body_human = body
		//	if(HAIR in body_human.dna.species.species_traits)
		//		hair_style = body_human.hair_style
		//		hair_color = brighten_color(body_human.hair_color)
		//	if(FACEHAIR in body_human.dna.species.species_traits)
		//		facial_hair_style = body_human.facial_hair_style
		//		facial_hair_color = brighten_color(body_human.facial_hair_color)

	update_icon()

	//if(!T)
	//	var/list/turfs = get_area_turfs(/area/shuttle/arrival)
	//	if(turfs.len)
	//		T = pick(turfs)
	//	else
	//		T = SSmapping.get_station_center()

	forceMove(T)

	if(!name)
		name = random_unique_name(gender)
	real_name = name

	//if(!fun_verbs)
	//	verbs -= /mob/dead/observer/verb/boo
	//	verbs -= /mob/dead/observer/verb/possess

	animate(src, pixel_y = 2, time = 10, loop = -1)

	//GLOB.dead_mob_list += src

	//for(var/v in GLOB.active_alternate_appearances)
	//	if(!v)
	//		continue
	//	var/datum/atom_hud/alternate_appearance/AA = v
	//	AA.onNewMob(src)

	. = ..()

	//grant_all_languages()

/mob/dead/observer/Destroy()
	GLOB.ghost_images_default -= ghostimage_default
	QDEL_NULL(ghostimage_default)

	GLOB.ghost_images_simple -= ghostimage_simple
	QDEL_NULL(ghostimage_simple)

	//updateallghostimages()

	//QDEL_NULL(spawners_menu)
	return ..()

/mob/dead/CanPass(atom/movable/mover, turf/target)
	return 1

/mob/dead/observer/proc/update_icon(new_form)
	//if(client)
	//	ghost_accs = client.prefs.ghost_accs
	//	ghost_others = client.prefs.ghost_others

	if(hair_overlay)
		cut_overlay(hair_overlay)
		hair_overlay = null

	if(facial_hair_overlay)
		cut_overlay(facial_hair_overlay)
		facial_hair_overlay = null


	if(new_form)
		icon_state = new_form
		if(icon_state in GLOB.ghost_forms_with_directions_list)
			ghostimage_default.icon_state = new_form + "_nodir"
		else
			ghostimage_default.icon_state = new_form

	if(ghost_accs >= GHOST_ACCS_DIR && icon_state in GLOB.ghost_forms_with_directions_list)
		updatedir = 1
	else
		updatedir = 0
		setDir(2 		)

	//if(ghost_accs == GHOST_ACCS_FULL && icon_state in GLOB.ghost_forms_with_accessories_list)
	//	var/datum/sprite_accessory/S
	//	if(facial_hair_style)
	//		S = GLOB.facial_hair_styles_list[facial_hair_style]
	//		if(S)
	//			facial_hair_overlay = mutable_appearance(S.icon, "[S.icon_state]", -HAIR_LAYER)
	//			if(facial_hair_color)
	//				facial_hair_overlay.color = "#" + facial_hair_color
	//			facial_hair_overlay.alpha = 200
	//			add_overlay(facial_hair_overlay)
	//	if(hair_style)
	//		S = GLOB.hair_styles_list[hair_style]
	//		if(S)
	//			hair_overlay = mutable_appearance(S.icon, "[S.icon_state]", -HAIR_LAYER)
	//			if(hair_color)
	//				hair_overlay.color = "#" + hair_color
	//			hair_overlay.alpha = 200
	//			add_overlay(hair_overlay)

/mob/dead/observer/canUseTopic(atom/movable/M, be_close=FALSE, no_dextery=FALSE, no_tk=FALSE)
	return IsAdminGhost(usr)

/mob/dead/observer/is_literate()
	return TRUE

/mob/dead/observer/examine(mob/user)
	..()
	if(!invisibility)
		to_chat(user, "It seems extremely obvious.")

/mob/dead/observer/proc/set_invisibility(value)
	invisibility = value
	if(!value)
		set_light(1, 2)
	else
		set_light(0, 0)

/mob/proc/ghostize(can_reenter_corpse = 1)
	if(key)
		if(!cmptext(copytext(key,1,2),"@"))
			stop_sound_channel(CHANNEL_HEARTBEAT)
			var/mob/dead/observer/ghost = new(src)
			SStgui.on_transfer(src, ghost)
			ghost.can_reenter_corpse = can_reenter_corpse
			ghost.key = key
			return ghost

/mob/dead/observer/Move(NewLoc, direct)
	if(updatedir)
		setDir(direct)
	var/oldloc = loc

	if(NewLoc)
		forceMove(NewLoc)
		//update_parallax_contents()
	else
		forceMove(get_turf(src))
		if((direct & NORTH) && y < world.maxy)
			y++
		else if((direct & SOUTH) && y > 1)
			y--
		if((direct & EAST) && x < world.maxx)
			x++
		else if((direct & WEST) && x > 1)
			x--

	Moved(oldloc, direct)

/mob/dead/observer/Process_Spacemove(movement_dir)
	return 1