/datum/reagent/drug
	name = "Drug"
	id = "drug"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	taste_description = "bitterness"
	var/trippy = TRUE

///datum/reagent/drug/on_mob_delete(mob/living/M)
//	if(trippy)
//		SEND_SIGNAL(M, COMSIG_CLEAR_MOOD_EVENT, "[id]_high")

/datum/reagent/drug/nicotine
	name = "Nicotine"
	id = "nicotine"
	description = "Slightly reduces stun times. If overdosed it will deal toxin and oxygen damage."
	reagent_state = LIQUID
	color = "#60A584"
	addiction_threshold = 10
	taste_description = "smoke"
	trippy = FALSE
	overdose_threshold=15
	metabolization_rate = 0.125 * REAGENTS_METABOLISM

///datum/reagent/drug/nicotine/on_mob_life(mob/living/carbon/M)
//	if(prob(1))
//		var/smoke_message = pick("You feel relaxed.", "You feel calmed.","You feel alert.","You feel rugged.")
//		to_chat(M, "<span class='notice'>[smoke_message]</span>")
//	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "smoked", /datum/mood_event/smoked, name)
//	M.AdjustStun(-20, FALSE)
//	M.AdjustKnockdown(-20, FALSE)
//	M.AdjustUnconscious(-20, FALSE)
//	M.AdjustParalyzed(-20, FALSE)
//	M.AdjustImmobilized(-20, FALSE)
//	M.adjustStaminaLoss(-0.5*REM, 0)
//	..()
//	. = 1

///datum/reagent/drug/nicotine/overdose_process(mob/living/M)
//	M.adjustToxLoss(0.1*REM, 0)
//	M.adjustOxyLoss(1.1*REM, 0)
//	..()
//	. = 1