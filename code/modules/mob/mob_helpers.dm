/mob/proc/lowest_buckled_mob()
	. = src
	if(buckled && ismob(buckled))
		var/mob/Buckled = buckled
		. = Buckled.lowest_buckled_mob()

/proc/check_zone(zone)
	if(!zone)
		return BODY_ZONE_CHEST
	switch(zone)
		if(BODY_ZONE_PRECISE_EYES)
			zone = BODY_ZONE_HEAD
		if(BODY_ZONE_PRECISE_MOUTH)
			zone = BODY_ZONE_HEAD
		if(BODY_ZONE_PRECISE_L_HAND)
			zone = BODY_ZONE_L_ARM
		if(BODY_ZONE_PRECISE_R_HAND)
			zone = BODY_ZONE_R_ARM
		if(BODY_ZONE_PRECISE_L_FOOT)
			zone = BODY_ZONE_L_LEG
		if(BODY_ZONE_PRECISE_R_FOOT)
			zone = BODY_ZONE_R_LEG
		if(BODY_ZONE_PRECISE_GROIN)
			zone = BODY_ZONE_CHEST
	return zone

/proc/ran_zone(zone, probability = 80)

	zone = check_zone(zone)

	if(prob(probability))
		return zone

	var/t = rand(1, 18)
	switch(t)
		if(1)
			return BODY_ZONE_HEAD
		if(2)
			return BODY_ZONE_CHEST
		if(3 to 6)
			return BODY_ZONE_L_ARM
		if(7 to 10)
			return BODY_ZONE_R_ARM
		if(11 to 14)
			return BODY_ZONE_L_LEG
		if(15 to 18)
			return BODY_ZONE_R_LEG

	return zone

/proc/above_neck(zone)
	var/list/zones = list(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_PRECISE_EYES)
	if(zones.Find(zone))
		return 1
	else
		return 0

/proc/stars(n, pr)
	n = html_encode(n)
	if (pr == null)
		pr = 25
	if (pr <= 0)
		return null
	else
		if (pr >= 100)
			return n
	var/te = n
	var/t = ""
	n = length(n)
	var/p = null
	p = 1
	while(p <= n)
		if ((copytext(te, p, p + 1) == " " || prob(pr)))
			t = text("[][]", t, copytext(te, p, p + 1))
		else
			t = text("[]*", t)
		p++
	return sanitize(t)

/proc/Gibberish(t, p)
	var/returntext = ""
	for(var/i = 1, i <= length(t), i++)

		var/letter = copytext(t, i, i+1)
		if(prob(50))
			if(p >= 70)
				letter = ""

			for(var/j = 1, j <= rand(0, 2), j++)
				letter += pick("#","@","*","&","%","$","/", "<", ">", ";","*","*","*","*","*","*","*")

		returntext += letter

	return returntext

/proc/shake_camera(mob/M, duration, strength=1)
	if(!M || !M.client || duration < 1)
		return
	//var/client/C = M.client
	//var/oldx = C.pixel_x
	//var/oldy = C.pixel_y
	//var/max = strength*world.icon_size
	//var/min = -(strength*world.icon_size)

	//for(var/i in 0 to duration-1)
	//	if (i == 0)
	//		animate(C, pixel_x=rand(min,max), pixel_y=rand(min,max), time=1)
	//	else
	//		animate(pixel_x=rand(min,max), pixel_y=rand(min,max), time=1)
	//animate(pixel_x=oldx, pixel_y=oldy, time=1)

/proc/findname(msg)
	if(!istext(msg))
		msg = "[msg]"
	for(var/i in GLOB.mob_list)
		var/mob/M = i
		if(M.real_name == msg)
			return M
	return 0

/mob/verb/a_intent_change(input as text)
	set name = "a-intent"
	set hidden = 1

	if(!possible_a_intents || !possible_a_intents.len)
		return

	if(input in possible_a_intents)
		a_intent = input
	else
		var/current_intent = possible_a_intents.Find(a_intent)

		if(!current_intent)
			current_intent = 1

		if(input == INTENT_HOTKEY_RIGHT)
			current_intent += 1
		if(input == INTENT_HOTKEY_LEFT)
			current_intent -= 1

		if(current_intent < 1)
			current_intent = possible_a_intents.len
		if(current_intent > possible_a_intents.len)
			current_intent = 1

		a_intent = possible_a_intents[current_intent]

	if(hud_used && hud_used.action_intent)
		hud_used.action_intent.icon_state = "[a_intent]"

/proc/is_blind(A)
	if(ismob(A))
		var/mob/B = A
		return B.eye_blind
	return FALSE

/mob/proc/hallucinating()
	return FALSE

/proc/IsAdminGhost(var/mob/user)
	if(!user)
		return
	if(!user.client)
		return
	if(!isobserver(user))
		return
	//if(!check_rights_for(user.client, R_ADMIN))
	//	return
	//if(!user.client.AI_Interact)
	//	return
	return TRUE

/mob/proc/is_flying(mob/M = src)
	if(M.movement_type & FLYING)
		return 1
	else
		return 0

/mob/proc/can_hear()
	. = TRUE

/mob/proc/common_trait_examine()
	. = ""

	if(has_trait(TRAIT_DISSECTED))
		. += "<span class='notice'>This body has been dissected and analyzed. It is no longer worth experimenting on.</span><br>"