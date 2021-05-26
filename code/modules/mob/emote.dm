/mob/proc/emote(act, m_type = null, message = null, intentional = FALSE)
	act = lowertext(act)
	var/param = message
	var/custom_param = findchar(act, " ")
	if(custom_param)
		param = copytext(act, custom_param + 1, length(act) + 1)
		act = copytext(act, 1, custom_param)

	var/datum/emote/E
	//E = E.emote_list[act]
	E = GLOB.emote_list[act]//not_actual
	if(!E)
		to_chat(src, "<span class='notice'>Unusable emote '[act]'. Say *help for a list.</span>")
		return
	E.run_emote(src, param, m_type, intentional)