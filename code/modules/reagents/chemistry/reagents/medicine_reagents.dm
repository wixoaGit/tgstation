/datum/reagent/medicine/charcoal
	name = "Charcoal"
	id = "charcoal"
	description = "Heals toxin damage as well as slowly removing any other chemicals the patient has in their bloodstream."
	reagent_state = LIQUID
	color = "#000000"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	taste_description = "ash"

///datum/reagent/medicine/charcoal/on_mob_life(mob/living/carbon/M)
//	M.adjustToxLoss(-2*REM, 0)
//	. = 1
//	for(var/datum/reagent/R in M.reagents.reagent_list)
//		if(R != src)
//			M.reagents.remove_reagent(R.id,1)
//	..()

/datum/reagent/medicine/oculine
	name = "Oculine"
	id = "oculine"
	description = "Quickly restores eye damage, cures nearsightedness, and has a chance to restore vision to the blind."
	reagent_state = LIQUID
	color = "#FFFFFF"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	taste_description = "dull toxin"

///datum/reagent/medicine/oculine/on_mob_life(mob/living/carbon/M)
//	var/obj/item/organ/eyes/eyes = M.getorganslot(ORGAN_SLOT_EYES)
//	if (!eyes)
//		return
//	if(M.has_trait(TRAIT_BLIND, EYE_DAMAGE))
//		if(prob(20))
//			to_chat(M, "<span class='warning'>Your vision slowly returns...</span>")
//			M.cure_blind(EYE_DAMAGE)
//			M.cure_nearsighted(EYE_DAMAGE)
//			M.blur_eyes(35)
//
//	else if(M.has_trait(TRAIT_NEARSIGHT, EYE_DAMAGE))
//		to_chat(M, "<span class='warning'>The blackness in your peripheral vision fades.</span>")
//		M.cure_nearsighted(EYE_DAMAGE)
//		M.blur_eyes(10)
//	else if(M.eye_blind || M.eye_blurry)
//		M.set_blindness(0)
//		M.set_blurriness(0)
//	else if(eyes.eye_damage > 0)
//		M.adjust_eye_damage(-1)
//	..()