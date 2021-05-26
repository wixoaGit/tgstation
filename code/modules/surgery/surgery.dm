/datum/surgery
	var/name = "surgery"
	var/desc = "surgery description"
	var/status = 1
	var/list/steps = list()
	var/step_in_progress = 0
	var/can_cancel = 1
	var/list/target_mobtypes = list(/mob/living/carbon/human)
	var/location = BODY_ZONE_CHEST
	var/requires_bodypart_type = BODYPART_ORGANIC
	var/list/possible_locs = list()
	var/ignore_clothes = 0
	var/mob/living/carbon/target
	var/obj/item/bodypart/operated_bodypart
	var/requires_bodypart = TRUE
	var/success_multiplier = 0
	var/requires_real_bodypart = 0
	var/lying_required = TRUE
	var/self_operable = FALSE

/datum/surgery/advanced
	name = "advanced surgery"

/obj/item/disk/surgery
	name = "Surgery Procedure Disk"
	desc = "A disk that contains advanced surgery procedures, must be loaded into an Operating Console."
	icon_state = "datadisk1"
	materials = list(MAT_METAL=300, MAT_GLASS=100)
	var/list/surgeries

/obj/item/disk/surgery/debug
	name = "Debug Surgery Disk"
	desc = "A disk that contains all existing surgery procedures."
	icon_state = "datadisk1"
	materials = list(MAT_METAL=300, MAT_GLASS=100)

/obj/item/disk/surgery/debug/Initialize()
	. = ..()
	surgeries = subtypesof(/datum/surgery/advanced)