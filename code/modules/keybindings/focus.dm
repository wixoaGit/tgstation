/mob
	var/datum/focus

/mob/proc/set_focus(datum/new_focus)
	if(focus == new_focus)
		return
	focus = new_focus
	reset_perspective(focus)