/datum/language_holder
	var/list/languages = list(/datum/language/common)
	var/list/shadow_languages = list()
	var/only_speaks_language = null
	var/selected_default_language = null
	//var/datum/language_menu/language_menu

	var/omnitongue = FALSE
	var/owner

/datum/language_holder/New(owner)
	src.owner = owner

	languages = typecacheof(languages)
	shadow_languages = typecacheof(shadow_languages)

/datum/language_holder/Destroy()
	owner = null
	//QDEL_NULL(language_menu)
	languages.Cut()
	shadow_languages.Cut()
	return ..()

/datum/language_holder/proc/has_language(datum/language/dt)
	if(is_type_in_typecache(dt, languages))
		return LANGUAGE_KNOWN
	else
		var/atom/movable/AM = get_atom()
		var/datum/language_holder/L = AM.get_language_holder(shadow=FALSE)
		if(L != src)
			if(is_type_in_typecache(dt, L.shadow_languages))
				return LANGUAGE_SHADOWED
	return FALSE

/datum/language_holder/proc/get_atom()
	if(ismovableatom(owner))
		. = owner
	else if(istype(owner, /datum/mind))
		var/datum/mind/M = owner
		if(M.current)
			. = M.current