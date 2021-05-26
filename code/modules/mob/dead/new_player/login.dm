/mob/dead/new_player/Login()
	//if(CONFIG_GET(flag/use_exp_tracking))
	//	client.set_exp_from_db()
	//	client.set_db_player_flags()
	if(!mind)
		mind = new /datum/mind(key)
		mind.active = 1
		mind.current = src
	
	..()

	//var/motd = global.config.motd
	var/motd = config.motd//not_actual
	if(motd)
		//to_chat(src, "<div class=\"motd\">[motd]</div>", handle_whitespace=FALSE)
		to_chat(src, "<div class='motd'>[motd]</div>", handle_whitespace=FALSE)//not_actual
	
	new_player_panel()
	client.playtitlemusic()