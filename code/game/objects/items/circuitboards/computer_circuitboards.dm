/obj/item/circuitboard/computer/cloning
	name = "Cloning (Computer Board)"
	build_path = /obj/machinery/computer/cloning

/obj/item/circuitboard/computer/arcade/battle
	name = "Arcade Battle (Computer Board)"
	build_path = /obj/machinery/computer/arcade/battle

/obj/item/circuitboard/computer/arcade/orion_trail
	name = "Orion Trail (Computer Board)"
	build_path = /obj/machinery/computer/arcade/orion_trail

/obj/item/circuitboard/computer/powermonitor
	name = "Power Monitor (Computer Board)"
	build_path = /obj/machinery/computer/monitor

/obj/item/circuitboard/computer/gulag_teleporter_console
	name = "Labor Camp teleporter console (Computer Board)"
	build_path = /obj/machinery/computer/gulag_teleporter_computer

/obj/item/circuitboard/computer/rdconsole/production
	name = "R&D Console Production Only (Computer Board)"
	build_path = /obj/machinery/computer/rdconsole/production

/obj/item/circuitboard/computer/rdconsole
	name = "R&D Console (Computer Board)"
	build_path = /obj/machinery/computer/rdconsole/core

/obj/item/circuitboard/computer/rdconsole/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		if(build_path == /obj/machinery/computer/rdconsole/core)
			name = "R&D Console - Robotics (Computer Board)"
			build_path = /obj/machinery/computer/rdconsole/robotics
			to_chat(user, "<span class='notice'>Access protocols successfully updated.</span>")
		else
			name = "R&D Console (Computer Board)"
			build_path = /obj/machinery/computer/rdconsole/core
			to_chat(user, "<span class='notice'>Defaulting access protocols.</span>")
	else
		return ..()

/obj/item/circuitboard/computer/cargo
	name = "Supply Console (Computer Board)"
	build_path = /obj/machinery/computer/cargo
	var/contraband = FALSE

/obj/item/circuitboard/computer/cargo/multitool_act(mob/living/user)
	if(!(obj_flags & EMAGGED))
		contraband = !contraband
		to_chat(user, "<span class='notice'>Receiver spectrum set to [contraband ? "Broad" : "Standard"].</span>")
	else
		to_chat(user, "<span class='notice'>The spectrum chip is unresponsive.</span>")

/obj/item/circuitboard/computer/cargo/emag_act(mob/living/user)
	if(!(obj_flags & EMAGGED))
		contraband = TRUE
		obj_flags |= EMAGGED
		to_chat(user, "<span class='notice'>You adjust [src]'s routing and receiver spectrum, unlocking special supplies and contraband.</span>")

/obj/item/circuitboard/computer/cargo/express
	name = "Express Supply Console (Computer Board)"
	build_path = /obj/machinery/computer/cargo/express

/obj/item/circuitboard/computer/cargo/express/multitool_act(mob/living/user)
	if (!(obj_flags & EMAGGED))
		to_chat(user, "<span class='notice'>Routing protocols are already set to: \"factory defaults\".</span>")
	else
		to_chat(user, "<span class='notice'>You reset the routing protocols to: \"factory defaults\".</span>")
		obj_flags &= ~EMAGGED

/obj/item/circuitboard/computer/cargo/express/emag_act(mob/living/user)
		to_chat(user, "<span class='notice'>You change the routing protocols, allowing the Drop Pod to land anywhere on the station.</span>")
		obj_flags |= EMAGGED

/obj/item/circuitboard/computer/cargo/request
	name = "Supply Request Console (Computer Board)"
	build_path = /obj/machinery/computer/cargo/request

/obj/item/circuitboard/computer/bounty
	name = "Nanotrasen Bounty Console (Computer Board)"
	build_path = /obj/machinery/computer/bounty

/obj/item/circuitboard/computer/operating
	name = "Operating Computer (Computer Board)"
	build_path = /obj/machinery/computer/operating

/obj/item/circuitboard/computer/mining_shuttle
	name = "Mining Shuttle (Computer Board)"
	build_path = /obj/machinery/computer/shuttle/mining

/obj/item/circuitboard/computer/syndicate_shuttle
	name = "Syndicate Shuttle (Computer Board)"
	build_path = /obj/machinery/computer/shuttle/syndicate
	var/challenge = FALSE
	var/moved = FALSE

/obj/item/circuitboard/computer/syndicate_shuttle/Initialize()
	. = ..()
	GLOB.syndicate_shuttle_boards += src

/obj/item/circuitboard/computer/syndicate_shuttle/Destroy()
	GLOB.syndicate_shuttle_boards -= src
	return ..()