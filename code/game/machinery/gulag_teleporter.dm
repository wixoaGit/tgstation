/obj/machinery/gulag_teleporter
	name = "labor camp teleporter"
	desc = "A bluespace teleporter used for teleporting prisoners to the labor camp."
	icon = 'icons/obj/machines/implantchair.dmi'
	icon_state = "implantchair"
	state_open = FALSE
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 200
	active_power_usage = 5000
	circuit = /obj/item/circuitboard/machine/gulag_teleporter
	var/locked = FALSE
	var/message_cooldown
	var/breakout_time = 600
	//var/jumpsuit_type = /obj/item/clothing/under/rank/prisoner
	//var/shoes_type = /obj/item/clothing/shoes/sneakers/orange
	var/obj/machinery/gulag_item_reclaimer/linked_reclaimer
	//var/static/list/telegulag_required_items = typecacheof(list(
	//	/obj/item/implant,
	//	/obj/item/clothing/suit/space/eva/plasmaman,
	//	/obj/item/clothing/under/plasmaman,
	//	/obj/item/clothing/head/helmet/space/plasmaman,
	//	/obj/item/tank/internals,
	//	/obj/item/clothing/mask/breath,
	//	/obj/item/clothing/mask/gas))

/obj/item/circuitboard/machine/gulag_teleporter
	name = "labor camp teleporter (Machine Board)"
	build_path = /obj/machinery/gulag_teleporter
	//req_components = list(
	//						/obj/item/stack/ore/bluespace_crystal = 2,
	//						/obj/item/stock_parts/scanning_module,
	//						/obj/item/stock_parts/manipulator)
	//def_components = list(/obj/item/stack/ore/bluespace_crystal = /obj/item/stack/ore/bluespace_crystal/artificial)