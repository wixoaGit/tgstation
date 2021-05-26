//GLOBAL_PROTECT(admin_verbs_debug_mapping)
GLOBAL_LIST_INIT(admin_verbs_debug_mapping, list(
	///client/proc/camera_view,
	///client/proc/sec_camera_report,
	///client/proc/intercom_view,
	///client/proc/air_status,
	///client/proc/Cell,
	///client/proc/atmosscan,
	///client/proc/powerdebug,
	///client/proc/count_objects_on_z_level,
	///client/proc/count_objects_all,
	///client/proc/cmd_assume_direct_control,
	///client/proc/startSinglo,
	///client/proc/set_server_fps,
	/client/proc/cmd_admin_grantfullaccess,
	///client/proc/cmd_admin_areatest_all,
	///client/proc/cmd_admin_areatest_station,
	//#ifdef TESTING
	///client/proc/see_dirty_varedits,
	//#endif
	///client/proc/cmd_admin_test_atmos_controllers,
	///client/proc/cmd_admin_rejuvenate,
	///datum/admins/proc/show_traitor_panel,
	///client/proc/disable_communication,
	///client/proc/cmd_show_at_list,
	///client/proc/cmd_show_at_markers,
	///client/proc/manipulate_organs,
	///client/proc/start_line_profiling,
	///client/proc/stop_line_profiling,
	///client/proc/show_line_profiling,
	///client/proc/create_mapping_job_icons,
	///client/proc/debug_z_levels,
	///client/proc/place_ruin
))

/client/proc/enable_debug_verbs()
	//set category = "Debug"
	//set name = "Debug verbs - Enable"
	//if(!check_rights(R_DEBUG))
	//	return
	verbs -= /client/proc/enable_debug_verbs
	verbs.Add(/client/proc/disable_debug_verbs, GLOB.admin_verbs_debug_mapping)
	//SSblackbox.record_feedback("tally", "admin_verb", 1, "Enable Debug Verbs")

/client/proc/disable_debug_verbs()
	//set category = "Debug"
	//set name = "Debug verbs - Disable"
	verbs.Remove(/client/proc/disable_debug_verbs, GLOB.admin_verbs_debug_mapping)
	verbs += /client/proc/enable_debug_verbs
	//SSblackbox.record_feedback("tally", "admin_verb", 1, "Disable Debug Verbs")