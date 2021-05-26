///client/proc/cmd_admin_delete(atom/A as obj|mob|turf in world)
/client/proc/cmd_admin_delete(atom/A as obj|mob)//not_actual
	//set category = "Admin"
	//set name = "Delete"

	if(!check_rights(R_SPAWN|R_DEBUG))
		return

	//admin_delete(A)
	qdel(A)//not_actual

///client/proc/open_shuttle_manipulator()
/mob/verb/open_shuttle_manipulator()//not_actual
	//set category = "Admin"
	//set name = "Shuttle Manipulator"
	//set desc = "Opens the shuttle manipulator UI."

	for(var/obj/machinery/shuttle_manipulator/M in GLOB.machines)
		M.ui_interact(usr)