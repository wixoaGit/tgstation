/obj/machinery/gulag_item_reclaimer
	name = "equipment reclaimer station"
	desc = "Used to reclaim your items after you finish your sentence at the labor camp."
	icon = 'icons/obj/terminals.dmi'
	icon_state = "dorm_taken"
	req_access = list(ACCESS_SECURITY)
	density = FALSE
	use_power = IDLE_POWER_USE
	idle_power_usage = 100
	active_power_usage = 2500
	var/list/stored_items = list()
	var/obj/item/card/id/prisoner/inserted_id = null
	var/obj/machinery/gulag_teleporter/linked_teleporter = null