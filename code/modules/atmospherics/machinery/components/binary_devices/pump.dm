/obj/machinery/atmospherics/components/binary/pump
	icon_state = "pump_map-2"
	name = "gas pump"
	desc = "A pump that moves gas by pressure."

	can_unwrench = TRUE
	shift_underlay_only = FALSE

	var/target_pressure = ONE_ATMOSPHERE

	var/frequency = 0
	var/id = null
	//var/datum/radio_frequency/radio_connection

	//construction_type = /obj/item/pipe/directional
	pipe_state = "pump"

/obj/machinery/atmospherics/components/binary/pump/Destroy()
	//SSradio.remove_object(src,frequency)
	//if(radio_connection)
	//	radio_connection = null
	return ..()

/obj/machinery/atmospherics/components/binary/pump/update_icon_nopipes()
	icon_state = (on && is_operational()) ? "pump_on" : "pump_off"

/obj/machinery/atmospherics/components/binary/pump/process_atmos()
	if(!on || !is_operational())
		return

	var/datum/gas_mixture/air1 = airs[1]
	var/datum/gas_mixture/air2 = airs[2]

	var/output_starting_pressure = air2.return_pressure()

	if((target_pressure - output_starting_pressure) < 0.01)
		return

	if((air1.total_moles() > 0) && (air1.temperature>0))
		var/pressure_delta = target_pressure - output_starting_pressure
		var/transfer_moles = pressure_delta*air2.volume/(air1.temperature * R_IDEAL_GAS_EQUATION)

		var/datum/gas_mixture/removed = air1.remove(transfer_moles)
		air2.merge(removed)

		update_parents()

/obj/machinery/atmospherics/components/binary/pump/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
																datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "atmos_pump", name, 335, 115, master_ui, state)
		ui.open()

/obj/machinery/atmospherics/components/binary/pump/ui_data()
	var/data = list()
	data["on"] = on
	data["pressure"] = round(target_pressure)
	data["max_pressure"] = round(MAX_OUTPUT_PRESSURE)
	return data

/obj/machinery/atmospherics/components/binary/pump/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("power")
			on = !on
			//investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE
		if("pressure")
			var/pressure = params["pressure"]
			if(pressure == "max")
				pressure = MAX_OUTPUT_PRESSURE
				. = TRUE
			else if(pressure == "input")
				pressure = input("New output pressure (0-[MAX_OUTPUT_PRESSURE] kPa):", name, target_pressure) as num|null
				if(!isnull(pressure) && !..())
					. = TRUE
			else if(text2num(pressure) != null)
				pressure = text2num(pressure)
				. = TRUE
			if(.)
				target_pressure = CLAMP(pressure, 0, MAX_OUTPUT_PRESSURE)
				//investigate_log("was set to [target_pressure] kPa by [key_name(usr)]", INVESTIGATE_ATMOS)
	update_icon()

/obj/machinery/atmospherics/components/binary/pump/atmosinit()
	..()
	//if(frequency)
	//	set_frequency(frequency)

/obj/machinery/atmospherics/components/binary/pump/layer1
	piping_layer = 1
	icon_state= "pump_map-1"

/obj/machinery/atmospherics/components/binary/pump/layer3
	piping_layer = 3
	icon_state= "pump_map-3"

/obj/machinery/atmospherics/components/binary/pump/on
	on = TRUE
	icon_state = "pump_on_map-2"

/obj/machinery/atmospherics/components/binary/pump/on/layer1
	piping_layer = 1
	icon_state= "pump_on_map-1"

/obj/machinery/atmospherics/components/binary/pump/on/layer3
	piping_layer = 3
	icon_state= "pump_on_map-3"