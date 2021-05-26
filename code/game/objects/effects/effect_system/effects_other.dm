/datum/effect_system/reagents_explosion
	var/amount
	var/flashing = 0
	var/flashing_factor = 0
	var/explosion_message = 1

/datum/effect_system/reagents_explosion/set_up(amt, loca, flash = 0, flash_fact = 0, message = 1)
	amount = amt
	explosion_message = message
	if(isturf(loca))
		location = loca
	else
		location = get_turf(loca)

	flashing = flash
	flashing_factor = flash_fact

/datum/effect_system/reagents_explosion/start()
	if(explosion_message)
		location.visible_message("<span class='danger'>The solution violently explodes!</span>", \
								"<span class='italics'>You hear an explosion!</span>")
	if (amount < 1)
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(2, 1, location)
		s.start()

		//for(var/mob/living/L in viewers(1, location))
		//	if(prob(50 * amount))
		//		to_chat(L, "<span class='danger'>The explosion knocks you down.</span>")
		//		L.Paralyze(rand(20,100))
		return
	else
		dyn_explosion(location, amount, flashing_factor)