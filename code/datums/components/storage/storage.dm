#define COLLECT_ONE 0
#define COLLECT_EVERYTHING 1
#define COLLECT_SAME 2

#define DROP_NOTHING 0
#define DROP_AT_PARENT 1
#define DROP_AT_LOCATION 2

/datum/component/storage
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/datum/component/storage/concrete/master

	var/list/can_hold
	var/list/cant_hold

	var/list/mob/is_using

	var/locked = FALSE

	var/max_w_class = WEIGHT_CLASS_SMALL
	var/max_combined_w_class = 14
	var/max_items = 7

	var/emp_shielded = FALSE

	var/silent = FALSE
	var/click_gather = FALSE
	var/rustle_sound = TRUE
	var/allow_quick_empty = FALSE
	var/allow_quick_gather = FALSE

	var/collection_mode = COLLECT_EVERYTHING

	var/insert_preposition = "in"

	var/display_numerical_stacking = FALSE

	var/obj/screen/storage/boxes
	var/obj/screen/close/closer

	var/allow_big_nesting = FALSE

	var/attack_hand_interact = TRUE
	var/quickdraw = FALSE

	//var/datum/action/item_action/storage_gather_mode/modeswitch_action

	var/screen_max_columns = 7
	var/screen_max_rows = INFINITY
	var/screen_pixel_x = 16
	var/screen_pixel_y = 16
	var/screen_start_x = 4
	var/screen_start_y = 2

/datum/component/storage/Initialize(datum/component/storage/concrete/master)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	if(master)
		change_master(master)
	boxes = new(null, src)
	closer = new(null, src)
	orient2hud()

	//RegisterSignal(parent, COMSIG_CONTAINS_STORAGE, .proc/on_check)
	//RegisterSignal(parent, COMSIG_IS_STORAGE_LOCKED, .proc/check_locked)
	//RegisterSignal(parent, COMSIG_TRY_STORAGE_SHOW, .proc/signal_show_attempt)
	RegisterSignal(parent, COMSIG_TRY_STORAGE_INSERT, .proc/signal_insertion_attempt)
	RegisterSignal(parent, COMSIG_TRY_STORAGE_CAN_INSERT, .proc/signal_can_insert)
	//RegisterSignal(parent, COMSIG_TRY_STORAGE_TAKE_TYPE, .proc/signal_take_type)
	//RegisterSignal(parent, COMSIG_TRY_STORAGE_FILL_TYPE, .proc/signal_fill_type)
	//RegisterSignal(parent, COMSIG_TRY_STORAGE_SET_LOCKSTATE, .proc/set_locked)
	//RegisterSignal(parent, COMSIG_TRY_STORAGE_TAKE, .proc/signal_take_obj)
	//RegisterSignal(parent, COMSIG_TRY_STORAGE_QUICK_EMPTY, .proc/signal_quick_empty)
	//RegisterSignal(parent, COMSIG_TRY_STORAGE_HIDE_FROM, .proc/signal_hide_attempt)
	//RegisterSignal(parent, COMSIG_TRY_STORAGE_HIDE_ALL, .proc/close_all)
	//RegisterSignal(parent, COMSIG_TRY_STORAGE_RETURN_INVENTORY, .proc/signal_return_inv)

	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/attackby)

	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, .proc/on_attack_hand)
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_PAW, .proc/on_attack_hand)
	//RegisterSignal(parent, COMSIG_ATOM_EMP_ACT, .proc/emp_act)
	//RegisterSignal(parent, COMSIG_ATOM_ATTACK_GHOST, .proc/show_to_ghost)
	RegisterSignal(parent, COMSIG_ATOM_ENTERED, .proc/refresh_mob_views)
	RegisterSignal(parent, COMSIG_ATOM_EXITED, .proc/_remove_and_refresh)
	//RegisterSignal(parent, COMSIG_ATOM_CANREACH, .proc/canreach_react)

	RegisterSignal(parent, COMSIG_ITEM_PRE_ATTACK, .proc/preattack_intercept)
	//RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, .proc/attack_self)
	//RegisterSignal(parent, COMSIG_ITEM_PICKUP, .proc/signal_on_pickup)

	//RegisterSignal(parent, COMSIG_MOVABLE_POST_THROW, .proc/close_all)
	//RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/on_move)

	//RegisterSignal(parent, COMSIG_CLICK_ALT, .proc/on_alt_click)
	//RegisterSignal(parent, COMSIG_MOUSEDROP_ONTO, .proc/mousedrop_onto)
	//RegisterSignal(parent, COMSIG_MOUSEDROPPED_ONTO, .proc/mousedrop_receive)

	//update_actions()

/datum/component/storage/Destroy()
	close_all()
	QDEL_NULL(boxes)
	QDEL_NULL(closer)
	LAZYCLEARLIST(is_using)
	return ..()

/datum/component/storage/proc/change_master(datum/component/storage/concrete/new_master)
	if(new_master == src || (!isnull(new_master) && !istype(new_master)))
		return FALSE
	if(master)
		master.on_slave_unlink(src)
	master = new_master
	if(master)
		master.on_slave_link(src)
	return TRUE

/datum/component/storage/proc/master()
	if(master == src)
		return
	return master

/datum/component/storage/proc/real_location()
	var/datum/component/storage/concrete/master = master()
	return master? master.real_location() : null

/datum/component/storage/proc/preattack_intercept(datum/source, obj/O, mob/M, params)
	if(!isitem(O) || !click_gather || SEND_SIGNAL(O, COMSIG_CONTAINS_STORAGE))
		return FALSE
	. = COMPONENT_NO_ATTACK
	if(locked)
		to_chat(M, "<span class='warning'>[parent] seems to be locked!</span>")
		return FALSE
	var/obj/item/I = O
	if(collection_mode == COLLECT_ONE)
		if(can_be_inserted(I, null, M))
			handle_item_insertion(I, null, M)
		return
	if(!isturf(I.loc))
		return
	var/list/things = I.loc.contents.Copy()
	if(collection_mode == COLLECT_SAME)
		things = typecache_filter_list(things, typecacheof(I.type))
	var/len = length(things)
	if(!len)
		to_chat(M, "<span class='notice'>You failed to pick up anything with [parent].</span>")
		return
	var/datum/progressbar/progress = new(M, len, I.loc)
	var/list/rejections = list()
	//while(do_after(M, 10, TRUE, parent, FALSE, CALLBACK(src, .proc/handle_mass_pickup, things, I.loc, rejections, progress)))
	//	stoplag(1)
	qdel(progress)
	to_chat(M, "<span class='notice'>You put everything you could [insert_preposition] [parent].</span>")

/datum/component/storage/proc/quick_empty(mob/M)
	var/atom/A = parent
	if(!M.canUseStorage() || !A.Adjacent(M) || M.incapacitated())
		return
	if(locked)
		to_chat(M, "<span class='warning'>[parent] seems to be locked!</span>")
		return FALSE
	A.add_fingerprint(M)
	to_chat(M, "<span class='notice'>You start dumping out [parent].</span>")
	var/turf/T = get_turf(A)
	var/list/things = contents()
	var/datum/progressbar/progress = new(M, length(things), T)
	while (do_after(M, 10, TRUE, T, FALSE, CALLBACK(src, .proc/mass_remove_from_storage, T, things, progress)))
		stoplag(1)
	qdel(progress)

/datum/component/storage/proc/mass_remove_from_storage(atom/target, list/things, datum/progressbar/progress, trigger_on_found = TRUE)
	var/atom/real_location = real_location()
	for(var/obj/item/I in things)
		things -= I
		if(I.loc != real_location)
			continue
		remove_from_storage(I, target)
		if(trigger_on_found && I.on_found())
			return FALSE
		if(TICK_CHECK)
			progress.update(progress.goal - length(things))
			return TRUE
	progress.update(progress.goal - length(things))
	return FALSE

/datum/component/storage/proc/do_quick_empty(atom/_target)
	if(!_target)
		_target = get_turf(parent)
	if(usr)
		hide_from(usr)
	var/list/contents = contents()
	var/atom/real_location = real_location()
	for(var/obj/item/I in contents)
		if(I.loc != real_location)
			continue
		remove_from_storage(I, _target)
	return TRUE

/datum/component/storage/proc/_process_numerical_display()
	. = list()
	var/atom/real_location = real_location()
	for(var/obj/item/I in real_location.contents)
		if(QDELETED(I))
			continue
		if(!.["[I.type]-[I.name]"])
			.["[I.type]-[I.name]"] = new /datum/numbered_display(I, 1)
		else
			var/datum/numbered_display/ND = .["[I.type]-[I.name]"]
			ND.number++

/datum/component/storage/proc/orient2hud()
	var/atom/real_location = real_location()
	var/adjusted_contents = real_location.contents.len

	var/list/datum/numbered_display/numbered_contents
	if(display_numerical_stacking)
		numbered_contents = _process_numerical_display()
		adjusted_contents = numbered_contents.len

	var/columns = CLAMP(max_items, 1, screen_max_columns)
	var/rows = CLAMP(CEILING(adjusted_contents / columns, 1), 1, screen_max_rows)
	standard_orient_objs(rows, columns, numbered_contents)

/datum/component/storage/proc/standard_orient_objs(rows, cols, list/obj/item/numerical_display_contents)
	boxes.screen_loc = "[screen_start_x]:[screen_pixel_x],[screen_start_y]:[screen_pixel_y] to [screen_start_x+cols-1]:[screen_pixel_x],[screen_start_y+rows-1]:[screen_pixel_y]"
	var/cx = screen_start_x
	var/cy = screen_start_y
	if(islist(numerical_display_contents))
		for(var/type in numerical_display_contents)
			var/datum/numbered_display/ND = numerical_display_contents[type]
			ND.sample_object.mouse_opacity = MOUSE_OPACITY_OPAQUE
			ND.sample_object.screen_loc = "[cx]:[screen_pixel_x],[cy]:[screen_pixel_y]"
			//ND.sample_object.maptext = "<font color='white'>[(ND.number > 1)? "[ND.number]" : ""]</font>"
			ND.sample_object.layer = ABOVE_HUD_LAYER
			//ND.sample_object.plane = ABOVE_HUD_PLANE
			cx++
			if(cx - screen_start_x >= cols)
				cx = screen_start_x
				cy++
				if(cy - screen_start_y >= rows)
					break
	else
		var/atom/real_location = real_location()
		for(var/obj/O in real_location)
			if(QDELETED(O))
				continue
			O.mouse_opacity = MOUSE_OPACITY_OPAQUE
			O.screen_loc = "[cx]:[screen_pixel_x],[cy]:[screen_pixel_y]"
			//O.maptext = ""
			O.layer = ABOVE_HUD_LAYER
			//O.plane = ABOVE_HUD_PLANE
			cx++
			if(cx - screen_start_x >= cols)
				cx = screen_start_x
				cy++
				if(cy - screen_start_y >= rows)
					break
	closer.screen_loc = "[screen_start_x + cols]:[screen_pixel_x],[screen_start_y]:[screen_pixel_y]"

/datum/component/storage/proc/show_to(mob/M)
	if(!M.client)
		return FALSE
	var/atom/real_location = real_location()
	if(M.active_storage != src && (M.stat == CONSCIOUS))
		for(var/obj/item/I in real_location)
			if(I.on_found(M))
				return FALSE
	if(M.active_storage)
		M.active_storage.hide_from(M)
	orient2hud()
	M.client.screen |= boxes
	M.client.screen |= closer
	M.client.screen |= real_location.contents
	M.active_storage = src
	LAZYOR(is_using, M)
	return TRUE

/datum/component/storage/proc/hide_from(mob/M)
	if(!M.client)
		return TRUE
	var/atom/real_location = real_location()
	M.client.screen -= boxes
	M.client.screen -= closer
	M.client.screen -= real_location.contents
	if(M.active_storage == src)
		M.active_storage = null
	LAZYREMOVE(is_using, M)
	return TRUE

/datum/component/storage/proc/close(mob/M)
	hide_from(M)

/datum/component/storage/proc/close_all()
	. = FALSE
	for(var/mob/M in can_see_contents())
		close(M)
		. = TRUE

/datum/component/storage/proc/_removal_reset(atom/movable/thing)
	if(!istype(thing))
		return FALSE
	var/datum/component/storage/concrete/master = master()
	if(!istype(master))
		return FALSE
	return master._removal_reset(thing)

/datum/component/storage/proc/_remove_and_refresh(datum/source, atom/movable/thing)
	_removal_reset(thing)
	refresh_mob_views()

/datum/component/storage/proc/remove_from_storage(atom/movable/AM, atom/new_location)
	if(!istype(AM))
		return FALSE
	var/datum/component/storage/concrete/master = master()
	if(!istype(master))
		return FALSE
	return master.remove_from_storage(AM, new_location)

/datum/component/storage/proc/refresh_mob_views()
	var/list/seeing = can_see_contents()
	for(var/i in seeing)
		show_to(i)
	return TRUE

/datum/component/storage/proc/can_see_contents()
	var/list/cansee = list()
	for(var/mob/M in is_using)
		if(M.active_storage == src && M.client)
			cansee |= M
		else
			LAZYREMOVE(is_using, M)
	return cansee

/datum/component/storage/proc/attackby(datum/source, obj/item/I, mob/M, params)
	//if(istype(I, /obj/item/hand_labeler))
	//	var/obj/item/hand_labeler/labeler = I
	//	if(labeler.mode)
	//		return FALSE
	. = TRUE
	if(iscyborg(M))
		return
	if(!can_be_inserted(I, FALSE, M))
		var/atom/real_location = real_location()
		if(real_location.contents.len >= max_items)
			return TRUE
		return FALSE
	handle_item_insertion(I, FALSE, M)

/datum/component/storage/proc/contents()
	var/atom/real_location = real_location()
	return real_location.contents.Copy()

/datum/component/storage/proc/can_be_inserted(obj/item/I, stop_messages = FALSE, mob/M)
	if(!istype(I) || (I.item_flags & ABSTRACT))
		return FALSE
	if(I == parent)
		return FALSE
	var/atom/real_location = real_location()
	var/atom/host = parent
	if(real_location == I.loc)
		return FALSE
	if(locked)
		if(M && !stop_messages)
			host.add_fingerprint(M)
			to_chat(M, "<span class='warning'>[host] seems to be locked!</span>")
		return FALSE
	if(real_location.contents.len >= max_items)
		if(!stop_messages)
			to_chat(M, "<span class='warning'>[host] is full, make some space!</span>")
		return FALSE
	if(length(can_hold))
		if(!is_type_in_typecache(I, can_hold))
			if(!stop_messages)
				to_chat(M, "<span class='warning'>[host] cannot hold [I]!</span>")
			return FALSE
	if(is_type_in_typecache(I, cant_hold))
		if(!stop_messages)
			to_chat(M, "<span class='warning'>[host] cannot hold [I]!</span>")
		return FALSE
	if(I.w_class > max_w_class)
		if(!stop_messages)
			to_chat(M, "<span class='warning'>[I] is too big for [host]!</span>")
		return FALSE
	var/sum_w_class = I.w_class
	for(var/obj/item/_I in real_location)
		sum_w_class += _I.w_class
	if(sum_w_class > max_combined_w_class)
		if(!stop_messages)
			to_chat(M, "<span class='warning'>[I] won't fit in [host], make some space!</span>")
		return FALSE
	if(isitem(host))
		var/obj/item/IP = host
		GET_COMPONENT_FROM(STR_I, /datum/component/storage, I)
		if((I.w_class >= IP.w_class) && STR_I && !allow_big_nesting)
			if(!stop_messages)
				to_chat(M, "<span class='warning'>[IP] cannot hold [I] as it's a storage item of the same size!</span>")
			return FALSE
	if(I.item_flags & NODROP)
		if(!stop_messages)
			to_chat(M, "<span class='warning'>\the [I] is stuck to your hand, you can't put it in \the [host]!</span>")
		return FALSE
	var/datum/component/storage/concrete/master = master()
	if(!istype(master))
		return FALSE
	return master.slave_can_insert_object(src, I, stop_messages, M)

/datum/component/storage/proc/_insert_physical_item(obj/item/I, override = FALSE)
	return FALSE

/datum/component/storage/proc/handle_item_insertion(obj/item/I, prevent_warning = FALSE, mob/M, datum/component/storage/remote)
	var/atom/parent = src.parent
	var/datum/component/storage/concrete/master = master()
	if(!istype(master))
		return FALSE
	if(silent)
		prevent_warning = TRUE
	if(M)
		parent.add_fingerprint(M)
	. = master.handle_item_insertion_from_slave(src, I, prevent_warning, M)

/datum/component/storage/proc/mob_item_insertion_feedback(mob/user, mob/M, obj/item/I, override = FALSE)
	if(silent && !override)
		return
	if(rustle_sound)
		playsound(parent, "rustle", 50, 1, -5)
	for(var/mob/viewing in viewers(user, null))
		if(M == viewing)
			to_chat(usr, "<span class='notice'>You put [I] [insert_preposition]to [parent].</span>")
		else if(in_range(M, viewing))
			viewing.show_message("<span class='notice'>[M] puts [I] [insert_preposition]to [parent].</span>", 1)
		else if(I && I.w_class >= 3)
			viewing.show_message("<span class='notice'>[M] puts [I] [insert_preposition]to [parent].</span>", 1)

/datum/component/storage/proc/update_icon()
	if(isobj(parent))
		var/obj/O = parent
		O.update_icon()

/datum/component/storage/proc/signal_insertion_attempt(datum/source, obj/item/I, mob/M, silent = FALSE, force = FALSE)
	if((!force && !can_be_inserted(I, TRUE, M)) || (I == parent))
		return FALSE
	return handle_item_insertion(I, silent, M)

/datum/component/storage/proc/signal_can_insert(datum/source, obj/item/I, mob/M, silent = FALSE)
	return can_be_inserted(I, silent, M)

/datum/component/storage/proc/on_attack_hand(datum/source, mob/user)
	var/atom/A = parent
	if(!attack_hand_interact)
		return
	if(user.active_storage == src && A.loc == user)
		user.active_storage.close(user)
		close(user)
		. = COMPONENT_NO_ATTACK_HAND
		return

	if(rustle_sound)
		playsound(A, "rustle", 50, 1, -5)

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.l_store == A && !H.get_active_held_item())
			. = COMPONENT_NO_ATTACK_HAND
			H.put_in_hands(A)
			H.l_store = null
			return
		if(H.r_store == A && !H.get_active_held_item())
			. = COMPONENT_NO_ATTACK_HAND
			H.put_in_hands(A)
			H.r_store = null
			return

	if(A.loc == user)
		. = COMPONENT_NO_ATTACK_HAND
		if(locked)
			to_chat(user, "<span class='warning'>[parent] seems to be locked!</span>")
		else
			show_to(user)