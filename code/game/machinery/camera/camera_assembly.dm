#define STATE_WRENCHED 1
#define STATE_WELDED 2
#define STATE_WIRED 3
#define STATE_FINISHED 4

/obj/item/wallframe/camera
	name = "camera assembly"
	desc = "The basic construction for Nanotrasen-Always-Watching-You cameras."
	icon = 'icons/obj/machines/camera.dmi'
	icon_state = "cameracase"
	materials = list(MAT_METAL=400, MAT_GLASS=250)
	result_path = /obj/structure/camera_assembly

/obj/structure/camera_assembly
	name = "camera assembly"
	desc = "The basic construction for Nanotrasen-Always-Watching-You cameras."
	icon = 'icons/obj/machines/camera.dmi'
	icon_state = "camera_assembly"
	max_integrity = 150
	var/obj/item/analyzer/xray_module
	var/malf_xray_firmware_active
	var/malf_xray_firmware_present
	var/obj/item/stack/sheet/mineral/plasma/emp_module
	var/malf_emp_firmware_active
	var/malf_emp_firmware_present
	//var/obj/item/assembly/prox_sensor/proxy_module
	var/state = STATE_WRENCHED

#undef STATE_WRENCHED
#undef STATE_WELDED
#undef STATE_WIRED
#undef STATE_FINISHED