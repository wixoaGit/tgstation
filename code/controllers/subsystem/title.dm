SUBSYSTEM_DEF(title)
	name = "Title Screen"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_TITLE
	
	var/icon = 'icons/default_title.dmi'
	var/turf/closed/indestructible/splashscreen/splash_turf