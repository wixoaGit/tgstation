/obj/item/ammo_box
	name = "ammo box (null_reference_exception)"
	desc = "A box of ammo."
	icon = 'icons/obj/ammo.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	item_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	materials = list(MAT_METAL = 30000)
	throwforce = 2
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	var/list/stored_ammo = list()
	var/ammo_type = /obj/item/ammo_casing
	var/max_ammo = 7
	var/multiple_sprites = 0
	var/caliber
	var/multiload = 1
	var/start_empty = 0
	var/list/bullet_cost
	var/list/base_cost

/obj/item/ammo_box/Initialize()
	. = ..()
	if (!bullet_cost)
		for (var/material in materials)
			var/material_amount = materials[material]
			LAZYSET(base_cost, material, (material_amount * 0.10))

			material_amount *= 0.90
			material_amount /= max_ammo
			LAZYSET(bullet_cost, material, material_amount)
	if(!start_empty)
		for(var/i = 1, i <= max_ammo, i++)
			stored_ammo += new ammo_type(src)
	update_icon()

/obj/item/ammo_box/proc/get_round(keep = 0)
	if (!stored_ammo.len)
		return null
	else
		var/b = stored_ammo[stored_ammo.len]
		stored_ammo -= b
		if (keep)
			stored_ammo.Insert(1,b)
		return b

/obj/item/ammo_box/update_icon()
	var/shells_left = stored_ammo.len
	switch(multiple_sprites)
		if(1)
			icon_state = "[initial(icon_state)]-[shells_left]"
		if(2)
			icon_state = "[initial(icon_state)]-[shells_left ? "[max_ammo]" : "0"]"
	desc = "[initial(desc)] There [(shells_left == 1) ? "is" : "are"] [shells_left] shell\s left!"
	for (var/material in bullet_cost)
		var/material_amount = bullet_cost[material]
		material_amount = (material_amount*stored_ammo.len) + base_cost[material]
		materials[material] = material_amount

/obj/item/ammo_box/magazine/proc/ammo_count(countempties = TRUE)
	var/boolets = 0
	for(var/obj/item/ammo_casing/bullet in stored_ammo)
		if(bullet && (bullet.BB || countempties))
			boolets++
	return boolets

/obj/item/ammo_box/magazine/handle_atom_del(atom/A)
	stored_ammo -= A
	update_icon()