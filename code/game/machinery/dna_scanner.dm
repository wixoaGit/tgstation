/obj/machinery/dna_scannernew
	name = "\improper DNA scanner"
	desc = "It scans DNA structures."
	icon = 'icons/obj/machines/cloning.dmi'
	icon_state = "scanner"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	active_power_usage = 300
	//occupant_typecache = list(/mob/living, /obj/item/bodypart/head, /obj/item/organ/brain)
	circuit = /obj/item/circuitboard/machine/clonescanner
	var/locked = FALSE
	var/damage_coeff
	var/scan_level
	var/precision_coeff
	var/message_cooldown
	var/breakout_time = 1200

/obj/machinery/dna_scannernew/RefreshParts()
	scan_level = 0
	damage_coeff = 0
	precision_coeff = 0
	for(var/obj/item/stock_parts/scanning_module/P in component_parts)
		scan_level += P.rating
	for(var/obj/item/stock_parts/manipulator/P in component_parts)
		precision_coeff = P.rating
	for(var/obj/item/stock_parts/micro_laser/P in component_parts)
		damage_coeff = P.rating

/obj/machinery/dna_scannernew/examine(mob/user)
	..()
	if(in_range(user, src) || isobserver(user))
		to_chat(user, "<span class='notice'>The status display reads: Radiation pulse accuracy increased by factor <b>[precision_coeff**2]</b>.<br>Radiation pulse damage decreased by factor <b>[damage_coeff**2]</b>.<span>")

/obj/machinery/dna_scannernew/update_icon()
	if(stat & (NOPOWER|BROKEN))
		icon_state = initial(icon_state)+ (state_open ? "_open" : "") + "_unpowered"
		return

	if((stat & MAINT) || panel_open)
		icon_state = initial(icon_state)+ (state_open ? "_open" : "") + "_maintenance"
		return
	
	if(occupant)
		icon_state = initial(icon_state)+ "_occupied"
		return

	icon_state = initial(icon_state)+ (state_open ? "_open" : "")

/obj/machinery/dna_scannernew/power_change()
	..()
	update_icon()

/obj/machinery/dna_scannernew/proc/toggle_open(mob/user)
	if(panel_open)
		to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")
		return

	if(state_open)
		close_machine()
		return

	else if(locked)
		to_chat(user, "<span class='notice'>The bolts are locked down, securing the door shut.</span>")
		return

	open_machine()

/obj/machinery/dna_scannernew/container_resist(mob/living/user)
	if(!locked)
		open_machine()
		return
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user.visible_message("<span class='notice'>You see [user] kicking against the door of [src]!</span>", \
		"<span class='notice'>You lean on the back of [src] and start pushing the door open... (this will take about [DisplayTimeText(breakout_time)].)</span>", \
		"<span class='italics'>You hear a metallic creaking from [src].</span>")
	if(do_after(user,(breakout_time), target = src))
		if(!user || user.stat != CONSCIOUS || user.loc != src || state_open || !locked)
			return
		locked = FALSE
		user.visible_message("<span class='warning'>[user] successfully broke out of [src]!</span>", \
			"<span class='notice'>You successfully break out of [src]!</span>")
		open_machine()

/obj/machinery/dna_scannernew/close_machine(mob/living/carbon/user)
	if(!state_open)
		return FALSE

	..(user)

	//if(iscarbon(occupant))
	//	var/obj/machinery/computer/scan_consolenew/console = locate_computer(/obj/machinery/computer/scan_consolenew)
	//	if(console)
	//		console.on_scanner_close()

	return TRUE

/obj/machinery/dna_scannernew/open_machine()
	if(state_open)
		return FALSE

	..()

	return TRUE

/obj/machinery/dna_scannernew/relaymove(mob/user as mob)
	if(user.stat || locked)
		if(message_cooldown <= world.time)
			message_cooldown = world.time + 50
			to_chat(user, "<span class='warning'>[src]'s door won't budge!</span>")
		return
	open_machine()

/obj/machinery/dna_scannernew/attackby(obj/item/I, mob/user, params)

	if(!occupant && default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		update_icon()
		return

	if(default_pry_open(I))
		return

	if(default_deconstruction_crowbar(I))
		return

	return ..()

/obj/machinery/dna_scannernew/interact(mob/user)
	toggle_open(user)