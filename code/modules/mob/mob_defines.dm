/mob
	datum_flags = DF_USE_TAG
	density = TRUE
	layer = MOB_LAYER
	//animate_movement = 2
	flags_1 = HEAR_1
	//hud_possible = list(ANTAG_HUD)
	pressure_resistance = 8
	//mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	throwforce = 10

	var/datum/mind/mind

	var/list/movespeed_modification
	var/cached_multiplicative_slowdown

	var/list/datum/action/actions = list()

	var/stat = CONSCIOUS

	var/zone_selected = null

	var/obj/machinery/machine = null

	var/next_move = null
	var/notransform = null
	var/eye_blind = 0
	var/real_name = null
	var/spacewalk = FALSE

	var/bodytemperature = BODYTEMP_NORMAL
	var/jitteriness = 0
	var/dizziness = 0
	var/nutrition = NUTRITION_LEVEL_START_MIN
	var/satiety = 0

	var/overeatduration = 0
	var/a_intent = INTENT_HELP
	var/list/possible_a_intents = null
	var/m_intent = MOVE_INTENT_RUN
	var/atom/movable/buckled = null

	var/active_hand_index = 1
	var/list/held_items = list()

	var/datum/component/storage/active_storage
	var/datum/hud/hud_used = null
	var/research_scanner = FALSE

	var/in_throw_mode = 0

	var/job = null

	var/list/faction = list("neutral")

	var/status_flags = CANSTUN|CANKNOCKDOWN|CANUNCONSCIOUS|CANPUSH

	var/digitalcamo = 0

	var/has_unlimited_silicon_privilege = 0

	var/deathsound

	var/turf/listed_turf = null

	var/list/progressbars = null