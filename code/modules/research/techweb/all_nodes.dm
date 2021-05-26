/datum/techweb_node/base
	id = "base"
	starting_node = TRUE
	display_name = "Basic Research Technology"
	description = "NT default research technologies."
	//design_ids = list("basic_matter_bin", "basic_cell", "basic_scanning", "basic_capacitor", "basic_micro_laser", "micro_mani", "desttagger", "handlabel", "packagewrap",
	//"destructive_analyzer", "circuit_imprinter", "experimentor", "rdconsole", "design_disk", "tech_disk", "rdserver", "rdservercontrol", "mechfab", "paystand",
	//"space_heater", "beaker", "large_beaker", "bucket", "xlarge_beaker", "sec_rshot", "sec_beanbag_slug", "sec_bshot", "sec_slug", "sec_Islug", "sec_dart", "sec_38",
	//"rglass","plasteel","plastitanium","plasmaglass","plasmareinforcedglass","titaniumglass","plastitaniumglass")
	design_ids = list("basic_micro_laser")//not_actual

/datum/techweb_node/mmi
	id = "mmi"
	starting_node = TRUE
	display_name = "Man Machine Interface"
	description = "A slightly Frankensteinian device that allows human brains to interface natively with software APIs."
	//design_ids = list("mmi")
	design_ids = list()//not_actual

/datum/techweb_node/cyborg
	id = "cyborg"
	starting_node = TRUE
	display_name = "Cyborg Construction"
	description = "Sapient robots with preloaded tool modules and programmable laws."
	//design_ids = list("robocontrol", "sflash", "borg_suit", "borg_head", "borg_chest", "borg_r_arm", "borg_l_arm", "borg_r_leg", "borg_l_leg", "borgupload",
	//"cyborgrecharger", "borg_upgrade_restart", "borg_upgrade_rename")
	design_ids = list()//not_actual

/datum/techweb_node/mech
	id = "mecha"
	starting_node = TRUE
	display_name = "Mechanical Exosuits"
	description = "Mechanized exosuits that are several magnitudes stronger and more powerful than the average human."
	//design_ids = list("mecha_tracking", "mechacontrol", "mechapower", "mech_recharger", "ripley_chassis", "firefighter_chassis", "ripley_torso", "ripley_left_arm", "ripley_right_arm", "ripley_left_leg", "ripley_right_leg",
	//"ripley_main", "ripley_peri", "mech_hydraulic_clamp")
	design_ids = list()//not_actual

/datum/techweb_node/mech_tools
	id = "mech_tools"
	starting_node = TRUE
	display_name = "Basic Exosuit Equipment"
	description = "Various tools fit for basic mech units"
	//design_ids = list("mech_drill", "mech_mscanner", "mech_extinguisher", "mech_cable_layer")
	design_ids = list()//not_actual

/datum/techweb_node/basic_tools
	id = "basic_tools"
	starting_node = TRUE
	display_name = "Basic Tools"
	description = "Basic mechanical, electronic, surgical and botanical tools."
	//design_ids = list("screwdriver", "wrench", "wirecutters", "crowbar", "multitool", "welding_tool", "tscanner", "analyzer", "cable_coil", "pipe_painter", "airlock_painter", "scalpel", "circular_saw", "surgicaldrill", "retractor", "cautery", "hemostat", "cultivator", "plant_analyzer", "shovel", "spade", "hatchet")
	design_ids = list("screwdriver", "wrench", "wirecutters", "crowbar", "multitool", "welding_tool", "cable_coil")//not_actual

/datum/techweb_node/biotech
	id = "biotech"
	display_name = "Biological Technology"
	description = "What makes us tick."	
	prereq_ids = list("base")
	//design_ids = list("chem_heater", "chem_master", "chem_dispenser", "sleeper", "vr_sleeper", "pandemic", "defibrillator", "defibmount", "operating", "soda_dispenser", "beer_dispenser", "healthanalyzer", "medspray","genescanner")
	design_ids = list("chem_heater")//not_actual
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/adv_biotech
	id = "adv_biotech"
	display_name = "Advanced Biotechnology"
	description = "Advanced Biotechnology"
	prereq_ids = list("biotech")
	//design_ids = list("piercesyringe", "crewpinpointer", "smoke_machine", "plasmarefiller", "limbgrower", "meta_beaker", "healthanalyzer_advanced", "harvester", "holobarrier_med", "detective_scanner", "defibrillator_compact")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/bio_process
	id = "bio_process"
	display_name = "Biological Processing"
	description = "From slimes to kitchens."
	prereq_ids = list("biotech")
	//design_ids = list("smartfridge", "gibber", "deepfryer", "monkey_recycler", "processor", "gibber", "microwave", "reagentgrinder", "dish_drive")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000