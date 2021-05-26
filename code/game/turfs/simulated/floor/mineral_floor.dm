/turf/open/floor/mineral
	name = "mineral floor"
	icon_state = ""
	var/list/icons
	tiled_dirt = FALSE


/turf/open/floor/mineral/Initialize()
	if(!broken_states)
		broken_states = list("[initial(icon_state)]_dam")
	. = ..()
	icons = typelist("icons", icons)


/turf/open/floor/mineral/update_icon()
	if(!..())
		return 0
	if(!broken && !burnt)
		if( !(icon_state in icons) )
			icon_state = initial(icon_state)

/turf/open/floor/mineral/titanium
	name = "shuttle floor"
	icon_state = "titanium"
	floor_tile = /obj/item/stack/tile/mineral/titanium
	broken_states = list("titanium_dam1","titanium_dam2","titanium_dam3","titanium_dam4","titanium_dam5")

/turf/open/floor/mineral/titanium/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/mineral/titanium/yellow
	icon_state = "titanium_yellow"

/turf/open/floor/mineral/titanium/yellow/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/mineral/titanium/blue
	icon_state = "titanium_blue"

/turf/open/floor/mineral/titanium/blue/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/mineral/titanium/white
	icon_state = "titanium_white"

/turf/open/floor/mineral/titanium/white/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/mineral/titanium/purple
	icon_state = "titanium_purple"

/turf/open/floor/mineral/titanium/purple/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/mineral/plastitanium
	name = "shuttle floor"
	icon_state = "plastitanium"
	floor_tile = /obj/item/stack/tile/mineral/plastitanium
	broken_states = list("plastitanium_dam1","plastitanium_dam2","plastitanium_dam3","plastitanium_dam4","plastitanium_dam5")

/turf/open/floor/mineral/plastitanium/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/mineral/plastitanium/red
	icon_state = "plastitanium_red"

/turf/open/floor/mineral/plastitanium/red/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/mineral/plastitanium/red/brig
	name = "brig floor"