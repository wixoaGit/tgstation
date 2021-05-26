/datum/uplink_item
	var/name = "item name"
	var/category = "item category"
	var/desc = "item description"
	var/item = null
	var/refund_path = null
	var/cost = 0
	var/refund_amount = 0
	var/refundable = FALSE
	var/surplus = 100
	var/surplus_nullcrates
	var/cant_discount = FALSE
	var/limited_stock = -1
	var/list/include_modes = list()
	var/list/exclude_modes = list()
	var/list/restricted_roles = list()
	var/player_minimum
	var/purchase_log_vis = TRUE
	var/restricted = FALSE
	var/list/restricted_species
	var/illegal_tech = TRUE

/datum/uplink_item/New()
	. = ..()
	if(isnull(surplus_nullcrates))
		surplus_nullcrates = surplus

/datum/uplink_item/proc/purchase(mob/user, datum/component/uplink/U)
	var/atom/A = spawn_item(item, user, U)
	//if(purchase_log_vis && U.purchase_log)
	//	U.purchase_log.LogPurchase(A, src, cost)

/datum/uplink_item/proc/spawn_item(spawn_path, mob/user, datum/component/uplink/U)
	if(!spawn_path)
		return
	var/atom/A
	if(ispath(spawn_path))
		A = new spawn_path(get_turf(user))
	else
		A = spawn_path
	if(ishuman(user) && istype(A, /obj/item))
		var/mob/living/carbon/human/H = user
		if(H.put_in_hands(A))
			to_chat(H, "[A] materializes into your hands!")
			return A
	to_chat(user, "[A] materializes onto the floor.")
	return A