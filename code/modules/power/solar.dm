#define SOLAR_MAX_DIST 40
#define SOLARGENRATE 1500

/obj/machinery/power/solar
	name = "solar panel"
	desc = "A solar panel. Generates electricity when in contact with sunlight."
	icon = 'goon/icons/obj/power.dmi'
	icon_state = "sp_base"
	density = TRUE
	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0
	var/id = 0
	max_integrity = 150
	integrity_failure = 50
	var/obscured = 0
	var/sunfrac = 0
	var/adir = SOUTH
	var/ndir = SOUTH
	var/turn_angle = 0
	//var/obj/machinery/power/solar_control/control = null

/obj/machinery/power/solar/Initialize(mapload, obj/item/solar_assembly/S)
	. = ..()
	//Make(S)
	connect_to_network()

/obj/machinery/power/solar/Destroy()
	//unset_control()
	return ..()

/obj/machinery/power/solar/crowbar_act(mob/user, obj/item/I)
	playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
	user.visible_message("[user] begins to take the glass off [src].", "<span class='notice'>You begin to take the glass off [src]...</span>")
	if(I.use_tool(src, user, 50))
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
		user.visible_message("[user] takes the glass off [src].", "<span class='notice'>You take the glass off [src].</span>")
		deconstruct(TRUE)
	return TRUE

/obj/machinery/power/solar/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(stat & BROKEN)
				playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 60, 1)
			else
				playsound(loc, 'sound/effects/glasshit.ogg', 90, 1)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 100, 1)

/obj/machinery/power/solar/obj_break(damage_flag)
	if(!(stat & BROKEN) && !(flags_1 & NODECONSTRUCT_1))
		playsound(loc, 'sound/effects/glassbr3.ogg', 100, 1)
		stat |= BROKEN
		//unset_control()
		update_icon()

/obj/machinery/power/solar/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(disassembled)
			//var/obj/item/solar_assembly/S = locate() in src
			//if(S)
			//	S.forceMove(loc)
			//	S.give_glass(stat & BROKEN)
		else
			playsound(src, "shatter", 70, 1)
			new /obj/item/shard(src.loc)
			new /obj/item/shard(src.loc)
	qdel(src)

/obj/machinery/power/solar/update_icon()
	..()
	cut_overlays()
	if(stat & BROKEN)
		add_overlay(mutable_appearance(icon, "solar_panel-b", FLY_LAYER))
	else
		add_overlay(mutable_appearance(icon, "solar_panel", FLY_LAYER))
		//src.setDir(angle2dir(adir))

/obj/machinery/power/solar/process()
	if(stat & BROKEN)
		return
	//if(!control)
	//	return

	//if(powernet)
	//	if(powernet == control.powernet)
	//		if(obscured)
	//			return
	//		var/sgen = SOLARGENRATE * sunfrac
	//		add_avail(sgen)
	//		/ontrol.gen += sgen
	//	else
	//		unset_control()

/obj/machinery/power/solar_control
	name = "solar panel control"
	desc = "A controller for solar panel arrays."
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 250
	max_integrity = 200
	integrity_failure = 100
	var/icon_screen = "solar"
	var/icon_keyboard = "power_key"
	var/id = 0
	var/currentdir = 0
	var/targetdir = 0
	var/gen = 0
	var/lastgen = 0
	var/track = 0
	var/trackrate = 600
	var/nexttime = 0
	//var/obj/machinery/power/tracker/connected_tracker = null
	var/list/connected_panels = list()

/obj/machinery/power/solar_control/Initialize()
	. = ..()
	//if(powernet)
	//	set_panels(currentdir)
	connect_to_network()

/obj/machinery/power/solar_control/Destroy()
	//for(var/obj/machinery/power/solar/M in connected_panels)
	//	M.unset_control()
	//if(connected_tracker)
	//	connected_tracker.unset_control()
	return ..()

/obj/machinery/power/solar_control/update_icon()
	cut_overlays()
	if(stat & NOPOWER)
		add_overlay("[icon_keyboard]_off")
		return
	add_overlay(icon_keyboard)
	if(stat & BROKEN)
		add_overlay("[icon_state]_broken")
	else
		add_overlay(icon_screen)

/obj/item/paper/guides/jobs/engi/solars
	name = "paper- 'Going green! Setup your own solar array instructions.'"
	info = "<h1>Welcome</h1><p>At greencorps we love the environment, and space. With this package you are able to help mother nature and produce energy without any usage of fossil fuel or plasma! Singularity energy is dangerous while solar energy is safe, which is why it's better. Now here is how you setup your own solar array.</p><p>You can make a solar panel by wrenching the solar assembly onto a cable node. Adding a glass panel, reinforced or regular glass will do, will finish the construction of your solar panel. It is that easy!</p><p>Now after setting up 19 more of these solar panels you will want to create a solar tracker to keep track of our mother nature's gift, the sun. These are the same steps as before except you insert the tracker equipment circuit into the assembly before performing the final step of adding the glass. You now have a tracker! Now the last step is to add a computer to calculate the sun's movements and to send commands to the solar panels to change direction with the sun. Setting up the solar computer is the same as setting up any computer, so you should have no trouble in doing that. You do need to put a wire node under the computer, and the wire needs to be connected to the tracker.</p><p>Congratulations, you should have a working solar array. If you are having trouble, here are some tips. Make sure all solar equipment are on a cable node, even the computer. You can always deconstruct your creations if you make a mistake.</p><p>That's all to it, be safe, be green!</p>"