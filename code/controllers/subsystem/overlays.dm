SUBSYSTEM_DEF(overlays)
	name = "Overlay"
	flags = SS_TICKER
	wait = 1
	priority = FIRE_PRIORITY_OVERLAYS
	init_order = INIT_ORDER_OVERLAY
	
	var/list/queue
	var/list/stats
	var/list/overlay_icon_state_caches
	var/list/overlay_icon_cache

/datum/controller/subsystem/overlays/PreInit()
	overlay_icon_state_caches = list()
	overlay_icon_cache = list()
	queue = list()
	stats = list()

/datum/controller/subsystem/overlays/Initialize()
	initialized = TRUE
	fire(mc_check = FALSE)
	return ..()

/datum/controller/subsystem/overlays/stat_entry()
	..("Ov:[length(queue)]")

/datum/controller/subsystem/overlays/Shutdown()
	//text2file(render_stats(stats), "[GLOB.log_directory]/overlay.log")

/datum/controller/subsystem/overlays/Recover()
	overlay_icon_state_caches = SSoverlays.overlay_icon_state_caches
	overlay_icon_cache = SSoverlays.overlay_icon_cache
	queue = SSoverlays.queue

/atom/proc/cut_overlays()
	overlays = list()

/atom/proc/cut_overlay(list/overlays, priority)
	src.overlays -= overlays

/atom/proc/add_overlay(overlay)
	overlays += overlay