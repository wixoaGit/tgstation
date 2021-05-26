/obj/structure/closet
	name = "closet"
	desc = "It's a basic storage unit."
	icon = 'icons/obj/closet.dmi'
	icon_state = "generic"
	density = TRUE
	layer = BELOW_OBJ_LAYER
	var/icon_door = null
	var/icon_door_override = 0
	var/secure = FALSE
	var/opened = FALSE
	var/welded = FALSE
	var/locked = FALSE
	var/wall_mounted = 0
	max_integrity = 200
	integrity_failure = 50
	var/breakout_time = 1200
	var/message_cooldown
	var/horizontal = FALSE
	var/allow_dense = FALSE
	var/dense_when_open = FALSE
	var/max_mob_size = MOB_SIZE_HUMAN
	var/mob_storage_capacity = 3
	var/storage_capacity = 30
	var/open_sound = 'sound/machines/click.ogg'
	var/close_sound = 'sound/machines/click.ogg'
	var/material_drop = /obj/item/stack/sheet/metal
	var/material_drop_amount = 2
	var/icon_welded = "welded"

/obj/structure/closet/Initialize(mapload)
	if(mapload && !opened)
		addtimer(CALLBACK(src, .proc/take_contents), 0)
	. = ..()
	update_icon()
	PopulateContents()

/obj/structure/closet/proc/PopulateContents()
	return

/obj/structure/closet/Destroy()
	dump_contents()
	return ..()

/obj/structure/closet/update_icon()
	cut_overlays()
	if(opened == FALSE)
		layer = OBJ_LAYER
		if(icon_door)
			add_overlay("[icon_door]_door")
		else
			add_overlay("[icon_state]_door")
		if(welded)
			add_overlay(icon_welded)
		if(secure && !broken)
			if(locked)
				add_overlay("locked")
			else
				add_overlay("unlocked")
	else
		layer = BELOW_OBJ_LAYER
		if(icon_door_override)
			add_overlay("[icon_door]_open")
		else
			add_overlay("[icon_state]_open")

/obj/structure/closet/examine(mob/user)
	..()
	if(welded)
		to_chat(user, "<span class='notice'>It's welded shut.</span>")
	if(anchored)
		to_chat(user, "<span class='notice'>It is <b>bolted</b> to the ground.</span>")
	if(opened)
		to_chat(user, "<span class='notice'>The parts are <b>welded</b> together.</span>")
	else if(secure && !opened)
		to_chat(user, "<span class='notice'>Alt-click to [locked ? "unlock" : "lock"].</span>")
	if(isliving(user))
		var/mob/living/L = user
		if(L.has_trait(TRAIT_SKITTISH))
			to_chat(user, "<span class='notice'>Ctrl-Shift-click [src] to jump inside.</span>")

/obj/structure/closet/CanPass(atom/movable/mover, turf/target)
	if(wall_mounted)
		return TRUE
	return !density

/obj/structure/closet/proc/can_open(mob/living/user)
	if(welded || locked)
		return FALSE
	var/turf/T = get_turf(src)
	for(var/mob/living/L in T)
		if(L.anchored || horizontal && L.mob_size > MOB_SIZE_TINY && L.density)
			if(user)
				to_chat(user, "<span class='danger'>There's something large on top of [src], preventing it from opening.</span>" )
			return FALSE
	return TRUE

/obj/structure/closet/proc/can_close(mob/living/user)
	var/turf/T = get_turf(src)
	for(var/obj/structure/closet/closet in T)
		if(closet != src && !closet.wall_mounted)
			return FALSE
	for(var/mob/living/L in T)
		if(L.anchored || horizontal && L.mob_size > MOB_SIZE_TINY && L.density)
			if(user)
				to_chat(user, "<span class='danger'>There's something too large in [src], preventing it from closing.</span>")
			return FALSE
	return TRUE

/obj/structure/closet/proc/dump_contents()
	var/atom/L = get_turf(src)
	for(var/atom/movable/AM in src)
		AM.forceMove(L)
		if(throwing)
			step(AM, dir)
	if(throwing)
		throwing.finalize(FALSE)

/obj/structure/closet/proc/take_contents()
	var/atom/L = drop_location()
	for(var/atom/movable/AM in L)
		if(AM != src && insert(AM) == -1)
			break

/obj/structure/closet/proc/open(mob/living/user)
	if(opened || !can_open(user))
		return
	playsound(loc, open_sound, 15, 1, -3)
	opened = TRUE
	density = FALSE
	if(!dense_when_open)
		density = FALSE
	climb_time *= 0.5
	dump_contents()
	update_icon()
	return 1

/obj/structure/closet/proc/insert(atom/movable/AM)
	if(contents.len >= storage_capacity)
		return -1

	if(ismob(AM))
		if(!isliving(AM))
			return
		var/mob/living/L = AM
		if(L.anchored || L.buckled || L.incorporeal_move || L.has_buckled_mobs())
			return
		if(L.mob_size > MOB_SIZE_TINY)
			if(horizontal && L.density)
				return
			if(L.mob_size > max_mob_size)
				return
			var/mobs_stored = 0
			for(var/mob/living/M in contents)
				if(++mobs_stored >= mob_storage_capacity)
					return
		L.stop_pulling()
	else if(istype(AM, /obj/structure/closet))
		return
	else if(isobj(AM))
		if (istype(AM, /obj/item))
			var/obj/item/I = AM
			if (I.item_flags & NODROP)
				return
		//else if(!allow_objects && !istype(AM, /obj/effect/dummy/chameleon))
		//	return
		if(!allow_dense && AM.density)
			return
		if(AM.anchored || AM.has_buckled_mobs())
			return
	else
		return

	AM.forceMove(src)

	return 1

/obj/structure/closet/proc/close(mob/living/user)
	if(!opened || !can_close(user))
		return FALSE
	take_contents()
	playsound(loc, close_sound, 15, 1, -3)
	opened = FALSE
	density = TRUE
	update_icon()
	return 1

/obj/structure/closet/proc/toggle(/mob/living/user, silent)
	if (opened)
		return close()
	else
		return open()

/obj/structure/closet/deconstruct(disassembled = TRUE)
	if(ispath(material_drop) && material_drop_amount && !(flags_1 & NODECONSTRUCT_1))
		new material_drop(loc, material_drop_amount)
	qdel(src)

/obj/structure/closet/obj_break(damage_flag)
	if(!broken && !(flags_1 & NODECONSTRUCT_1))
		bust_open()

/obj/structure/closet/attackby(obj/item/W, mob/user, params)
	if(user in src)
		return
	if(src.tool_interact(W,user))
		return 1
	else
		return ..()

/obj/structure/closet/proc/tool_interact(obj/item/W, mob/user)
	. = TRUE
	if (opened)
		if(user.transferItemToLoc(W, drop_location()))
			return
	else
		toggle(user)

/obj/structure/closet/relaymove(mob/user)
	if(user.stat || !isturf(loc) || !isliving(user))
		return
	if(locked)
		if(message_cooldown <= world.time)
			message_cooldown = world.time + 50
			to_chat(user, "<span class='warning'>[src]'s door won't budge!</span>")
		return
	container_resist(user)

/obj/structure/closet/attack_hand(mob/living/user)
	. = ..()
	if (.)
		return
	if(!(user.mobility_flags & MOBILITY_STAND) && get_dist(src, user) > 0)
		return
	
	if(!toggle(user))
		togglelock(user)

/obj/structure/closet/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/closet/attack_robot(mob/user)
	if(user.Adjacent(src))
		return attack_hand(user)

/obj/structure/closet/Exit(atom/movable/AM)
	open()
	if(AM.loc == src)
		return 0
	return 1

/obj/structure/closet/container_resist(mob/living/user)
	if(opened)
		return
	if(ismovableatom(loc))
		user.changeNext_move(CLICK_CD_BREAKOUT)
		user.last_special = world.time + CLICK_CD_BREAKOUT
		var/atom/movable/AM = loc
		AM.relay_container_resist(user, src)
		return
	if(!welded && !locked)
		open()
		return

	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user.visible_message("<span class='warning'>[src] begins to shake violently!</span>", \
		"<span class='notice'>You lean on the back of [src] and start pushing the door open... (this will take about [DisplayTimeText(breakout_time)].)</span>", \
		"<span class='italics'>You hear banging from [src].</span>")
	if(do_after(user,(breakout_time), target = src))
		if(!user || user.stat != CONSCIOUS || user.loc != src || opened || (!locked && !welded) )
			return
		user.visible_message("<span class='danger'>[user] successfully broke out of [src]!</span>",
							"<span class='notice'>You successfully break out of [src]!</span>")
		bust_open()
	else
		if(user.loc == src)
			to_chat(user, "<span class='warning'>You fail to break out of [src]!</span>")

/obj/structure/closet/proc/bust_open()
	welded = FALSE
	locked = FALSE
	broken = TRUE
	open()

/obj/structure/closet/AltClick(mob/user)
	..()
	if(!user.canUseTopic(src, BE_CLOSE) || !isturf(loc))
		return
	if(opened || !secure)
		return
	else
		togglelock(user)

/obj/structure/closet/proc/togglelock(mob/living/user, silent)
	if(secure && !broken)
		if(allowed(user))
			if(iscarbon(user))
				add_fingerprint(user)
			locked = !locked
			user.visible_message("<span class='notice'>[user] [locked ? null : "un"]locks [src].</span>",
							"<span class='notice'>You [locked ? null : "un"]lock [src].</span>")
			update_icon()
		else if(!silent)
			to_chat(user, "<span class='notice'>Access Denied</span>")
	else if(secure && broken)
		to_chat(user, "<span class='warning'>\The [src] is broken!</span>")

/obj/structure/closet/emag_act(mob/user)
	if(secure && !broken)
		user.visible_message("<span class='warning'>Sparks fly from [src]!</span>",
						"<span class='warning'>You scramble [src]'s lock, breaking it open!</span>",
						"<span class='italics'>You hear a faint electrical spark.</span>")
		playsound(src, "sparks", 50, 1)
		broken = TRUE
		locked = FALSE
		update_icon()

/obj/structure/closet/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if (!(. & EMP_PROTECT_CONTENTS))
		for(var/obj/O in src)
			O.emp_act(severity)
	if(secure && !broken && !(. & EMP_PROTECT_SELF))
		if(prob(50 / severity))
			locked = !locked
			update_icon()
		if(prob(20 / severity) && !opened)
			if(!locked)
				open()
			else
				req_access = list()
				req_access += pick(get_all_accesses())

/obj/structure/closet/contents_explosion(severity, target)
	for(var/atom/A in contents)
		A.ex_act(severity, target)
		CHECK_TICK

/obj/structure/closet/AllowDrop()
	return TRUE