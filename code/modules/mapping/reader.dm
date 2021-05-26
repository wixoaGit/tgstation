#define SPACE_KEY "space"

/datum/grid_set
	var/xcrd
	var/ycrd
	var/zcrd
	var/gridLines

/datum/parsed_map
	var/original_path
	var/key_len = 0
	var/list/grid_models = list()
	var/list/gridSets = list()

	var/list/modelCache

	var/list/parsed_bounds
	var/list/bounds

	//var/static/regex/dmmRegex = new(@'"([a-zA-Z]+)" = \(((?:.|\n)*?)\)\n(?!\t)|\((\d+),(\d+),(\d+)\) = \{"([a-zA-Z\n]*)"\}', "g")
	//var/static/regex/trimQuotesRegex = new(@'^[\s\n]+"?|"?[\s\n]+$|^"|"$', "g")
	//var/static/regex/trimRegex = new(@'^[\s\n]+|[\s\n]+$', "g")
	//not_actual
	var/regex/dmmRegex = new(@'"([a-zA-Z]+)" = \(((?:.|\n)*?)\)\n(?!\t)|\((\d+),(\d+),(\d+)\) = \{"([a-zA-Z\n]*)"\}', "g")
	var/regex/trimQuotesRegex = new(@'^[\s\n]+"?|"?[\s\n]+$|^"|"$', "g")
	var/regex/trimRegex = new(@'^[\s\n]+|[\s\n]+$', "g")

	#ifdef TESTING
	var/turfsSkipped = 0
	#endif

/datum/parsed_map/New(tfile, x_lower = -INFINITY, x_upper = INFINITY, y_lower = -INFINITY, y_upper=INFINITY, measureOnly=FALSE)
	if(isfile(tfile))
		original_path = "[tfile]"
		tfile = file2text(tfile)
	else if(isnull(tfile))
		return

	bounds = parsed_bounds = list(1.#INF, 1.#INF, 1.#INF, -1.#INF, -1.#INF, -1.#INF)
	var/stored_index = 1

	while(dmmRegex.Find(tfile, stored_index))
		stored_index = dmmRegex.next

		if(dmmRegex.group[1])
			var/key = dmmRegex.group[1]
			if(grid_models[key])
				continue
			if(key_len != length(key))
				if(!key_len)
					key_len = length(key)
				else
					CRASH("Inconsistent key length in DMM")
			if(!measureOnly)
				grid_models[key] = dmmRegex.group[2]

		else if(dmmRegex.group[3])
			if(!key_len)
				CRASH("Coords before model definition in DMM")

			var/curr_x = text2num(dmmRegex.group[3])

			if(curr_x < x_lower || curr_x > x_upper)
				continue

			var/datum/grid_set/gridSet = new

			gridSet.xcrd = curr_x
			gridSet.ycrd = text2num(dmmRegex.group[4])
			gridSet.zcrd = text2num(dmmRegex.group[5])

			bounds[MAP_MINX] = min(bounds[MAP_MINX], CLAMP(gridSet.xcrd, x_lower, x_upper))
			bounds[MAP_MINZ] = min(bounds[MAP_MINZ], gridSet.zcrd)
			bounds[MAP_MAXZ] = max(bounds[MAP_MAXZ], gridSet.zcrd)

			var/list/gridLines = splittext(dmmRegex.group[6], "\n")
			gridSet.gridLines = gridLines

			var/leadingBlanks = 0
			//while(leadingBlanks < gridLines.len && gridLines[++leadingBlanks] == "")
			while(leadingBlanks < gridLines.len && gridLines[++leadingBlanks] == "") pass();//not_actual
			if(leadingBlanks > 1)
				gridLines.Cut(1, leadingBlanks)

			if(!gridLines.len)
				continue

			gridSets += gridSet

			if(gridLines.len && gridLines[gridLines.len] == "")
				gridLines.Cut(gridLines.len)

			bounds[MAP_MINY] = min(bounds[MAP_MINY], CLAMP(gridSet.ycrd, y_lower, y_upper))
			gridSet.ycrd += gridLines.len - 1
			bounds[MAP_MAXY] = max(bounds[MAP_MAXY], CLAMP(gridSet.ycrd, y_lower, y_upper))

			var/maxx = gridSet.xcrd
			if(gridLines.len)
				maxx = max(maxx, gridSet.xcrd + length(gridLines[1]) / key_len - 1)

			bounds[MAP_MAXX] = CLAMP(max(bounds[MAP_MAXX], maxx), x_lower, x_upper)
		CHECK_TICK

	if(bounds[1] == 1.#INF)
		bounds = null
	parsed_bounds = bounds

/datum/parsed_map/proc/load(x_offset, y_offset, z_offset, cropMap, no_changeturf, x_lower, x_upper, y_lower, y_upper, placeOnTop)
	Master.StartLoadingMap()
	. = _load_impl(x_offset, y_offset, z_offset, cropMap, no_changeturf, x_lower, x_upper, y_lower, y_upper, placeOnTop)
	Master.StopLoadingMap()

/datum/parsed_map/proc/_load_impl(x_offset = 1, y_offset = 1, z_offset = world.maxz + 1, cropMap = FALSE, no_changeturf = FALSE, x_lower = -INFINITY, x_upper = INFINITY, y_lower = -INFINITY, y_upper = INFINITY, placeOnTop = FALSE)
	var/list/areaCache = list()
	var/list/modelCache = build_cache(no_changeturf)
	var/space_key = modelCache[SPACE_KEY]
	var/list/bounds
	src.bounds = bounds = list(1.#INF, 1.#INF, 1.#INF, -1.#INF, -1.#INF, -1.#INF)

	for(var/I in gridSets)
		var/datum/grid_set/gset = I
		var/ycrd = gset.ycrd + y_offset - 1
		var/zcrd = gset.zcrd + z_offset - 1
		if(!cropMap && ycrd > world.maxy)
			world.maxy = ycrd
		var/zexpansion = zcrd > world.maxz
		if(zexpansion)
			if(cropMap)
				continue
			else
				while (zcrd > world.maxz)
					world.incrementMaxZ()
			if(!no_changeturf)
				WARNING("Z-level expansion occurred without no_changeturf set, this may cause problems when /turf/AfterChange is called")

		for(var/line in gset.gridLines)
			if((ycrd - y_offset + 1) < y_lower || (ycrd - y_offset + 1) > y_upper)
				--ycrd
				continue
			if(ycrd <= world.maxy && ycrd >= 1)
				var/xcrd = gset.xcrd + x_offset - 1
				for(var/tpos = 1 to length(line) - key_len + 1 step key_len)
					if((xcrd - x_offset + 1) < x_lower || (xcrd - x_offset + 1) > x_upper)
						++xcrd
						continue
					if(xcrd > world.maxx)
						if(cropMap)
							break
						else
							world.maxx = xcrd

					if(xcrd >= 1)
						var/model_key = copytext(line, tpos, tpos + key_len)
						var/no_afterchange = no_changeturf || zexpansion
						if(!no_afterchange || (model_key != space_key))
							var/list/cache = modelCache[model_key]
							if(!cache)
								CRASH("Undefined model key in DMM: [model_key]")
							build_coordinate(areaCache, cache, locate(xcrd, ycrd, zcrd), no_afterchange, placeOnTop)

							bounds[MAP_MINX] = min(bounds[MAP_MINX], xcrd)
							bounds[MAP_MINY] = min(bounds[MAP_MINY], ycrd)
							bounds[MAP_MINZ] = min(bounds[MAP_MINZ], zcrd)
							bounds[MAP_MAXX] = max(bounds[MAP_MAXX], xcrd)
							bounds[MAP_MAXY] = max(bounds[MAP_MAXY], ycrd)
							bounds[MAP_MAXZ] = max(bounds[MAP_MAXZ], zcrd)
						#ifdef TESTING
						else
							++turfsSkipped
						#endif
						CHECK_TICK
					++xcrd
			--ycrd

		CHECK_TICK

	if(!no_changeturf)
		for(var/t in block(locate(bounds[MAP_MINX], bounds[MAP_MINY], bounds[MAP_MINZ]), locate(bounds[MAP_MAXX], bounds[MAP_MAXY], bounds[MAP_MAXZ])))
			var/turf/T = t
			T.AfterChange(CHANGETURF_IGNORE_AIR)

	#ifdef TESTING
	if(turfsSkipped)
		testing("Skipped loading [turfsSkipped] default turfs")
	#endif

	return TRUE

/datum/parsed_map/proc/build_cache(no_changeturf, bad_paths=null)
	if(modelCache && !bad_paths)
		return modelCache
	. = modelCache = list()
	var/list/grid_models = src.grid_models
	for(var/model_key in grid_models)
		var/model = grid_models[model_key]
		var/list/members = list()
		var/list/members_attributes = list()

		var/index = 1
		var/old_position = 1
		var/dpos

		while(dpos != 0)
			dpos = find_next_delimiter_position(model, old_position, ",", "{", "}")

			var/full_def = trim_text(copytext(model, old_position, dpos))
			var/variables_start = findtext(full_def, "{")
			var/path_text = trim_text(copytext(full_def, 1, variables_start))
			var/atom_def = text2path(path_text)
			old_position = dpos + 1

			if(!ispath(atom_def, /atom))
				if(bad_paths)
					LAZYOR(bad_paths[path_text], model_key)
				continue
			members.Add(atom_def)

			var/list/fields = list()

			if(variables_start)
				full_def = copytext(full_def,variables_start+1,length(full_def))
				fields = readlist(full_def, ";")
				if(fields.len)
					if(!trim(fields[fields.len]))
						--fields.len
					for(var/I in fields)
						var/value = fields[I]
						if(istext(value))
							fields[I] = apply_text_macros(value)

			members_attributes.len++
			//members_attributes[index++] = fields
			//not_actual
			var/_index = index
			index++
			members_attributes[_index] = fields

			CHECK_TICK
		if(no_changeturf \
			&& !(.[SPACE_KEY]) \
			&& members.len == 2 \
			&& members_attributes.len == 2 \
			&& length(members_attributes[1]) == 0 \
			&& length(members_attributes[2]) == 0 \
			&& (world.area in members) \
			&& (world.turf in members))

			.[SPACE_KEY] = model_key
			continue


		.[model_key] = list(members, members_attributes)

/datum/parsed_map/proc/build_coordinate(list/areaCache, list/model, turf/crds, no_changeturf as num, placeOnTop as num)
	var/index
	var/list/members = model[1]
	var/list/members_attributes = model[2]

	index = members.len
	if(members[index] != /area/template_noop)
		var/atype = members[index]
		GLOB._preloader.setup(members_attributes[index], atype)
		var/atom/instance = areaCache[atype]
		if (!instance)
			instance = GLOB.areas_by_type[atype]
			if (!instance)
				instance = new atype(null)
			areaCache[atype] = instance
		if(crds)
			instance.contents.Add(crds)

		if(GLOB.use_preloader && instance)
			GLOB._preloader.load(instance)

	var/first_turf_index = 1
	//not_actual, uncommenting the following causes only turfs to load correctly?
	//while(!ispath(members[first_turf_index], /turf))
	//	first_turf_index++

	SSatoms.map_loader_begin()
	var/turf/T
	if(members[first_turf_index] != /turf/template_noop)
		T = instance_atom(members[first_turf_index],members_attributes[first_turf_index],crds,no_changeturf,placeOnTop)

	if(T)
		index = first_turf_index + 1
		while(index <= members.len - 1)
			//var/underlay = T.appearance
			T = instance_atom(members[index],members_attributes[index],crds,no_changeturf,placeOnTop)
			//T.underlays += underlay
			index++

	for(index in 1 to first_turf_index-1)
		instance_atom(members[index],members_attributes[index],crds,no_changeturf,placeOnTop)
	SSatoms.map_loader_stop()

/datum/parsed_map/proc/instance_atom(path,list/attributes, turf/crds, no_changeturf, placeOnTop)
	GLOB._preloader.setup(attributes, path)

	if(crds)
		if(ispath(path, /turf))
			if(placeOnTop)
				. = crds.PlaceOnTop(null, path, CHANGETURF_DEFER_CHANGE | (no_changeturf ? CHANGETURF_SKIP : NONE))
			else if(!no_changeturf)
				. = crds.ChangeTurf(path, null, CHANGETURF_DEFER_CHANGE)
			else
				. = create_atom(path, crds)
		else
			. = create_atom(path, crds)

	if(GLOB.use_preloader && .)
		GLOB._preloader.load(.)

	if(TICK_CHECK)
		SSatoms.map_loader_stop()
		stoplag()
		SSatoms.map_loader_begin()

/datum/parsed_map/proc/create_atom(path, crds)
	set waitfor = FALSE
	. = new path (crds)

/datum/parsed_map/proc/trim_text(what as text,trim_quotes=0)
	if(trim_quotes)
		return trimQuotesRegex.Replace(what, "")
	else
		return trimRegex.Replace(what, "")

/datum/parsed_map/proc/find_next_delimiter_position(text as text,initial_position as num, delimiter=",",opening_escape="\"",closing_escape="\"")
	var/position = initial_position
	var/next_delimiter = findtext(text,delimiter,position,0)
	var/next_opening = findtext(text,opening_escape,position,0)

	while((next_opening != 0) && (next_opening < next_delimiter))
		position = findtext(text,closing_escape,next_opening + 1,0)+1
		next_delimiter = findtext(text,delimiter,position,0)
		next_opening = findtext(text,opening_escape,position,0)

	return next_delimiter

/datum/parsed_map/proc/readlist(text as text, delimiter=",")
	. = list()
	if (!text)
		return

	var/position
	var/old_position = 1

	while(position != 0)
		position = find_next_delimiter_position(text,old_position,delimiter)

		var/equal_position = findtext(text,"=",old_position, position)

		var/trim_left = trim_text(copytext(text,old_position,(equal_position ? equal_position : position)))
		var/left_constant = delimiter == ";" ? trim_left : parse_constant(trim_left)
		old_position = position + 1

		if(equal_position && !isnum(left_constant))
			var/trim_right = trim_text(copytext(text,equal_position+1,position))
			var/right_constant = parse_constant(trim_right)
			.[left_constant] = right_constant

		else
			. += list(left_constant)

/datum/parsed_map/proc/parse_constant(text)
	var/num = text2num(text)
	if(isnum(num))
		return num

	if(findtext(text,"\"",1,2))
		return copytext(text,2,findtext(text,"\"",3,0))

	if(copytext(text,1,6) == "list(")
		return readlist(copytext(text,6,length(text)))

	var/path = text2path(text)
	if(ispath(path))
		return path

	if(copytext(text,1,2) == "'")
		return file(copytext(text,2,length(text)))

	if(text == "null")
		return null

	return text

/datum/parsed_map/Destroy()
	..()
	return QDEL_HINT_HARDDEL_NOW