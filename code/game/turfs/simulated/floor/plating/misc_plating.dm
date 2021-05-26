/turf/open/floor/plating/airless
	icon_state = "plating"
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/plating/abductor
	name = "alien floor"
	icon_state = "alienpod1"
	tiled_dirt = FALSE

/turf/open/floor/plating/abductor/Initialize()
	. = ..()
	icon_state = "alienpod[rand(1,9)]"


/turf/open/floor/plating/abductor2
	name = "alien plating"
	icon_state = "alienplating"
	tiled_dirt = FALSE

/turf/open/floor/plating/abductor2/break_tile()
	return

/turf/open/floor/plating/abductor2/burn_tile()
	return

/turf/open/floor/plating/abductor2/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/plating/ashplanet
	icon = 'icons/turf/mining.dmi'
	gender = PLURAL
	name = "ash"
	icon_state = "ash"
	smooth = SMOOTH_MORE|SMOOTH_BORDER
	var/smooth_icon = 'icons/turf/floors/ash.dmi'
	desc = "The ground is covered in volcanic ash."
	baseturfs = /turf/open/floor/plating/ashplanet/wateryrock
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	attachment_holes = FALSE
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE

/turf/open/floor/plating/ashplanet/Initialize()
	if(smooth)
		var/matrix/M = new
		M.Translate(-4, -4)
		transform = M
		icon = smooth_icon
	. = ..()

/turf/open/floor/plating/ashplanet/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/plating/ashplanet/break_tile()
	return

/turf/open/floor/plating/ashplanet/burn_tile()
	return

/turf/open/floor/plating/ashplanet/ash
	canSmoothWith = list(/turf/open/floor/plating/ashplanet/ash, /turf/closed)
	layer = HIGH_TURF_LAYER
	slowdown = 1

/turf/open/floor/plating/ashplanet/rocky
	gender = PLURAL
	name = "rocky ground"
	icon_state = "rockyash"
	smooth_icon = 'icons/turf/floors/rocky_ash.dmi'
	layer = MID_TURF_LAYER
	canSmoothWith = list(/turf/open/floor/plating/ashplanet/rocky, /turf/closed)
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/plating/ashplanet/wateryrock
	gender = PLURAL
	name = "wet rocky ground"
	smooth = null
	icon_state = "wateryrock"
	slowdown = 2
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/plating/ashplanet/wateryrock/Initialize()
	icon_state = "[icon_state][rand(1, 9)]"
	. = ..()