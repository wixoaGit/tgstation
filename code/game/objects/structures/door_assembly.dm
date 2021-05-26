/obj/structure/door_assembly
	name = "airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/public.dmi'
	icon_state = "construction"
	var/overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
	anchored = FALSE
	density = TRUE
	max_integrity = 200
	var/state = AIRLOCK_ASSEMBLY_NEEDS_WIRES
	var/base_name = "airlock"
	var/mineral = null
	var/obj/item/electronics/airlock/electronics = null
	var/airlock_type = /obj/machinery/door/airlock
	var/glass_type = /obj/machinery/door/airlock/glass
	var/glass = 0
	var/created_name = null
	var/heat_proof_finished = 0
	var/previous_assembly = /obj/structure/door_assembly
	var/noglass = FALSE
	var/material_type = /obj/item/stack/sheet/metal
	var/material_amt = 4

/obj/structure/door_assembly/Initialize()
	. = ..()
	update_icon()
	update_name()

/obj/structure/door_assembly/examine(mob/user)
	..()
	var/doorname = ""
	if(created_name)
		doorname = ", written on it is '[created_name]'"
	switch(state)
		if(AIRLOCK_ASSEMBLY_NEEDS_WIRES)
			if(anchored)
				to_chat(user, "<span class='notice'>The anchoring bolts are <b>wrenched</b> in place, but the maintenance panel lacks <i>wiring</i>.</span>")
			else
				to_chat(user, "<span class='notice'>The assembly is <b>welded together</b>, but the anchoring bolts are <i>unwrenched</i>.</span>")
		if(AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS)
			to_chat(user, "<span class='notice'>The maintenance panel is <b>wired</b>, but the circuit slot is <i>empty</i>.</span>")
		if(AIRLOCK_ASSEMBLY_NEEDS_SCREWDRIVER)
			to_chat(user, "<span class='notice'>The circuit is <b>connected loosely</b> to its slot, but the maintenance panel is <i>unscrewed and open</i>.</span>")
	if(!mineral && !glass && !noglass)
		to_chat(user, "<span class='notice'>There is a small <i>paper</i> placard on the assembly[doorname]. There are <i>empty</i> slots for glass windows and mineral covers.</span>")
	else if(!mineral && glass && !noglass)
		to_chat(user, "<span class='notice'>There is a small <i>paper</i> placard on the assembly[doorname]. There are <i>empty</i> slots for mineral covers.</span>")
	else if(mineral && !glass && !noglass)
		to_chat(user, "<span class='notice'>There is a small <i>paper</i> placard on the assembly[doorname]. There are <i>empty</i> slots for glass windows.</span>")
	else
		to_chat(user, "<span class='notice'>There is a small <i>paper</i> placard on the assembly[doorname].</span>")

/obj/structure/door_assembly/update_icon()
	cut_overlays()
	if(!glass)
		add_overlay(get_airlock_overlay("fill_construction", icon))
	else if(glass)
		add_overlay(get_airlock_overlay("glass_construction", overlays_file))
	add_overlay(get_airlock_overlay("panel_c[state+1]", overlays_file))

/obj/structure/door_assembly/proc/update_name()
	name = ""
	switch(state)
		if(AIRLOCK_ASSEMBLY_NEEDS_WIRES)
			if(anchored)
				name = "secured "
		if(AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS)
			name = "wired "
		if(AIRLOCK_ASSEMBLY_NEEDS_SCREWDRIVER)
			name = "near finished "
	name += "[heat_proof_finished ? "heat-proofed " : ""][glass ? "window " : ""][base_name] assembly"

/obj/structure/door_assembly/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/turf/T = get_turf(src)
		if(!disassembled)
			material_amt = rand(2,4)
		new material_type(T, material_amt)
		if(glass)
			if(disassembled)
				if(heat_proof_finished)
					new /obj/item/stack/sheet/rglass(T)
				else
					new /obj/item/stack/sheet/glass(T)
			else
				new /obj/item/shard(T)
		//if(mineral)
		//	var/obj/item/stack/sheet/mineral/mineral_path = text2path("/obj/item/stack/sheet/mineral/[mineral]")
		//	new mineral_path(T, 2)
	qdel(src)
