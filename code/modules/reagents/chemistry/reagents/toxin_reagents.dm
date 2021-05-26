/datum/reagent/toxin
	name = "Toxin"
	id = "toxin"
	description = "A toxic chemical."
	color = "#CF3600"
	taste_description = "bitterness"
	taste_mult = 1.2
	var/toxpwr = 1.5
	var/silent_toxin = FALSE

///datum/reagent/toxin/on_mob_life(mob/living/carbon/M)
//	if(toxpwr)
//		M.adjustToxLoss(toxpwr*REM, 0)
//		. = TRUE
//	..()

/datum/reagent/toxin/mutagen
	name = "Unstable mutagen"
	id = "mutagen"
	description = "Might cause unpredictable mutations. Keep away from children."
	color = "#00FF00"
	toxpwr = 0
	taste_description = "slime"
	taste_mult = 0.9

///datum/reagent/toxin/mutagen/reaction_mob(mob/living/carbon/M, method=TOUCH, reac_volume)
//	if(!..())
//		return
//	if(!M.has_dna())
//		return
//	if((method==VAPOR && prob(min(33, reac_volume))) || method==INGEST || method==PATCH || method==INJECT)
//		M.randmuti()
//		if(prob(98))
//			M.easy_randmut(NEGATIVE+MINOR_NEGATIVE)
//		else
//			M.easy_randmut(POSITIVE)
//		M.updateappearance()
//		M.domutcheck()
//	..()

///datum/reagent/toxin/mutagen/on_mob_life(mob/living/carbon/C)
//	C.apply_effect(5,EFFECT_IRRADIATE,0)
//	return ..()

/datum/reagent/toxin/acid
	name = "Sulphuric acid"
	id = "sacid"
	description = "A strong mineral acid with the molecular formula H2SO4."
	color = "#00FF32"
	toxpwr = 1
	var/acidpwr = 10
	taste_description = "acid"
	self_consuming = TRUE

/datum/reagent/toxin/acid/fluacid
	name = "Fluorosulfuric acid"
	id = "facid"
	description = "Fluorosulfuric acid is an extremely corrosive chemical substance."
	color = "#5050FF"
	toxpwr = 2
	acidpwr = 42.0