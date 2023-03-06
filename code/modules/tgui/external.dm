/datum/proc/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	return FALSE

/datum/proc/ui_data(mob/user)
	return list()

/datum/proc/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(!ui || ui.status != UI_INTERACTIVE)
		return 1

/datum/proc/ui_host(mob/user)
	return src

///mob/var/list/open_uis = list()
//not_actual
/mob
	var/list/open_uis = list()

/datum/proc/ui_close()

/client/verb/uiclose(ref as text)
	set name = "uiclose"
	set hidden = 1

	var/datum/tgui/ui = locate(ref)

	if(istype(ui))
		ui.close()
		if(src && src.mob)
			src.mob.unset_machine()