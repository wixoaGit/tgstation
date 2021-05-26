/datum/design
	var/name = "Name"
	var/desc = "Desc"
	var/id = DESIGN_ID_IGNORE
	var/build_type = null
	var/list/materials = list()
	var/construction_time
	var/build_path = null
	var/list/make_reagents = list()
	var/list/category = null
	var/list/reagents_list = list()
	var/maxstack = 1
	var/lathe_time_factor = 1
	var/dangerous_construction = FALSE
	var/departmental_flags = ALL
	var/list/datum/techweb_node/unlocked_by = list()
	var/research_icon
	var/research_icon_state
	var/icon_cache

/datum/design/error_design
	name = "ERROR"
	desc = "This usually means something in the database has corrupted. If this doesn't go away automatically, inform Central Comamnd so their techs can fix this ASAP(tm)"

/datum/design/Destroy()
	SSresearch.techweb_designs -= id
	return ..()

/datum/design/proc/icon_html(client/user)
	//var/datum/asset/spritesheet/sheet = get_asset_datum(/datum/asset/spritesheet/research_designs)
	//sheet.send(user)
	//return sheet.icon_tag(id)
	return "([id])"//not_actual

/obj/item/disk/design_disk
	name = "Component Design Disk"
	desc = "A disk for storing device design data for construction in lathes."
	icon_state = "datadisk1"
	materials = list(MAT_METAL=300, MAT_GLASS=100)
	var/list/blueprints = list()
	var/max_blueprints = 1

/obj/item/disk/design_disk/Initialize()
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)
	//for(var/i in 1 to max_blueprints)
	//	blueprints += null
	blueprints.len = max_blueprints//not_actual

/obj/item/disk/design_disk/adv
	name = "Advanced Component Design Disk"
	desc = "A disk for storing device design data for construction in lathes. This one has extra storage space."
	materials = list(MAT_METAL=300, MAT_GLASS=100, MAT_SILVER = 50)
	max_blueprints = 5