/mob/living/carbon/death(gibbed)
	if(stat == DEAD)
		return

	//silent = FALSE
	//losebreath = 0

	if(!gibbed)
		emote("deathgasp")

	. = ..()
	
	//for(var/T in get_traumas())
	//	var/datum/brain_trauma/BT = T
	//	BT.on_death()
	
	//if(SSticker.mode)
	//	SSticker.mode.check_win()