/world/New()

	log_world("World loaded at [time_stamp()]!")

	//GLOB.config_error_log = GLOB.world_manifest_log = GLOB.world_pda_log = GLOB.world_job_debug_log = GLOB.sql_error_log = GLOB.world_href_log = GLOB.world_runtime_log = GLOB.world_attack_log = GLOB.world_game_log = "data/logs/config_error.[GUID()].log"
	GLOB.config_error_log = GLOB.world_manifest_log = GLOB.world_pda_log = GLOB.world_job_debug_log = GLOB.sql_error_log = GLOB.world_href_log = GLOB.world_runtime_log = GLOB.world_attack_log = GLOB.world_game_log = "data/logs/config_error.[rand(0, 99999)].log"//not_actual

	make_datum_references_lists()

	//config.Load(params[OVERRIDE_CONFIG_DIRECTORY_PARAMETER])
	config.Load()//not_actual

	SetupLogs()

	GLOB.timezoneOffset = text2num(time2text(0,"hh")) * 36000

	Master.Initialize(10, FALSE, TRUE)

/world/proc/SetupLogs()
	//var/override_dir = params[OVERRIDE_LOG_DIRECTORY_PARAMETER]
	var/override_dir = null//not_actual
	if(!override_dir)
		var/realtime = world.realtime
		var/texttime = time2text(realtime, "YYYY/MM/DD")
		GLOB.log_directory = "data/logs/[texttime]/round-"
		//GLOB.picture_logging_prefix = "L_[time2text(realtime, "YYYYMMDD")]_"
		//GLOB.picture_log_directory = "data/picture_logs/[texttime]/round-"
		if(GLOB.round_id)
			GLOB.log_directory += "[GLOB.round_id]"
			//GLOB.picture_logging_prefix += "R_[GLOB.round_id]_"
			//GLOB.picture_log_directory += "[GLOB.round_id]"
		else
			var/timestamp = replacetext(time_stamp(), ":", ".")
			GLOB.log_directory += "[timestamp]"
			//GLOB.picture_log_directory += "[timestamp]"
			//GLOB.picture_logging_prefix += "T_[timestamp]_"
	//else
	//	GLOB.log_directory = "data/logs/[override_dir]"
	//	GLOB.picture_logging_prefix = "O_[override_dir]_"
	//	GLOB.picture_log_directory = "data/picture_logs/[override_dir]"

	GLOB.world_game_log = "[GLOB.log_directory]/game.log"
	GLOB.world_mecha_log = "[GLOB.log_directory]/mecha.log"
	GLOB.world_attack_log = "[GLOB.log_directory]/attack.log"
	GLOB.world_pda_log = "[GLOB.log_directory]/pda.log"
	GLOB.world_telecomms_log = "[GLOB.log_directory]/telecomms.log"
	GLOB.world_manifest_log = "[GLOB.log_directory]/manifest.log"
	GLOB.world_href_log = "[GLOB.log_directory]/hrefs.log"
	GLOB.sql_error_log = "[GLOB.log_directory]/sql.log"
	GLOB.world_qdel_log = "[GLOB.log_directory]/qdel.log"
	GLOB.world_runtime_log = "[GLOB.log_directory]/runtime.log"
	GLOB.query_debug_log = "[GLOB.log_directory]/query_debug.log"
	GLOB.world_job_debug_log = "[GLOB.log_directory]/job_debug.log"

//#ifdef UNIT_TESTS
//	GLOB.test_log = file("[GLOB.log_directory]/tests.log")
//	start_log(GLOB.test_log)
//#endif
	start_log(GLOB.world_game_log)
	start_log(GLOB.world_attack_log)
	start_log(GLOB.world_pda_log)
	start_log(GLOB.world_telecomms_log)
	start_log(GLOB.world_manifest_log)
	start_log(GLOB.world_href_log)
	start_log(GLOB.world_qdel_log)
	start_log(GLOB.world_runtime_log)
	start_log(GLOB.world_job_debug_log)

	//GLOB.changelog_hash = md5('html/changelog.html')
	if(fexists(GLOB.config_error_log))
		fcopy(GLOB.config_error_log, "[GLOB.log_directory]/config_error.log")
		fdel(GLOB.config_error_log)

	if(GLOB.round_id)
		log_game("Round ID: [GLOB.round_id]")

	//log_runtime(GLOB.revdata.get_log_message())

/world/proc/incrementMaxZ()
	maxz++
	//SSmobs.MaxZChanged()
	//SSidlenpcpool.MaxZChanged