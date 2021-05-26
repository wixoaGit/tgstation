/obj/machinery/mecha_part_fabricator
	icon = 'icons/obj/robotics.dmi'
	icon_state = "fab-idle"
	name = "exosuit fabricator"
	desc = "Nothing is being built."
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	active_power_usage = 5000
	req_access = list(ACCESS_ROBOTICS)
	circuit = /obj/item/circuitboard/machine/mechfab
	var/time_coeff = 1
	var/component_coeff = 1
	//var/datum/techweb/specialized/autounlocking/exofab/stored_research
	var/sync = 0
	var/part_set
	var/datum/design/being_built
	var/list/queue = list()
	var/processing_queue = 0
	var/screen = "main"
	var/temp
	var/list/part_sets = list(
								"Cyborg",
								"Ripley",
								"Firefighter",
								"Odysseus",
								"Gygax",
								"Durand",
								"H.O.N.K",
								"Phazon",
								"Exosuit Equipment",
								"Cyborg Upgrade Modules",
								"Misc"
								)