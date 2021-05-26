/mob/living
	var/maxHealth = 100
	var/health = 100

	var/bruteloss = 0
	var/oxyloss = 0
	var/toxloss = 0
	var/fireloss = 0
	var/cloneloss = 0
	var/staminaloss = 0
	var/crit_threshold = HEALTH_THRESHOLD_CRIT

	var/mobility_flags = MOBILITY_FLAGS_DEFAULT

	var/resting = FALSE

	var/lying = 0
	var/lying_prev = 0

	var/hallucination = 0

	var/last_special = 0
	var/timeofdeath = 0

	var/incorporeal_move = FALSE

	var/now_pushing = null

	var/tod = null

	var/on_fire = 0
	var/fire_stacks = 0

	var/mob_size = MOB_SIZE_HUMAN
	var/list/mob_biotypes = list(MOB_ORGANIC)
	var/has_limbs = 0

	var/smoke_delay = 0

	var/last_bumped = 0
	var/unique_name = 0

	var/hellbound = 0

	var/blood_volume = 0

	var/list/status_effects

	var/stuttering = 0
	var/slurring = 0
	var/cultslurring = 0
	var/derpspeech = 0

	var/radiation = 0