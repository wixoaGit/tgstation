/datum/controller/configuration
	name = "Configuration"

	var/directory = "config"

	var/list/entries
	var/list/entries_by_type

	var/list/maplist
	var/datum/map_config/defaultmap

	var/list/modes
	var/list/gamemode_cache
	var/list/votable_modes
	var/list/mode_names
	var/list/mode_reports
	var/list/mode_false_report_weight

	var/motd

/datum/controller/configuration/proc/Load(_directory)
	//if(IsAdminAdvancedProcCall())
	//	return
	if(_directory)
		directory = _directory
	//if(entries)
	//	CRASH("[THIS_PROC_TYPE_WEIRD] called more than once!")
	InitEntries()
	LoadModes()
	if(fexists("[directory]/config.txt") && LoadEntries("config.txt") <= 1)
		var/list/legacy_configs = list("game_options.txt", "dbconfig.txt", "comms.txt")
		//for(var/I in legacy_configs)
		//	if(fexists("[directory]/[I]"))
		//		log_config("No $include directives found in config.txt! Loading legacy [legacy_configs.Join("/")] files...")
		//		for(var/J in legacy_configs)
		//			LoadEntries(J)
		//		break
	//loadmaplist(CONFIG_MAPS_FILE)
	LoadMOTD()

/datum/controller/configuration/proc/InitEntries()
	var/list/_entries = list()
	entries = _entries
	var/list/_entries_by_type = list()
	entries_by_type = _entries_by_type

	for(var/I in typesof(/datum/config_entry))
		var/datum/config_entry/E = I
		if(initial(E.abstract_type) == I)
			continue
		E = new I
		var/esname = E.name
		var/datum/config_entry/test = _entries[esname]
		if(test)
			log_config("Error: [test.type] has the same name as [E.type]: [esname]! Not initializing [E.type]!")
			qdel(E)
			continue
		_entries[esname] = E
		_entries_by_type[I] = E

/datum/controller/configuration/proc/LoadEntries(filename, list/stack = list())
	//if(IsAdminAdvancedProcCall())
	//	return

	//var/filename_to_test = world.system_type == MS_WINDOWS ? lowertext(filename) : filename
	var/filename_to_test = lowertext(filename)//not_actual
	if(filename_to_test in stack)
		//log_config("Warning: Config recursion detected ([english_list(stack)]), breaking!")
		return
	stack = stack + filename_to_test

	log_config("Loading config file [filename]...")
	var/list/lines = world.file2list("[directory]/[filename]")
	var/list/_entries = entries
	for(var/L in lines)
		L = trim(L)
		if(!L)
			continue

		var/firstchar = copytext(L, 1, 2)
		if(firstchar == "#")
			continue

		var/lockthis = firstchar == "@"
		if(lockthis)
			L = copytext(L, 2)

		var/pos = findtext(L, " ")
		var/entry = null
		var/value = null

		if(pos)
			entry = lowertext(copytext(L, 1, pos))
			value = copytext(L, pos + 1)
		else
			entry = lowertext(L)

		if(!entry)
			continue

		if(entry == "$include")
			if(!value)
				log_config("Warning: Invalid $include directive: [value]")
			else
				LoadEntries(value, stack)
				++.
			continue

		var/datum/config_entry/E = _entries[entry]
		if(!E)
			log_config("Unknown setting in configuration: '[entry]'")
			continue

		if(lockthis)
			E.protection |= CONFIG_ENTRY_LOCKED

		//if(E.deprecated_by)
		//	var/datum/config_entry/new_ver = entries_by_type[E.deprecated_by]
		//	var/new_value = E.DeprecationUpdate(value)
		//	var/good_update = istext(new_value)
		//	log_config("Entry [entry] is deprecated and will be removed soon. Migrate to [new_ver.name]![good_update ? " Suggested new value is: [new_value]" : ""]")
		//	if(!warned_deprecated_configs)
		//		addtimer(CALLBACK(GLOBAL_PROC, /proc/message_admins, "This server is using deprecated configuration settings. Please check the logs and update accordingly."), 0)
		//		warned_deprecated_configs = TRUE
		//	if(good_update)
		//		value = new_value
		//		E = new_ver
		//	else
		//		warning("[new_ver.type] is deprecated but gave no proper return for DeprecationUpdate()")

		var/validated = E.ValidateAndSet(value)
		if(!validated)
			log_config("Failed to validate setting \"[value]\" for [entry]")
		else
			if(E.modified && !E.dupes_allowed)
				log_config("Duplicate setting for [entry] ([value], [E.resident_file]) detected! Using latest.")

		E.resident_file = filename

		if(validated)
			E.modified = TRUE

	++.

/datum/controller/configuration/proc/Get(entry_type)
	var/datum/config_entry/E = entry_type
	var/entry_is_abstract = initial(E.abstract_type) == entry_type
	if(entry_is_abstract)
		CRASH("Tried to retrieve an abstract config_entry: [entry_type]")
	E = entries_by_type[entry_type]
	if(!E)
		CRASH("Missing config entry for [entry_type]!")
	//if((E.protection & CONFIG_ENTRY_HIDDEN) && IsAdminAdvancedProcCall() && GLOB.LastAdminCalledProc == "Get" && GLOB.LastAdminCalledTargetRef == "[REF(src)]")
	//	log_admin_private("Config access of [entry_type] attempted by [key_name(usr)]")
	//	return
	return E.config_entry_value

/datum/controller/configuration/proc/LoadModes()
	gamemode_cache = typecacheof(/datum/game_mode, TRUE)
	modes = list()
	mode_names = list()
	mode_reports = list()
	mode_false_report_weight = list()
	votable_modes = list()
	var/list/probabilities = Get(/datum/config_entry/keyed_list/probability)
	for(var/T in gamemode_cache)
		var/datum/game_mode/M = new T()

		if(M.config_tag)
			if(!(M.config_tag in modes))
				modes += M.config_tag
				mode_names[M.config_tag] = M.name
				probabilities[M.config_tag] = M.probability
				mode_reports[M.report_type] = M.generate_report()
				if(probabilities[M.config_tag]>0)
					mode_false_report_weight[M.report_type] = M.false_report_weight
				else
					mode_false_report_weight[M.report_type] = min(1, M.false_report_weight)
				if(M.votable)
					votable_modes += M.config_tag
		qdel(M)
	votable_modes += "secret"

/datum/controller/configuration/proc/LoadMOTD()
	motd = file2text("[directory]/motd.txt")
	//var/tm_info = GLOB.revdata.GetTestMergeInfo()
	var/tm_info = ""//not_actual
	if(motd || tm_info)
		motd = motd ? "[motd]<br>[tm_info]" : tm_info

/datum/controller/configuration/proc/pick_mode(mode_name)
	for(var/T in gamemode_cache)
		var/datum/game_mode/M = T
		var/ct = initial(M.config_tag)
		if(ct && ct == mode_name)
			return new T
	return new /datum/game_mode/extended()