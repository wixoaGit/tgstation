#define LIGHT_EMERGENCY_POWER_USE 0.2

#define LIGHT_OK 0
#define LIGHT_EMPTY 1
#define LIGHT_BROKEN 2
#define LIGHT_BURNED 3

/obj/item/wallframe/light_fixture
	name = "light fixture frame"
	desc = "Used for building lights."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-construct-item"
	result_path = /obj/structure/light_construct
	inverse = TRUE

/obj/item/wallframe/light_fixture/small
	name = "small light fixture frame"
	icon_state = "bulb-construct-item"
	result_path = /obj/structure/light_construct/small
	materials = list(MAT_METAL=MINERAL_MATERIAL_AMOUNT)

/obj/item/wallframe/light_fixture/try_build(turf/on_wall, user)
	if(!..())
		return
	var/area/A = get_area(user)
	if(!IS_DYNAMIC_LIGHTING(A))
		to_chat(user, "<span class='warning'>You cannot place [src] in this area!</span>")
		return
	return TRUE

/obj/structure/light_construct
	name = "light fixture frame"
	desc = "A light fixture under construction."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-construct-stage1"
	anchored = TRUE
	layer = WALL_OBJ_LAYER
	max_integrity = 200
	armor = list("melee" = 50, "bullet" = 10, "laser" = 10, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 50)

	var/stage = 1
	var/fixture_type = "tube"
	var/sheets_refunded = 2
	var/obj/machinery/light/newlight = null
	var/obj/item/stock_parts/cell/cell

	var/cell_connectors = TRUE

/obj/structure/light_construct/Initialize(mapload, ndir, building)
	. = ..()
	if(building)
		setDir(ndir)

/obj/structure/light_construct/Destroy()
	QDEL_NULL(cell)
	return ..()

/obj/machinery/light/proc/seton(s)
	on = (s && status == LIGHT_OK)
	update()

/obj/structure/light_construct/get_cell()
	return cell

/obj/structure/light_construct/examine(mob/user)
	..()
	switch(src.stage)
		if(1)
			to_chat(user, "It's an empty frame.")
		if(2)
			to_chat(user, "It's wired.")
		if(3)
			to_chat(user, "The casing is closed.")
	if(cell_connectors)
		if(cell)
			to_chat(user, "You see [cell] inside the casing.")
		else
			to_chat(user, "The casing has no power cell for backup power.")
	else
		to_chat(user, "<span class='danger'>This casing doesn't support power cells for backup power.</span>")
		return

/obj/structure/light_construct/attack_hand(mob/user)
	if(cell)
		user.visible_message("[user] removes [cell] from [src]!","<span class='notice'>You remove [cell].</span>")
		user.put_in_hands(cell)
		cell.update_icon()
		cell = null
		add_fingerprint(user)

///obj/structure/light_construct/attack_tk(mob/user)
//	if(cell)
//		to_chat(user, "<span class='notice'>You telekinetically remove [cell].</span>")
//		cell.forceMove(drop_location())
//		cell.attack_tk(user)
//		cell = null

/obj/structure/light_construct/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(istype(W, /obj/item/stock_parts/cell))
		if(!cell_connectors)
			to_chat(user, "<span class='warning'>This [name] can't support a power cell!</span>")
			return
		if(W.item_flags & NODROP)
			to_chat(user, "<span class='warning'>[W] is stuck to your hand!</span>")
			return
		if(cell)
			to_chat(user, "<span class='warning'>There is a power cell already installed!</span>")
		else if(user.temporarilyRemoveItemFromInventory(W))
			user.visible_message("<span class='notice'>[user] hooks up [W] to [src].</span>", \
			"<span class='notice'>You add [W] to [src].</span>")
			playsound(src, 'sound/machines/click.ogg', 50, TRUE)
			W.forceMove(src)
			cell = W
			add_fingerprint(user)
		return
	switch(stage)
		if(1)
			if(W.tool_behaviour == TOOL_WRENCH)
				if(cell)
					to_chat(user, "<span class='warning'>You have to remove the cell first!</span>")
					return
				else
					to_chat(user, "<span class='notice'>You begin deconstructing [src]...</span>")
					if (W.use_tool(src, user, 30, volume=50))
						new /obj/item/stack/sheet/metal(drop_location(), sheets_refunded)
						user.visible_message("[user.name] deconstructs [src].", \
							"<span class='notice'>You deconstruct [src].</span>", "<span class='italics'>You hear a ratchet.</span>")
						playsound(src, 'sound/items/deconstruct.ogg', 75, 1)
						qdel(src)
					return

			if(istype(W, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/coil = W
				if(coil.use(1))
					icon_state = "[fixture_type]-construct-stage2"
					stage = 2
					user.visible_message("[user.name] adds wires to [src].", \
						"<span class='notice'>You add wires to [src].</span>")
				else
					to_chat(user, "<span class='warning'>You need one length of cable to wire [src]!</span>")
				return
		if(2)
			if(W.tool_behaviour == TOOL_WRENCH)
				to_chat(usr, "<span class='warning'>You have to remove the wires first!</span>")
				return

			if(W.tool_behaviour == TOOL_WIRECUTTER)
				stage = 1
				icon_state = "[fixture_type]-construct-stage1"
				new /obj/item/stack/cable_coil(drop_location(), 1, "red")
				user.visible_message("[user.name] removes the wiring from [src].", \
					"<span class='notice'>You remove the wiring from [src].</span>", "<span class='italics'>You hear clicking.</span>")
				W.play_tool_sound(src, 100)
				return

			if(W.tool_behaviour == TOOL_SCREWDRIVER)
				user.visible_message("[user.name] closes [src]'s casing.", \
					"<span class='notice'>You close [src]'s casing.</span>", "<span class='italics'>You hear screwing.</span>")
				W.play_tool_sound(src, 75)
				switch(fixture_type)
					if("tube")
						newlight = new /obj/machinery/light/built(loc)
					if("bulb")
						newlight = new /obj/machinery/light/small/built(loc)
				newlight.setDir(dir)
				transfer_fingerprints_to(newlight)
				if(cell)
					newlight.cell = cell
					cell.forceMove(newlight)
					cell = null
				qdel(src)
				return
	return ..()

///obj/structure/light_construct/blob_act(obj/structure/blob/B)
//	if(B && B.loc == loc)
//		qdel(src)


/obj/structure/light_construct/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/metal(loc, sheets_refunded)
	qdel(src)

/obj/structure/light_construct/small
	name = "small light fixture frame"
	icon_state = "bulb-construct-stage1"
	fixture_type = "bulb"
	sheets_refunded = 1

/obj/machinery/light
	name = "light fixture"
	icon = 'icons/obj/lighting.dmi'
	var/overlayicon = 'icons/obj/lighting_overlay.dmi'
	var/base_state = "tube"
	icon_state = "tube"
	desc = "A lighting fixture."
	layer = WALL_OBJ_LAYER
	max_integrity = 100
	use_power = ACTIVE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 20
	power_channel = LIGHT
	var/on = FALSE
	var/on_gs = FALSE
	var/static_power_used = 0
	var/brightness = 8
	var/bulb_power = 1
	var/bulb_colour = "#FFFFFF"
	var/status = LIGHT_OK
	var/flickering = FALSE
	var/light_type = /obj/item/light/tube
	var/fitting = "tube"
	var/switchcount = 0

	var/rigged = FALSE

	var/obj/item/stock_parts/cell/cell
	var/start_with_cell = TRUE

	var/nightshift_enabled = FALSE
	var/nightshift_allowed = TRUE
	var/nightshift_brightness = 8
	var/nightshift_light_power = 0.45
	var/nightshift_light_color = "#FFDDCC"

	var/emergency_mode = FALSE
	var/no_emergency = FALSE
	var/bulb_emergency_brightness_mul = 0.25
	var/bulb_emergency_colour = "#FF3232"
	var/bulb_emergency_pow_mul = 0.75
	var/bulb_emergency_pow_min = 0.5

/obj/machinery/light/broken
	status = LIGHT_BROKEN
	icon_state = "tube-broken"

/obj/machinery/light/small
	icon_state = "bulb"
	base_state = "bulb"
	fitting = "bulb"
	brightness = 4
	desc = "A small lighting fixture."
	light_type = /obj/item/light/bulb

/obj/machinery/light/small/broken
	status = LIGHT_BROKEN
	icon_state = "bulb-broken"

/obj/machinery/light/Move()
	if(status != LIGHT_BROKEN)
		break_light_tube(1)
	return ..()

/obj/machinery/light/built
	icon_state = "tube-empty"
	start_with_cell = FALSE

/obj/machinery/light/built/Initialize()
	. = ..()
	status = LIGHT_EMPTY
	update(0)

/obj/machinery/light/small/built
	icon_state = "bulb-empty"

/obj/machinery/light/small/built/Initialize()
	. = ..()
	status = LIGHT_EMPTY
	update(0)

/obj/machinery/light/Initialize(mapload)
	. = ..()

	//if(!mapload)
	//	var/area/A = get_area(src)
	//	var/obj/machinery/power/apc/temp_apc = A.get_apc()
	//	nightshift_enabled = temp_apc?.nightshift_lights

	if(start_with_cell && !no_emergency)
		cell = new/obj/item/stock_parts/cell/emergency_light(src)
	//spawn(2)
	//	switch(fitting)
	//		if("tube")
	//			brightness = 8
	//			if(prob(2))
	//				break_light_tube(1)
	//		if("bulb")
	//			brightness = 4
	//			if(prob(5))
	//				break_light_tube(1)
	//	spawn(1)
	//		update(0)

/obj/machinery/light/Destroy()
	var/area/A = get_area(src)
	if(A)
		on = FALSE
	QDEL_NULL(cell)
	return ..()

/obj/machinery/light/update_icon()
	cut_overlays()
	switch(status)
		if(LIGHT_OK)
			var/area/A = get_area(src)
			//if(emergency_mode || (A && A.fire))
			if(FALSE)//not_actual
				icon_state = "[base_state]_emergency"
			else
				icon_state = "[base_state]"
				if(on)
					var/mutable_appearance/glowybit = mutable_appearance(overlayicon, base_state, ABOVE_LIGHTING_LAYER, ABOVE_LIGHTING_PLANE)
					//glowybit.alpha = CLAMP(light_power*250, 30, 200)
					add_overlay(glowybit)
		if(LIGHT_EMPTY)
			icon_state = "[base_state]-empty"
		if(LIGHT_BURNED)
			icon_state = "[base_state]-burned"
		if(LIGHT_BROKEN)
			icon_state = "[base_state]-broken"
	return

/obj/machinery/light/proc/update(trigger = TRUE)
	switch(status)
		if(LIGHT_BROKEN,LIGHT_BURNED,LIGHT_EMPTY)
			on = FALSE
	emergency_mode = FALSE
	if(on)
		var/BR = brightness
		var/PO = bulb_power
		var/CO = bulb_colour
		var/area/A = get_area(src)
		if (A && A.fire)
			CO = bulb_emergency_colour
		else if (nightshift_enabled)
			BR = nightshift_brightness
			PO = nightshift_light_power
			CO = nightshift_light_color
		var/matching = light && BR == light.light_range && PO == light.light_power && CO == light.light_color
		if(!matching)
			switchcount++
			if(rigged)
				if(status == LIGHT_OK && trigger)
					explode()
			else if( prob( min(60, (switchcount^2)*0.01) ) )
				if(trigger)
					burn_out()
			else
				use_power = ACTIVE_POWER_USE
				set_light(BR, PO, CO)
	else if(has_emergency_power(LIGHT_EMERGENCY_POWER_USE) && !turned_off())
		use_power = IDLE_POWER_USE
		emergency_mode = TRUE
		START_PROCESSING(SSmachines, src)
	else
		use_power = IDLE_POWER_USE
		set_light(0)
	update_icon()

	active_power_usage = (brightness * 10)
	if(on != on_gs)
		on_gs = on
		if(on)
			static_power_used = brightness * 20
			addStaticPower(static_power_used, STATIC_LIGHT)
		else
			removeStaticPower(static_power_used, STATIC_LIGHT)

	broken_sparks(start_only=TRUE)

/obj/machinery/light/proc/broken_sparks(start_only=FALSE)
	//if(status == LIGHT_BROKEN && has_power())
	//	if(!start_only)
	//		do_sparks(3, TRUE, src)
	//	var/delay = rand(BROKEN_SPARKS_MIN, BROKEN_SPARKS_MAX)
	//	addtimer(CALLBACK(src, .proc/broken_sparks), delay, TIMER_UNIQUE | TIMER_NO_HASH_WAIT)

/obj/machinery/light/process()
	if (!cell)
		return PROCESS_KILL
	if(has_power())
		if (cell.charge == cell.maxcharge)
			return PROCESS_KILL
		cell.charge = min(cell.maxcharge, cell.charge + LIGHT_EMERGENCY_POWER_USE)
	if(emergency_mode && !use_emergency_power(LIGHT_EMERGENCY_POWER_USE))
		update(FALSE)

/obj/machinery/light/proc/burn_out()
	if(status == LIGHT_OK)
		status = LIGHT_BURNED
		icon_state = "[base_state]-burned"
		on = FALSE
		set_light(0)

/obj/machinery/light/get_cell()
	return cell

/obj/machinery/light/examine(mob/user)
	..()
	switch(status)
		if(LIGHT_OK)
			to_chat(user, "It is turned [on? "on" : "off"].")
		if(LIGHT_EMPTY)
			to_chat(user, "The [fitting] has been removed.")
		if(LIGHT_BURNED)
			to_chat(user, "The [fitting] is burnt out.")
		if(LIGHT_BROKEN)
			to_chat(user, "The [fitting] has been smashed.")
	if(cell)
		to_chat(user, "Its backup power charge meter reads [round((cell.charge / cell.maxcharge) * 100, 0.1)]%.")

/obj/machinery/light/attackby(obj/item/W, mob/living/user, params)
	//if(istype(W, /obj/item/lightreplacer))
	if(FALSE)//not_actual
	//	var/obj/item/lightreplacer/LR = W
	//	LR.ReplaceLight(src, user)

	else if(istype(W, /obj/item/light))
		if(status == LIGHT_OK)
			to_chat(user, "<span class='warning'>There is a [fitting] already inserted!</span>")
		else
			src.add_fingerprint(user)
			var/obj/item/light/L = W
			if(istype(L, light_type))
				if(!user.temporarilyRemoveItemFromInventory(L))
					return

				src.add_fingerprint(user)
				if(status != LIGHT_EMPTY)
					drop_light_tube(user)
					to_chat(user, "<span class='notice'>You replace [L].</span>")
				else
					to_chat(user, "<span class='notice'>You insert [L].</span>")
				status = L.status
				switchcount = L.switchcount
				rigged = L.rigged
				brightness = L.brightness
				on = has_power()
				update()

				qdel(L)

				if(on && rigged)
					explode()
			else
				to_chat(user, "<span class='warning'>This type of light requires a [fitting]!</span>")
	else if(status == LIGHT_EMPTY)
		if(W.tool_behaviour == TOOL_SCREWDRIVER)
			W.play_tool_sound(src, 75)
			user.visible_message("[user.name] opens [src]'s casing.", \
				"<span class='notice'>You open [src]'s casing.</span>", "<span class='italics'>You hear a noise.</span>")
			deconstruct()
		else
			to_chat(user, "<span class='userdanger'>You stick \the [W] into the light socket!</span>")
			if(has_power() && (W.flags_1 & CONDUCT_1))
				do_sparks(3, TRUE, src)
				//if (prob(75))
				//	electrocute_mob(user, get_area(src), src, rand(0.7,1.0), TRUE)
	else
		return ..()

/obj/machinery/light/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/obj/structure/light_construct/newlight = null
		var/cur_stage = 2
		if(!disassembled)
			cur_stage = 1
		switch(fitting)
			if("tube")
				newlight = new /obj/structure/light_construct(src.loc)
				newlight.icon_state = "tube-construct-stage[cur_stage]"

			if("bulb")
				newlight = new /obj/structure/light_construct/small(src.loc)
				newlight.icon_state = "bulb-construct-stage[cur_stage]"
		newlight.setDir(src.dir)
		newlight.stage = cur_stage
		if(!disassembled)
			newlight.obj_integrity = newlight.max_integrity * 0.5
			if(status != LIGHT_BROKEN)
				break_light_tube()
			if(status != LIGHT_EMPTY)
				drop_light_tube()
			new /obj/item/stack/cable_coil(loc, 1, "red")
		transfer_fingerprints_to(newlight)
		if(cell)
			newlight.cell = cell
			cell.forceMove(newlight)
			cell = null
	qdel(src)

/obj/machinery/light/attacked_by(obj/item/I, mob/living/user)
	..()
	//if(status == LIGHT_BROKEN || status == LIGHT_EMPTY)
	//	if(on && (I.flags_1 & CONDUCT_1))
	//		if(prob(12))
	//			electrocute_mob(user, get_area(src), src, 0.3, TRUE)

/obj/machinery/light/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	. = ..()
	if(. && !QDELETED(src))
		if(prob(damage_amount * 5))
			break_light_tube()

/obj/machinery/light/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			switch(status)
				if(LIGHT_EMPTY)
					playsound(loc, 'sound/weapons/smash.ogg', 50, 1)
				if(LIGHT_BROKEN)
					playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 90, 1)
				else
					playsound(loc, 'sound/effects/glasshit.ogg', 90, 1)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, 1)

/obj/machinery/light/proc/turned_off()
	var/area/A = get_area(src)
	return !A.lightswitch && A.power_light || flickering

/obj/machinery/light/proc/has_power()
	var/area/A = get_area(src)
	return A.lightswitch && A.power_light

/obj/machinery/light/proc/has_emergency_power(pwr)
	if(no_emergency || !cell)
		return FALSE
	if(pwr ? cell.charge >= pwr : cell.charge)
		return status == LIGHT_OK

/obj/machinery/light/proc/use_emergency_power(pwr = LIGHT_EMERGENCY_POWER_USE)
	if(!has_emergency_power(pwr))
		return FALSE
	if(cell.charge > 300)
		visible_message("<span class='warning'>[src] short-circuits from too powerful of a power cell!</span>")
		burn_out()
		return FALSE
	cell.use(pwr)
	set_light(brightness * bulb_emergency_brightness_mul, max(bulb_emergency_pow_min, bulb_emergency_pow_mul * (cell.charge / cell.maxcharge)), bulb_emergency_colour)
	return TRUE

/obj/machinery/light/attack_hand(mob/living/carbon/human/user)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	add_fingerprint(user)

	if(status == LIGHT_EMPTY)
		to_chat(user, "There is no [fitting] in this light.")
		return

	if(on)
		var/prot = 0
		var/mob/living/carbon/human/H = user

		if(istype(H))
			//if(isethereal(H))
			//	to_chat(H, "<span class='notice'>You start channeling some power through the [fitting] into your body.</span>")
			//	if(do_after(user, 50, target = src))
			//		to_chat(H, "<span class='notice'>You receive some charge from the [fitting].</span>")
			//		return
			//	return

			if(H.gloves)
				var/obj/item/clothing/gloves/G = H.gloves
				if(G.max_heat_protection_temperature)
					prot = (G.max_heat_protection_temperature > 360)
		else
			prot = 1

		if(prot > 0 || user.has_trait(TRAIT_RESISTHEAT) || user.has_trait(TRAIT_RESISTHEATHANDS))
			to_chat(user, "<span class='notice'>You remove the light [fitting].</span>")
		//else if(istype(user) && user.dna.check_mutation(TK))
		//	to_chat(user, "<span class='notice'>You telekinetically remove the light [fitting].</span>")
		else
			to_chat(user, "<span class='warning'>You try to remove the light [fitting], but you burn your hand on it!</span>")

			var/obj/item/bodypart/affecting = H.get_bodypart("[(user.active_hand_index % 2 == 0) ? "r" : "l" ]_arm")
			if(affecting && affecting.receive_damage( 0, 5 ))
				H.update_damage_overlays()
			return
	else
		to_chat(user, "<span class='notice'>You remove the light [fitting].</span>")
	
	drop_light_tube(user)

/obj/machinery/light/proc/drop_light_tube(mob/user)
	var/obj/item/light/L = new light_type()
	L.status = status
	L.rigged = rigged
	L.brightness = brightness

	L.switchcount = switchcount
	switchcount = 0

	L.update()
	L.forceMove(loc)

	if(user)
		L.add_fingerprint(user)
		user.put_in_active_hand(L)

	status = LIGHT_EMPTY
	update()
	return L

/obj/machinery/light/proc/break_light_tube(skip_sound_and_sparks = 0)
	if(status == LIGHT_EMPTY || status == LIGHT_BROKEN)
		return

	if(!skip_sound_and_sparks)
		if(status == LIGHT_OK || status == LIGHT_BURNED)
			playsound(src.loc, 'sound/effects/glasshit.ogg', 75, 1)
		if(on)
			do_sparks(3, TRUE, src)
	status = LIGHT_BROKEN
	update()

/obj/machinery/light/power_change()
	var/area/A = get_area(src)
	seton(A.lightswitch && A.power_light)

/obj/machinery/light/proc/explode()
	set waitfor = 0
	var/turf/T = get_turf(src.loc)
	break_light_tube()
	sleep(2)
	explosion(T, 0, 0, 2, 2)
	sleep(1)
	qdel(src)

/obj/item/light
	icon = 'icons/obj/lighting.dmi'
	force = 2
	throwforce = 5
	w_class = WEIGHT_CLASS_TINY
	var/status = LIGHT_OK
	var/base_state
	var/switchcount = 0
	materials = list(MAT_GLASS=100)
	grind_results = list("silicon" = 5, "nitrogen" = 10)
	var/rigged = FALSE
	var/brightness = 2

/obj/item/light/suicide_act(mob/living/carbon/user)
	if (status == LIGHT_BROKEN)
		user.visible_message("<span class='suicide'>[user] begins to stab [user.p_them()]self with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
		return BRUTELOSS
	else
		user.visible_message("<span class='suicide'>[user] begins to eat \the [src]! It looks like [user.p_theyre()] not very bright!</span>")
		shatter()
		return BRUTELOSS

/obj/item/light/tube
	name = "light tube"
	desc = "A replacement light tube."
	icon_state = "ltube"
	base_state = "ltube"
	item_state = "c_tube"
	brightness = 8

/obj/item/light/tube/broken
	status = LIGHT_BROKEN

/obj/item/light/bulb
	name = "light bulb"
	desc = "A replacement light bulb."
	icon_state = "lbulb"
	base_state = "lbulb"
	item_state = "contvapour"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	brightness = 4

/obj/item/light/bulb/broken
	status = LIGHT_BROKEN

/obj/item/light/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!..())
		shatter()

/obj/item/light/proc/update()
	switch(status)
		if(LIGHT_OK)
			icon_state = base_state
			desc = "A replacement [name]."
		if(LIGHT_BURNED)
			icon_state = "[base_state]-burned"
			desc = "A burnt-out [name]."
		if(LIGHT_BROKEN)
			icon_state = "[base_state]-broken"
			desc = "A broken [name]."

/obj/item/light/Initialize()
	. = ..()
	update()

/obj/item/light/ComponentInitialize()
	. = ..()
	//AddComponent(/datum/component/caltrop, force)

/obj/item/light/Crossed(mob/living/L)
	. = ..()
	if(istype(L) && has_gravity(loc))
		if(L.has_trait(TRAIT_LIGHT_STEP))
			playsound(loc, 'sound/effects/glass_step.ogg', 30, 1)
		else
			playsound(loc, 'sound/effects/glass_step.ogg', 50, 1)
		if(status == LIGHT_BURNED || status == LIGHT_OK)
			shatter()

/obj/item/light/attackby(obj/item/I, mob/user, params)
	..()
	//if(istype(I, /obj/item/reagent_containers/syringe))
	if(FALSE)//not_actual
		//var/obj/item/reagent_containers/syringe/S = I

		//to_chat(user, "<span class='notice'>You inject the solution into \the [src].</span>")

		//if(S.reagents.has_reagent("plasma", 5))

		//	rigged = TRUE

		//S.reagents.clear_reagents()
	else
		..()
	return

/obj/item/light/attack(mob/living/M, mob/living/user, def_zone)
	..()
	shatter()

/obj/item/light/attack_obj(obj/O, mob/living/user)
	..()
	shatter()

/obj/item/light/proc/shatter()
	if(status == LIGHT_OK || status == LIGHT_BURNED)
		visible_message("<span class='danger'>[src] shatters.</span>","<span class='italics'>You hear a small glass object shatter.</span>")
		status = LIGHT_BROKEN
		force = 5
		playsound(src.loc, 'sound/effects/glasshit.ogg', 75, 1)
		//if(rigged)
		//	atmos_spawn_air("plasma=5")
		update()

/obj/machinery/light/floor
	name = "floor light"
	icon = 'icons/obj/lighting.dmi'
	base_state = "floor"
	icon_state = "floor"
	brightness = 4
	layer = 2.5
	light_type = /obj/item/light/bulb
	fitting = "bulb"