/obj/effect/spawner/lootdrop
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "random_loot"
	layer = OBJ_LAYER
	var/lootcount = 1
	var/lootdoubles = TRUE
	var/list/loot
	var/fan_out_items = FALSE

/obj/effect/spawner/lootdrop/Initialize(mapload)
	..()
	if(loot && loot.len)
		var/turf/T = get_turf(src)
		var/loot_spawned = 0
		while((lootcount-loot_spawned) && loot.len)
			var/lootspawn = pickweight(loot)
			if(!lootdoubles)
				loot.Remove(lootspawn)

			if(lootspawn)
				var/atom/movable/spawned_loot = new lootspawn(T)
				if (!fan_out_items)
					if (pixel_x != 0)
						spawned_loot.pixel_x = pixel_x
					if (pixel_y != 0)
						spawned_loot.pixel_y = pixel_y
				else
					if (loot_spawned)
						spawned_loot.pixel_x = spawned_loot.pixel_y = ((!(loot_spawned%2)*loot_spawned/2)*-1)+((loot_spawned%2)*(loot_spawned+1)/2*1)
			loot_spawned++
	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/lootdrop/maintenance
	name = "maintenance loot spawner"

/obj/effect/spawner/lootdrop/maintenance/Initialize(mapload)
	loot = GLOB.maintenance_loot
	. = ..()

/obj/effect/spawner/lootdrop/maintenance/two
	name = "2 x maintenance loot spawner"
	lootcount = 2

/obj/effect/spawner/lootdrop/maintenance/three
	name = "3 x maintenance loot spawner"
	lootcount = 3

/obj/effect/spawner/lootdrop/maintenance/four
	name = "4 x maintenance loot spawner"
	lootcount = 4

/obj/effect/spawner/lootdrop/maintenance/five
	name = "5 x maintenance loot spawner"
	lootcount = 5

/obj/effect/spawner/lootdrop/maintenance/six
	name = "6 x maintenance loot spawner"
	lootcount = 6

/obj/effect/spawner/lootdrop/maintenance/seven
	name = "7 x maintenance loot spawner"
	lootcount = 7

/obj/effect/spawner/lootdrop/maintenance/eight
	name = "8 x maintenance loot spawner"
	lootcount = 8

/obj/effect/spawner/lootdrop/techstorage
	name = "generic circuit board spawner"
	lootdoubles = FALSE
	fan_out_items = TRUE
	lootcount = INFINITY

/obj/effect/spawner/lootdrop/techstorage/service
	name = "service circuit board spawner"
	loot = list(
				/obj/item/circuitboard/computer/arcade/battle,
				/obj/item/circuitboard/computer/arcade/orion_trail,
				/obj/item/circuitboard/machine/autolathe,
//				/obj/item/circuitboard/computer/mining,
//				/obj/item/circuitboard/machine/ore_redemption,
//				/obj/item/circuitboard/machine/mining_equipment_vendor,
				/obj/item/circuitboard/machine/microwave,
//				/obj/item/circuitboard/machine/chem_dispenser/drinks,
//				/obj/item/circuitboard/machine/chem_dispenser/drinks/beer,
//				/obj/item/circuitboard/computer/slot_machine
				)

/obj/effect/spawner/lootdrop/techstorage/rnd
	name = "RnD circuit board spawner"
	loot = list(
//				/obj/item/circuitboard/computer/aifixer,
//				/obj/item/circuitboard/machine/rdserver,
				/obj/item/circuitboard/machine/mechfab,
				/obj/item/circuitboard/machine/circuit_imprinter/department,
//				/obj/item/circuitboard/computer/teleporter,
				/obj/item/circuitboard/machine/destructive_analyzer,
				/obj/item/circuitboard/computer/rdconsole,
//				/obj/item/circuitboard/computer/nanite_chamber_control,
//				/obj/item/circuitboard/computer/nanite_cloud_controller,
//				/obj/item/circuitboard/machine/nanite_chamber,
//				/obj/item/circuitboard/machine/nanite_programmer,
//				/obj/item/circuitboard/machine/nanite_program_hub
				)

/obj/effect/spawner/lootdrop/techstorage/security
	name = "security circuit board spawner"
	loot = list(
//				/obj/item/circuitboard/computer/secure_data,
//				/obj/item/circuitboard/computer/security,
//				/obj/item/circuitboard/computer/prisoner
				)

/obj/effect/spawner/lootdrop/techstorage/engineering
	name = "engineering circuit board spawner"
	loot = list(
//				/obj/item/circuitboard/computer/atmos_alert,
//				/obj/item/circuitboard/computer/stationalert,
				/obj/item/circuitboard/computer/powermonitor
				)

/obj/effect/spawner/lootdrop/techstorage/tcomms
	name = "tcomms circuit board spawner"
	loot = list(
//				/obj/item/circuitboard/computer/message_monitor,
				/obj/item/circuitboard/machine/telecomms/broadcaster,
				/obj/item/circuitboard/machine/telecomms/bus,
				/obj/item/circuitboard/machine/telecomms/server,
				/obj/item/circuitboard/machine/telecomms/receiver,
				/obj/item/circuitboard/machine/telecomms/processor,
				/obj/item/circuitboard/machine/announcement_system,
//				/obj/item/circuitboard/computer/comm_server,
//				/obj/item/circuitboard/computer/comm_monitor
				)

/obj/effect/spawner/lootdrop/techstorage/medical
	name = "medical circuit board spawner"
	loot = list(
				/obj/item/circuitboard/computer/cloning,
				/obj/item/circuitboard/machine/clonepod,
//				/obj/item/circuitboard/machine/chem_dispenser,
//				/obj/item/circuitboard/computer/scan_consolenew,
//				/obj/item/circuitboard/computer/med_data,
//				/obj/item/circuitboard/machine/smoke_machine,
//				/obj/item/circuitboard/machine/chem_master,
				/obj/item/circuitboard/machine/clonescanner,
//				/obj/item/circuitboard/computer/pandemic
				)

/obj/effect/spawner/lootdrop/techstorage/AI
	name = "secure AI circuit board spawner"
	loot = list(
//				/obj/item/circuitboard/computer/aiupload,
//				/obj/item/circuitboard/computer/borgupload,
//				/obj/item/circuitboard/aicore
				)

/obj/effect/spawner/lootdrop/techstorage/command
	name = "secure command circuit board spawner"
	loot = list(
//				/obj/item/circuitboard/computer/crew,
//				/obj/item/circuitboard/computer/communications,
//				/obj/item/circuitboard/computer/card
				)

/obj/effect/spawner/lootdrop/techstorage/RnD_secure
	name = "secure RnD circuit board spawner"
	loot = list(
//				/obj/item/circuitboard/computer/mecha_control,
//				/obj/item/circuitboard/computer/apc_control,
//				/obj/item/circuitboard/computer/robotics
				)