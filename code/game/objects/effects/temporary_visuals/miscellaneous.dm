/obj/effect/temp_visual/dir_setting/bloodsplatter
	icon = 'icons/effects/blood.dmi'
	duration = 5
	randomdir = FALSE
	layer = BELOW_MOB_LAYER
	var/splatter_type = "splatter"

/obj/effect/temp_visual/dir_setting/bloodsplatter/Initialize(mapload, set_dir)
	if(set_dir in GLOB.diagonals)
		icon_state = "[splatter_type][pick(1, 2, 6)]"
	else
		icon_state = "[splatter_type][pick(3, 4, 5)]"
	. = ..()
	var/target_pixel_x = 0
	var/target_pixel_y = 0
	switch(set_dir)
		if(NORTH)
			target_pixel_y = 16
		if(SOUTH)
			target_pixel_y = -16
			layer = ABOVE_MOB_LAYER
		if(EAST)
			target_pixel_x = 16
		if(WEST)
			target_pixel_x = -16
		if(NORTHEAST)
			target_pixel_x = 16
			target_pixel_y = 16
		if(NORTHWEST)
			target_pixel_x = -16
			target_pixel_y = 16
		if(SOUTHEAST)
			target_pixel_x = 16
			target_pixel_y = -16
			layer = ABOVE_MOB_LAYER
		if(SOUTHWEST)
			target_pixel_x = -16
			target_pixel_y = -16
			layer = ABOVE_MOB_LAYER
	animate(src, pixel_x = target_pixel_x, pixel_y = target_pixel_y, alpha = 0, time = duration)

/obj/effect/temp_visual/dir_setting/firing_effect
	icon = 'icons/effects/effects.dmi'
	icon_state = "firing_effect"
	duration = 2

/obj/effect/temp_visual/dir_setting/firing_effect/setDir(newdir)
	switch(newdir)
		if(NORTH)
			layer = BELOW_MOB_LAYER
			pixel_x = rand(-3,3)
			pixel_y = rand(4,6)
		if(SOUTH)
			pixel_x = rand(-3,3)
			pixel_y = rand(-1,1)
		else
			pixel_x = rand(-1,1)
			pixel_y = rand(-1,1)
	..()

/obj/effect/temp_visual/dir_setting/firing_effect/energy
	icon_state = "firing_effect_energy"
	duration = 3

/obj/effect/temp_visual/dir_setting/firing_effect/magic
	icon_state = "shieldsparkles"
	duration = 3

/obj/effect/temp_visual/impact_effect
	icon_state = "impact_bullet"
	duration = 5

/obj/effect/temp_visual/impact_effect/Initialize(mapload, x, y)
	pixel_x = x
	pixel_y = y
	return ..()

/obj/effect/temp_visual/impact_effect/red_laser
	icon_state = "impact_laser"
	duration = 4

/obj/effect/temp_visual/impact_effect/red_laser/wall
	icon_state = "impact_laser_wall"
	duration = 10

/obj/effect/temp_visual/impact_effect/blue_laser
	icon_state = "impact_laser_blue"
	duration = 4

/obj/effect/temp_visual/heart
	name = "heart"
	icon = 'icons/mob/animal.dmi'
	icon_state = "heart"
	duration = 25

/obj/effect/temp_visual/heart/Initialize(mapload)
	. = ..()
	pixel_x = rand(-4,4)
	pixel_y = rand(-4,4)
	animate(src, pixel_y = pixel_y + 32, alpha = 0, time = 25)