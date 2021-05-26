/obj/machinery/power/rtg
	name = "radioisotope thermoelectric generator"
	desc = "A simple nuclear power generator, used in small outposts to reliably provide power for decades."
	icon = 'icons/obj/power.dmi'
	icon_state = "rtg"
	density = TRUE
	use_power = NO_POWER_USE
	//circuit = /obj/item/circuitboard/machine/rtg

	can_buckle = TRUE
	buckle_lying = FALSE
	buckle_requires_restraints = TRUE

	var/power_gen = 1000

	var/irradiate = TRUE

/obj/machinery/power/rtg/Initialize()
	. = ..()
	connect_to_network()

/obj/machinery/power/rtg/process()
	..()
	add_avail(power_gen)
	//if(panel_open && irradiate)
	//	radiation_pulse(src, 60)

/obj/machinery/power/rtg/RefreshParts()
	var/part_level = 0
	for(var/obj/item/stock_parts/SP in component_parts)
		part_level += SP.rating

	power_gen = initial(power_gen) * part_level

/obj/machinery/power/rtg/examine(mob/user)
	..()
	if(in_range(user, src) || isobserver(user))
		to_chat(user, "<span class='notice'>The status display reads: Power generation now at <b>[power_gen*0.001]</b>kW.<span>")

/obj/machinery/power/rtg/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-open", initial(icon_state), I))
		return
	else if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/power/rtg/advanced
	desc = "An advanced RTG capable of moderating isotope decay, increasing power output but reducing lifetime. It uses plasma-fueled radiation collectors to increase output even further."
	power_gen = 1250
	//circuit = /obj/item/circuitboard/machine/rtg/advanced