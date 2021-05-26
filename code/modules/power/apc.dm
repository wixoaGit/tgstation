#define UPSTATE_CELL_IN		(1<<0)
#define UPSTATE_OPENED1		(1<<1)
#define UPSTATE_OPENED2		(1<<2)
#define UPSTATE_MAINT		(1<<3)
#define UPSTATE_BROKE		(1<<4)
#define UPSTATE_BLUESCREEN	(1<<5)
#define UPSTATE_WIREEXP		(1<<6)
#define UPSTATE_ALLGOOD		(1<<7)

#define APC_RESET_EMP "emp"

#define APC_UPOVERLAY_CHARGEING0	(1<<0)
#define APC_UPOVERLAY_CHARGEING1	(1<<1)
#define APC_UPOVERLAY_CHARGEING2	(1<<2)
#define APC_UPOVERLAY_EQUIPMENT0	(1<<3)
#define APC_UPOVERLAY_EQUIPMENT1	(1<<4)
#define APC_UPOVERLAY_EQUIPMENT2	(1<<5)
#define APC_UPOVERLAY_LIGHTING0		(1<<6)
#define APC_UPOVERLAY_LIGHTING1		(1<<7)
#define APC_UPOVERLAY_LIGHTING2		(1<<8)
#define APC_UPOVERLAY_ENVIRON0		(1<<9)
#define APC_UPOVERLAY_ENVIRON1		(1<<10)
#define APC_UPOVERLAY_ENVIRON2		(1<<11)
#define APC_UPOVERLAY_LOCKED		(1<<12)
#define APC_UPOVERLAY_OPERATING		(1<<13)

#define APC_ELECTRONICS_MISSING 0
#define APC_ELECTRONICS_INSTALLED 1
#define APC_ELECTRONICS_SECURED 2

#define APC_COVER_CLOSED 0
#define APC_COVER_OPENED 1
#define APC_COVER_REMOVED 2

#define APC_NOT_CHARGING 0
#define APC_CHARGING 1
#define APC_FULLY_CHARGED 2

/obj/machinery/power/apc
	name = "area power controller"
	desc = "A control terminal for the area's electrical systems."
	
	icon_state = "apc0"
	use_power = NO_POWER_USE
	req_access = null
	max_integrity = 200
	integrity_failure = 50
	resistance_flags = FIRE_PROOF
	interaction_flags_machine = INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON
	
	var/lon_range = 1.5
	var/area/area
	var/areastring = null
	var/obj/item/stock_parts/cell/cell
	var/start_charge = 90
	var/cell_type = /obj/item/stock_parts/cell/upgraded
	var/opened = APC_COVER_CLOSED
	var/shorted = 0
	var/lighting = 3
	var/equipment = 3
	var/environ = 3
	var/operating = TRUE
	var/charging = APC_NOT_CHARGING
	var/chargemode = 1
	var/chargecount = 0
	var/locked = TRUE
	var/coverlocked = TRUE
	var/tdir = null
	var/obj/machinery/power/terminal/terminal = null
	var/lastused_light = 0
	var/lastused_equip = 0
	var/lastused_environ = 0
	var/lastused_total = 0
	var/main_status = 0
	var/malfhack = 0
	//var/mob/living/silicon/ai/malfai = null
	var/mob/living/silicon/malfai = null//not_actual
	var/has_electronics = APC_ELECTRONICS_MISSING
	//var/obj/item/clockwork/integration_cog/integration_cog
	var/obj/item/integration_cog //not_actual
	var/longtermpower = 10
	var/auto_name = FALSE
	var/failure_timer = 0
	var/force_update = 0
	var/emergency_lights = FALSE
	var/nightshift_lights = FALSE
	var/last_nightshift_switch = 0
	var/update_state = -1
	var/update_overlay = -1
	var/icon_update_needed = FALSE

/obj/machinery/power/apc/auto_name
	auto_name = TRUE

/obj/machinery/power/apc/auto_name/north
	dir = NORTH
	pixel_y = 23

/obj/machinery/power/apc/auto_name/south
	dir = SOUTH
	pixel_y = -23

/obj/machinery/power/apc/auto_name/east
	dir = EAST
	pixel_x = 24

/obj/machinery/power/apc/auto_name/west
	dir = WEST
	pixel_x = -25

/obj/machinery/power/apc/get_cell()
	return cell

/obj/machinery/power/apc/New(turf/loc, var/ndir, var/building=0)
	if (!req_access)
		req_access = list(ACCESS_ENGINE_EQUIP)
	if (!armor)
		armor = list("melee" = 20, "bullet" = 20, "laser" = 10, "energy" = 100, "bomb" = 30, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 50)
	..()
	GLOB.apcs_list += src

	//wires = new /datum/wires/apc(src)
	if (building)
		setDir(ndir)
	tdir = dir
	setDir(SOUTH)

	switch(tdir)
		if(NORTH)
			pixel_y = 23
		if(SOUTH)
			pixel_y = -23
		if(EAST)
			pixel_x = 24
		if(WEST)
			pixel_x = -25
	if (building)
		area = get_area(src)
		opened = APC_COVER_OPENED
		operating = FALSE
		name = "\improper [get_area_name(area, TRUE)] APC"
		stat |= MAINT
		update_icon()
		addtimer(CALLBACK(src, .proc/update), 5)

/obj/machinery/power/apc/Destroy()
	GLOB.apcs_list -= src

	//if(malfai && operating)
	//	malfai.malf_picker.processing_time = CLAMP(malfai.malf_picker.processing_time - 10,0,1000)
	area.power_light = FALSE
	area.power_equip = FALSE
	area.power_environ = FALSE
	area.power_change()
	//if(occupier)
	//	malfvacate(1)
	//qdel(wires)
	//wires = null
	if(cell)
		qdel(cell)
	if(terminal)
		disconnect_terminal()
	. = ..()

/obj/machinery/power/apc/handle_atom_del(atom/A)
	if(A == cell)
		cell = null
		update_icon()
		updateUsrDialog()

/obj/machinery/power/apc/proc/make_terminal()
	terminal = new/obj/machinery/power/terminal(loc)
	terminal.setDir(tdir)
	terminal.master = src

/obj/machinery/power/apc/Initialize(mapload)
	. = ..()
	if(!mapload)
		return
	has_electronics = APC_ELECTRONICS_SECURED
	if(cell_type)
		cell = new cell_type
		cell.charge = start_charge * cell.maxcharge / 100

	var/area/A = loc.loc

	if(areastring)
		area = get_area_instance_from_text(areastring)
		if(!area)
			area = A
			stack_trace("Bad areastring path for [src], [areastring]")
	else if(isarea(A) && areastring == null)
		area = A

	if(auto_name)
		name = "\improper [get_area_name(area, TRUE)] APC"

	update_icon()

	make_terminal()

	addtimer(CALLBACK(src, .proc/update), 5)

/obj/machinery/power/apc/examine(mob/user)
	..()
	if(stat & BROKEN)
		return
	if(opened)
		if(has_electronics && terminal)
			to_chat(user, "The cover is [opened==APC_COVER_REMOVED?"removed":"open"] and the power cell is [ cell ? "installed" : "missing"].")
		else
			to_chat(user, "It's [ !terminal ? "not" : "" ] wired up.")
			to_chat(user, "The electronics are[!has_electronics?"n't":""] installed.")
		if(user.Adjacent(src) && integration_cog)
			to_chat(user, "<span class='warning'>[src]'s innards have been replaced by strange brass machinery!</span>")

	else
		if (stat & MAINT)
			to_chat(user, "The cover is closed. Something is wrong with it. It doesn't work.")
		else if (malfhack)
			to_chat(user, "The cover is broken. It may be hard to force it open.")
		else
			to_chat(user, "The cover is closed.")

	if(integration_cog && is_servant_of_ratvar(user))
		to_chat(user, "<span class='brass'>There is an integration cog installed!</span>")

	to_chat(user, "<span class='notice'>Alt-Click the APC to [ locked ? "unlock" : "lock"] the interface.</span>")

	if(issilicon(user))
		to_chat(user, "<span class='notice'>Ctrl-Click the APC to switch the breaker [ operating ? "off" : "on"].</span>")

/obj/machinery/power/apc/update_icon()
	var/update = check_updates()
	if(!update)
		icon_update_needed = FALSE
		return

	if(update & 1)
		if(update_state & UPSTATE_ALLGOOD)
			icon_state = "apc0"
		else if(update_state & (UPSTATE_OPENED1|UPSTATE_OPENED2))
			var/basestate = "apc[ cell ? "2" : "1" ]"
			if(update_state & UPSTATE_OPENED1)
				if(update_state & (UPSTATE_MAINT|UPSTATE_BROKE))
					icon_state = "apcmaint"
				else
					icon_state = basestate
			else if(update_state & UPSTATE_OPENED2)
				if (update_state & UPSTATE_BROKE || malfhack)
					icon_state = "[basestate]-b-nocover"
				else
					icon_state = "[basestate]-nocover"
		else if(update_state & UPSTATE_BROKE)
			icon_state = "apc-b"
		else if(update_state & UPSTATE_BLUESCREEN)
			icon_state = "apcemag"
		else if(update_state & UPSTATE_WIREEXP)
			icon_state = "apcewires"
		else if(update_state & UPSTATE_MAINT)
			icon_state = "apc0"

	if(!(update_state & UPSTATE_ALLGOOD))
		//SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)
		cut_overlays()//not_actual

	if(update & 2)
		//SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)
		cut_overlays()//not_actual
		if(!(stat & (BROKEN|MAINT)) && update_state & UPSTATE_ALLGOOD)
			//SSvis_overlays.add_vis_overlay(src, icon, "apcox-[locked]", ABOVE_LIGHTING_LAYER, ABOVE_LIGHTING_PLANE, dir)
			add_overlay(mutable_appearance(icon, "apcox-[locked]", ABOVE_LIGHTING_LAYER, ABOVE_LIGHTING_PLANE))//not_actual
			//SSvis_overlays.add_vis_overlay(src, icon, "apco3-[charging]", ABOVE_LIGHTING_LAYER, ABOVE_LIGHTING_PLANE, dir)
			add_overlay(mutable_appearance(icon, "apco3-[charging]", ABOVE_LIGHTING_LAYER, ABOVE_LIGHTING_PLANE))//not_actual
			if(operating)
				//SSvis_overlays.add_vis_overlay(src, icon, "apco0-[equipment]", ABOVE_LIGHTING_LAYER, ABOVE_LIGHTING_PLANE, dir)
				add_overlay(mutable_appearance(icon, "apco0-[equipment]", ABOVE_LIGHTING_LAYER, ABOVE_LIGHTING_PLANE))//not_actual
				//SSvis_overlays.add_vis_overlay(src, icon, "apco1-[lighting]", ABOVE_LIGHTING_LAYER, ABOVE_LIGHTING_PLANE, dir)
				add_overlay(mutable_appearance(icon, "apco1-[lighting]", ABOVE_LIGHTING_LAYER, ABOVE_LIGHTING_PLANE))//not_actual
				//SSvis_overlays.add_vis_overlay(src, icon, "apco2-[environ]", ABOVE_LIGHTING_LAYER, ABOVE_LIGHTING_PLANE, dir)
				add_overlay(mutable_appearance(icon, "apco2-[environ]", ABOVE_LIGHTING_LAYER, ABOVE_LIGHTING_PLANE))//not_actual

	if(update_state & UPSTATE_ALLGOOD)
		switch(charging)
			if(APC_NOT_CHARGING)
				light_color = LIGHT_COLOR_RED
			if(APC_CHARGING)
				light_color = LIGHT_COLOR_BLUE
			if(APC_FULLY_CHARGED)
				light_color = LIGHT_COLOR_GREEN
		set_light(lon_range)
	else if(update_state & UPSTATE_BLUESCREEN)
		light_color = LIGHT_COLOR_BLUE
		set_light(lon_range)
	else
		set_light(0)

	icon_update_needed = FALSE

/obj/machinery/power/apc/proc/check_updates()
	var/last_update_state = update_state
	var/last_update_overlay = update_overlay
	update_state = 0
	update_overlay = 0

	if(cell)
		update_state |= UPSTATE_CELL_IN
	if(stat & BROKEN)
		update_state |= UPSTATE_BROKE
	if(stat & MAINT)
		update_state |= UPSTATE_MAINT
	if(opened)
		if(opened==APC_COVER_OPENED)
			update_state |= UPSTATE_OPENED1
		if(opened==APC_COVER_REMOVED)
			update_state |= UPSTATE_OPENED2
	else if((obj_flags & EMAGGED) || malfai)
		update_state |= UPSTATE_BLUESCREEN
	else if(panel_open)
		update_state |= UPSTATE_WIREEXP
	if(update_state <= 1)
		update_state |= UPSTATE_ALLGOOD

	if(operating)
		update_overlay |= APC_UPOVERLAY_OPERATING

	if(update_state & UPSTATE_ALLGOOD)
		if(locked)
			update_overlay |= APC_UPOVERLAY_LOCKED

		if(!charging)
			update_overlay |= APC_UPOVERLAY_CHARGEING0
		else if(charging == APC_CHARGING)
			update_overlay |= APC_UPOVERLAY_CHARGEING1
		else if(charging == APC_FULLY_CHARGED)
			update_overlay |= APC_UPOVERLAY_CHARGEING2

		if (!equipment)
			update_overlay |= APC_UPOVERLAY_EQUIPMENT0
		else if(equipment == 1)
			update_overlay |= APC_UPOVERLAY_EQUIPMENT1
		else if(equipment == 2)
			update_overlay |= APC_UPOVERLAY_EQUIPMENT2

		if(!lighting)
			update_overlay |= APC_UPOVERLAY_LIGHTING0
		else if(lighting == 1)
			update_overlay |= APC_UPOVERLAY_LIGHTING1
		else if(lighting == 2)
			update_overlay |= APC_UPOVERLAY_LIGHTING2

		if(!environ)
			update_overlay |= APC_UPOVERLAY_ENVIRON0
		else if(environ==1)
			update_overlay |= APC_UPOVERLAY_ENVIRON1
		else if(environ==2)
			update_overlay |= APC_UPOVERLAY_ENVIRON2


	var/results = 0
	if(last_update_state == update_state && last_update_overlay == update_overlay)
		return 0
	if(last_update_state != update_state)
		results += 1
	if(last_update_overlay != update_overlay)
		results += 2
	return results

/obj/machinery/power/apc/proc/queue_icon_update()
	icon_update_needed = TRUE

/obj/machinery/power/apc/crowbar_act(mob/user, obj/item/W)
	. = TRUE
	if (opened)
		if (has_electronics == APC_ELECTRONICS_INSTALLED)
			if (terminal)
				to_chat(user, "<span class='warning'>Disconnect the wires first!</span>")
				return
			W.play_tool_sound(src)
			to_chat(user, "<span class='notice'>You attempt to remove the power control board...</span>" )
			if(W.use_tool(src, user, 50))
				if (has_electronics == APC_ELECTRONICS_INSTALLED)
					has_electronics = APC_ELECTRONICS_MISSING
					if (stat & BROKEN)
						user.visible_message(\
							"[user.name] has broken the power control board inside [src.name]!",\
							"<span class='notice'>You break the charred power control board and remove the remains.</span>",
							"<span class='italics'>You hear a crack.</span>")
						return
					else if (obj_flags & EMAGGED)
						obj_flags &= ~EMAGGED
						user.visible_message(\
							"[user.name] has discarded an emagged power control board from [src.name]!",\
							"<span class='notice'>You discard the emagged power control board.</span>")
						return
					else if (malfhack)
						user.visible_message(\
							"[user.name] has discarded a strangely programmed power control board from [src.name]!",\
							"<span class='notice'>You discard the strangely programmed board.</span>")
						malfai = null
						malfhack = 0
						return
					else
						user.visible_message(\
							"[user.name] has removed the power control board from [src.name]!",\
							"<span class='notice'>You remove the power control board.</span>")
						new /obj/item/electronics/apc(loc)
						return
		else if(integration_cog)
			user.visible_message("<span class='notice'>[user] starts prying [integration_cog] from [src]...</span>", \
			"<span class='notice'>You painstakingly start tearing [integration_cog] out of [src]'s guts...</span>")
			W.play_tool_sound(src)
			if(W.use_tool(src, user, 100))
				user.visible_message("<span class='notice'>[user] destroys [integration_cog] in [src]!</span>", \
				"<span class='notice'>[integration_cog] comes free with a clank and snaps in two as the machinery returns to normal!</span>")
				playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
				QDEL_NULL(integration_cog)
			return
		else if (opened!=APC_COVER_REMOVED)
			opened = APC_COVER_CLOSED
			coverlocked = TRUE
			update_icon()
			return
	else if (!(stat & BROKEN))
		if(coverlocked && !(stat & MAINT))
			to_chat(user, "<span class='warning'>The cover is locked and cannot be opened!</span>")
			return
		else if (panel_open)
			to_chat(user, "<span class='warning'>Exposed wires prevents you from opening it!</span>")
			return
		else
			opened = APC_COVER_OPENED
			update_icon()
			return

/obj/machinery/power/apc/screwdriver_act(mob/living/user, obj/item/W)
	if(..())
		return TRUE
	. = TRUE
	if(opened)
		if(cell)
			user.visible_message("[user] removes \the [cell] from [src]!","<span class='notice'>You remove \the [cell].</span>")
			var/turf/T = get_turf(user)
			cell.forceMove(T)
			cell.update_icon()
			cell = null
			charging = APC_NOT_CHARGING
			update_icon()
			return
		else
			switch (has_electronics)
				if (APC_ELECTRONICS_INSTALLED)
					has_electronics = APC_ELECTRONICS_SECURED
					stat &= ~MAINT
					W.play_tool_sound(src)
					to_chat(user, "<span class='notice'>You screw the circuit electronics into place.</span>")
				if (APC_ELECTRONICS_SECURED)
					has_electronics = APC_ELECTRONICS_INSTALLED
					stat |= MAINT
					W.play_tool_sound(src)
					to_chat(user, "<span class='notice'>You unfasten the electronics.</span>")
				else
					to_chat(user, "<span class='warning'>There is nothing to secure!</span>")
					return
			update_icon()
	else if(obj_flags & EMAGGED)
		to_chat(user, "<span class='warning'>The interface is broken!</span>")
		return
	else
		panel_open = !panel_open
		to_chat(user, "The wires have been [panel_open ? "exposed" : "unexposed"]")
		update_icon()

/obj/machinery/power/apc/wirecutter_act(mob/living/user, obj/item/W)
	if (terminal && opened)
		terminal.dismantle(user, W)
		return TRUE

/obj/machinery/power/apc/welder_act(mob/living/user, obj/item/W)
	if (opened && !has_electronics && !terminal)
		if(!W.tool_start_check(user, amount=3))
			return
		user.visible_message("[user.name] welds [src].", \
							"<span class='notice'>You start welding the APC frame...</span>", \
							"<span class='italics'>You hear welding.</span>")
		if(W.use_tool(src, user, 50, volume=50, amount=3))
			if ((stat & BROKEN) || opened==APC_COVER_REMOVED)
				new /obj/item/stack/sheet/metal(loc)
				user.visible_message(\
					"[user.name] has cut [src] apart with [W].",\
					"<span class='notice'>You disassembled the broken APC frame.</span>")
			else
				new /obj/item/wallframe/apc(loc)
				user.visible_message(\
					"[user.name] has cut [src] from the wall with [W].",\
					"<span class='notice'>You cut the APC frame from the wall.</span>")
			qdel(src)
			return TRUE

/obj/machinery/power/apc/AltClick(mob/user)
	..()
	if(!user.canUseTopic(src, !issilicon(user)) || !isturf(loc))
		return
	else
		togglelock(user)

/obj/machinery/power/apc/proc/togglelock(mob/living/user)
	if(obj_flags & EMAGGED)
		to_chat(user, "<span class='warning'>The interface is broken!</span>")
	else if(opened)
		to_chat(user, "<span class='warning'>You must close the cover to swipe an ID card!</span>")
	else if(panel_open)
		to_chat(user, "<span class='warning'>You must close the panel!</span>")
	else if(stat & (BROKEN|MAINT))
		to_chat(user, "<span class='warning'>Nothing happens!</span>")
	else
		//if(allowed(usr) && !wires.is_cut(WIRE_IDSCAN) && !malfhack)
		if(allowed(usr) && !malfhack)//not_actual
			locked = !locked
			to_chat(user, "<span class='notice'>You [ locked ? "lock" : "unlock"] the APC interface.</span>")
			update_icon()
			updateUsrDialog()
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")

/obj/machinery/power/apc/proc/toggle_nightshift_lights(mob/living/user)
	if(last_nightshift_switch > world.time - 100)
		to_chat(usr, "<span class='warning'>[src]'s night lighting circuit breaker is still cycling!</span>")
		return
	last_nightshift_switch = world.time
	set_nightshift(!nightshift_lights)

/obj/machinery/power/apc/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(!(stat & BROKEN))
			set_broken()
		if(opened != APC_COVER_REMOVED)
			opened = APC_COVER_REMOVED
			coverlocked = FALSE
			visible_message("<span class='warning'>The APC cover is knocked down!</span>")
			update_icon()

/obj/machinery/power/apc/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(opened && (!issilicon(user)))
		if(cell)
			user.visible_message("[user] removes \the [cell] from [src]!","<span class='notice'>You remove \the [cell].</span>")
			user.put_in_hands(cell)
			cell.update_icon()
			src.cell = null
			charging = APC_NOT_CHARGING
			src.update_icon()
		return
	if((stat & MAINT) && !opened)
		return

/obj/machinery/power/apc/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
										datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)

	if(!ui)
		ui = new(user, src, ui_key, "apc", name, 535, 515, master_ui, state)
		ui.open()
	if(ui)
		ui.set_autoupdate(state = (failure_timer ? 1 : 0))

/obj/machinery/power/apc/ui_data(mob/user)
	var/list/data = list(
		"locked" = locked && !(integration_cog && is_servant_of_ratvar(user)),
		"failTime" = failure_timer,
		"isOperating" = operating,
		"externalPower" = main_status,
		"powerCellStatus" = cell ? cell.percent() : null,
		"chargeMode" = chargemode,
		"chargingStatus" = charging,
		"totalLoad" = DisplayPower(lastused_total),
		"coverLocked" = coverlocked,
		//"siliconUser" = user.has_unlimited_silicon_privilege || user.using_power_flow_console(),
		"siliconUser" = user.has_unlimited_silicon_privilege,//not_actual
		"malfStatus" = get_malf_status(user),
		"emergencyLights" = !emergency_lights,
		"nightshiftLights" = nightshift_lights,

		"powerChannels" = list(
			list(
				"title" = "Equipment",
				"powerLoad" = DisplayPower(lastused_equip),
				"status" = equipment,
				"topicParams" = list(
					"auto" = list("eqp" = 3),
					"on"   = list("eqp" = 2),
					"off"  = list("eqp" = 1)
				)
			),
			list(
				"title" = "Lighting",
				"powerLoad" = DisplayPower(lastused_light),
				"status" = lighting,
				"topicParams" = list(
					"auto" = list("lgt" = 3),
					"on"   = list("lgt" = 2),
					"off"  = list("lgt" = 1)
				)
			),
			list(
				"title" = "Environment",
				"powerLoad" = DisplayPower(lastused_environ),
				"status" = environ,
				"topicParams" = list(
					"auto" = list("env" = 3),
					"on"   = list("env" = 2),
					"off"  = list("env" = 1)
				)
			)
		)
	)
	return data

/obj/machinery/power/apc/proc/get_malf_status(mob/living/silicon/ai/malf)
	//if(istype(malf) && malf.malf_picker)
	//	if(malfai == (malf.parent || malf))
	//		if(occupier == malf)
	//			return 3
	//		else if(istype(malf.loc, /obj/machinery/power/apc))
	//			return 4
	//		else
	//			return 2
	//	else
	//		return 1
	//else
	//	return 0
	return 0//not_actual

/obj/machinery/power/apc/proc/update()
	if(operating && !shorted && !failure_timer)
		area.power_light = (lighting > 1)
		area.power_equip = (equipment > 1)
		area.power_environ = (environ > 1)
	else
		area.power_light = FALSE
		area.power_equip = FALSE
		area.power_environ = FALSE
	area.power_change()

/obj/machinery/power/apc/proc/can_use(mob/user, loud = 0)
	if(IsAdminGhost(user))
		return TRUE
	//if(user.has_unlimited_silicon_privilege)
	//	var/mob/living/silicon/ai/AI = user
	//	var/mob/living/silicon/robot/robot = user
	//	if (                                                             \
	//		src.aidisabled ||                                            \
	//		malfhack && istype(malfai) &&                                \
	//		(                                                            \
	//			(istype(AI) && (malfai!=AI && malfai != AI.parent)) ||   \
	//			(istype(robot) && (robot in malfai.connected_robots))    \
	//		)                                                            \
	//	)
	//		if(!loud)
	//			to_chat(user, "<span class='danger'>\The [src] has eee disabled!</span>")
	//		return FALSE
	return TRUE


/obj/machinery/power/apc/ui_act(action, params)
	if(..() || !can_use(usr, 1) || (locked && !usr.has_unlimited_silicon_privilege && !failure_timer && !(integration_cog && (is_servant_of_ratvar(usr)))))
		return
	switch(action)
		if("lock")
			if(usr.has_unlimited_silicon_privilege)
				if((obj_flags & EMAGGED) || (stat & (BROKEN|MAINT)))
					to_chat(usr, "The APC does not respond to the command.")
				else
					locked = !locked
					update_icon()
					. = TRUE
		if("cover")
			coverlocked = !coverlocked
			. = TRUE
		if("breaker")
			toggle_breaker(usr)
			. = TRUE
		if("toggle_nightshift")
			toggle_nightshift_lights()
			. = TRUE
		if("charge")
			chargemode = !chargemode
			if(!chargemode)
				charging = APC_NOT_CHARGING
				update_icon()
			. = TRUE
		if("channel")
			if(params["eqp"])
				equipment = setsubsystem(text2num(params["eqp"]))
				update_icon()
				update()
			else if(params["lgt"])
				lighting = setsubsystem(text2num(params["lgt"]))
				update_icon()
				update()
			else if(params["env"])
				environ = setsubsystem(text2num(params["env"]))
				update_icon()
				update()
			. = TRUE
		if("overload")
			if(usr.has_unlimited_silicon_privilege)
				overload_lighting()
				. = TRUE
		if("hack")
			//if(get_malf_status(usr))
			//	malfhack(usr)
		if("occupy")
			//if(get_malf_status(usr))
			//	malfoccupy(usr)
		if("deoccupy")
			//if(get_malf_status(usr))
			//	malfvacate()
		if("reboot")
			failure_timer = 0
			update_icon()
			update()
		if("emergency_lighting")
			emergency_lights = !emergency_lights
			//for(var/obj/machinery/light/L in area)
			//	if(!initial(L.no_emergency))
			//		L.no_emergency = emergency_lights
			//		INVOKE_ASYNC(L, /obj/machinery/light/.proc/update, FALSE)
			//	CHECK_TICK
	return 1

/obj/machinery/power/apc/proc/toggle_breaker(mob/user)
	if(!is_operational() || failure_timer)
		return
	operating = !operating
	add_hiddenprint(user)
	log_combat(user, src, "turned [operating ? "on" : "off"]")
	update()
	update_icon()

/obj/machinery/power/apc/surplus()
	if(terminal)
		return terminal.surplus()
	else
		return 0

/obj/machinery/power/apc/add_load(amount)
	if(terminal && terminal.powernet)
		terminal.add_load(amount)

/obj/machinery/power/apc/avail()
	if(terminal)
		return terminal.avail()
	else
		return 0

/obj/machinery/power/apc/process()
	if(icon_update_needed)
		update_icon()
	if(stat & (BROKEN|MAINT))
		return
	if(!area.requires_power)
		return
	if(failure_timer)
		update()
		queue_icon_update()
		failure_timer--
		force_update = 1
		return

	lastused_light = area.usage(STATIC_LIGHT)
	lastused_light += area.usage(LIGHT)
	lastused_equip = area.usage(EQUIP)
	lastused_equip += area.usage(STATIC_EQUIP)
	lastused_environ = area.usage(ENVIRON)
	lastused_environ += area.usage(STATIC_ENVIRON)
	area.clear_usage()

	lastused_total = lastused_light + lastused_equip + lastused_environ

	var/last_lt = lighting
	var/last_eq = equipment
	var/last_en = environ
	var/last_ch = charging

	var/excess = surplus()

	if(!src.avail())
		main_status = 0
	else if(excess < 0)
		main_status = 1
	else
		main_status = 2

	if(cell && !shorted)
		var/cellused = min(cell.charge, GLOB.CELLRATE * lastused_total)
		cell.use(cellused)

		if(excess > lastused_total)
			cell.give(cellused)
			add_load(cellused/GLOB.CELLRATE)


		else
			if((cell.charge/GLOB.CELLRATE + excess) >= lastused_total)
				cell.charge = min(cell.maxcharge, cell.charge + GLOB.CELLRATE * excess)
				add_load(excess)
				charging = APC_NOT_CHARGING

			else
				charging = APC_NOT_CHARGING
				chargecount = 0
				equipment = autoset(equipment, 0)
				lighting = autoset(lighting, 0)
				environ = autoset(environ, 0)

		if(charging && longtermpower < 10)
			longtermpower += 1
		else if(longtermpower > -10)
			longtermpower -= 2

		if(cell.charge <= 0)
			equipment = autoset(equipment, 0)
			lighting = autoset(lighting, 0)
			environ = autoset(environ, 0)
			area.poweralert(0, src)
		else if(cell.percent() < 15 && longtermpower < 0)
			equipment = autoset(equipment, 2)
			lighting = autoset(lighting, 2)
			environ = autoset(environ, 1)
			area.poweralert(0, src)
		else if(cell.percent() < 30 && longtermpower < 0)
			equipment = autoset(equipment, 2)
			lighting = autoset(lighting, 1)
			environ = autoset(environ, 1)
			area.poweralert(0, src)
		else
			equipment = autoset(equipment, 1)
			lighting = autoset(lighting, 1)
			environ = autoset(environ, 1)
			area.poweralert(1, src)
			if(cell.percent() > 75)
				area.poweralert(1, src)

		if(chargemode && charging == APC_CHARGING && operating)
			if(excess > 0)
				var/ch = min(excess*GLOB.CELLRATE, cell.maxcharge*GLOB.CHARGELEVEL)
				add_load(ch/GLOB.CELLRATE)
				cell.give(ch)

			else
				charging = APC_NOT_CHARGING
				chargecount = 0

		if(cell.charge >= cell.maxcharge)
			cell.charge = cell.maxcharge
			charging = APC_FULLY_CHARGED

		if(chargemode)
			if(!charging)
				if(excess > cell.maxcharge*GLOB.CHARGELEVEL)
					chargecount++
				else
					chargecount = 0

				if(chargecount == 10)

					chargecount = 0
					charging = APC_CHARGING

		else
			charging = 0
			chargecount = 0

	else

		charging = APC_NOT_CHARGING
		chargecount = 0
		equipment = autoset(equipment, 0)
		lighting = autoset(lighting, 0)
		environ = autoset(environ, 0)
		area.poweralert(0, src)

	if(last_lt != lighting || last_eq != equipment || last_en != environ || force_update)
		force_update = 0
		queue_icon_update()
		update()
	else if (last_ch != charging)
		queue_icon_update()

/obj/machinery/power/apc/proc/autoset(val, on)
	if(on==0)
		if(val==2)
			return 0
		else if(val==3)
			return 1
	else if(on==1)
		if(val==1)
			return 3
	else if(on==2)
		if(val==3)
			return 1
	return val

/obj/machinery/power/apc/proc/set_broken()
	//if(malfai && operating)
	//	malfai.malf_picker.processing_time = CLAMP(malfai.malf_picker.processing_time - 10,0,1000)
	stat |= BROKEN
	operating = FALSE
	//if(occupier)
	//	malfvacate(1)
	update_icon()
	update()

/obj/machinery/power/apc/proc/overload_lighting()
	if(!operating || shorted)
		return
	if( cell && cell.charge>=20)
		cell.use(20)
		//INVOKE_ASYNC(src, .proc/break_lights)

/obj/machinery/power/apc/proc/setsubsystem(val)
	if(cell && cell.charge > 0)
		return (val==1) ? 0 : val
	else if(val == 3)
		return 1
	else
		return 0

/obj/machinery/power/apc/proc/set_nightshift(on)
	set waitfor = FALSE
	nightshift_lights = on
	//for(var/obj/machinery/light/L in area)
	//	if(L.nightshift_allowed)
	//		L.nightshift_enabled = nightshift_lights
	//		L.update(FALSE)
	//	CHECK_TICK

#undef UPSTATE_CELL_IN
#undef UPSTATE_OPENED1
#undef UPSTATE_OPENED2
#undef UPSTATE_MAINT
#undef UPSTATE_BROKE
#undef UPSTATE_BLUESCREEN
#undef UPSTATE_WIREEXP
#undef UPSTATE_ALLGOOD

#undef APC_RESET_EMP

#undef APC_ELECTRONICS_MISSING
#undef APC_ELECTRONICS_INSTALLED
#undef APC_ELECTRONICS_SECURED

#undef APC_COVER_CLOSED
#undef APC_COVER_OPENED
#undef APC_COVER_REMOVED

#undef APC_NOT_CHARGING
#undef APC_CHARGING
#undef APC_FULLY_CHARGED

#undef APC_UPOVERLAY_CHARGEING0
#undef APC_UPOVERLAY_CHARGEING1
#undef APC_UPOVERLAY_CHARGEING2
#undef APC_UPOVERLAY_EQUIPMENT0
#undef APC_UPOVERLAY_EQUIPMENT1
#undef APC_UPOVERLAY_EQUIPMENT2
#undef APC_UPOVERLAY_LIGHTING0
#undef APC_UPOVERLAY_LIGHTING1
#undef APC_UPOVERLAY_LIGHTING2
#undef APC_UPOVERLAY_ENVIRON0
#undef APC_UPOVERLAY_ENVIRON1
#undef APC_UPOVERLAY_ENVIRON2
#undef APC_UPOVERLAY_LOCKED
#undef APC_UPOVERLAY_OPERATING

/obj/item/electronics/apc
	name = "power control module"
	icon_state = "power_mod"
	custom_price = 5
	desc = "Heavy-duty switching circuits for power control."