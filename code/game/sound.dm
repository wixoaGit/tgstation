/proc/playsound(atom/source, soundin, vol as num, vary, extrarange as num, falloff, frequency = null, channel = 0, pressure_affected = TRUE, ignore_walls = TRUE)
	if(isarea(source))
		throw EXCEPTION("playsound(): source is an area")
		return

	var/turf/turf_source = get_turf(source)

	if (!turf_source)
		return
	
	channel = channel || open_sound_channel()

	var/sound/S = sound(get_sfx(soundin))
	//var/maxdistance = (world.view + extrarange)
	var/maxdistance = (15 + extrarange)//not_actual
	var/z = turf_source.z
	//var/list/listeners = SSmobs.clients_by_zlevel[z]
	var/list/listeners = GLOB.player_list//not_actual
	//if(!ignore_walls)
	//	listeners = listeners & hearers(maxdistance,turf_source)
	for(var/P in listeners)
		var/mob/M = P
		if(get_dist(M, turf_source) <= maxdistance)
			M.playsound_local(turf_source, soundin, vol, vary, frequency, falloff, channel, pressure_affected, S)
	//for(var/P in SSmobs.dead_players_by_zlevel[z])
	//	var/mob/M = P
	//	if(get_dist(M, turf_source) <= maxdistance)
	//		M.playsound_local(turf_source, soundin, vol, vary, frequency, falloff, channel, pressure_affected, S)

/mob/proc/playsound_local(turf/turf_source, soundin, vol as num, vary, frequency, falloff, channel = 0, pressure_affected = TRUE, sound/S)
	if(!client || !can_hear())
		return

	if(!S)
		S = sound(get_sfx(soundin))

	S.wait = 0
	S.channel = channel || open_sound_channel()
	S.volume = vol

	if(vary)
		if(frequency)
			S.frequency = frequency
		else
			S.frequency = get_rand_frequency()

	if(isturf(turf_source))
		var/turf/T = get_turf(src)

		var/distance = get_dist(T, turf_source)

		//S.volume -= max(distance - world.view, 0) * 2
		S.volume -= max(distance - 15, 0) * 2//not_actual

		if(pressure_affected)
			var/pressure_factor = 1
			var/datum/gas_mixture/hearer_env = T.return_air()
			var/datum/gas_mixture/source_env = turf_source.return_air()

			if(hearer_env && source_env)
				var/pressure = min(hearer_env.return_pressure(), source_env.return_pressure())
				if(pressure < ONE_ATMOSPHERE)
					pressure_factor = max((pressure - SOUND_MINIMUM_PRESSURE)/(ONE_ATMOSPHERE - SOUND_MINIMUM_PRESSURE), 0)
			else
				pressure_factor = 0

			if(distance <= 1)
				pressure_factor = max(pressure_factor, 0.15)

			S.volume *= pressure_factor

		if(S.volume <= 0)
			return

		var/dx = turf_source.x - T.x
		S.x = dx
		var/dz = turf_source.y - T.y
		S.z = dz
		S.y = 1
		S.falloff = (falloff ? falloff : FALLOFF_SOUNDS)

	SEND_SOUND(src, S)

GLOBAL_VAR_INIT(next_channel, 1)//not_actual
/proc/open_sound_channel()
	//var/static/next_channel = 1
	//. = ++next_channel
	. = ++GLOB.next_channel//not_actual
	//if(next_channel > CHANNEL_HIGHEST_AVAILABLE)
	if(GLOB.next_channel > CHANNEL_HIGHEST_AVAILABLE)//not_actual
		//next_channel = 1
		GLOB.next_channel = 1//not_actual

/mob/proc/stop_sound_channel(chan)
	SEND_SOUND(src, sound(null, repeat = 0, wait = 0, channel = chan))

/client/proc/playtitlemusic(vol = 85)
	set waitfor = FALSE
	UNTIL(SSticker.login_music)

	//if(prefs && (prefs.toggles & SOUND_LOBBY))
	if (TRUE)//not_actual
		SEND_SOUND(src, sound(SSticker.login_music, repeat = 0, wait = 0, volume = vol, channel = CHANNEL_LOBBYMUSIC))

/proc/get_rand_frequency()
	return rand(32000, 55000)

/proc/get_sfx(soundin)
	if(istext(soundin))
		switch(soundin)
			if ("shatter")
				soundin = pick('sound/effects/glassbr1.ogg','sound/effects/glassbr2.ogg','sound/effects/glassbr3.ogg')
			if ("explosion")
				soundin = pick('sound/effects/explosion1.ogg','sound/effects/explosion2.ogg')
			if ("sparks")
				soundin = pick('sound/effects/sparks1.ogg','sound/effects/sparks2.ogg','sound/effects/sparks3.ogg','sound/effects/sparks4.ogg')
			if ("rustle")
				soundin = pick('sound/effects/rustle1.ogg','sound/effects/rustle2.ogg','sound/effects/rustle3.ogg','sound/effects/rustle4.ogg','sound/effects/rustle5.ogg')
			if ("bodyfall")
				soundin = pick('sound/effects/bodyfall1.ogg','sound/effects/bodyfall2.ogg','sound/effects/bodyfall3.ogg','sound/effects/bodyfall4.ogg')
			if ("punch")
				soundin = pick('sound/weapons/punch1.ogg','sound/weapons/punch2.ogg','sound/weapons/punch3.ogg','sound/weapons/punch4.ogg')
			if ("clownstep")
				soundin = pick('sound/effects/clownstep1.ogg','sound/effects/clownstep2.ogg')
			if ("suitstep")
				soundin = pick('sound/effects/suitstep1.ogg','sound/effects/suitstep2.ogg')
			if ("swing_hit")
				soundin = pick('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg')
			if ("hiss")
				soundin = pick('sound/voice/hiss1.ogg','sound/voice/hiss2.ogg','sound/voice/hiss3.ogg','sound/voice/hiss4.ogg')
			if ("pageturn")
				soundin = pick('sound/effects/pageturn1.ogg', 'sound/effects/pageturn2.ogg','sound/effects/pageturn3.ogg')
			if ("gunshot")
				soundin = pick('sound/weapons/gunshot.ogg', 'sound/weapons/gunshot2.ogg','sound/weapons/gunshot3.ogg','sound/weapons/gunshot4.ogg')
			if ("ricochet")
				soundin = pick(	'sound/weapons/effects/ric1.ogg', 'sound/weapons/effects/ric2.ogg','sound/weapons/effects/ric3.ogg','sound/weapons/effects/ric4.ogg','sound/weapons/effects/ric5.ogg')
			if ("terminal_type")
				soundin = pick('sound/machines/terminal_button01.ogg', 'sound/machines/terminal_button02.ogg', 'sound/machines/terminal_button03.ogg', \
								'sound/machines/terminal_button04.ogg', 'sound/machines/terminal_button05.ogg', 'sound/machines/terminal_button06.ogg', \
								'sound/machines/terminal_button07.ogg', 'sound/machines/terminal_button08.ogg')
			if ("desceration")
				soundin = pick('sound/misc/desceration-01.ogg', 'sound/misc/desceration-02.ogg', 'sound/misc/desceration-03.ogg')
			if ("im_here")
				soundin = pick('sound/hallucinations/im_here1.ogg', 'sound/hallucinations/im_here2.ogg')
			if ("can_open")
				soundin = pick('sound/effects/can_open1.ogg', 'sound/effects/can_open2.ogg', 'sound/effects/can_open3.ogg')
			if("bullet_miss")
				soundin = pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg')
			if("gun_insert_empty_magazine")
				soundin = pick('sound/weapons/gun_magazine_insert_empty_1.ogg', 'sound/weapons/gun_magazine_insert_empty_2.ogg', 'sound/weapons/gun_magazine_insert_empty_3.ogg', 'sound/weapons/gun_magazine_insert_empty_4.ogg')
			if("gun_insert_full_magazine")
				soundin = pick('sound/weapons/gun_magazine_insert_full_1.ogg', 'sound/weapons/gun_magazine_insert_full_2.ogg', 'sound/weapons/gun_magazine_insert_full_3.ogg', 'sound/weapons/gun_magazine_insert_full_4.ogg', 'sound/weapons/gun_magazine_insert_full_5.ogg')
			if("gun_remove_empty_magazine")
				soundin = pick('sound/weapons/gun_magazine_remove_empty_1.ogg', 'sound/weapons/gun_magazine_remove_empty_2.ogg', 'sound/weapons/gun_magazine_remove_empty_3.ogg', 'sound/weapons/gun_magazine_remove_empty_4.ogg')
			if("gun_slide_lock")
				soundin = pick('sound/weapons/gun_slide_lock_1.ogg', 'sound/weapons/gun_slide_lock_2.ogg', 'sound/weapons/gun_slide_lock_3.ogg', 'sound/weapons/gun_slide_lock_4.ogg', 'sound/weapons/gun_slide_lock_5.ogg')
			if("revolver_spin")
				soundin = pick('sound/weapons/revolverspin1.ogg', 'sound/weapons/revolverspin2.ogg', 'sound/weapons/revolverspin3.ogg')
			if("law")
				soundin = pick('sound/voice/beepsky/god.ogg', 'sound/voice/beepsky/iamthelaw.ogg', 'sound/voice/beepsky/secureday.ogg', 'sound/voice/beepsky/radio.ogg', 'sound/voice/beepsky/insult.ogg', 'sound/voice/beepsky/creep.ogg')
			if("honkbot_e")
				soundin = pick('sound/items/bikehorn.ogg', 'sound/items/AirHorn2.ogg', 'sound/misc/sadtrombone.ogg', 'sound/items/AirHorn.ogg', 'sound/effects/reee.ogg',  'sound/items/WEEOO1.ogg', 'sound/voice/beepsky/iamthelaw.ogg', 'sound/voice/beepsky/creep.ogg','sound/magic/Fireball.ogg' ,'sound/effects/pray.ogg', 'sound/voice/hiss1.ogg','sound/machines/buzz-sigh.ogg', 'sound/machines/ping.ogg', 'sound/weapons/flashbang.ogg', 'sound/weapons/bladeslice.ogg')
	return soundin