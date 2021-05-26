/turf/open/floor/mech_bay_recharge_floor
	name = "mech bay recharge station"
	desc = "Parking a mech on this station will recharge its internal power cell."
	icon = 'icons/turf/floors.dmi'
	icon_state = "recharge_floor"

/turf/open/floor/mech_bay_recharge_floor/break_tile()
	ScrapeAway()

/turf/open/floor/mech_bay_recharge_floor/airless
	icon_state = "recharge_floor_asteroid"
	initial_gas_mix = AIRLESS_ATMOS