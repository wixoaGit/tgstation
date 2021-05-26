/obj/item/circuitboard/machine/sleeper
	name = "Sleeper (Machine Board)"
	build_path = /obj/machinery/sleeper
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sheet/glass = 2)

/obj/item/circuitboard/machine/vr_sleeper
	name = "VR Sleeper (Machine Board)"
	build_path = /obj/machinery/vr_sleeper
	req_components = list(
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stock_parts/scanning_module = 2,
		/obj/item/stack/sheet/glass = 2)

/obj/item/circuitboard/machine/announcement_system
	name = "Announcement System (Machine Board)"
	build_path = /obj/machinery/announcement_system
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/machine/autolathe
	name = "Autolathe (Machine Board)"
	build_path = /obj/machinery/autolathe
	req_components = list(
		/obj/item/stock_parts/matter_bin = 3,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/machine/clonepod
	name = "Clone Pod (Machine Board)"
	build_path = /obj/machinery/clonepod
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/scanning_module = 2,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/machine/clonescanner
	name = "Cloning Scanner (Machine Board)"
	build_path = /obj/machinery/dna_scannernew
	req_components = list(
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stack/cable_coil = 2)

/obj/item/circuitboard/machine/holopad
	name = "AI Holopad (Machine Board)"
	build_path = /obj/machinery/holopad
	req_components = list(/obj/item/stock_parts/capacitor = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/telecomms/broadcaster
	name = "Subspace Broadcaster (Machine Board)"
	build_path = /obj/machinery/telecomms/broadcaster
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stock_parts/subspace/filter = 1,
		/obj/item/stock_parts/subspace/crystal = 1,
		/obj/item/stock_parts/micro_laser = 2)

/obj/item/circuitboard/machine/telecomms/bus
	name = "Bus Mainframe (Machine Board)"
	build_path = /obj/machinery/telecomms/bus
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stock_parts/subspace/filter = 1)

/obj/item/circuitboard/machine/telecomms/hub
	name = "Hub Mainframe (Machine Board)"
	build_path = /obj/machinery/telecomms/hub
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/subspace/filter = 2)

/obj/item/circuitboard/machine/telecomms/processor
	name = "Processor Unit (Machine Board)"
	build_path = /obj/machinery/telecomms/processor
	req_components = list(
		/obj/item/stock_parts/manipulator = 3,
		/obj/item/stock_parts/subspace/filter = 1,
		/obj/item/stock_parts/subspace/treatment = 2,
		/obj/item/stock_parts/subspace/analyzer = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/subspace/amplifier = 1)

/obj/item/circuitboard/machine/telecomms/receiver
	name = "Subspace Receiver (Machine Board)"
	build_path = /obj/machinery/telecomms/receiver
	req_components = list(
		/obj/item/stock_parts/subspace/ansible = 1,
		/obj/item/stock_parts/subspace/filter = 1,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/micro_laser = 1)

/obj/item/circuitboard/machine/telecomms/relay
	name = "Relay Mainframe (Machine Board)"
	build_path = /obj/machinery/telecomms/relay
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/subspace/filter = 2)

/obj/item/circuitboard/machine/telecomms/server
	name = "Telecommunication Server (Machine Board)"
	build_path = /obj/machinery/telecomms/server
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stock_parts/subspace/filter = 1)

/obj/item/circuitboard/machine/vendor
	name = "Booze-O-Mat Vendor (Machine Board)"
	desc = "You can turn the \"brand selection\" dial using a screwdriver."
	build_path = /obj/machinery/vending/boozeomat
	//req_components = list(/obj/item/vending_refill/boozeomat = 1)

	//var/static/list/vending_names_paths = list(
	//	/obj/machinery/vending/boozeomat = "Booze-O-Mat",
	//	/obj/machinery/vending/coffee = "Solar's Best Hot Drinks",
	//	/obj/machinery/vending/snack = "Getmore Chocolate Corp",
	//	/obj/machinery/vending/cola = "Robust Softdrinks",
	//	/obj/machinery/vending/cigarette = "ShadyCigs Deluxe",
	//	/obj/machinery/vending/games = "\improper Good Clean Fun",
	//	/obj/machinery/vending/autodrobe = "AutoDrobe",
	//	/obj/machinery/vending/wardrobe/sec_wardrobe = "SecDrobe",
	//	/obj/machinery/vending/wardrobe/medi_wardrobe = "MediDrobe",
	//	/obj/machinery/vending/wardrobe/engi_wardrobe = "EngiDrobe",
	//	/obj/machinery/vending/wardrobe/atmos_wardrobe = "AtmosDrobe",
	//	/obj/machinery/vending/wardrobe/cargo_wardrobe = "CargoDrobe",
	//	/obj/machinery/vending/wardrobe/robo_wardrobe = "RoboDrobe",
	//	/obj/machinery/vending/wardrobe/science_wardrobe = "SciDrobe",
	//	/obj/machinery/vending/wardrobe/hydro_wardrobe = "HyDrobe",
	//	/obj/machinery/vending/wardrobe/curator_wardrobe = "CuraDrobe",
	//	/obj/machinery/vending/wardrobe/bar_wardrobe = "BarDrobe",
	//	/obj/machinery/vending/wardrobe/chef_wardrobe = "ChefDrobe",
	//	/obj/machinery/vending/wardrobe/jani_wardrobe = "JaniDrobe",
	//	/obj/machinery/vending/wardrobe/law_wardrobe = "LawDrobe",
	//	/obj/machinery/vending/wardrobe/chap_wardrobe = "ChapDrobe",
	//	/obj/machinery/vending/wardrobe/chem_wardrobe = "ChemDrobe",
	//	/obj/machinery/vending/wardrobe/gene_wardrobe = "GeneDrobe",
	//	/obj/machinery/vending/wardrobe/viro_wardrobe = "ViroDrobe",
	//	/obj/machinery/vending/clothing = "ClothesMate",
	//	/obj/machinery/vending/medical = "NanoMed Plus",
	//	/obj/machinery/vending/wallmed = "NanoMed")

/obj/item/circuitboard/machine/mechfab
	name = "Exosuit Fabricator (Machine Board)"
	build_path = /obj/machinery/mecha_part_fabricator
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/machine/biogenerator
	name = "Biogenerator (Machine Board)"
	//build_path = /obj/machinery/biogenerator
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/machine/plantgenes
	name = "Plant DNA Manipulator (Machine Board)"
	build_path = /obj/machinery/plantgenes
	req_components = list(
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/scanning_module = 1)

/obj/item/circuitboard/machine/plantgenes/vault
	name = "alien board (Plant DNA Manipulator)"
	icon_state = "abductor_mod"
	//def_components = list(
	//	/obj/item/stock_parts/manipulator = /obj/item/stock_parts/manipulator/femto,
	//	/obj/item/stock_parts/micro_laser = /obj/item/stock_parts/micro_laser/quadultra,
	//	/obj/item/stock_parts/scanning_module = /obj/item/stock_parts/scanning_module/triphasic)

/obj/item/circuitboard/machine/hydroponics
	name = "Hydroponics Tray (Machine Board)"
	build_path = /obj/machinery/hydroponics/constructable
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/sheet/glass = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/seed_extractor
	name = "Seed Extractor (Machine Board)"
	build_path = /obj/machinery/seed_extractor
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/chem_heater
	name = "Chemical Heater (Machine Board)"
	build_path = /obj/machinery/chem_heater
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/machine/reagentgrinder
	name = "Machine Design (All-In-One Grinder)"
	build_path = /obj/machinery/reagentgrinder/constructed
	req_components = list(
		/obj/item/stock_parts/manipulator = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/circuit_imprinter
	name = "Circuit Imprinter (Machine Board)"
	build_path = /obj/machinery/rnd/production/circuit_imprinter
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/reagent_containers/glass/beaker = 2)

/obj/item/circuitboard/machine/circuit_imprinter/department
	name = "Departmental Circuit Imprinter (Machine Board)"
	build_path = /obj/machinery/rnd/production/circuit_imprinter/department

/obj/item/circuitboard/machine/circuit_imprinter/department/science
	name = "Departmental Circuit Imprinter - Science (Machine Board)"
	build_path = /obj/machinery/rnd/production/circuit_imprinter/department/science

/obj/item/circuitboard/machine/destructive_analyzer
	name = "Destructive Analyzer (Machine Board)"
	build_path = /obj/machinery/rnd/destructive_analyzer
	req_components = list(
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 1)

/obj/item/circuitboard/machine/protolathe
	name = "Protolathe (Machine Board)"
	build_path = /obj/machinery/rnd/production/protolathe
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/reagent_containers/glass/beaker = 2)

/obj/item/circuitboard/machine/protolathe/department
	name = "Departmental Protolathe (Machine Board)"
	build_path = /obj/machinery/rnd/production/protolathe/department

/obj/item/circuitboard/machine/protolathe/department/cargo
	name = "Departmental Protolathe (Machine Board) - Cargo"
	build_path = /obj/machinery/rnd/production/protolathe/department/cargo

/obj/item/circuitboard/machine/protolathe/department/engineering
	name = "Departmental Protolathe (Machine Board) - Engineering"
	build_path = /obj/machinery/rnd/production/protolathe/department/engineering

/obj/item/circuitboard/machine/protolathe/department/medical
	name = "Departmental Protolathe (Machine Board) - Medical"
	build_path = /obj/machinery/rnd/production/protolathe/department/medical

/obj/item/circuitboard/machine/protolathe/department/science
	name = "Departmental Protolathe (Machine Board) - Science"
	build_path = /obj/machinery/rnd/production/protolathe/department/science

/obj/item/circuitboard/machine/protolathe/department/security
	name = "Departmental Protolathe (Machine Board) - Security"
	build_path = /obj/machinery/rnd/production/protolathe/department/security

/obj/item/circuitboard/machine/protolathe/department/service
	name = "Departmental Protolathe - Service (Machine Board)"
	build_path = /obj/machinery/rnd/production/protolathe/department/service

/obj/item/circuitboard/machine/techfab
	name = "\improper Techfab (Machine Board)"
	build_path = /obj/machinery/rnd/production/techfab
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/reagent_containers/glass/beaker = 2)

/obj/item/circuitboard/machine/techfab/department
	name = "\improper Departmental Techfab (Machine Board)"
	build_path = /obj/machinery/rnd/production/techfab/department

/obj/item/circuitboard/machine/techfab/department/cargo
	name = "\improper Departmental Techfab (Machine Board) - Cargo"
	build_path = /obj/machinery/rnd/production/techfab/department/cargo

/obj/item/circuitboard/machine/techfab/department/engineering
	name = "\improper Departmental Techfab (Machine Board) - Engineering"
	build_path = /obj/machinery/rnd/production/techfab/department/engineering

/obj/item/circuitboard/machine/techfab/department/medical
	name = "\improper Departmental Techfab (Machine Board) - Medical"
	build_path = /obj/machinery/rnd/production/techfab/department/medical

/obj/item/circuitboard/machine/techfab/department/science
	name = "\improper Departmental Techfab (Machine Board) - Science"
	build_path = /obj/machinery/rnd/production/techfab/department/science

/obj/item/circuitboard/machine/techfab/department/security
	name = "\improper Departmental Techfab (Machine Board) - Security"
	build_path = /obj/machinery/rnd/production/techfab/department/security

/obj/item/circuitboard/machine/techfab/department/service
	name = "\improper Departmental Techfab - Service (Machine Board)"
	build_path = /obj/machinery/rnd/production/techfab/department/service

/obj/item/circuitboard/machine/microwave
	name = "Microwave (Machine Board)"
	build_path = /obj/machinery/microwave
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stack/sheet/glass = 2)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/ore_silo
	name = "Ore Silo (Machine Board)"
	build_path = /obj/machinery/ore_silo
	req_components = list()