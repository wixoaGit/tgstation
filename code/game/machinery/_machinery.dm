/obj/machinery
	name = "machinery"
	icon = 'icons/obj/stationobjs.dmi'
	desc = "Some kind of machine."
	verb_say = "beeps"
	verb_yell = "blares"
	pressure_resistance = 15
	max_integrity = 200
	layer = BELOW_OBJ_LAYER

	anchored = TRUE
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND | INTERACT_ATOM_UI_INTERACT
	
	var/stat = 0
	var/use_power = IDLE_POWER_USE
	var/idle_power_usage = 0
	var/active_power_usage = 0
	var/power_channel = EQUIP
	var/list/component_parts = null
	var/panel_open = FALSE
	var/state_open = FALSE
	var/critical_machine = FALSE
	var/atom/movable/occupant = null
	var/speed_process = FALSE
	var/obj/item/circuitboard/circuit
	var/damage_deflection = 0

	var/interaction_flags_machine = INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON | INTERACT_MACHINE_SET_MACHINE
	var/fair_market_price = 69
	var/market_verb = "Customer"
	var/payment_department = ACCOUNT_ENG

/obj/machinery/Initialize()
	if(!armor)
		armor = list("melee" = 25, "bullet" = 10, "laser" = 10, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 70)
	. = ..()
	GLOB.machines += src

	if(ispath(circuit, /obj/item/circuitboard))
		circuit = new circuit
		circuit.apply_default_parts(src)
	
	if(!speed_process)
		START_PROCESSING(SSmachines, src)
	else
		START_PROCESSING(SSfastprocess, src)
	power_change()
	//RegisterSignal(src, COMSIG_ENTER_AREA, .proc/power_change)
	
	//if (occupant_typecache)
	//	occupant_typecache = typecacheof(occupant_typecache)

/obj/machinery/Destroy()
	GLOB.machines.Remove(src)
	if(!speed_process)
		STOP_PROCESSING(SSmachines, src)
	else
		STOP_PROCESSING(SSfastprocess, src)
	dropContents()
	return ..()

/obj/machinery/process()
	return PROCESS_KILL

/obj/machinery/proc/process_atmos()
	return PROCESS_KILL

/obj/machinery/proc/open_machine(drop = TRUE)
	state_open = TRUE
	density = FALSE
	if(drop)
		dropContents()
	update_icon()
	updateUsrDialog()

/obj/machinery/proc/dropContents(list/subset = null)
	var/turf/T = get_turf(src)
	for(var/atom/movable/A in contents)
		if(subset && !(A in subset))
			continue
		A.forceMove(T)
		if(isliving(A))
			var/mob/living/L = A
			L.update_mobility()
	occupant = null

/obj/machinery/proc/close_machine(atom/movable/target = null)
	state_open = FALSE
	density = TRUE
	//if(!target)
	//	for(var/am in loc)
	//		if (!(occupant_typecache ? is_type_in_typecache(am, occupant_typecache) : isliving(am)))
	//			continue
	//		var/atom/movable/AM = am
	//		if(AM.has_buckled_mobs())
	//			continue
	//		if(isliving(AM))
	//			var/mob/living/L = am
	//			if(L.buckled || L.mob_size >= MOB_SIZE_LARGE)
	//				continue
	//		target = am

	//var/mob/living/mobtarget = target
	//if(target && !target.has_buckled_mobs() && (!isliving(target) || !mobtarget.buckled))
	//	occupant = target
	//	target.forceMove(src)
	updateUsrDialog()
	update_icon()

/obj/machinery/proc/auto_use_power()
	if(!powered(power_channel))
		return 0
	if(use_power == 1)
		use_power(idle_power_usage,power_channel)
	else if(use_power >= 2)
		use_power(active_power_usage,power_channel)
	return 1

/obj/machinery/proc/is_operational()
	return !(stat & (NOPOWER|BROKEN|MAINT))

/obj/machinery/can_interact(mob/user)
	var/silicon = issiliconoradminghost(user)
	if((stat & (NOPOWER|BROKEN)) && !(interaction_flags_machine & INTERACT_MACHINE_OFFLINE))
		return FALSE
	if(panel_open && !(interaction_flags_machine & INTERACT_MACHINE_OPEN))
		if(!silicon || !(interaction_flags_machine & INTERACT_MACHINE_OPEN_SILICON))
			return FALSE

	if(silicon)
		if(!(interaction_flags_machine & INTERACT_MACHINE_ALLOW_SILICON))
			return FALSE
	else
		if(interaction_flags_machine & INTERACT_MACHINE_REQUIRES_SILICON)
			return FALSE
		if(!Adjacent(user))
			var/mob/living/carbon/H = user
			//if(!(istype(H) && H.has_dna() && H.dna.check_mutation(TK)))
			if(TRUE)//not_actual
				return FALSE
	return TRUE

/obj/machinery/interact(mob/user, special_state)
	if(interaction_flags_machine & INTERACT_MACHINE_SET_MACHINE)
		user.set_machine(src)
	. = ..()

/obj/machinery/ui_act(action, params)
	add_fingerprint(usr)
	return ..()

/obj/machinery/Topic(href, href_list)
	..()
	if(!can_interact(usr))
		return 1
	if(!usr.canUseTopic(src))
		return 1
	add_fingerprint(usr)
	return 0

/obj/machinery/attack_paw(mob/living/user)
	if(user.a_intent != INTENT_HARM)
		return attack_hand(user)
	else
		user.changeNext_move(CLICK_CD_MELEE)
		user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
		user.visible_message("<span class='danger'>[user.name] smashes against \the [src.name] with its paws.</span>", null, null, COMBAT_MESSAGE_RANGE)
		take_damage(4, BRUTE, "melee", 1)

/obj/machinery/_try_interact(mob/user)
	//if((interaction_flags_machine & INTERACT_MACHINE_WIRES_IF_OPEN) && panel_open && (attempt_wire_interaction(user) == WIRE_INTERACTION_BLOCK))
	//	return TRUE
	return ..()

/obj/machinery/proc/RefreshParts()
	return

/obj/machinery/proc/default_pry_open(obj/item/I)
	. = !(state_open || panel_open || is_operational() || (flags_1 & NODECONSTRUCT_1)) && I.tool_behaviour == TOOL_CROWBAR
	if(.)
		I.play_tool_sound(src, 50)
		visible_message("<span class='notice'>[usr] pries open \the [src].</span>", "<span class='notice'>You pry open \the [src].</span>")
		open_machine()

/obj/machinery/proc/default_deconstruction_crowbar(obj/item/I, ignore_panel = 0)
	. = (panel_open || ignore_panel) && !(flags_1 & NODECONSTRUCT_1) && I.tool_behaviour == TOOL_CROWBAR
	if(.)
		I.play_tool_sound(src, 50)
		deconstruct(TRUE)

/obj/machinery/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		on_deconstruction()
		if(component_parts && component_parts.len)
			spawn_frame(disassembled)
			for(var/obj/item/I in component_parts)
				I.forceMove(loc)
	qdel(src)

/obj/machinery/proc/spawn_frame(disassembled)
	var/obj/structure/frame/machine/M = new /obj/structure/frame/machine(loc)
	. = M
	M.setAnchored(anchored)
	if(!disassembled)
		M.obj_integrity = M.max_integrity * 0.5
	transfer_fingerprints_to(M)
	M.state = 2
	M.icon_state = "box_1"

/obj/machinery/obj_break(damage_flag)
	if(!(flags_1 & NODECONSTRUCT_1))
		stat |= BROKEN

/obj/machinery/contents_explosion(severity, target)
	if(occupant)
		occupant.ex_act(severity, target)

/obj/machinery/handle_atom_del(atom/A)
	if(A == occupant)
		occupant = null
		update_icon()
		updateUsrDialog()

/obj/machinery/proc/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/I)
	if(!(flags_1 & NODECONSTRUCT_1) && I.tool_behaviour == TOOL_SCREWDRIVER)
		I.play_tool_sound(src, 50)
		if(!panel_open)
			panel_open = TRUE
			icon_state = icon_state_open
			to_chat(user, "<span class='notice'>You open the maintenance hatch of [src].</span>")
		else
			panel_open = FALSE
			icon_state = icon_state_closed
			to_chat(user, "<span class='notice'>You close the maintenance hatch of [src].</span>")
		return 1
	return 0

/obj/machinery/proc/default_change_direction_wrench(mob/user, obj/item/I)
	if(panel_open && I.tool_behaviour == TOOL_WRENCH)
		I.play_tool_sound(src, 50)
		setDir(turn(dir,-90))
		to_chat(user, "<span class='notice'>You rotate [src].</span>")
		return 1
	return 0

/obj/proc/can_be_unfasten_wrench(mob/user, silent)
	if(!(isfloorturf(loc) || istype(loc, /turf/open/indestructible)) && !anchored)
		to_chat(user, "<span class='warning'>[src] needs to be on the floor to be secured!</span>")
		return FAILED_UNFASTEN
	return SUCCESSFUL_UNFASTEN

/obj/proc/default_unfasten_wrench(mob/user, obj/item/I, time = 20)
	if(!(flags_1 & NODECONSTRUCT_1) && I.tool_behaviour == TOOL_WRENCH)
		var/can_be_unfasten = can_be_unfasten_wrench(user)
		if(!can_be_unfasten || can_be_unfasten == FAILED_UNFASTEN)
			return can_be_unfasten
		if(time)
			to_chat(user, "<span class='notice'>You begin [anchored ? "un" : ""]securing [src]...</span>")
		I.play_tool_sound(src, 50)
		var/prev_anchored = anchored
		if(I.use_tool(src, user, time, extra_checks = CALLBACK(src, .proc/unfasten_wrench_check, prev_anchored, user)))
			to_chat(user, "<span class='notice'>You [anchored ? "un" : ""]secure [src].</span>")
			setAnchored(!anchored)
			playsound(src, 'sound/items/deconstruct.ogg', 50, 1)
			return SUCCESSFUL_UNFASTEN
		return FAILED_UNFASTEN
	return CANT_UNFASTEN

/obj/proc/unfasten_wrench_check(prev_anchored, mob/user)
	if(anchored != prev_anchored)
		return FALSE
	if(can_be_unfasten_wrench(user, TRUE) != SUCCESSFUL_UNFASTEN)
		return FALSE
	return TRUE

/obj/machinery/proc/display_parts(mob/user)
	to_chat(user, "<span class='notice'>It contains the following parts:</span>")
	for(var/obj/item/C in component_parts)
		to_chat(user, "<span class='notice'>[icon2html(C, user)] \A [C].</span>")

/obj/machinery/examine(mob/user)
	..()
	if(stat & BROKEN)
		to_chat(user, "<span class='notice'>It looks broken and non-functional.</span>")
	if(!(resistance_flags & INDESTRUCTIBLE))
		if(resistance_flags & ON_FIRE)
			to_chat(user, "<span class='warning'>It's on fire!</span>")
		var/healthpercent = (obj_integrity/max_integrity) * 100
		switch(healthpercent)
			if(50 to 99)
				to_chat(user,  "It looks slightly damaged.")
			if(25 to 50)
				to_chat(user,  "It appears heavily damaged.")
			if(0 to 25)
				to_chat(user,  "<span class='warning'>It's falling apart!</span>")
	if(user.research_scanner && component_parts)
		display_parts(user)

/obj/machinery/proc/on_construction()
	return

/obj/machinery/proc/on_deconstruction()
	return

/obj/machinery/proc/can_be_overridden()
	. = 1

///obj/machinery/tesla_act(power, tesla_flags, shocked_objects)
//	..()
//	if(prob(85) && (tesla_flags & TESLA_MACHINE_EXPLOSIVE))
//		explosion(src, 1, 2, 4, flame_range = 2, adminlog = FALSE, smoke = FALSE)
//	if(tesla_flags & TESLA_OBJ_DAMAGE)
//		take_damage(power/2000, BURN, "energy")
//		if(prob(40))
//			emp_act(EMP_LIGHT)

/obj/machinery/Exited(atom/movable/AM, atom/newloc)
	. = ..()
	if (AM == occupant)
		occupant = null

/obj/machinery/proc/adjust_item_drop_location(atom/movable/AM)
	//var/md5 = md5(AM.name)
	//for (var/i in 1 to 32)
	//	. += hex2num(md5[i])
	//. = . % 9
	. = 0//not_actual
	AM.pixel_x = -8 + ((.%3)*8)
	AM.pixel_y = -8 + (round( . / 3)*8)