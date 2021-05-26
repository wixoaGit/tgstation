#define SMESRATE 0.05

#define SMES_CLEVEL_1		1
#define SMES_CLEVEL_2		2
#define SMES_CLEVEL_3		3
#define SMES_CLEVEL_4		4
#define SMES_CLEVEL_5		5
#define SMES_OUTPUTTING		6
#define SMES_NOT_OUTPUTTING 7
#define SMES_INPUTTING		8
#define SMES_INPUT_ATTEMPT	9

/obj/machinery/power/smes
	name = "power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit."
	icon_state = "smes"
	density = TRUE
	use_power = NO_POWER_USE
	//circuit = /obj/item/circuitboard/machine/smes
	var/capacity = 5e6
	var/charge = 0

	var/input_attempt = TRUE
	var/inputting = TRUE
	var/input_level = 50000
	var/input_level_max = 200000
	var/input_available = 0

	var/output_attempt = TRUE
	var/outputting = TRUE
	var/output_level = 50000
	var/output_level_max = 200000
	var/output_used = 0

	var/obj/machinery/power/terminal/terminal = null

/obj/machinery/power/smes/examine(user)
	..()
	if(!terminal)
		to_chat(user, "<span class='warning'>This SMES has no power terminal!</span>")

/obj/machinery/power/smes/Initialize()
	. = ..()
	/*dir_loop:
		for(var/d in GLOB.cardinals)
			var/turf/T = get_step(src, d)
			for(var/obj/machinery/power/terminal/term in T)
				if(term && term.dir == turn(d, 180))
					terminal = term
					break dir_loop*/
	//not_actual
	for(var/d in GLOB.cardinals)
		var/turf/T = get_step(src, d)
		for(var/obj/machinery/power/terminal/term in T)
			if(term && term.dir == turn(d, 180))
				terminal = term
				break
		if (terminal) break

	if(!terminal)
		stat |= BROKEN
		return
	terminal.master = src
	update_icon()

/obj/machinery/power/smes/Destroy()
	//if(SSticker.IsRoundInProgress())
	//	var/turf/T = get_turf(src)
	//	message_admins("SMES deleted at [ADMIN_VERBOSEJMP(T)]")
	//	log_game("SMES deleted at [AREACOORD(T)]")
	//	investigate_log("<font color='red'>deleted</font> at [AREACOORD(T)]", INVESTIGATE_SINGULO)
	if(terminal)
		disconnect_terminal()
	return ..()

/obj/machinery/power/smes/proc/make_terminal(turf/T)
	terminal = new/obj/machinery/power/terminal(T)
	terminal.setDir(get_dir(T,src))
	terminal.master = src
	stat &= ~BROKEN

/obj/machinery/power/smes/disconnect_terminal()
	if(terminal)
		terminal.master = null
		terminal = null
		stat |= BROKEN

/obj/machinery/power/smes/update_icon()
	cut_overlays()
	if(stat & BROKEN)
		return

	if(panel_open)
		return

	if(outputting)
		add_overlay("smes-op1")
	else
		add_overlay("smes-op0")

	if(inputting)
		add_overlay("smes-oc1")
	else
		if(input_attempt)
			add_overlay("smes-oc0")

	var/clevel = chargedisplay()
	if(clevel>0)
		add_overlay("smes-og[clevel]")

/obj/machinery/power/smes/proc/chargedisplay()
	return CLAMP(round(5.5*charge/capacity),0,5)

/obj/machinery/power/smes/process()
	if(stat & BROKEN)
		return

	var/last_disp = chargedisplay()
	var/last_chrg = inputting
	var/last_onln = outputting

	if(terminal && input_attempt)
		input_available = terminal.surplus()

		if(inputting)
			if(input_available > 0)

				var/load = min(min((capacity-charge)/SMESRATE, input_level), input_available)

				charge += load * SMESRATE

				terminal.add_load(load)

			else
				inputting = FALSE

		else
			if(input_attempt && input_available > 0)
				inputting = TRUE
	else
		inputting = FALSE

	if(output_attempt)
		if(outputting)
			output_used = min( charge/SMESRATE, output_level)

			if (add_avail(output_used))
				charge -= output_used*SMESRATE
			else
				outputting = FALSE

			if(output_used < 0.0001)
				outputting = FALSE
				//investigate_log("lost power and turned <font color='red'>off</font>", INVESTIGATE_SINGULO)
		else if(output_attempt && charge > output_level && output_level > 0)
			outputting = TRUE
		else
			output_used = 0
	else
		outputting = FALSE

	if(last_disp != chargedisplay() || last_chrg != inputting || last_onln != outputting)
		update_icon()

/obj/machinery/power/smes/proc/restore()
	if(stat & BROKEN)
		return

	if(!outputting)
		output_used = 0
		return

	var/excess = powernet.netexcess

	excess = min(output_used, excess)

	excess = min((capacity-charge)/SMESRATE, excess)

	var/clev = chargedisplay()

	charge += excess * SMESRATE
	powernet.netexcess -= excess

	output_used -= excess

	if(clev != chargedisplay() )
		update_icon()
	return

/obj/machinery/power/smes/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
										datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "smes", name, 340, 440, master_ui, state)
		ui.open()

/obj/machinery/power/smes/ui_data()
	var/list/data = list(
		"capacityPercent" = round(100*charge/capacity, 0.1),
		"capacity" = capacity,
		"charge" = charge,

		"inputAttempt" = input_attempt,
		"inputting" = inputting,
		"inputLevel" = input_level,
		"inputLevel_text" = DisplayPower(input_level),
		"inputLevelMax" = input_level_max,
		"inputAvailable" = DisplayPower(input_available),

		"outputAttempt" = output_attempt,
		"outputting" = outputting,
		"outputLevel" = output_level,
		"outputLevel_text" = DisplayPower(output_level),
		"outputLevelMax" = output_level_max,
		"outputUsed" = DisplayPower(output_used)
	)
	return data

/obj/machinery/power/smes/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("tryinput")
			input_attempt = !input_attempt
			log_smes(usr)
			update_icon()
			. = TRUE
		if("tryoutput")
			output_attempt = !output_attempt
			log_smes(usr)
			update_icon()
			. = TRUE
		if("input")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "input")
				target = input("New input target (0-[input_level_max]):", name, input_level) as num|null
				if(!isnull(target) && !..())
					. = TRUE
			else if(target == "min")
				target = 0
				. = TRUE
			else if(target == "max")
				target = input_level_max
				. = TRUE
			else if(adjust)
				target = input_level + adjust
				. = TRUE
			else if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				input_level = CLAMP(target, 0, input_level_max)
				log_smes(usr)
		if("output")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "input")
				target = input("New output target (0-[output_level_max]):", name, output_level) as num|null
				if(!isnull(target) && !..())
					. = TRUE
			else if(target == "min")
				target = 0
				. = TRUE
			else if(target == "max")
				target = output_level_max
				. = TRUE
			else if(adjust)
				target = output_level + adjust
				. = TRUE
			else if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				output_level = CLAMP(target, 0, output_level_max)
				log_smes(usr)

/obj/machinery/power/smes/proc/log_smes(mob/user)
	//investigate_log("input/output; [input_level>output_level?"<font color='green'>":"<font color='red'>"][input_level]/[output_level]</font> | Charge: [charge] | Output-mode: [output_attempt?"<font color='green'>on</font>":"<font color='red'>off</font>"] | Input-mode: [input_attempt?"<font color='green'>auto</font>":"<font color='red'>off</font>"] by [user ? key_name(user) : "outside forces"]", INVESTIGATE_SINGULO)

/obj/machinery/power/smes/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	input_attempt = rand(0,1)
	inputting = input_attempt
	output_attempt = rand(0,1)
	outputting = output_attempt
	output_level = rand(0, output_level_max)
	input_level = rand(0, input_level_max)
	charge -= 1e6/severity
	if (charge < 0)
		charge = 0
	update_icon()
	log_smes()

/obj/machinery/power/smes/engineering
	charge = 1.5e6