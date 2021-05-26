#define EXPLOSION_THROW_SPEED 4

GLOBAL_LIST_EMPTY(explosions)

/proc/explosion(atom/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, adminlog = TRUE, ignorecap = FALSE, flame_range = 0, silent = FALSE, smoke = FALSE)
	return new /datum/explosion(epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, adminlog, ignorecap, flame_range, silent, smoke)

/datum/explosion
	var/explosion_id
	var/atom/explosion_source
	var/started_at
	var/running = TRUE
	var/stopped = 0
	var/static/id_counter = 0

#define EX_PREPROCESS_EXIT_CHECK \
	if(!running) {\
		stopped = 2;\
		qdel(src);\
		return;\
	}

#define EX_PREPROCESS_CHECK_TICK \
	if(TICK_CHECK) {\
		stoplag();\
		EX_PREPROCESS_EXIT_CHECK\
	}

/datum/explosion/New(atom/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, adminlog, ignorecap, flame_range, silent, smoke)
	set waitfor = FALSE

	var/id = ++id_counter
	explosion_id = id
	explosion_source = epicenter

	epicenter = get_turf(epicenter)
	if(!epicenter)
		return

	GLOB.explosions += src
	if(isnull(flame_range))
		flame_range = light_impact_range
	if(isnull(flash_range))
		flash_range = devastation_range

	var/orig_dev_range = devastation_range
	var/orig_heavy_range = heavy_impact_range
	var/orig_light_range = light_impact_range

	var/orig_max_distance = max(devastation_range, heavy_impact_range, light_impact_range, flash_range, flame_range)

	//var/cap_multiplier = SSmapping.level_trait(epicenter.z, ZTRAIT_BOMBCAP_MULTIPLIER)
	var/cap_multiplier = null//not_actual
	if (isnull(cap_multiplier))
		cap_multiplier = 1

	if(!ignorecap)
		devastation_range = min(GLOB.MAX_EX_DEVESTATION_RANGE * cap_multiplier, devastation_range)
		heavy_impact_range = min(GLOB.MAX_EX_HEAVY_RANGE * cap_multiplier, heavy_impact_range)
		light_impact_range = min(GLOB.MAX_EX_LIGHT_RANGE * cap_multiplier, light_impact_range)
		flash_range = min(GLOB.MAX_EX_FLASH_RANGE * cap_multiplier, flash_range)
		flame_range = min(GLOB.MAX_EX_FLAME_RANGE * cap_multiplier, flame_range)

	stoplag()

	EX_PREPROCESS_EXIT_CHECK

	started_at = REALTIMEOFDAY

	var/max_range = max(devastation_range, heavy_impact_range, light_impact_range, flame_range)

	if(adminlog)
		//message_admins("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range], [flame_range]) in [ADMIN_VERBOSEJMP(epicenter)]")
		log_game("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range], [flame_range]) in [loc_name(epicenter)]")

	var/x0 = epicenter.x
	var/y0 = epicenter.y
	var/z0 = epicenter.z
	var/area/areatype = get_area(epicenter)
	//SSblackbox.record_feedback("associative", "explosion", 1, list("dev" = devastation_range, "heavy" = heavy_impact_range, "light" = light_impact_range, "flash" = flash_range, "flame" = flame_range, "orig_dev" = orig_dev_range, "orig_heavy" = orig_heavy_range, "orig_light" = orig_light_range, "x" = x0, "y" = y0, "z" = z0, "area" = areatype.type, "time" = time_stamp("YYYY-MM-DD hh:mm:ss", 1)))

	var/far_dist = 0
	far_dist += heavy_impact_range * 5
	far_dist += devastation_range * 20

	if(!silent)
		var/frequency = get_rand_frequency()
		var/sound/explosion_sound = sound(get_sfx("explosion"))
		var/sound/far_explosion_sound = sound('sound/effects/explosionfar.ogg')

		for(var/mob/M in GLOB.player_list)
			var/turf/M_turf = get_turf(M)
			if(M_turf && M_turf.z == z0)
				var/dist = get_dist(M_turf, epicenter)
				var/baseshakeamount
				if(orig_max_distance - dist > 0)
					baseshakeamount = sqrt((orig_max_distance - dist)*0.1)
				//if(dist <= round(max_range + world.view - 2, 1))
				if(dist <= round(max_range + 15 - 2, 1))//not_actual
					M.playsound_local(epicenter, null, 100, 1, frequency, falloff = 5, S = explosion_sound)
					if(baseshakeamount > 0)
						shake_camera(M, 25, CLAMP(baseshakeamount, 0, 10))
				else if(dist <= far_dist)
					var/far_volume = CLAMP(far_dist, 30, 50)
					far_volume += (dist <= far_dist * 0.5 ? 50 : 0)
					M.playsound_local(epicenter, null, far_volume, 1, frequency, falloff = 5, S = far_explosion_sound)
					if(baseshakeamount > 0)
						shake_camera(M, 10, CLAMP(baseshakeamount*0.25, 0, 2.5))
			EX_PREPROCESS_CHECK_TICK

	var/postponeCycles = max(round(devastation_range/8),1)
	//SSlighting.postpone(postponeCycles)
	//SSmachines.postpone(postponeCycles)

	if(heavy_impact_range > 1)
		var/datum/effect_system/explosion/E
		if(smoke)
			E = new /datum/effect_system/explosion/smoke
		else
			E = new
		E.set_up(epicenter)
		E.start()

	EX_PREPROCESS_CHECK_TICK

	//if(flash_range)
	//	for(var/mob/living/L in viewers(flash_range, epicenter))
	//		L.flash_act()

	EX_PREPROCESS_CHECK_TICK

	var/list/exploded_this_tick = list()
	var/list/affected_turfs = GatherSpiralTurfs(max_range, epicenter)

	//var/reactionary = CONFIG_GET(flag/reactionary_explosions)
	var/reactionary = FALSE//not_actual
	//var/list/cached_exp_block
	var/list/cached_exp_block = list()//not_actual

	//if(reactionary)
	//	cached_exp_block = CaculateExplosionBlock(affected_turfs)

	var/iteration = 0
	var/affTurfLen = affected_turfs.len
	var/expBlockLen = cached_exp_block.len
	for(var/TI in affected_turfs)
		var/turf/T = TI
		++iteration
		var/init_dist = cheap_hypotenuse(T.x, T.y, x0, y0)
		var/dist = init_dist

		if(reactionary)
			var/turf/Trajectory = T
			while(Trajectory != epicenter)
				Trajectory = get_step_towards(Trajectory, epicenter)
				dist += cached_exp_block[Trajectory]

		var/flame_dist = dist < flame_range
		var/throw_dist = dist

		if(dist < devastation_range)
			dist = EXPLODE_DEVASTATE
		else if(dist < heavy_impact_range)
			dist = EXPLODE_HEAVY
		else if(dist < light_impact_range)
			dist = EXPLODE_LIGHT
		else
			dist = EXPLODE_NONE

		if(T == epicenter)
			var/list/items = list()
			for(var/I in T)
				var/atom/A = I
				if (!A.prevent_content_explosion())
					items += A.GetAllContents()
			for(var/O in items)
				var/atom/A = O
				if(!QDELETED(A))
					A.ex_act(dist)

		if(flame_dist && prob(40) && !isspaceturf(T) && !T.density)
			new /obj/effect/hotspot(T)

		if(dist > EXPLODE_NONE)
			T.explosion_level = max(T.explosion_level, dist)
			T.explosion_id = id
			T.ex_act(dist)
			exploded_this_tick += T

		var/throw_dir = get_dir(epicenter,T)
		for(var/obj/item/I in T)
			if(!I.anchored)
				var/throw_range = rand(throw_dist, max_range)
				var/turf/throw_at = get_ranged_target_turf(I, throw_dir, throw_range)
				I.throw_speed = EXPLOSION_THROW_SPEED
				I.throw_at(throw_at, throw_range, EXPLOSION_THROW_SPEED)

		var/break_condition
		if(reactionary)
			break_condition = iteration == expBlockLen && iteration < affTurfLen
		else
			break_condition = iteration == affTurfLen && !stopped

		if(break_condition || TICK_CHECK)
			stoplag()

			if(!running)
				break

			affTurfLen = affected_turfs.len
			expBlockLen = cached_exp_block.len

			if(break_condition)
				if(reactionary)
					UNTIL(iteration < affTurfLen || !running)
				else
					UNTIL(iteration < expBlockLen || stopped)

				if(!running)
					break

				affTurfLen = affected_turfs.len
				expBlockLen = cached_exp_block.len

			var/circumference = (PI * (init_dist + 4) * 2)
			if(exploded_this_tick.len > circumference)
				for(var/Unexplode in exploded_this_tick)
					var/turf/UnexplodeT = Unexplode
					UnexplodeT.explosion_level = 0
				exploded_this_tick.Cut()

	for(var/Unexplode in exploded_this_tick)
		var/turf/UnexplodeT = Unexplode
		UnexplodeT.explosion_level = 0
	exploded_this_tick.Cut()

	var/took = (REALTIMEOFDAY - started_at) / 10

	//if(GLOB.Debug2)
	//	log_world("## DEBUG: Explosion([x0],[y0],[z0])(d[devastation_range],h[heavy_impact_range],l[light_impact_range]): Took [took] seconds.")

	//if(running)
	//	for(var/array in GLOB.doppler_arrays)
	//		var/obj/machinery/doppler_array/A = array
	//		A.sense_explosion(epicenter, devastation_range, heavy_impact_range, light_impact_range, took,orig_dev_range, orig_heavy_range, orig_light_range)

	++stopped
	qdel(src)

#undef EX_PREPROCESS_EXIT_CHECK
#undef EX_PREPROCESS_CHECK_TICK

/datum/explosion/proc/GatherSpiralTurfs(range, turf/epicenter)
	set waitfor = FALSE
	. = list()
	spiral_range_turfs(range, epicenter, outlist = ., tick_checked = TRUE)
	++stopped

/datum/explosion/proc/CaculateExplosionBlock(list/affected_turfs)
	set waitfor = FALSE

	. = list()
	var/processed = 0
	while(running)
		var/I
		for(I in (processed + 1) to affected_turfs.len)
			var/turf/T = affected_turfs[I]
			var/current_exp_block = T.density ? T.explosion_block : 0

			for(var/obj/O in T)
				var/the_block = O.explosion_block
				current_exp_block += the_block == EXPLOSION_BLOCK_PROC ? O.GetExplosionBlock() : the_block

			.[T] = current_exp_block

			if(TICK_CHECK)
				break

		processed = I
		stoplag()

/datum/explosion/Destroy()
	running = FALSE
	if(stopped < 2)
		return QDEL_HINT_IWILLGC
	GLOB.explosions -= src
	explosion_source = null
	return ..()

/proc/dyn_explosion(turf/epicenter, power, flash_range, adminlog = TRUE, ignorecap = TRUE, flame_range = 0, silent = FALSE, smoke = TRUE)
	if(!power)
		return
	var/range = 0
	range = round((2 * power)**GLOB.DYN_EX_SCALE)
	explosion(epicenter, round(range * 0.25), round(range * 0.5), round(range), flash_range*range, adminlog, ignorecap, flame_range*range, silent, smoke)