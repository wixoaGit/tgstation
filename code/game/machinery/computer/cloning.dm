#define AUTOCLONING_MINIMAL_LEVEL 3

/obj/machinery/computer/cloning
	name = "cloning console"
	desc = "Used to clone people and manage DNA."
	icon_screen = "dna"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/computer/cloning
	req_access = list(ACCESS_GENETICS)
	//var/obj/machinery/dna_scannernew/scanner
	var/list/pods
	var/temp = "Inactive"
	var/scantemp_ckey
	var/scantemp = "Ready to Scan"
	var/menu = 1
	var/list/records = list()
	var/datum/data/record/active_record
	var/obj/item/disk/data/diskette

	var/include_se = FALSE
	var/include_ui = FALSE
	var/include_ue = FALSE

	var/loading = FALSE
	var/autoprocess = FALSE

	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/cloning/Initialize()
	. = ..()
	updatemodules(TRUE)

/obj/machinery/computer/cloning/Destroy()
	if(pods)
		for(var/P in pods)
			DetachCloner(P)
		pods = null
	return ..()

/obj/machinery/computer/cloning/proc/updatemodules(findfirstcloner)
	//scanner = findscanner()
	if(findfirstcloner && !LAZYLEN(pods))
		findcloner()
	if(!autoprocess)
		STOP_PROCESSING(SSmachines, src)
	else
		START_PROCESSING(SSmachines, src)

/obj/machinery/computer/cloning/proc/findscanner()
	//var/obj/machinery/dna_scannernew/scannerf = null

	for(var/direction in GLOB.cardinals)
		//scannerf = locate(/obj/machinery/dna_scannernew, get_step(src, direction))

		//if (!isnull(scannerf) && scannerf.is_operational())
		//	return scannerf

	return null

/obj/machinery/computer/cloning/proc/findcloner()
	var/obj/machinery/clonepod/podf = null

	for(var/direction in GLOB.cardinals)
		podf = locate(/obj/machinery/clonepod, get_step(src, direction))
		if (!isnull(podf) && podf.is_operational())
			AttachCloner(podf)

/obj/machinery/computer/cloning/proc/AttachCloner(obj/machinery/clonepod/pod)
	if(!pod.connected)
		pod.connected = src
		LAZYADD(pods, pod)

/obj/machinery/computer/cloning/proc/DetachCloner(obj/machinery/clonepod/pod)
	pod.connected = null
	LAZYREMOVE(pods, pod)

/obj/machinery/computer/cloning/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/disk/data))
		if (!diskette)
			if (!user.transferItemToLoc(W,src))
				return
			diskette = W
			to_chat(user, "<span class='notice'>You insert [W].</span>")
			playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
			updateUsrDialog()
	else if(W.tool_behaviour == TOOL_MULTITOOL)
		//if(!multitool_check_buffer(user, W))
		//	return
		//var/obj/item/multitool/P = W

		//if(istype(P.buffer, /obj/machinery/clonepod))
		//	if(get_area(P.buffer) != get_area(src))
		//		to_chat(user, "<font color = #666633>-% Cannot link machines across power zones. Buffer cleared %-</font color>")
		//		P.buffer = null
		//		return
		//	to_chat(user, "<font color = #666633>-% Successfully linked [P.buffer] with [src] %-</font color>")
		//	var/obj/machinery/clonepod/pod = P.buffer
		//	if(pod.connected)
		//		pod.connected.DetachCloner(pod)
		//	AttachCloner(pod)
		//else
		//	P.buffer = src
		//	to_chat(user, "<font color = #666633>-% Successfully stored [REF(P.buffer)] [P.buffer.name] in buffer %-</font color>")
		return
	else
		return ..()