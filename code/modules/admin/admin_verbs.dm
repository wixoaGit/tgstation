//GLOBAL_PROTECT(admin_verbs_admin)
GLOBAL_LIST_INIT(admin_verbs_admin, world.AVerbsAdmin())
/world/proc/AVerbsAdmin()
	return list(
	///client/proc/invisimin,
	///datum/admins/proc/show_player_panel,
	///datum/verbs/menu/Admin/verb/playerpanel,
	///client/proc/game_panel,
	///client/proc/check_ai_laws,
	///datum/admins/proc/toggleooc,
	///datum/admins/proc/toggleoocdead,
	///datum/admins/proc/toggleenter,
	///datum/admins/proc/toggleguests,
	///datum/admins/proc/announce,
	///datum/admins/proc/set_admin_notice,
	///client/proc/admin_ghost,
	///client/proc/toggle_view_range,
	///client/proc/getserverlogs,
	///client/proc/getcurrentlogs,
	///client/proc/cmd_admin_subtle_message,
	///client/proc/cmd_admin_headset_message,
	///client/proc/cmd_admin_delete,
	///client/proc/cmd_admin_check_contents,
	///client/proc/centcom_podlauncher,
	///client/proc/check_antagonists,
	///datum/admins/proc/access_news_network,
	///client/proc/jumptocoord,
	///client/proc/Getmob,
	///client/proc/Getkey,
	///client/proc/jumptoarea,
	///client/proc/jumptokey,
	///client/proc/jumptomob,
	///client/proc/jumptoturf,
	///client/proc/admin_call_shuttle,
	///client/proc/admin_cancel_shuttle,
	///client/proc/cmd_admin_direct_narrate,
	///client/proc/cmd_admin_world_narrate,
	///client/proc/cmd_admin_local_narrate,
	///client/proc/cmd_admin_create_centcom_report,
	///client/proc/cmd_change_command_name,
	///client/proc/cmd_admin_check_player_exp,
	///client/proc/toggle_combo_hud,
	///client/proc/toggle_AI_interact,
	///client/proc/open_shuttle_manipulator,
	///client/proc/deadchat,
	///client/proc/toggleprayers,
	///client/proc/toggle_prayer_sound,
	///client/proc/colorasay,
	///client/proc/resetasaycolor,
	///client/proc/toggleadminhelpsound,
	///client/proc/respawn_character,
	///datum/admins/proc/open_borgopanel
	)
GLOBAL_LIST_INIT(admin_verbs_server, world.AVerbsServer())
/world/proc/AVerbsServer()
	return list(
	/datum/admins/proc/startnow,
	///datum/admins/proc/restart,
	///datum/admins/proc/end_round,
	///datum/admins/proc/delay,
	///datum/admins/proc/toggleaban,
	///client/proc/everyone_random,
	///datum/admins/proc/toggleAI,
	/client/proc/cmd_admin_delete,
	///client/proc/cmd_debug_del_all,
	///client/proc/toggle_random_events,
	///client/proc/forcerandomrotate,
	///client/proc/adminchangemap,
	///client/proc/panicbunker,
	///client/proc/toggle_hub
	)

//GLOBAL_PROTECT(admin_verbs_debug)
GLOBAL_LIST_INIT(admin_verbs_debug, world.AVerbsDebug())
/world/proc/AVerbsDebug()
	return list(
	///client/proc/restart_controller,
	///client/proc/cmd_admin_list_open_jobs,
	///client/proc/Debug2,
	///client/proc/cmd_debug_make_powernets,
	///client/proc/cmd_debug_mob_lists,
	/client/proc/cmd_admin_delete,
	///client/proc/cmd_debug_del_all,
	///client/proc/restart_controller,
	/client/proc/enable_debug_verbs,
	///client/proc/callproc,
	///client/proc/callproc_datum,
	///client/proc/SDQL2_query,
	///client/proc/test_movable_UI,
	///client/proc/test_snap_UI,
	///client/proc/debugNatureMapGenerator,
	///client/proc/check_bomb_impacts,
	///proc/machine_upgrade,
	///client/proc/populate_world,
	///client/proc/get_dynex_power,
	///client/proc/get_dynex_range,
	///client/proc/set_dynex_scale,
	///client/proc/cmd_display_del_log,
	///client/proc/create_outfits,
	///client/proc/modify_goals,
	///client/proc/debug_huds,
	///client/proc/map_template_load,
	///client/proc/map_template_upload,
	///client/proc/jump_to_ruin,
	///client/proc/clear_dynamic_transit,
	///client/proc/toggle_medal_disable,
	///client/proc/view_runtimes,
	///client/proc/pump_random_event,
	///client/proc/cmd_display_init_log,
	///client/proc/cmd_display_overlay_log,
	///client/proc/reload_configuration,
	///datum/admins/proc/create_or_modify_area,
	)

/client/proc/add_admin_verbs()
	if(holder)
		//control_freak = CONTROL_FREAK_SKIN | CONTROL_FREAK_MACROS

		var/rights = holder.rank.rights
		//verbs += GLOB.admin_verbs_default
		//if(rights & R_BUILD)
		//	verbs += /client/proc/togglebuildmodeself
		if(rights & R_ADMIN)
			verbs += GLOB.admin_verbs_admin
		//if(rights & R_BAN)
		//	verbs += GLOB.admin_verbs_ban
		//if(rights & R_FUN)
		//	verbs += GLOB.admin_verbs_fun
		if(rights & R_SERVER)
			verbs += GLOB.admin_verbs_server
		if(rights & R_DEBUG)
			verbs += GLOB.admin_verbs_debug
		//if(rights & R_POSSESS)
		//	verbs += GLOB.admin_verbs_possess
		//if(rights & R_PERMISSIONS)
		//	verbs += GLOB.admin_verbs_permissions
		//if(rights & R_STEALTH)
		//	verbs += /client/proc/stealth
		//if(rights & R_ADMIN)
		//	verbs += GLOB.admin_verbs_poll
		//if(rights & R_SOUND)
		//	verbs += GLOB.admin_verbs_sounds
		//	if(CONFIG_GET(string/invoke_youtubedl))
		//		verbs += /client/proc/play_web_sound
		//if(rights & R_SPAWN)
		//	verbs += GLOB.admin_verbs_spawn

///client/proc/game_panel()
/mob/verb/game_panel()//not_actual
	//set name = "Game Panel"
	//set category = "Admin"
	//if(holder)
	//	holder.Game()
	//not_actual
	if (client.holder)
		client.holder.Game()
	//SSblackbox.record_feedback("tally", "admin_verb", 1, "Game Panel")