/datum/component/storage/concrete
	var/drop_all_on_deconstruct = TRUE
	var/drop_all_on_destroy = FALSE
	var/transfer_contents_on_component_transfer = FALSE
	var/list/datum/component/storage/slaves = list()

	var/list/_contents_limbo
	var/list/_user_limbo

/datum/component/storage/concrete/Initialize()
	. = ..()
	//RegisterSignal(parent, COMSIG_ATOM_CONTENTS_DEL, .proc/on_contents_del)
	//RegisterSignal(parent, COMSIG_OBJ_DECONSTRUCT, .proc/on_deconstruct)

/datum/component/storage/concrete/Destroy()
	var/atom/real_location = real_location()
	//for(var/atom/_A in real_location)
	//	_A.mouse_opacity = initial(_A.mouse_opacity)
	if(drop_all_on_destroy)
		do_quick_empty()
	for(var/i in slaves)
		var/datum/component/storage/slave = i
		slave.change_master(null)
	QDEL_LIST(_contents_limbo)
	_user_limbo = null
	return ..()

/datum/component/storage/concrete/master()
	return src

/datum/component/storage/concrete/real_location()
	return parent

/datum/component/storage/concrete/_insert_physical_item(obj/item/I, override = FALSE)
	. = TRUE
	var/atom/real_location = real_location()
	if(I.loc != real_location)
		I.forceMove(real_location)
	refresh_mob_views()

/datum/component/storage/concrete/refresh_mob_views()
	. = ..()
	for(var/i in slaves)
		var/datum/component/storage/slave = i
		slave.refresh_mob_views()

/datum/component/storage/concrete/proc/on_slave_link(datum/component/storage/S)
	if(S == src)
		return FALSE
	slaves += S
	return TRUE

/datum/component/storage/concrete/proc/on_slave_unlink(datum/component/storage/S)
	slaves -= S
	return FALSE

/datum/component/storage/concrete/_removal_reset(atom/movable/thing)
	thing.layer = initial(thing.layer)
	//thing.plane = initial(thing.plane)
	//thing.mouse_opacity = initial(thing.mouse_opacity)
	//if(thing.maptext)
	//	thing.maptext = ""

/datum/component/storage/concrete/remove_from_storage(atom/movable/AM, atom/new_location)
	var/atom/parent = src.parent
	var/list/seeing_mobs = can_see_contents()
	for(var/mob/M in seeing_mobs)
		M.client.screen -= AM
	if(ismob(parent.loc) && isitem(AM))
		var/obj/item/I = AM
		var/mob/M = parent.loc
		I.dropped(M)
	if(new_location)
		_removal_reset(AM)
		AM.forceMove(new_location)
		AM.on_exit_storage(src)
	else
		AM.moveToNullspace()
	refresh_mob_views()
	if(isobj(parent))
		var/obj/O = parent
		O.update_icon()
	return TRUE

/datum/component/storage/concrete/proc/slave_can_insert_object(datum/component/storage/slave, obj/item/I, stop_messages = FALSE, mob/M)
	return TRUE

/datum/component/storage/concrete/proc/handle_item_insertion_from_slave(datum/component/storage/slave, obj/item/I, prevent_warning = FALSE, M)
	. = handle_item_insertion(I, prevent_warning, M, slave)
	if(. && !prevent_warning)
		slave.mob_item_insertion_feedback(usr, M, I)

/datum/component/storage/concrete/handle_item_insertion(obj/item/I, prevent_warning = FALSE, mob/M, datum/component/storage/remote)
	var/datum/component/storage/concrete/master = master()
	var/atom/parent = src.parent
	var/moved = FALSE
	if(!istype(I))
		return FALSE
	if(M)
		if(!M.temporarilyRemoveItemFromInventory(I))
			return FALSE
		else
			moved = TRUE
	if(I.pulledby)
		I.pulledby.stop_pulling()
	if(silent)
		prevent_warning = TRUE
	if(!_insert_physical_item(I))
		if(moved)
			if(M)
				if(!M.put_in_active_hand(I))
					I.forceMove(parent.drop_location())
			else
				I.forceMove(parent.drop_location())
		return FALSE
	I.on_enter_storage(master)
	refresh_mob_views()
	//I.mouse_opacity = MOUSE_OPACITY_OPAQUE
	if(M)
		if(M.client && M.active_storage != src)
			M.client.screen -= I
		//if(M.observers && M.observers.len)
		//	for(var/i in M.observers)
		//		var/mob/dead/observe = i
		//		if(observe.client && observe.active_storage != src)
		//			observe.client.screen -= I
		if(!remote)
			parent.add_fingerprint(M)
			if(!prevent_warning)
				mob_item_insertion_feedback(usr, M, I)
	update_icon()
	return TRUE

/datum/component/storage/concrete/update_icon()
	if(isobj(parent))
		var/obj/O = parent
		O.update_icon()
	for(var/i in slaves)
		var/datum/component/storage/slave = i
		slave.update_icon()