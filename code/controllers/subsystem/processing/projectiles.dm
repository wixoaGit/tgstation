PROCESSING_SUBSYSTEM_DEF(projectiles)
	name = "Projectiles"
	wait = 1
	stat_tag = "PP"
	flags = SS_NO_INIT|SS_TICKER
	var/global_max_tick_moves = 10
	var/global_pixel_speed = 2
	var/global_iterations_per_move = 16

/datum/controller/subsystem/processing/projectiles/proc/set_pixel_speed(new_speed)
	global_pixel_speed = new_speed
	for(var/i in processing)
		var/obj/item/projectile/P = i
		if(istype(P))
			P.set_pixel_speed(new_speed)