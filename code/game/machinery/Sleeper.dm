/obj/machinery/sleeper
	name = "sleeper"
	desc = "An enclosed machine used to stabilize and heal patients."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	density = FALSE
	state_open = TRUE
	circuit = /obj/item/circuitboard/machine/sleeper
	var/efficiency = 1
	var/min_health = -25
	var/list/available_chems
	var/controls_inside = FALSE
	var/list/possible_chems = list(
		list("epinephrine", "morphine", "salbutamol", "bicaridine", "kelotane"),
		list("oculine","inacusiate"),
		list("antitoxin", "mutadone", "mannitol", "pen_acid"),
		list("omnizine")
	)
	var/list/chem_buttons
	var/scrambled_chems = FALSE
	var/enter_message = "<span class='notice'><b>You feel cool air surround you. You go numb as your senses turn inward.</b></span>"
	payment_department = ACCOUNT_MED
	fair_market_price = 5

/obj/machinery/sleeper/syndie
	icon_state = "sleeper_s"
	controls_inside = TRUE

/obj/machinery/sleeper/syndie/fullupgrade/Initialize()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/machine/sleeper(null)
	//component_parts += new /obj/item/stock_parts/matter_bin/bluespace(null)
	//component_parts += new /obj/item/stock_parts/manipulator/femto(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null)
	RefreshParts()