/obj/machinery/camera
	name = "security camera"
	desc = "It's used to monitor rooms."
	icon = 'icons/obj/machines/camera.dmi'
	icon_state = "camera"
	use_power = ACTIVE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 10
	layer = WALL_OBJ_LAYER
	resistance_flags = FIRE_PROOF

	armor = list("melee" = 50, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 90, "acid" = 50)
	max_integrity = 100
	integrity_failure = 50
	var/default_camera_icon = "camera"
	var/list/network = list("ss13")
	var/c_tag = null
	var/status = TRUE
	var/start_active = FALSE
	var/invuln = null
	//var/obj/item/camera_bug/bug = null
	var/obj/structure/camera_assembly/assembly = null
	var/area/myarea = null

	var/view_range = 7
	var/short_range = 2

	var/alarm_on = FALSE
	var/busy = FALSE
	var/emped = FALSE
	var/in_use_lights = 0

	var/upgrades = 0
	//var/datum/component/empprotection/emp_component

	var/internal_light = TRUE

/obj/machinery/camera/Initialize(mapload, obj/structure/camera_assembly/CA)
	. = ..()
	for(var/i in network)
		network -= i
		network += lowertext(i)
	if(CA)
		assembly = CA
		//if(assembly.xray_module)
		//	upgradeXRay()
		//else if(assembly.malf_xray_firmware_present)
		//	upgradeXRay(TRUE)

		//if(assembly.emp_module)
		//	upgradeEmpProof()
		//else if(assembly.malf_xray_firmware_present)
		//	upgradeEmpProof(TRUE)

		//if(assembly.proxy_module)
		//	upgradeMotion()
	else
		//assembly = new(src)
		assembly = new /obj/structure/camera_assembly(src)//not_actual
		assembly.state = 4
	//GLOB.cameranet.cameras += src
	//GLOB.cameranet.addCamera(src)
	//if (isturf(loc))
	//	myarea = get_area(src)
	//	LAZYADD(myarea.cameras, src)
	//proximity_monitor = new(src, 1)

	//if(mapload && is_station_level(z) && prob(3) && !start_active)
	//	toggle_cam()
	//else
	//	update_icon()
	update_icon()//not_actual

/obj/machinery/camera/Destroy()
	//if(can_use())
	//	toggle_cam(null, 0)
	//GLOB.cameranet.cameras -= src
	//if(isarea(myarea))
	//	LAZYREMOVE(myarea.cameras, src)
	QDEL_NULL(assembly)
	//QDEL_NULL(emp_component)
	//if(bug)
	//	bug.bugged_cameras -= src.c_tag
	//	if(bug.current == src)
	//		bug.current = null
	//	bug = null
	//cancelCameraAlarm()
	return ..()

/obj/machinery/camera/examine(mob/user)
	..()
	//if(isEmpProof(TRUE))
	//	to_chat(user, "It has electromagnetic interference shielding installed.")
	//else
	//	to_chat(user, "<span class='info'>It can be shielded against electromagnetic interference with some <b>plasma</b>.</span>")
	//if(isXRay(TRUE))
	//	to_chat(user, "It has an X-ray photodiode installed.")
	//else
	//	to_chat(user, "<span class='info'>It can be upgraded with an X-ray photodiode with an <b>analyzer</b>.</span>")
	//if(isMotion())
	//	to_chat(user, "It has a proximity sensor installed.")
	//else
	//	to_chat(user, "<span class='info'>It can be upgraded with a <b>proximity sensor</b>.</span>")

	if(!status)
		to_chat(user, "<span class='info'>It's currently deactivated.</span>")
		if(!panel_open && powered())
			to_chat(user, "<span class='notice'>You'll need to open its maintenance panel with a <b>screwdriver</b> to turn it back on.</span>")
	if(panel_open)
		to_chat(user, "<span class='info'>Its maintenance panel is currently open.</span>")
		if(!status && powered())
			to_chat(user, "<span class='info'>It can reactivated with a <b>screwdriver</b>.</span>")

/obj/machinery/camera/update_icon()
	var/xray_module
	//if(isXRay(TRUE))
	//	xray_module = "xray"
	if(!status)
		icon_state = "[xray_module][default_camera_icon]_off"
	else if (stat & EMPED)
		icon_state = "[xray_module][default_camera_icon]_emp"
	else
		icon_state = "[xray_module][default_camera_icon][in_use_lights ? "_in_use" : ""]"