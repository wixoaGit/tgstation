SUBSYSTEM_DEF(tgui)
	name = "tgui"
	wait = 9
	flags = SS_NO_INIT
	priority = FIRE_PRIORITY_TGUI
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT

	var/list/currentrun = list()
	var/list/open_uis = list()
	var/list/processing_uis = list()
	var/basehtml

/datum/controller/subsystem/tgui/PreInit()
	basehtml = file2text('tgui/tgui.html')

/datum/controller/subsystem/tgui/Shutdown()
	close_all_uis()

/datum/controller/subsystem/tgui/stat_entry()
	..("P:[processing_uis.len]")

/datum/controller/subsystem/tgui/fire(resumed = 0)
	if (!resumed)
		src.currentrun = processing_uis.Copy()
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/datum/tgui/ui = currentrun[currentrun.len]
		currentrun.len--
		if(ui && ui.user && ui.src_object)
			ui.process()
		else
			processing_uis.Remove(ui)
		if (MC_TICK_CHECK)
			return