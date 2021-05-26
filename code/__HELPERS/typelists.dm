GLOBAL_LIST_EMPTY(typelists)

/datum/proc/typelist(key, list/values = list())
	var/list/mytypelist = GLOB.typelists[type] || (GLOB.typelists[type] = list())
	return mytypelist[key] || (mytypelist[key] = values.Copy())