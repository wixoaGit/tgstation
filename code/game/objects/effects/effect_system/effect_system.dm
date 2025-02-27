/obj/effect/particle_effect
	name = "particle effect"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pass_flags = PASSTABLE | PASSGRILLE
	anchored = TRUE

/obj/effect/particle_effect/Initialize()
	. = ..()
	//GLOB.cameranet.updateVisibility(src)

/obj/effect/particle_effect/Destroy()
	//GLOB.cameranet.updateVisibility(src)
	return ..()

/datum/effect_system
	var/number = 3
	var/cardinals = FALSE
	var/turf/location
	var/atom/holder
	var/effect_type
	var/total_effects = 0
	var/autocleanup = FALSE

/datum/effect_system/Destroy()
	holder = null
	location = null
	return ..()

/datum/effect_system/proc/set_up(n = 3, c = FALSE, loca)
	if(n > 10)
		n = 10
	number = n
	cardinals = c
	if(isturf(loca))
		location = loca
	else
		location = get_turf(loca)

/datum/effect_system/proc/attach(atom/atom)
	holder = atom

/datum/effect_system/proc/start()
	for(var/i in 1 to number)
		if(total_effects > 20)
			return
		INVOKE_ASYNC(src, .proc/generate_effect)

/datum/effect_system/proc/generate_effect()
	if(holder)
		location = get_turf(holder)
	var/obj/effect/E = new effect_type(location)
	total_effects++
	var/direction
	if(cardinals)
		direction = pick(GLOB.cardinals)
	else
		direction = pick(GLOB.alldirs)
	var/steps_amt = pick(1,2,3)
	for(var/j in 1 to steps_amt)
		//sleep(5)
		step(E,direction)
	addtimer(CALLBACK(src, .proc/decrement_total_effect), 20)

/datum/effect_system/proc/decrement_total_effect()
	total_effects--
	if(autocleanup && total_effects <= 0)
		qdel(src)