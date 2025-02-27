/datum/gas_mixture/immutable
	var/initial_temperature
	gc_share = TRUE

/datum/gas_mixture/immutable/New()
	..()
	garbage_collect()

/datum/gas_mixture/immutable/garbage_collect()
	temperature = initial_temperature
	temperature_archived = initial_temperature
	gases.Cut()

/datum/gas_mixture/immutable/archive()
	return 1

/datum/gas_mixture/immutable/merge()
	return 0

/datum/gas_mixture/immutable/share(datum/gas_mixture/sharer, atmos_adjacent_turfs = 4)
	. = ..(sharer, 0)
	garbage_collect()

/datum/gas_mixture/immutable/react()
	return 0

/datum/gas_mixture/immutable/copy()
	return new type 

/datum/gas_mixture/immutable/copy_from()
	return 0

/datum/gas_mixture/immutable/copy_from_turf()
	return 0

/datum/gas_mixture/immutable/parse_gas_string()
	return 0

/datum/gas_mixture/immutable/temperature_share(datum/gas_mixture/sharer, conduction_coefficient, sharer_temperature, sharer_heat_capacity)
	. = ..()
	temperature = initial_temperature

/datum/gas_mixture/immutable/space
	initial_temperature = TCMB

/datum/gas_mixture/immutable/space/heat_capacity()
	return HEAT_CAPACITY_VACUUM

/datum/gas_mixture/immutable/space/remove()
	return copy()

/datum/gas_mixture/immutable/space/remove_ratio()
	return copy()