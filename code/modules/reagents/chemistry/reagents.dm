#define REM REAGENTS_EFFECT_MULTIPLIER

/datum/reagent
	var/name = "Reagent"
	var/id = "reagent"
	var/description = ""
	var/specific_heat = SPECIFIC_HEAT_DEFAULT
	var/taste_description = "metaphorical salt"
	var/taste_mult = 1
	var/glass_name = "glass of ...what?"
	var/glass_desc = "You can't really tell what this is."
	var/glass_icon_state = null
	var/shot_glass_icon_state = null
	var/datum/reagents/holder = null
	var/reagent_state = LIQUID
	var/list/data
	var/current_cycle = 0
	var/volume = 0
	var/color = "#000000"
	var/can_synth = TRUE
	var/metabolization_rate = REAGENTS_METABOLISM
	var/overrides_metab = 0
	var/overdose_threshold = 0
	var/addiction_threshold = 0
	var/addiction_stage = 0
	var/overdosed = 0
	var/self_consuming = FALSE
	var/reagent_weight = 1

/datum/reagent/Destroy()
	. = ..()
	holder = null

/datum/reagent/proc/reaction_turf(turf/T, volume)
	return

/datum/reagent/proc/on_mob_add(mob/living/L)
	return

/datum/reagent/proc/on_mob_delete(mob/living/L)
	return

/datum/reagent/proc/on_new(data)
	return

/datum/reagent/proc/on_merge(data)
	return

/datum/reagent/proc/on_ex_act(severity)
	return