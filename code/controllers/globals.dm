GLOBAL_REAL(GLOB, /datum/controller/global_vars)

/datum/controller/global_vars
	name = "Global Variables"

	var/list/gvars_datum_in_built_vars
	var/list/gvars_datum_init_order

/datum/controller/global_vars/New()
	if (GLOB)
		return
	GLOB = src

	Initialize()

/datum/controller/global_vars/Destroy()
	return QDEL_HINT_IWILLGC

/datum/controller/global_vars/Initialize()
	var/list/global_procs = typesof(/datum/controller/global_vars/proc)
	for (var/I in global_procs)
		call(src, I)()