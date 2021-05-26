/datum/design/crowbar
	name = "Pocket Crowbar"
	id = "crowbar"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(MAT_METAL = 50)
	build_path = /obj/item/crowbar
	category = list("initial","Tools","Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/multitool
	name = "Multitool"
	id = "multitool"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 20)
	build_path = /obj/item/multitool
	category = list("initial","Tools","Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/weldingtool
	name = "Welding Tool"
	id = "welding_tool"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(MAT_METAL = 70, MAT_GLASS = 20)
	build_path = /obj/item/weldingtool
	category = list("initial","Tools","Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/screwdriver
	name = "Screwdriver"
	id = "screwdriver"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(MAT_METAL = 75)
	build_path = /obj/item/screwdriver
	category = list("initial","Tools","Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/wirecutters
	name = "Wirecutters"
	id = "wirecutters"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(MAT_METAL = 80)
	build_path = /obj/item/wirecutters
	category = list("initial","Tools","Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/wrench
	name = "Wrench"
	id = "wrench"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(MAT_METAL = 150)
	build_path = /obj/item/wrench
	category = list("initial","Tools","Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/cable_coil
	name = "Cable Coil"
	id = "cable_coil"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 10, MAT_GLASS = 5)
	build_path = /obj/item/stack/cable_coil/random
	category = list("initial","Tools","Tool Designs")
	maxstack = 30
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE