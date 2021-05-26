/proc/lizard_name(gender)
	if(gender == MALE)
		return "[pick(GLOB.lizard_names_male)]-[pick(GLOB.lizard_names_male)]"
	else
		return "[pick(GLOB.lizard_names_female)]-[pick(GLOB.lizard_names_female)]"

GLOBAL_VAR(command_name)
/proc/command_name()
	if (GLOB.command_name)
		return GLOB.command_name

	var/name = "Central Command"

	GLOB.command_name = name
	return name

/proc/station_name()
	if(!GLOB.station_name)
		var/newname
		var/config_station_name = CONFIG_GET(string/stationname)
		if(config_station_name)
			newname = config_station_name
		else
			newname = new_station_name()
		
		set_station_name(newname)

	return GLOB.station_name

/proc/set_station_name(newname)
	GLOB.station_name = newname

	var/config_server_name = CONFIG_GET(string/servername)
	if(config_server_name)
		world.name = "[config_server_name][config_server_name == GLOB.station_name ? "" : ": [GLOB.station_name]"]"
	else
		world.name = GLOB.station_name


/proc/new_station_name()
	var/random = rand(1,5)
	var/name = ""
	var/new_station_name = ""

	if (prob(10))
		name = pick(GLOB.station_prefixes)
		new_station_name = name + " "
		name = ""

	//for(var/holiday_name in SSevents.holidays)
	//	if(holiday_name == "Friday the 13th")
	//		random = 13
	//	var/datum/holiday/holiday = SSevents.holidays[holiday_name]
	//	name = holiday.getStationPrefix()
	if(!name)
		name = pick(GLOB.station_names)
	if(name)
		new_station_name += name + " "

	name = pick(GLOB.station_suffixes)
	new_station_name += name + " "

	switch(random)
		if(1)
			new_station_name += "[rand(1, 99)]"
		if(2)
			new_station_name += pick(GLOB.greek_letters)
		if(3)
			new_station_name += "\Roman[rand(1,99)]"
		if(4)
			new_station_name += pick(GLOB.phonetic_alphabet)
		if(5)
			new_station_name += pick(GLOB.numbers_as_words)
		if(13)
			new_station_name += pick("13","XIII","Thirteen")
	return new_station_name

GLOBAL_VAR(syndicate_code_phrase)
GLOBAL_VAR(syndicate_code_response)

/proc/generate_code_phrase(return_list=FALSE)

	if(!return_list)
		. = ""
	else
		. = list()

	//var/words = pick(
	//	50; 2,
	//	200; 3,
	//	50; 4,
	//	25; 5
	//)
	var/words = pick(2, 3, 4, 5)//not_actual

	var/list/safety = list(1,2,3)
	var/nouns = strings(ION_FILE, "ionabstract")
	var/objects = strings(ION_FILE, "ionobjects")
	var/adjectives = strings(ION_FILE, "ionadjectives")
	var/threats = strings(ION_FILE, "ionthreats")
	var/foods = strings(ION_FILE, "ionfood")
	var/drinks = strings(ION_FILE, "iondrinks")
	//var/list/locations = GLOB.teleportlocs.len ? GLOB.teleportlocs : drinks
	var/list/locations = drinks//not_actual

	var/list/names = list()
	for(var/datum/data/record/t in GLOB.data_core.general)
		names += t.fields["name"]

	var/maxwords = words

	for(words,words>0,words--)
		if(words==1&&(1 in safety)&&(2 in safety))
			safety = list(pick(1,2))
		else if(words==1&&maxwords==2)
			safety = list(3)

		switch(pick(safety))
			if(1)
				switch(rand(1,2))
					if(1)
						if(names.len&&prob(70))
							. += pick(names)
						else
							if(prob(10))
								. += pick(lizard_name(MALE),lizard_name(FEMALE))
							else
								var/new_name = pick(pick(GLOB.first_names_male,GLOB.first_names_female))
								new_name += " "
								new_name += pick(GLOB.last_names)
								. += new_name
					if(2)
						. += pick(get_all_jobs())
				safety -= 1
			if(2)
				switch(rand(1,3))
					if(1)
						. += lowertext(pick(drinks))
					if(2)
						. += lowertext(pick(foods))
					if(3)
						. += lowertext(pick(locations))
				safety -= 2
			if(3)
				switch(rand(1,4))
					if(1)
						. += lowertext(pick(nouns))
					if(2)
						. += lowertext(pick(objects))
					if(3)
						. += lowertext(pick(adjectives))
					if(4)
						. += lowertext(pick(threats))
		if(!return_list)
			if(words==1)
				. += "."
			else
				. += ", "