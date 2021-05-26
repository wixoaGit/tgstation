/obj/item/circuitboard
	name = "circuit board"
	icon = 'icons/obj/module.dmi'
	icon_state = "id_mod"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	materials = list(MAT_GLASS=1000)
	w_class = WEIGHT_CLASS_SMALL
	grind_results = list("silicon" = 20)
	var/build_path = null

/obj/item/circuitboard/proc/apply_default_parts(obj/machinery/M)
	return

/obj/item/circuitboard/machine
	var/needs_anchored = TRUE
	var/list/req_components
	var/list/def_components

/obj/item/circuitboard/machine/apply_default_parts(obj/machinery/M)
	if(!req_components)
		return

	M.component_parts = list(src)
	moveToNullspace()

	for(var/comp_path in req_components)
		var/comp_amt = req_components[comp_path]
		if(!comp_amt)
			continue

		if(def_components && def_components[comp_path])
			comp_path = def_components[comp_path]

		if(ispath(comp_path, /obj/item/stack))
			M.component_parts += new comp_path(null, comp_amt)
		else
			for(var/i in 1 to comp_amt)
				M.component_parts += new comp_path(null)

	M.RefreshParts()

/obj/item/circuitboard/machine/examine(mob/user)
	..()
	if(LAZYLEN(req_components))
		var/list/nice_list = list()
		for(var/B in req_components)
			var/atom/A = B
			if(!ispath(A))
				continue
			nice_list += list("[req_components[A]] [initial(A.name)]")
		to_chat(user,"<span class='notice'>Required components: [english_list(nice_list)].</span>")