/mob/Login()
	GLOB.player_list |= src
	//lastKnownIP	= client.address
	//computer_id	= client.computer_id
	//log_access("Mob Login: [key_name(src)] was assigned to a [type]")
	//world.update_status()
	client.screen = list()
	client.images = list()

	if(!hud_used)
		create_mob_hud()
	if(hud_used)
		hud_used.show_hud(hud_used.hud_version)
		//hud_used.update_ui_style(ui_style2icon(client.prefs.UI_style))

	next_move = 1

	..()

	//reset_perspective(loc)

	if(loc)
		loc.on_log(TRUE)

	//reload_huds()

	reload_fullscreen()

	//add_click_catcher()

	sync_mind()

	//for(var/v in GLOB.active_alternate_appearances)
	//	if(!v)
	//		continue
	//	var/datum/atom_hud/alternate_appearance/AA = v
	//	AA.onNewMob(src)

	//update_client_colour()
	//update_mouse_pointer()
	if(client)
		//client.change_view(CONFIG_GET(string/default_view))

		//if(client.player_details.player_actions.len)
		//	for(var/datum/action/A in client.player_details.player_actions)
		//		A.Grant(src)
		
		//for(var/foo in client.player_details.post_login_callbacks)
		//	var/datum/callback/CB = foo
		//	CB.Invoke()
		//log_played_names(client.ckey,name,real_name)

	//log_message("Client [key_name(src)] has taken ownership of mob [src]([src.type])", LOG_OWNERSHIP)