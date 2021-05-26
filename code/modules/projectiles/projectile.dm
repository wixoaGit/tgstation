#define MOVES_HITSCAN -1
#define MUZZLE_EFFECT_PIXEL_INCREMENT 17

/obj/item/projectile
	name = "projectile"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "bullet"
	density = FALSE
	anchored = TRUE
	item_flags = ABSTRACT
	pass_flags = PASSTABLE
	//mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	movement_type = FLYING
	hitsound = 'sound/weapons/pierce.ogg'
	var/hitsound_wall = ""

	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/def_zone = ""
	var/atom/movable/firer = null
	var/suppressed = FALSE
	var/yo = null
	var/xo = null
	var/atom/original = null
	var/turf/starting = null
	var/list/permutated = list()
	var/p_x = 16
	var/p_y = 16

	var/fired = FALSE
	var/paused = FALSE
	var/last_projectile_move = 0
	var/last_process = 0
	var/time_offset = 0
	var/datum/point/vector/trajectory
	var/trajectory_ignore_forcemove = FALSE

	var/speed = 0.8
	var/Angle = 0
	var/original_angle = 0
	var/nondirectional_sprite = FALSE
	var/spread = 0
	//animate_movement = 0
	var/ricochets = 0
	var/ricochets_max = 2
	var/ricochet_chance = 30

	var/hitscan = FALSE
	var/list/beam_segments
	var/datum/point/beam_index
	var/turf/hitscan_last
	var/tracer_type
	var/muzzle_type
	var/impact_type

	var/hitscan_light_intensity = 1.5
	var/hitscan_light_range = 0.75
	var/hitscan_light_color_override
	var/muzzle_flash_intensity = 3
	var/muzzle_flash_range = 1.5
	var/muzzle_flash_color_override
	var/impact_light_intensity = 3
	var/impact_light_range = 2
	var/impact_light_color_override

	var/homing = FALSE
	var/atom/homing_target
	var/homing_turn_speed = 10
	var/homing_inaccuracy_min = 0
	var/homing_inaccuracy_max = 0
	var/homing_offset_x = 0
	var/homing_offset_y = 0

	var/ignore_source_check = FALSE

	var/damage = 10
	var/damage_type = BRUTE
	var/nodamage = 0
	var/flag = "bullet"
	var/projectile_type = /obj/item/projectile
	var/range = 50
	var/decayedRange
	var/reflect_range_decrease = 5
	var/reflectable = NONE

	var/stun = 0
	var/knockdown = 0
	var/paralyze = 0
	var/immobilize = 0
	var/unconscious = 0
	var/irradiate = 0
	var/stutter = 0
	var/slur = 0
	var/eyeblur = 0
	var/drowsy = 0
	var/stamina = 0
	var/jitter = 0
	var/dismemberment = 0
	var/impact_effect_type
	var/log_override = FALSE

	var/temporary_unstoppable_movement = FALSE

/obj/item/projectile/Initialize()
	. = ..()
	permutated = list()
	decayedRange = range

/obj/item/projectile/proc/Range()
	range--
	if(range <= 0 && loc)
		on_range()

/obj/item/projectile/proc/on_range()
	qdel(src)

/mob/living/proc/check_limb_hit(hit_zone)
	if(has_limbs)
		return hit_zone

/mob/living/carbon/check_limb_hit(hit_zone)
	if(get_bodypart(hit_zone))
		return hit_zone
	else
		return BODY_ZONE_CHEST

/obj/item/projectile/proc/prehit(atom/target)
	return TRUE

/obj/item/projectile/proc/on_hit(atom/target, blocked = FALSE)
	var/turf/target_loca = get_turf(target)

	var/hitx
	var/hity
	if(target == original)
		hitx = target.pixel_x + p_x - 16
		hity = target.pixel_y + p_y - 16
	else
		hitx = target.pixel_x + rand(-8, 8)
		hity = target.pixel_y + rand(-8, 8)

	if(!nodamage && (damage_type == BRUTE || damage_type == BURN) && iswallturf(target_loca) && prob(75))
		var/turf/closed/wall/W = target_loca
		if(impact_effect_type && !hitscan)
			new impact_effect_type(target_loca, hitx, hity)

		W.add_dent(WALL_DENT_SHOT, hitx, hity)

		return 0

	if(!isliving(target))
		if(impact_effect_type && !hitscan)
			new impact_effect_type(target_loca, hitx, hity)
		return 0

	var/mob/living/L = target

	if(blocked != 100)
		if(damage && L.blood_volume && damage_type == BRUTE)
			var/splatter_dir = dir
			if(starting)
				splatter_dir = get_dir(starting, target_loca)
			//if(isalien(L))
			if(FALSE)//not_actual
				//new /obj/effect/temp_visual/dir_setting/bloodsplatter/xenosplatter(target_loca, splatter_dir)
			else
				new /obj/effect/temp_visual/dir_setting/bloodsplatter(target_loca, splatter_dir)
			if(prob(33))
				L.add_splatter_floor(target_loca)
		else if(impact_effect_type && !hitscan)
			new impact_effect_type(target_loca, hitx, hity)

		var/organ_hit_text = ""
		var/limb_hit = L.check_limb_hit(def_zone)
		if(limb_hit)
			organ_hit_text = " in \the [parse_zone(limb_hit)]"
		if(suppressed)
			playsound(loc, hitsound, 5, 1, -1)
			to_chat(L, "<span class='userdanger'>You're shot by \a [src][organ_hit_text]!</span>")
		else
			if(hitsound)
				var/volume = vol_by_damage()
				playsound(loc, hitsound, volume, 1, -1)
			L.visible_message("<span class='danger'>[L] is hit by \a [src][organ_hit_text]!</span>", \
					"<span class='userdanger'>[L] is hit by \a [src][organ_hit_text]!</span>", null, COMBAT_MESSAGE_RANGE)
		L.on_hit(src)

	var/reagent_note
	if(reagents && reagents.reagent_list)
		reagent_note = " REAGENTS:"
		for(var/datum/reagent/R in reagents.reagent_list)
			reagent_note += R.id + " ("
			reagent_note += num2text(R.volume) + ") "

	//if(ismob(firer))
	//	log_combat(firer, L, "shot", src, reagent_note)
	//else
	//	L.log_message("has been shot by [firer] with [src]", LOG_ATTACK, color="orange")

	return L.apply_effects(stun, knockdown, unconscious, irradiate, slur, stutter, eyeblur, drowsy, blocked, stamina, jitter, paralyze, immobilize)

/obj/item/projectile/proc/vol_by_damage()
	if(src.damage)
		return CLAMP((src.damage) * 0.67, 30, 100)
	else
		return 50

/obj/item/projectile/proc/on_ricochet(atom/A)
	return

/obj/item/projectile/Bump(atom/A)
	var/datum/point/pcache = trajectory.copy_to()
	if(check_ricochet(A) && check_ricochet_flag(A) && ricochets < ricochets_max)
		ricochets++
		if(A.handle_ricochet(src))
			on_ricochet(A)
			ignore_source_check = TRUE
			decayedRange = max(0, decayedRange - reflect_range_decrease)
			range = decayedRange
			//if(hitscan)
			//	store_hitscan_collision(pcache)
			return TRUE
	if(firer && !ignore_source_check)
		var/mob/checking = firer
		if((A == firer) || (((A in firer.buckled_mobs) || (istype(checking) && (A == checking.buckled))) && (A != original)) || (A == firer.loc && ismecha(A)))
			trajectory_ignore_forcemove = TRUE
			forceMove(get_turf(A))
			trajectory_ignore_forcemove = FALSE
			return FALSE

	var/distance = get_dist(get_turf(A), starting)
	def_zone = ran_zone(def_zone, max(100-(7*distance), 5))

	if(isturf(A) && hitsound_wall)
		var/volume = CLAMP(vol_by_damage() + 20, 0, 100)
		if(suppressed)
			volume = 5
		playsound(loc, hitsound_wall, volume, 1, -1)

	if(!prehit(A))
		return FALSE

	var/permutation = A.bullet_act(src, def_zone)
	if(permutation == -1)
		if(!CHECK_BITFIELD(movement_type, UNSTOPPABLE))
			temporary_unstoppable_movement = TRUE
			ENABLE_BITFIELD(movement_type, UNSTOPPABLE)
		if(A)
			permutated.Add(A)
		return FALSE
	else
		var/atom/alt = select_target(A)
		if(alt)
			if(!prehit(alt))
				return FALSE
			alt.bullet_act(src, def_zone)
	if(!CHECK_BITFIELD(movement_type, UNSTOPPABLE))
		qdel(src)
	return TRUE

/obj/item/projectile/Move()
	. = ..()
	if(temporary_unstoppable_movement)
		DISABLE_BITFIELD(movement_type, UNSTOPPABLE)

/obj/item/projectile/proc/select_target(atom/A)
	if(!A || !A.density || (A.flags_1 & ON_BORDER_1) || ismob(A) || A == original)
		return
	var/turf/T = get_turf(A)
	if(original in T)
		return original
	var/list/mob/living/possible_mobs = typecache_filter_list(T, GLOB.typecache_mob) - A
	var/list/mob/mobs = list()
	for(var/mob/living/M in possible_mobs)
		if(!(M.mobility_flags & MOBILITY_STAND))
			continue
		mobs += M
	var/mob/M = safepick(mobs)
	if(M)
		return M.lowest_buckled_mob()
	var/obj/O = safepick(typecache_filter_list(T, GLOB.typecache_machine_or_structure) - A)
	if(O)
		return O

/obj/item/projectile/proc/check_ricochet()
	if(prob(ricochet_chance))
		return TRUE
	return FALSE

/obj/item/projectile/proc/check_ricochet_flag(atom/A)
	if(A.flags_1 & CHECK_RICOCHET_1)
		return TRUE
	return FALSE

/obj/item/projectile/Process_Spacemove(movement_dir = 0)
	return TRUE

/obj/item/projectile/process()
	last_process = world.time
	if(!loc || !fired || !trajectory)
		fired = FALSE
		return PROCESS_KILL
	if(paused || !isturf(loc))
		last_projectile_move += world.time - last_process
		return
	var/elapsed_time_deciseconds = (world.time - last_projectile_move) + time_offset
	time_offset = 0
	var/required_moves = speed > 0? FLOOR(elapsed_time_deciseconds / speed, 1) : MOVES_HITSCAN
	if(required_moves == MOVES_HITSCAN)
		required_moves = SSprojectiles.global_max_tick_moves
	else
		if(required_moves > SSprojectiles.global_max_tick_moves)
			var/overrun = required_moves - SSprojectiles.global_max_tick_moves
			required_moves = SSprojectiles.global_max_tick_moves
			time_offset += overrun * speed
		time_offset += MODULUS(elapsed_time_deciseconds, speed)

	for(var/i in 1 to required_moves)
		pixel_move(1, FALSE)

/obj/item/projectile/proc/fire(angle, atom/direct_target)
	//if(!log_override && firer && original)
	//	log_combat(firer, original, "fired at", src, "from [get_area_name(src, TRUE)]")
	if(direct_target)
		if(prehit(direct_target))
			direct_target.bullet_act(src, def_zone)
			qdel(src)
			return
	if(isnum(angle))
		setAngle(angle)
	if(spread)
		setAngle(Angle + ((rand() - 0.5) * spread))
	var/turf/starting = get_turf(src)
	if(isnull(Angle))
		if(isnull(xo) || isnull(yo))
			stack_trace("WARNING: Projectile [type] deleted due to being unable to resolve a target after angle was null!")
			qdel(src)
			return
		var/turf/target = locate(CLAMP(starting + xo, 1, world.maxx), CLAMP(starting + yo, 1, world.maxy), starting.z)
		setAngle(Get_Angle(src, target))
	original_angle = Angle
	if(!nondirectional_sprite)
		var/matrix/M = new
		M.Turn(Angle)
		transform = M
	trajectory_ignore_forcemove = TRUE
	forceMove(starting)
	trajectory_ignore_forcemove = FALSE
	//trajectory = new(starting.x, starting.y, starting.z, pixel_x, pixel_y, Angle, SSprojectiles.global_pixel_speed)
	trajectory = new /datum/point/vector(starting.x, starting.y, starting.z, pixel_x, pixel_y, Angle, SSprojectiles.global_pixel_speed)//not_actual
	last_projectile_move = world.time
	fired = TRUE
	//if(hitscan)
	//	process_hitscan()
	if(!(datum_flags & DF_ISPROCESSING))
		START_PROCESSING(SSprojectiles, src)
	pixel_move(1, FALSE)

/obj/item/projectile/proc/setAngle(new_angle)
	Angle = new_angle
	if(!nondirectional_sprite)
		var/matrix/M = new
		M.Turn(Angle)
		transform = M
	if(trajectory)
		trajectory.set_angle(new_angle)
	return TRUE

/obj/item/projectile/forceMove(atom/target)
	if(!isloc(target) || !isloc(loc) || !z)
		return ..()
	var/zc = target.z != z
	var/old = loc
	if(zc)
		before_z_change(old, target)
	. = ..()
	if(trajectory && !trajectory_ignore_forcemove && isturf(target))
		//if(hitscan)
		//	finalize_hitscan_and_generate_tracers(FALSE)
		trajectory.initialize_location(target.x, target.y, target.z, 0, 0)
		//if(hitscan)
		//	record_hitscan_start(RETURN_PRECISE_POINT(src))
	if(zc)
		after_z_change(old, target)

/obj/item/projectile/proc/after_z_change(atom/olcloc, atom/newloc)

/obj/item/projectile/proc/before_z_change(atom/oldloc, atom/newloc)

/obj/item/projectile/proc/set_pixel_speed(new_speed)
	if(trajectory)
		trajectory.set_speed(new_speed)
		return TRUE
	return FALSE

/obj/item/projectile/proc/pixel_move(trajectory_multiplier, hitscanning = FALSE)
	if(!loc || !trajectory)
		return
	last_projectile_move = world.time
	if(!nondirectional_sprite && !hitscanning)
		var/matrix/M = new
		M.Turn(Angle)
		transform = M
	//if(homing)
	//	process_homing()
	var/forcemoved = FALSE
	for(var/i in 1 to SSprojectiles.global_iterations_per_move)
		if(QDELETED(src))
			return
		trajectory.increment(trajectory_multiplier)
		var/turf/T = trajectory.return_turf()
		if(!istype(T))
			qdel(src)
			return
		if(T.z != loc.z)
			var/old = loc
			before_z_change(loc, T)
			trajectory_ignore_forcemove = TRUE
			forceMove(T)
			trajectory_ignore_forcemove = FALSE
			after_z_change(old, loc)
			if(!hitscanning)
				pixel_x = trajectory.return_px()
				pixel_y = trajectory.return_py()
			forcemoved = TRUE
			hitscan_last = loc
		else if(T != loc)
			step_towards(src, T)
			hitscan_last = loc
		if(can_hit_target(original, permutated))
			Bump(original)
	if(!hitscanning && !forcemoved)
		pixel_x = trajectory.return_px() - trajectory.mpx * trajectory_multiplier * SSprojectiles.global_iterations_per_move
		pixel_y = trajectory.return_py() - trajectory.mpy * trajectory_multiplier * SSprojectiles.global_iterations_per_move
		animate(src, pixel_x = trajectory.return_px(), pixel_y = trajectory.return_py(), time = 1, flags = ANIMATION_END_NOW)
	Range()

/obj/item/projectile/proc/can_hit_target(atom/target, var/list/passthrough)
	return (target && ((target.layer >= PROJECTILE_HIT_THRESHHOLD_LAYER) || ismob(target)) && (loc == get_turf(target)) && (!(target in passthrough)))

/obj/item/projectile/proc/preparePixelProjectile(atom/target, atom/source, params, spread = 0)
	var/turf/curloc = get_turf(source)
	var/turf/targloc = get_turf(target)
	trajectory_ignore_forcemove = TRUE
	forceMove(get_turf(source))
	trajectory_ignore_forcemove = FALSE
	starting = get_turf(source)
	original = target
	if(targloc || !params)
		yo = targloc.y - curloc.y
		xo = targloc.x - curloc.x
		setAngle(Get_Angle(src, targloc) + spread)

	if(isliving(source) && params)
		var/list/calculated = calculate_projectile_angle_and_pixel_offsets(source, params)
		p_x = calculated[2]
		p_y = calculated[3]

		setAngle(calculated[1] + spread)
	else if(targloc)
		yo = targloc.y - curloc.y
		xo = targloc.x - curloc.x
		setAngle(Get_Angle(src, targloc) + spread)
	else
		stack_trace("WARNING: Projectile [type] fired without either mouse parameters, or a target atom to aim at!")
		qdel(src)

/proc/calculate_projectile_angle_and_pixel_offsets(mob/user, params)
	var/list/mouse_control = params2list(params)
	var/p_x = 0
	var/p_y = 0
	var/angle = 0
	if(mouse_control["icon-x"])
		p_x = text2num(mouse_control["icon-x"])
	if(mouse_control["icon-y"])
		p_y = text2num(mouse_control["icon-y"])
	if(mouse_control["screen-loc"])
		var/list/screen_loc_params = splittext(mouse_control["screen-loc"], ",")

		var/list/screen_loc_X = splittext(screen_loc_params[1],":")

		var/list/screen_loc_Y = splittext(screen_loc_params[2],":")
		var/x = text2num(screen_loc_X[1]) * 32 + text2num(screen_loc_X[2]) - 32
		var/y = text2num(screen_loc_Y[1]) * 32 + text2num(screen_loc_Y[2]) - 32

		var/list/screenview = getviewsize(user.client.view)
		var/screenviewX = screenview[1] * world.icon_size
		var/screenviewY = screenview[2] * world.icon_size

		var/ox = round(screenviewX/2) - user.client.pixel_x
		var/oy = round(screenviewY/2) - user.client.pixel_y
		//angle = ATAN2(y - oy, x - ox)
		angle = ( !(y - oy) && !(x - ox) ? 0 : (x - ox) >= 0 ? arccos((y - oy) / sqrt((y - oy)*(y - oy) + (x - ox)*(x - ox))) : -arccos((y - oy) / sqrt((y - oy)*(y - oy) + (x - ox)*(x - ox))) )//not_actual
	return list(angle, p_x, p_y)

/obj/item/projectile/Destroy()
	//if(hitscan)
	//	finalize_hitscan_and_generate_tracers()
	STOP_PROCESSING(SSprojectiles, src)
	//cleanup_beam_segments()
	qdel(trajectory)
	return ..()