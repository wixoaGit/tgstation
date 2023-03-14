/client/verb/keyDown(_key as text)
	set instant = TRUE
	set hidden = TRUE

	keys_held[_key] = world.time
	var/movement = SSinput.movement_keys[_key]
	if(!(next_move_dir_sub & movement) && !keys_held["Ctrl"])
		next_move_dir_add |= movement

	switch(_key)
		//if("F1")
		//	if(keys_held["Ctrl"] && keys_held["Shift"])
		//		winset(src, null, "command=.options")
		//	else
		//		get_adminhelp()
		//	return
		if("F2")
			winset(src, null, "command=.screenshot [!keys_held["shift"] ? "auto" : ""]")
			return
		//if("F12")
		//	mob.button_pressed_F12()
		//	return

	if(holder)
		holder.key_down(_key, src)
	if(mob.focus)
		mob.focus.key_down(_key, src)

/client/verb/keyUp(_key as text)
	set instant = TRUE
	set hidden = TRUE

	keys_held -= _key
	var/movement = SSinput.movement_keys[_key]
	if(!(next_move_dir_add & movement))
		next_move_dir_sub |= movement

	if(holder)
		holder.key_up(_key, src)
	if(mob.focus)
		mob.focus.key_up(_key, src)

/client/keyLoop()
	if(holder)
		holder.keyLoop(src)
	if(mob.focus)
		mob.focus.keyLoop(src)