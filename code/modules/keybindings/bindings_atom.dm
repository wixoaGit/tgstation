/atom/movable/keyLoop(client/user)
	if(!user.keys_held["Ctrl"])
		var/movement_dir = NONE
		for(var/_key in user.keys_held)
			movement_dir = movement_dir | SSinput.movement_keys[_key]
		if(user.next_move_dir_add)
			movement_dir |= user.next_move_dir_add
		if(user.next_move_dir_sub)
			movement_dir &= ~user.next_move_dir_sub
		if((movement_dir & NORTH) && (movement_dir & SOUTH))
			movement_dir &= ~(NORTH|SOUTH)
		if((movement_dir & EAST) && (movement_dir & WEST))
			movement_dir &= ~(EAST|WEST)
		user.Move(get_step(src, movement_dir), movement_dir)