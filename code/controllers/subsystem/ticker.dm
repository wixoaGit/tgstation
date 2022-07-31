#define ROUND_START_MUSIC_LIST "strings/round_start_sounds.txt"

SUBSYSTEM_DEF(ticker)
	name = "Ticker"
	init_order = INIT_ORDER_TICKER

	priority = FIRE_PRIORITY_TICKER
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME

	var/current_state = GAME_STATE_STARTUP
	var/force_ending = 0
	var/start_immediately = FALSE
	var/setup_done = FALSE

	var/hide_mode = 0
	var/datum/game_mode/mode = null

	var/login_music

	var/list/minds = list()
	
	var/tipped = 0
	var/selected_tip
	
	var/timeLeft
	var/start_at

	var/gametime_offset = 432000
	var/station_time_rate_multiplier = 12
	
	var/totalPlayers = 0
	var/totalPlayersReady = 0

	var/roundend_check_paused = FALSE

	var/round_start_time = 0

/datum/controller/subsystem/ticker/Initialize(timeofday)
	load_mode()

	var/list/music = list()

	if(isemptylist(music))
		music = world.file2list(ROUND_START_MUSIC_LIST, "\n")
		login_music = pick(music)
	else
		login_music = "[global.config.directory]/title_music/sounds/[pick(music)]"

	if(!GLOB.syndicate_code_phrase)
		GLOB.syndicate_code_phrase	= generate_code_phrase()
	if(!GLOB.syndicate_code_response)
		GLOB.syndicate_code_response = generate_code_phrase()

	start_at = world.time + (CONFIG_GET(number/lobby_countdown) * 10)
	if(CONFIG_GET(flag/randomize_shift_time))
		gametime_offset = rand(0, 23) HOURS
	else if(CONFIG_GET(flag/shift_time_realtime))
		gametime_offset = world.timeofday
	return ..()

/datum/controller/subsystem/ticker/fire()
	switch (current_state)
		if(GAME_STATE_STARTUP)
			to_chat(world, "<span class='boldnotice'>Welcome to [station_name()]!</span>")
			current_state = GAME_STATE_PREGAME
			fire()
		if(GAME_STATE_PREGAME)
			if (isnull(timeLeft))
				timeLeft = max(0,start_at - world.time)
			totalPlayers = 0
			totalPlayersReady = 0
			for(var/mob/dead/new_player/player in GLOB.player_list)
				++totalPlayers
				if(player.ready == PLAYER_READY_TO_PLAY)
					++totalPlayersReady
			
			if(start_immediately)
				timeLeft = 0

			if (timeLeft < 0)
				return
			timeLeft = timeLeft - wait
			
			if(timeLeft <= 300 && !tipped)
				send_tip_of_the_round()
				tipped = TRUE

			if (timeLeft <= 0)
				current_state = GAME_STATE_SETTING_UP
				Master.SetRunLevel(RUNLEVEL_SETUP)
				if (start_immediately)
					fire()
		if(GAME_STATE_SETTING_UP)
			if (!setup())
				current_state = GAME_STATE_STARTUP
				start_at = world.time + (CONFIG_GET(number/lobby_countdown) * 10)
				timeLeft = null
				Master.SetRunLevel(RUNLEVEL_LOBBY)
		if(GAME_STATE_PLAYING)
			//mode.process(wait * 0.1)
			//check_queue()
			//check_maprotate()

			if(!roundend_check_paused && mode.check_finished(force_ending) || force_ending)
				current_state = GAME_STATE_FINISHED
				//toggle_ooc(TRUE)
				//toggle_dooc(TRUE)
				declare_completion(force_ending)
				Master.SetRunLevel(RUNLEVEL_POSTGAME)

/datum/controller/subsystem/ticker/proc/setup()
	to_chat(world, "<span class='boldannounce'>Starting game...</span>")

	var/list/datum/game_mode/runnable_modes
	if(GLOB.master_mode == "random" || GLOB.master_mode == "secret")
		//runnable_modes = config.get_runnable_modes()

		//if(GLOB.master_mode == "secret")
		//	hide_mode = 1
		//	if(GLOB.secret_force_mode != "secret")
		//		var/datum/game_mode/smode = config.pick_mode(GLOB.secret_force_mode)
		//		if(!smode.can_start())
		//			message_admins("\blue Unable to force secret [GLOB.secret_force_mode]. [smode.required_players] players and [smode.required_enemies] eligible antagonists needed.")
		//		else
		//			mode = smode

		//if(!mode)
		//	if(!runnable_modes.len)
		//		to_chat(world, "<B>Unable to choose playable game mode.</B> Reverting to pre-game lobby.")
		//		return 0
		//	mode = pickweight(runnable_modes)
		//	if(!mode)	//too few roundtypes all run too recently
		//		mode = pick(runnable_modes)
		return 0//not_actual
	else
		mode = config.pick_mode(GLOB.master_mode)
		if(!mode.can_start())
			to_chat(world, "<B>Unable to start [mode.name].</B> Not enough players, [mode.required_players] players and [mode.required_enemies] eligible antagonists needed. Reverting to pre-game lobby.")
			qdel(mode)
			mode = null
			SSjob.ResetOccupations()
			return 0
	
	var/can_continue = 0
	can_continue = src.mode.pre_setup()
	SSjob.DivideOccupations()

	if(hide_mode)
		var/list/modes = new
		//for (var/datum/game_mode/M in runnable_modes)
		//	modes += M.name
		//modes = sortList(modes)
		to_chat(world, "<b>The gamemode is: secret!\nPossibilities:</B> [english_list(modes)]")
	else
		mode.announce()
	
	create_characters()
	collect_minds()
	equip_characters()

	GLOB.data_core.manifest()

	transfer_characters()
	
	round_start_time = world.time

	to_chat(world, "<FONT color='blue'><B>Welcome to [station_name()], enjoy your stay!</B></FONT>")
	SEND_SOUND(world, sound('sound/ai/welcome.ogg'))
	
	current_state = GAME_STATE_PLAYING
	Master.SetRunLevel(RUNLEVEL_GAME)
	
	PostSetup()
	
	return TRUE

/datum/controller/subsystem/ticker/proc/PostSetup()
	set waitfor = FALSE
	mode.post_setup()
	//GLOB.start_state = new /datum/station_state()
	//GLOB.start_state.count()

	//var/list/adm = get_admin_counts()
	//var/list/allmins = adm["present"]
	//send2irc("Server", "Round [GLOB.round_id ? "#[GLOB.round_id]:" : "of"] [hide_mode ? "secret":"[mode.name]"] has started[allmins.len ? ".":" with no active admins online!"]")
	setup_done = TRUE
	
	for (var/I in GLOB.start_landmarks_list)
		var/obj/effect/landmark/start/S = I
		if (istype(S))
			S.after_round_start()
		else
			stack_trace("[S] [S.type] found in start landmarks list, which isn't a start landmark!")

/datum/controller/subsystem/ticker/proc/create_characters()
	for (var/mob/dead/new_player/player in GLOB.player_list)
		if(player.ready == PLAYER_READY_TO_PLAY && player.mind)
			GLOB.joined_player_list += player.ckey
			player.create_character(FALSE)
		else
			player.new_player_panel()

/datum/controller/subsystem/ticker/proc/collect_minds()
	for(var/mob/dead/new_player/P in GLOB.player_list)
		if(P.new_character && P.new_character.mind)
			SSticker.minds += P.new_character.mind

/datum/controller/subsystem/ticker/proc/equip_characters()
	var/captainless=1
	for(var/mob/dead/new_player/N in GLOB.player_list)
		var/mob/living/carbon/human/player = N.new_character
		if(istype(player) && player.mind && player.mind.assigned_role)
			if(player.mind.assigned_role == "Captain")
				captainless=0
			if(player.mind.assigned_role != player.mind.special_role)
				SSjob.EquipRank(N, player.mind.assigned_role, 0)
			//if(CONFIG_GET(flag/roundstart_traits) && ishuman(N.new_character))
			//	SSquirks.AssignQuirks(N.new_character, N.client, TRUE)
		CHECK_TICK
	if(captainless)
		for(var/mob/dead/new_player/N in GLOB.player_list)
			if(N.new_character)
				to_chat(N, "Captainship not forced on anyone.")
			CHECK_TICK

/datum/controller/subsystem/ticker/proc/transfer_characters()
	var/list/livings = list()
	for(var/mob/dead/new_player/player in GLOB.mob_list)
		var/mob/living = player.transfer_character()
		if(living)
			qdel(player)
			living.notransform = TRUE
			if(living.client)
				var/obj/screen/splash/S = new(living.client, TRUE)
				S.Fade(TRUE)
			livings += living
	if(livings.len)
		addtimer(CALLBACK(src, .proc/release_characters, livings), 30, TIMER_CLIENT_TIME)

/datum/controller/subsystem/ticker/proc/release_characters(list/livings)
	for(var/I in livings)
		var/mob/living/L = I
		L.notransform = FALSE

/datum/controller/subsystem/ticker/proc/send_tip_of_the_round()
	var/m
	if(selected_tip)
		m = selected_tip
	else
		var/list/randomtips = world.file2list("strings/tips.txt")
		var/list/memetips = world.file2list("strings/sillytips.txt")
		if(randomtips.len && prob(95))
			m = pick(randomtips)
		else if(memetips.len)
			m = pick(memetips)

	if(m)
		to_chat(world, "<font color='purple'><b>Tip of the round: </b>[html_encode(m)]</font>")

/datum/controller/subsystem/ticker/proc/HasRoundStarted()
	return current_state >= GAME_STATE_PLAYING

/datum/controller/subsystem/ticker/proc/IsRoundInProgress()
	return current_state == GAME_STATE_PLAYING

/datum/controller/subsystem/ticker/proc/GetTimeLeft()
	if(isnull(SSticker.timeLeft))
		return max(0, start_at - world.time)
	return timeLeft

/datum/controller/subsystem/ticker/proc/load_mode()
	var/mode = trim(file2text("data/mode.txt"))
	if(mode)
		GLOB.master_mode = mode
	else
		GLOB.master_mode = "extended"
	log_game("Saved mode is '[GLOB.master_mode]'")