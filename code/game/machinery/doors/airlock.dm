#define AIRLOCK_CLOSED	1
#define AIRLOCK_CLOSING	2
#define AIRLOCK_OPEN	3
#define AIRLOCK_OPENING	4
#define AIRLOCK_DENY	5
#define AIRLOCK_EMAG	6

#define AIRLOCK_SECURITY_NONE			0
#define AIRLOCK_SECURITY_METAL			1
#define AIRLOCK_SECURITY_PLASTEEL_I_S	2
#define AIRLOCK_SECURITY_PLASTEEL_I		3
#define AIRLOCK_SECURITY_PLASTEEL_O_S	4
#define AIRLOCK_SECURITY_PLASTEEL_O		5
#define AIRLOCK_SECURITY_PLASTEEL		6

#define AIRLOCK_INTEGRITY_N			 300
#define AIRLOCK_INTEGRITY_MULTIPLIER 1.5
#define AIRLOCK_DAMAGE_DEFLECTION_N  21
#define AIRLOCK_DAMAGE_DEFLECTION_R  30

/obj/machinery/door/airlock
	name = "airlock"
	icon = 'icons/obj/doors/airlocks/station/public.dmi'
	icon_state = "closed"
	max_integrity = 300
	var/normal_integrity = AIRLOCK_INTEGRITY_N
	integrity_failure = 70
	damage_deflection = AIRLOCK_DAMAGE_DEFLECTION_N
	autoclose = TRUE
	secondsElectrified = MACHINE_NOT_ELECTRIFIED
	assemblytype = /obj/structure/door_assembly
	normalspeed = 1
	explosion_block = 1
	//hud_possible = list(DIAG_AIRLOCK_HUD)

	var/security_level = 0
	var/aiControlDisabled = 0
	var/secondsMainPowerLost = 0
	var/secondsBackupPowerLost = 0
	var/spawnPowerRestoreRunning = FALSE
	var/lights = TRUE
	var/obj/item/electronics/airlock/electronics
	var/shockCooldown = FALSE
	var/detonated = FALSE
	var/doorOpen = 'sound/machines/airlock.ogg'
	var/doorClose = 'sound/machines/airlockclose.ogg'
	var/doorDeni = 'sound/machines/deniedbeep.ogg'
	var/boltUp = 'sound/machines/boltsup.ogg'
	var/boltDown = 'sound/machines/boltsdown.ogg'
	var/previous_airlock = /obj/structure/door_assembly
	var/airlock_material
	var/overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
	var/note_overlay_file = 'icons/obj/doors/airlocks/station/overlays.dmi'

	var/cyclelinkeddir = 0
	var/obj/machinery/door/airlock/cyclelinkedairlock
	var/shuttledocked = 0
	var/delayed_close_requested = FALSE

	var/air_tight = FALSE
	var/prying_so_hard = FALSE

/obj/machinery/door/airlock/Initialize()
	. = ..()
	wires = new /datum/wires/airlock(src)
	//if(frequency)
	//	set_frequency(frequency)

	//if(closeOtherId != null)
	//	addtimer(CALLBACK(.proc/update_other_id), 5)
	if(glass)
		airlock_material = "glass"
	if(security_level > AIRLOCK_SECURITY_METAL)
		obj_integrity = normal_integrity * AIRLOCK_INTEGRITY_MULTIPLIER
		max_integrity = normal_integrity * AIRLOCK_INTEGRITY_MULTIPLIER
	else
		obj_integrity = normal_integrity
		max_integrity = normal_integrity
	if(damage_deflection == AIRLOCK_DAMAGE_DEFLECTION_N && security_level > AIRLOCK_SECURITY_METAL)
		damage_deflection = AIRLOCK_DAMAGE_DEFLECTION_R
	prepare_huds()
	//for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
	//	diag_hud.add_to_hud(src)
	//diag_hud_set_electrified()

	return INITIALIZE_HINT_LATELOAD

/obj/machinery/door/airlock/LateInitialize()
	. = ..()
	if (cyclelinkeddir)
		cyclelinkairlock()
	//if(abandoned)
	//	var/outcome = rand(1,100)
	//	switch(outcome)
	//		if(1 to 9)
	//			var/turf/here = get_turf(src)
	//			for(var/turf/closed/T in range(2, src))
	//				here.PlaceOnTop(T.type)
	//				qdel(src)
	//				return
	//			here.PlaceOnTop(/turf/closed/wall)
	//			qdel(src)
	//			return
	//		if(9 to 11)
	//			lights = FALSE
	//			locked = TRUE
	//		if(12 to 15)
	//			locked = TRUE
	//		if(16 to 23)
	//			welded = TRUE
	//		if(24 to 30)
	//			panel_open = TRUE
	update_icon()

/obj/machinery/door/airlock/ComponentInitialize()
	. = ..()
	//AddComponent(/datum/component/ntnet_interface)

/obj/machinery/door/airlock/proc/cyclelinkairlock()
	if (cyclelinkedairlock)
		cyclelinkedairlock.cyclelinkedairlock = null
		cyclelinkedairlock = null
	if (!cyclelinkeddir)
		return
	//var/limit = world.view
	var/limit = 15//not_actual
	var/turf/T = get_turf(src)
	var/obj/machinery/door/airlock/FoundDoor
	do
		T = get_step(T, cyclelinkeddir)
		FoundDoor = locate() in T
		if (FoundDoor && FoundDoor.cyclelinkeddir != get_dir(FoundDoor, src))
			FoundDoor = null
		limit--
	while(!FoundDoor && limit)
	if (!FoundDoor)
		log_world("### MAP WARNING, [src] at [AREACOORD(src)] failed to find a valid airlock to cyclelink with!")
		return
	FoundDoor.cyclelinkedairlock = src
	cyclelinkedairlock = FoundDoor

/obj/machinery/door/airlock/Destroy()
	QDEL_NULL(wires)
	//if(charge)
	//	qdel(charge)
	//	charge = null
	QDEL_NULL(electronics)
	if (cyclelinkedairlock)
		if (cyclelinkedairlock.cyclelinkedairlock == src)
			cyclelinkedairlock.cyclelinkedairlock = null
		cyclelinkedairlock = null
	//if(id_tag)
	//	for(var/obj/machinery/doorButtons/D in GLOB.machines)
	//		D.removeMe(src)
	//qdel(note)
	//for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
	//	diag_hud.remove_from_hud(src)
	return ..()

/obj/machinery/door/airlock/proc/bolt()
	if(locked)
		return
	locked = TRUE
	playsound(src,boltDown,30,0,3)
	audible_message("<span class='italics'>You hear a click from the bottom of the door.</span>", null,  1)
	update_icon()

/obj/machinery/door/airlock/proc/unbolt()
	if(!locked)
		return
	locked = FALSE
	playsound(src,boltUp,30,0,3)
	audible_message("<span class='italics'>You hear a click from the bottom of the door.</span>", null,  1)
	update_icon()

/obj/machinery/door/airlock/handle_atom_del(atom/A)
	//if(A == note)
	//	note = null
	//	update_icon()

/obj/machinery/door/airlock/bumpopen(mob/living/user)
	if(!issilicon(usr))
		if(isElectrified())
			//if(!justzap)
			if(FALSE)//not_actual
				//if(shock(user, 100))
				//	justzap = TRUE
				//	addtimer(VARSET_CALLBACK(src, justzap, FALSE) , 10)
				//	return
			else
				return
		//else if(user.hallucinating() && ishuman(user) && prob(1) && !operating)
		//	var/mob/living/carbon/human/H = user
		//	if(H.gloves)
		//		var/obj/item/clothing/gloves/G = H.gloves
		//		if(G.siemens_coefficient)
		//			new /datum/hallucination/shock(H)
		//			return
	if (cyclelinkedairlock)
		//if (!shuttledocked && !emergency && !cyclelinkedairlock.shuttledocked && !cyclelinkedairlock.emergency && allowed(user))
		if(allowed(user))//not_actual
			if(cyclelinkedairlock.operating)
				cyclelinkedairlock.delayed_close_requested = TRUE
			else
				addtimer(CALLBACK(cyclelinkedairlock, .proc/close), 2)
	..()

/obj/machinery/door/airlock/proc/isElectrified()
	if(secondsElectrified != MACHINE_NOT_ELECTRIFIED)
		return TRUE
	return FALSE

/obj/machinery/door/airlock/proc/regainMainPower()
	if(secondsMainPowerLost > 0)
		secondsMainPowerLost = 0
	update_icon()

/obj/machinery/door/airlock/proc/handlePowerRestore()
	var/cont = TRUE
	while (cont)
		sleep(10)
		if(QDELETED(src))
			return
		cont = FALSE
		if(secondsMainPowerLost>0)
			if(!wires.is_cut(WIRE_POWER1) && !wires.is_cut(WIRE_POWER2))
				secondsMainPowerLost -= 1
				updateDialog()
			cont = TRUE
		if(secondsBackupPowerLost>0)
			if(!wires.is_cut(WIRE_BACKUP1) && !wires.is_cut(WIRE_BACKUP2))
				secondsBackupPowerLost -= 1
				updateDialog()
			cont = TRUE
	spawnPowerRestoreRunning = FALSE
	updateDialog()
	update_icon()

/obj/machinery/door/airlock/proc/loseMainPower()
	if(secondsMainPowerLost <= 0)
		secondsMainPowerLost = 60
		if(secondsBackupPowerLost < 10)
			secondsBackupPowerLost = 10
	if(!spawnPowerRestoreRunning)
		spawnPowerRestoreRunning = TRUE
	INVOKE_ASYNC(src, .proc/handlePowerRestore)
	update_icon()

/obj/machinery/door/airlock/proc/loseBackupPower()
	if(secondsBackupPowerLost < 60)
		secondsBackupPowerLost = 60
	if(!spawnPowerRestoreRunning)
		spawnPowerRestoreRunning = TRUE
	INVOKE_ASYNC(src, .proc/handlePowerRestore)
	update_icon()

/obj/machinery/door/airlock/proc/regainBackupPower()
	if(secondsBackupPowerLost > 0)
		secondsBackupPowerLost = 0
	update_icon()

/obj/machinery/door/airlock/proc/shock(mob/user, prb)
	if(!hasPower())
		return FALSE
	if(shockCooldown > world.time)
		return FALSE
	if(!prob(prb))
		return FALSE
	do_sparks(5, TRUE, src)
	var/check_range = TRUE
	if(electrocute_mob(user, get_area(src), src, 1, check_range))
		shockCooldown = world.time + 10
		return TRUE
	else
		return FALSE

/obj/machinery/door/airlock/update_icon(state=0, override=0)
	if(operating && !override)
		return
	switch(state)
		if(0)
			if(density)
				state = AIRLOCK_CLOSED
			else
				state = AIRLOCK_OPEN
			icon_state = ""
		if(AIRLOCK_OPEN, AIRLOCK_CLOSED)
			icon_state = ""
			icon_state = ""
		if(AIRLOCK_DENY, AIRLOCK_OPENING, AIRLOCK_CLOSING, AIRLOCK_EMAG)
			icon_state = "nonexistenticonstate"
	set_airlock_overlays(state)

/obj/machinery/door/airlock/proc/set_airlock_overlays(state)
	var/mutable_appearance/frame_overlay
	var/mutable_appearance/filling_overlay
	var/mutable_appearance/lights_overlay
	var/mutable_appearance/panel_overlay
	var/mutable_appearance/weld_overlay
	var/mutable_appearance/damag_overlay
	var/mutable_appearance/sparks_overlay
	var/mutable_appearance/note_overlay

	switch(state)
		if(AIRLOCK_CLOSED)
			frame_overlay = get_airlock_overlay("closed", icon)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_closed", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_closed", icon)
			if(panel_open)
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_closed_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_closed", overlays_file)
			if(welded)
				weld_overlay = get_airlock_overlay("welded", overlays_file)
			if(obj_integrity <integrity_failure)
				damag_overlay = get_airlock_overlay("sparks_broken", overlays_file)
			else if(obj_integrity < (0.75 * max_integrity))
				damag_overlay = get_airlock_overlay("sparks_damaged", overlays_file)
			if(lights && hasPower())
				if(locked)
					lights_overlay = get_airlock_overlay("lights_bolts", overlays_file)
				else if(emergency)
					lights_overlay = get_airlock_overlay("lights_emergency", overlays_file)
			//if(note)
			//	note_overlay = get_airlock_overlay(notetype, note_overlay_file)
		
		if(AIRLOCK_DENY)
			if(!hasPower())
				return
			frame_overlay = get_airlock_overlay("closed", icon)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_closed", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_closed", icon)
			if(panel_open)
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_closed_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_closed", overlays_file)
			if(obj_integrity <integrity_failure)
				damag_overlay = get_airlock_overlay("sparks_broken", overlays_file)
			else if(obj_integrity < (0.75 * max_integrity))
				damag_overlay = get_airlock_overlay("sparks_damaged", overlays_file)
			if(welded)
				weld_overlay = get_airlock_overlay("welded", overlays_file)
			lights_overlay = get_airlock_overlay("lights_denied", overlays_file)
			//if(note)
			//	note_overlay = get_airlock_overlay(notetype, note_overlay_file)
		
		if(AIRLOCK_EMAG)
			frame_overlay = get_airlock_overlay("closed", icon)
			sparks_overlay = get_airlock_overlay("sparks", overlays_file)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_closed", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_closed", icon)
			if(panel_open)
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_closed_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_closed", overlays_file)
			if(obj_integrity <integrity_failure)
				damag_overlay = get_airlock_overlay("sparks_broken", overlays_file)
			else if(obj_integrity < (0.75 * max_integrity))
				damag_overlay = get_airlock_overlay("sparks_damaged", overlays_file)
			if(welded)
				weld_overlay = get_airlock_overlay("welded", overlays_file)
			//if(note)
			//	note_overlay = get_airlock_overlay(notetype, note_overlay_file)

		if(AIRLOCK_CLOSING)
			frame_overlay = get_airlock_overlay("closing", icon)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_closing", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_closing", icon)
			if(lights && hasPower())
				lights_overlay = get_airlock_overlay("lights_closing", overlays_file)
			if(panel_open)
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_closing_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_closing", overlays_file)
			//if(note)
			//	note_overlay = get_airlock_overlay("[notetype]_closing", note_overlay_file)

		if(AIRLOCK_OPEN)
			frame_overlay = get_airlock_overlay("open", icon)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_open", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_open", icon)
			if(panel_open)
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_open_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_open", overlays_file)
			if(obj_integrity < (0.75 * max_integrity))
				damag_overlay = get_airlock_overlay("sparks_open", overlays_file)
			//if(note)
			//	note_overlay = get_airlock_overlay("[notetype]_open", note_overlay_file)

		if(AIRLOCK_OPENING)
			frame_overlay = get_airlock_overlay("opening", icon)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_opening", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_opening", icon)
			if(lights && hasPower())
				lights_overlay = get_airlock_overlay("lights_opening", overlays_file)
			if(panel_open)
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_opening_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_opening", overlays_file)
			//if(note)
			//	note_overlay = get_airlock_overlay("[notetype]_opening", note_overlay_file)

	cut_overlays()
	add_overlay(frame_overlay)
	add_overlay(filling_overlay)
	add_overlay(lights_overlay)
	add_overlay(panel_overlay)
	add_overlay(weld_overlay)
	add_overlay(sparks_overlay)
	add_overlay(damag_overlay)
	add_overlay(note_overlay)
	check_unres()

/proc/get_airlock_overlay(icon_state, icon_file)
	//var/obj/machinery/door/airlock/A
	//pass(A)
	//var/list/airlock_overlays = A.airlock_overlays
	//var/iconkey = "[icon_state][icon_file]"
	//if((!(. = airlock_overlays[iconkey])))
	//	. = airlock_overlays[iconkey] = mutable_appearance(icon_file, icon_state)
	return mutable_appearance(icon_file, icon_state)//not_actual

/obj/machinery/door/airlock/proc/check_unres()
	//if(hasPower() && unres_sides)
	//	if(unres_sides & NORTH)
	//		var/image/I = image(icon='icons/obj/doors/airlocks/station/overlays.dmi', icon_state="unres_n")
	//		I.pixel_y = 32
	//		set_light(l_range = 2, l_power = 1)
	//		add_overlay(I)
	//	if(unres_sides & SOUTH)
	//		var/image/I = image(icon='icons/obj/doors/airlocks/station/overlays.dmi', icon_state="unres_s")
	//		I.pixel_y = -32
	//		set_light(l_range = 2, l_power = 1)
	//		add_overlay(I)
	//	if(unres_sides & EAST)
	//		var/image/I = image(icon='icons/obj/doors/airlocks/station/overlays.dmi', icon_state="unres_e")
	//		I.pixel_x = 32
	//		set_light(l_range = 2, l_power = 1)
	//		add_overlay(I)
	//	if(unres_sides & WEST)
	//		var/image/I = image(icon='icons/obj/doors/airlocks/station/overlays.dmi', icon_state="unres_w")
	//		I.pixel_x = -32
	//		set_light(l_range = 2, l_power = 1)
	//		add_overlay(I)
	//else
	//	set_light(0)

/obj/machinery/door/airlock/do_animate(animation)
	switch(animation)
		if("opening")
			update_icon(AIRLOCK_OPENING)
		if("closing")
			update_icon(AIRLOCK_CLOSING)
		if("deny")
			if(!stat)
				update_icon(AIRLOCK_DENY)
				playsound(src,doorDeni,50,0,3)
				sleep(6)
				update_icon(AIRLOCK_CLOSED)

/obj/machinery/door/airlock/examine(mob/user)
	..()
	if(obj_flags & EMAGGED)
		to_chat(user, "<span class='warning'>Its access panel is smoking slightly.</span>")
	//if(charge && !panel_open && in_range(user, src))
	//	to_chat(user, "<span class='warning'>The maintenance panel seems haphazardly fastened.</span>")
	//if(charge && panel_open)
	//	to_chat(user, "<span class='warning'>Something is wired up to the airlock's electronics!</span>")
	//if(note)
	//	if(!in_range(user, src))
	//		to_chat(user, "There's a [note.name] pinned to the front. You can't read it from here.")
	//	else
	//		to_chat(user, "There's a [note.name] pinned to the front...")
	//		note.examine(user)

	if(panel_open)
		switch(security_level)
			if(AIRLOCK_SECURITY_NONE)
				to_chat(user, "Its wires are exposed!")
			if(AIRLOCK_SECURITY_METAL)
				to_chat(user, "Its wires are hidden behind a welded metal cover.")
			if(AIRLOCK_SECURITY_PLASTEEL_I_S)
				to_chat(user, "There is some shredded plasteel inside.")
			if(AIRLOCK_SECURITY_PLASTEEL_I)
				to_chat(user, "Its wires are behind an inner layer of plasteel.")
			if(AIRLOCK_SECURITY_PLASTEEL_O_S)
				to_chat(user, "There is some shredded plasteel inside.")
			if(AIRLOCK_SECURITY_PLASTEEL_O)
				to_chat(user, "There is a welded plasteel cover hiding its wires.")
			if(AIRLOCK_SECURITY_PLASTEEL)
				to_chat(user, "There is a protective grille over its panel.")
	else if(security_level)
		if(security_level == AIRLOCK_SECURITY_METAL)
			to_chat(user, "It looks a bit stronger.")
		else
			to_chat(user, "It looks very robust.")

	if(issilicon(user) && (!stat & BROKEN))
		to_chat(user, "<span class='notice'>Shift-click [src] to [ density ? "open" : "close"] it.</span>")
		to_chat(user, "<span class='notice'>Ctrl-click [src] to [ locked ? "raise" : "drop"] its bolts.</span>")
		to_chat(user, "<span class='notice'>Alt-click [src] to [ secondsElectrified ? "un-electrify" : "permanently electrify"] it.</span>")
		to_chat(user, "<span class='notice'>Ctrl-Shift-click [src] to [ emergency ? "disable" : "enable"] emergency access.</span>")

/obj/machinery/door/airlock/attack_ai(mob/user)
	//if(!canAIControl(user))
	//	if(canAIHack())
	//		hack(user)
	//		return
	//	else
	//		to_chat(user, "<span class='warning'>Airlock AI control has been blocked with a firewall. Unable to hack.</span>")
	if(obj_flags & EMAGGED)
		to_chat(user, "<span class='warning'>Unable to interface: Airlock is unresponsive.</span>")
		return
	if(detonated)
		to_chat(user, "<span class='warning'>Unable to interface. Airlock control panel damaged.</span>")
		return

	ui_interact(user)

/obj/machinery/door/airlock/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/door/airlock/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	//if(!(issilicon(user) || IsAdminGhost(user)))
	//	if(isElectrified())
	//		if(shock(user, 100))
	//			return

	//if(ishuman(user) && prob(40) && density)
	//	var/mob/living/carbon/human/H = user
	//	if((H.has_trait(TRAIT_DUMB)) && Adjacent(user))
	//		playsound(src, 'sound/effects/bang.ogg', 25, TRUE)
	//		if(!istype(H.head, /obj/item/clothing/head/helmet))
	//			H.visible_message("<span class='danger'>[user] headbutts the airlock.</span>", \
	//								"<span class='userdanger'>You headbutt the airlock!</span>")
	//			H.Paralyze(100)
	//			H.apply_damage(10, BRUTE, BODY_ZONE_HEAD)
	//		else
	//			visible_message("<span class='danger'>[user] headbutts the airlock. Good thing [user.p_theyre()] wearing a helmet.</span>")

/obj/machinery/door/airlock/Topic(href, href_list, var/nowindow = 0)
	if(!nowindow)
		..()
	if(!usr.canUseTopic(src) && !IsAdminGhost(usr))
		return
	add_fingerprint(usr)

	if((in_range(src, usr) && isturf(loc)) && panel_open)
		usr.set_machine(src)

	add_fingerprint(usr)
	if(!nowindow)
		updateUsrDialog()
	else
		updateDialog()

/obj/machinery/door/airlock/attackby(obj/item/C, mob/user, params)
	//if(!issilicon(user) && !IsAdminGhost(user))
	//	if(isElectrified())
	//		if(shock(user, 75))
	//			return
	add_fingerprint(user)

	if(panel_open)
		switch(security_level)
			if(AIRLOCK_SECURITY_NONE)
				if(istype(C, /obj/item/stack/sheet/metal))
					var/obj/item/stack/sheet/metal/S = C
					if(S.get_amount() < 2)
						to_chat(user, "<span class='warning'>You need at least 2 metal sheets to reinforce [src].</span>")
						return
					to_chat(user, "<span class='notice'>You start reinforcing [src].</span>")
					if(do_after(user, 20, TRUE, src))
						if(!panel_open || !S.use(2))
							return
						user.visible_message("<span class='notice'>[user] reinforces \the [src] with metal.</span>",
											"<span class='notice'>You reinforce \the [src] with metal.</span>")
						security_level = AIRLOCK_SECURITY_METAL
						update_icon()
					return
				else if(istype(C, /obj/item/stack/sheet/plasteel))
					var/obj/item/stack/sheet/plasteel/S = C
					if(S.get_amount() < 2)
						to_chat(user, "<span class='warning'>You need at least 2 plasteel sheets to reinforce [src].</span>")
						return
					to_chat(user, "<span class='notice'>You start reinforcing [src].</span>")
					if(do_after(user, 20, TRUE, src))
						if(!panel_open || !S.use(2))
							return
						user.visible_message("<span class='notice'>[user] reinforces \the [src] with plasteel.</span>",
											"<span class='notice'>You reinforce \the [src] with plasteel.</span>")
						security_level = AIRLOCK_SECURITY_PLASTEEL
						modify_max_integrity(normal_integrity * AIRLOCK_INTEGRITY_MULTIPLIER)
						damage_deflection = AIRLOCK_DAMAGE_DEFLECTION_R
						update_icon()
					return
			if(AIRLOCK_SECURITY_METAL)
				if(C.tool_behaviour == TOOL_WELDER)
					if(!C.tool_start_check(user, amount=2))
						return
					to_chat(user, "<span class='notice'>You begin cutting the panel's shielding...</span>")
					if(C.use_tool(src, user, 40, volume=50, amount = 2))
						if(!panel_open)
							return
						user.visible_message("<span class='notice'>[user] cuts through \the [src]'s shielding.</span>",
										"<span class='notice'>You cut through \the [src]'s shielding.</span>",
										"<span class='italics'>You hear welding.</span>")
						security_level = AIRLOCK_SECURITY_NONE
						spawn_atom_to_turf(/obj/item/stack/sheet/metal, user.loc, 2)
						update_icon()
					return
			if(AIRLOCK_SECURITY_PLASTEEL_I_S)
				if(C.tool_behaviour == TOOL_CROWBAR)
					var/obj/item/crowbar/W = C
					to_chat(user, "<span class='notice'>You start removing the inner layer of shielding...</span>")
					if(W.use_tool(src, user, 40, volume=100))
						if(!panel_open)
							return
						if(security_level != AIRLOCK_SECURITY_PLASTEEL_I_S)
							return
						user.visible_message("<span class='notice'>[user] remove \the [src]'s shielding.</span>",
											"<span class='notice'>You remove \the [src]'s inner shielding.</span>")
						security_level = AIRLOCK_SECURITY_NONE
						modify_max_integrity(normal_integrity)
						damage_deflection = AIRLOCK_DAMAGE_DEFLECTION_N
						spawn_atom_to_turf(/obj/item/stack/sheet/plasteel, user.loc, 1)
						update_icon()
					return
			if(AIRLOCK_SECURITY_PLASTEEL_I)
				if(C.tool_behaviour == TOOL_WELDER)
					if(!C.tool_start_check(user, amount=2))
						return
					to_chat(user, "<span class='notice'>You begin cutting the inner layer of shielding...</span>")
					if(C.use_tool(src, user, 40, volume=50, amount=2))
						if(!panel_open)
							return
						user.visible_message("<span class='notice'>[user] cuts through \the [src]'s shielding.</span>",
										"<span class='notice'>You cut through \the [src]'s shielding.</span>",
										"<span class='italics'>You hear welding.</span>")
						security_level = AIRLOCK_SECURITY_PLASTEEL_I_S
					return
			if(AIRLOCK_SECURITY_PLASTEEL_O_S)
				if(C.tool_behaviour == TOOL_CROWBAR)
					to_chat(user, "<span class='notice'>You start removing outer layer of shielding...</span>")
					if(C.use_tool(src, user, 40, volume=100))
						if(!panel_open)
							return
						if(security_level != AIRLOCK_SECURITY_PLASTEEL_O_S)
							return
						user.visible_message("<span class='notice'>[user] remove \the [src]'s shielding.</span>",
											"<span class='notice'>You remove \the [src]'s shielding.</span>")
						security_level = AIRLOCK_SECURITY_PLASTEEL_I
						spawn_atom_to_turf(/obj/item/stack/sheet/plasteel, user.loc, 1)
					return
			if(AIRLOCK_SECURITY_PLASTEEL_O)
				if(C.tool_behaviour == TOOL_WELDER)
					if(!C.tool_start_check(user, amount=2))
						return
					to_chat(user, "<span class='notice'>You begin cutting the outer layer of shielding...</span>")
					if(C.use_tool(src, user, 40, volume=50, amount=2))
						if(!panel_open)
							return
						user.visible_message("<span class='notice'>[user] cuts through \the [src]'s shielding.</span>",
										"<span class='notice'>You cut through \the [src]'s shielding.</span>",
										"<span class='italics'>You hear welding.</span>")
						security_level = AIRLOCK_SECURITY_PLASTEEL_O_S
					return
			if(AIRLOCK_SECURITY_PLASTEEL)
				if(C.tool_behaviour == TOOL_WIRECUTTER)
					//if(hasPower() && shock(user, 60))
					//	return
					to_chat(user, "<span class='notice'>You start cutting through the outer grille.</span>")
					if(C.use_tool(src, user, 10, volume=100))
						if(!panel_open)
							return
						user.visible_message("<span class='notice'>[user] cut through \the [src]'s outer grille.</span>",
											"<span class='notice'>You cut through \the [src]'s outer grille.</span>")
						security_level = AIRLOCK_SECURITY_PLASTEEL_O
					return
	if(C.tool_behaviour == TOOL_SCREWDRIVER)
		if(panel_open && detonated)
			to_chat(user, "<span class='warning'>[src] has no maintenance panel!</span>")
			return
		panel_open = !panel_open
		to_chat(user, "<span class='notice'>You [panel_open ? "open":"close"] the maintenance panel of the airlock.</span>")
		C.play_tool_sound(src)
		update_icon()
	//else if((C.tool_behaviour == TOOL_WIRECUTTER) && note)
	//	user.visible_message("<span class='notice'>[user] cuts down [note] from [src].</span>", "<span class='notice'>You remove [note] from [src].</span>")
	//	C.play_tool_sound(src)
	//	note.forceMove(get_turf(user))
	//	note = null
	//	update_icon()
	else if(is_wire_tool(C) && panel_open)
		attempt_wire_interaction(user)
		return
	//else if(istype(C, /obj/item/pai_cable))
	//	var/obj/item/pai_cable/cable = C
	//	cable.plugin(src, user)
	//else if(istype(C, /obj/item/airlock_painter))
	//	change_paintjob(C, user)
	//else if(istype(C, /obj/item/doorCharge))
	//	if(!panel_open || security_level)
	//		to_chat(user, "<span class='warning'>The maintenance panel must be open to apply [C]!</span>")
	//		return
	//	if(obj_flags & EMAGGED)
	//		return
	//	if(charge && !detonated)
	//		to_chat(user, "<span class='warning'>There's already a charge hooked up to this door!</span>")
	//		return
	//	if(detonated)
	//		to_chat(user, "<span class='warning'>The maintenance panel is destroyed!</span>")
	//		return
	//	to_chat(user, "<span class='warning'>You apply [C]. Next time someone opens the door, it will explode.</span>")
	//	panel_open = FALSE
	//	update_icon()
	//	user.transferItemToLoc(C, src, TRUE)
	//	charge = C
	//else if(istype(C, /obj/item/paper) || istype(C, /obj/item/photo))
	//	if(note)
	//		to_chat(user, "<span class='warning'>There's already something pinned to this airlock! Use wirecutters to remove it.</span>")
	//		return
	//	if(!user.transferItemToLoc(C, src))
	//		to_chat(user, "<span class='warning'>For some reason, you can't attach [C]!</span>")
	//		return
	//	user.visible_message("<span class='notice'>[user] pins [C] to [src].</span>", "<span class='notice'>You pin [C] to [src].</span>")
	//	note = C
	//	update_icon()
	else
		return ..()

/obj/machinery/door/airlock/try_to_weld(obj/item/weldingtool/W, mob/user)
	if(!operating && density)
		if(user.a_intent != INTENT_HELP)
			if(!W.tool_start_check(user, amount=0))
				return
			user.visible_message("[user] is [welded ? "unwelding":"welding"] the airlock.", \
							"<span class='notice'>You begin [welded ? "unwelding":"welding"] the airlock...</span>", \
							"<span class='italics'>You hear welding.</span>")
			if(W.use_tool(src, user, 40, volume=50, extra_checks = CALLBACK(src, .proc/weld_checks, W, user)))
				welded = !welded
				user.visible_message("[user.name] has [welded? "welded shut":"unwelded"] [src].", \
									"<span class='notice'>You [welded ? "weld the airlock shut":"unweld the airlock"].</span>")
				update_icon()
		else
			if(obj_integrity < max_integrity)
				if(!W.tool_start_check(user, amount=0))
					return
				user.visible_message("[user] is welding the airlock.", \
								"<span class='notice'>You begin repairing the airlock...</span>", \
								"<span class='italics'>You hear welding.</span>")
				if(W.use_tool(src, user, 40, volume=50, extra_checks = CALLBACK(src, .proc/weld_checks, W, user)))
					obj_integrity = max_integrity
					stat &= ~BROKEN
					user.visible_message("[user.name] has repaired [src].", \
										"<span class='notice'>You finish repairing the airlock.</span>")
					update_icon()
			else
				to_chat(user, "<span class='notice'>The airlock doesn't need repairing.</span>")

/obj/machinery/door/airlock/proc/weld_checks(obj/item/weldingtool/W, mob/user)
	return !operating && density

/obj/machinery/door/airlock/try_to_crowbar(obj/item/I, mob/living/user)
	var/beingcrowbarred = null
	if(I.tool_behaviour == TOOL_CROWBAR )
		beingcrowbarred = 1
	else
		beingcrowbarred = 0
	//if(panel_open && charge)
	//	to_chat(user, "<span class='notice'>You carefully start removing [charge] from [src]...</span>")
	//	if(!I.use_tool(src, user, 150, volume=50))
	//		to_chat(user, "<span class='warning'>You slip and [charge] detonates!</span>")
	//		charge.ex_act(EXPLODE_DEVASTATE)
	//		user.Paralyze(60)
	//		return
	//	user.visible_message("<span class='notice'>[user] removes [charge] from [src].</span>", \
	//						 "<span class='notice'>You gently pry out [charge] from [src] and unhook its wires.</span>")
	//	charge.forceMove(get_turf(user))
	//	charge = null
	//	return
	if(!security_level && (beingcrowbarred && panel_open && ((obj_flags & EMAGGED) || (density && welded && !operating && !hasPower() && !locked))))
		user.visible_message("[user] removes the electronics from the airlock assembly.", \
							 "<span class='notice'>You start to remove electronics from the airlock assembly...</span>")
		if(I.use_tool(src, user, 40, volume=100))
			deconstruct(TRUE, user)
			return
	else if(hasPower())
		to_chat(user, "<span class='warning'>The airlock's motors resist your efforts to force it!</span>")
	else if(locked)
		to_chat(user, "<span class='warning'>The airlock's bolts prevent it from being forced!</span>")
	//else if( !welded && !operating)
	//	if(!beingcrowbarred)
	//		var/obj/item/twohanded/fireaxe/F = I
	//		if(F.wielded)
	//			INVOKE_ASYNC(src, (density ? .proc/open : .proc/close), 2)
	//		else
	//			to_chat(user, "<span class='warning'>You need to be wielding the fire axe to do that!</span>")
	//	else
	//		INVOKE_ASYNC(src, (density ? .proc/open : .proc/close), 2)

	if(istype(I, /obj/item/crowbar/power))
		//if(isElectrified())
		//	shock(user,100)
		//	return

		if(!density)
			return

		if(locked)
			to_chat(user, "<span class='warning'>The bolts are down, it won't budge!</span>")
			return

		if(welded)
			to_chat(user, "<span class='warning'>It's welded, it won't budge!</span>")
			return

		var/time_to_open = 5
		if(hasPower() && !prying_so_hard)
			time_to_open = 50
			playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)
			prying_so_hard = TRUE
			if(do_after(user, time_to_open, TRUE, src))
				open(2)
				if(density && !open(2))
					to_chat(user, "<span class='warning'>Despite your attempts, [src] refuses to open.</span>")
			prying_so_hard = FALSE

/obj/machinery/door/airlock/open(forced=0)
	if( operating || welded || locked )
		return FALSE
	//if(!forced)
	//	if(!hasPower() || wires.is_cut(WIRE_OPEN))
	//		return FALSE
	//if(charge && !detonated)
	//	panel_open = TRUE
	//	update_icon(AIRLOCK_OPENING)
	//	visible_message("<span class='warning'>[src]'s panel is blown off in a spray of deadly shrapnel!</span>")
	//	charge.forceMove(drop_location())
	//	charge.ex_act(EXPLODE_DEVASTATE)
	//	detonated = 1
	//	charge = null
	//	for(var/mob/living/carbon/human/H in orange(2,src))
	//		H.Unconscious(160)
	//		H.adjust_fire_stacks(20)
	//		H.IgniteMob()
	//		H.apply_damage(40, BRUTE, BODY_ZONE_CHEST)
	//	return
	if(forced < 2)
		if(obj_flags & EMAGGED)
			return FALSE
		use_power(50)
		playsound(src, doorOpen, 30, 1)
		//if(closeOther != null && istype(closeOther, /obj/machinery/door/airlock/) && !closeOther.density)
		//	closeOther.close()
	else
		playsound(src, 'sound/machines/airlockforced.ogg', 30, TRUE)

	if(autoclose)
		autoclose_in(normalspeed ? 150 : 15)

	if(!density)
		return TRUE
	operating = TRUE
	update_icon(AIRLOCK_OPENING, 1)
	sleep(1)
	set_opacity(0)
	update_freelook_sight()
	sleep(4)
	density = FALSE
	air_update_turf(1)
	sleep(1)
	layer = OPEN_DOOR_LAYER
	update_icon(AIRLOCK_OPEN, 1)
	operating = FALSE
	if(delayed_close_requested)
		delayed_close_requested = FALSE
		addtimer(CALLBACK(src, .proc/close), 1)
	return TRUE

/obj/machinery/door/airlock/close(forced=0)
	if(operating || welded || locked)
		return
	if(density)
		return TRUE
	//if(!forced)
	//	if(!hasPower() || wires.is_cut(WIRE_BOLTS))
	//		return
	if(safe)
		for(var/atom/movable/M in get_turf(src))
			if(M.density && M != src)
				autoclose_in(60)
				return

	if(forced < 2)
		if(obj_flags & EMAGGED)
			return
		use_power(50)
		playsound(src, doorClose, 30, TRUE)
	else
		playsound(src, 'sound/machines/airlockforced.ogg', 30, TRUE)

	var/obj/structure/window/killthis = (locate(/obj/structure/window) in get_turf(src))
	if(killthis)
		killthis.ex_act(EXPLODE_HEAVY)

	operating = TRUE
	update_icon(AIRLOCK_CLOSING, 1)
	layer = CLOSED_DOOR_LAYER
	if(air_tight)
		density = TRUE
		air_update_turf(1)
	sleep(1)
	if(!air_tight)
		density = TRUE
		air_update_turf(1)
	sleep(4)
	//if(!safe)
	//	crush()
	//if(visible && !glass)
	//	set_opacity(1)
	update_freelook_sight()
	sleep(1)
	update_icon(AIRLOCK_CLOSED, 1)
	operating = FALSE
	delayed_close_requested = FALSE
	//if(safe)
	//	CheckForMobs()
	return TRUE

/obj/machinery/door/airlock/emag_act(mob/user)
	if(!operating && density && hasPower() && !(obj_flags & EMAGGED))
		operating = TRUE
		update_icon(AIRLOCK_EMAG, 1)
		sleep(6)
		if(QDELETED(src))
			return
		operating = FALSE
		if(!open())
			update_icon(AIRLOCK_CLOSED, 1)
		obj_flags |= EMAGGED
		lights = FALSE
		locked = TRUE
		loseMainPower()
		loseBackupPower()

/obj/machinery/door/airlock/obj_break(damage_flag)
	if(!(flags_1 & BROKEN) && !(flags_1 & NODECONSTRUCT_1))
		stat |= BROKEN
		if(!panel_open)
			panel_open = TRUE
		//wires.cut_all()
		update_icon()

/obj/machinery/door/airlock/proc/set_electrified(seconds, mob/user)
	secondsElectrified = seconds
	//diag_hud_set_electrified()
	//if(secondsElectrified > MACHINE_NOT_ELECTRIFIED)
	//	INVOKE_ASYNC(src, .proc/electrified_loop)

	if(user)
		var/message
		switch(secondsElectrified)
			if(MACHINE_ELECTRIFIED_PERMANENT)
				message = "permanently shocked"
			if(MACHINE_NOT_ELECTRIFIED)
				message = "unshocked"
			else
				message = "temp shocked for [secondsElectrified] seconds"
		//LAZYADD(shockedby, text("\[[time_stamp()]\] [key_name(user)] - ([uppertext(message)])"))
		log_combat(user, src, message)
		add_hiddenprint(user)

/obj/machinery/door/airlock/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(obj_integrity < (0.75 * max_integrity))
		update_icon()

/obj/machinery/door/airlock/deconstruct(disassembled = TRUE, mob/user)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/obj/structure/door_assembly/A
		if(assemblytype)
			A = new assemblytype(loc)
		else
			A = new /obj/structure/door_assembly(loc)
		A.heat_proof_finished = heat_proof
		A.setAnchored(TRUE)
		A.glass = glass
		A.state = AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS
		A.created_name = name
		A.previous_assembly = previous_airlock
		A.update_name()
		A.update_icon()

		if(!disassembled)
			if(A)
				A.obj_integrity = A.max_integrity * 0.5
		else if(obj_flags & EMAGGED)
			if(user)
				to_chat(user, "<span class='warning'>You discard the damaged electronics.</span>")
		else
			if(user)
				to_chat(user, "<span class='notice'>You remove the airlock electronics.</span>")

			var/obj/item/electronics/airlock/ae
			if(!electronics)
				ae = new/obj/item/electronics/airlock(loc)
				gen_access()
				if(req_one_access.len)
					ae.one_access = 1
					ae.accesses = req_one_access
				else
					ae.accesses = req_access
			else
				ae = electronics
				electronics = null
				ae.forceMove(drop_location())
	qdel(src)

#undef AIRLOCK_CLOSED
#undef AIRLOCK_CLOSING
#undef AIRLOCK_OPEN
#undef AIRLOCK_OPENING
#undef AIRLOCK_DENY
#undef AIRLOCK_EMAG

#undef AIRLOCK_SECURITY_NONE
#undef AIRLOCK_SECURITY_METAL
#undef AIRLOCK_SECURITY_PLASTEEL_I_S
#undef AIRLOCK_SECURITY_PLASTEEL_I
#undef AIRLOCK_SECURITY_PLASTEEL_O_S
#undef AIRLOCK_SECURITY_PLASTEEL_O
#undef AIRLOCK_SECURITY_PLASTEEL

#undef AIRLOCK_INTEGRITY_N
#undef AIRLOCK_INTEGRITY_MULTIPLIER
#undef AIRLOCK_DAMAGE_DEFLECTION_N
#undef AIRLOCK_DAMAGE_DEFLECTION_R