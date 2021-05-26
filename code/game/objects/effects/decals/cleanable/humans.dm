/obj/effect/decal/cleanable/blood
	name = "blood"
	desc = "It's red and gooey. Perhaps it's the chef's cooking?"
	icon = 'icons/effects/blood.dmi'
	icon_state = "floor1"
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")
	blood_state = BLOOD_STATE_HUMAN
	bloodiness = BLOOD_AMOUNT_PER_DECAL

/obj/effect/decal/cleanable/blood/replace_decal(obj/effect/decal/cleanable/blood/C)
	//C.add_blood_DNA(return_blood_DNA())
	if (bloodiness)
		if (C.bloodiness < MAX_SHOE_BLOODINESS)
			C.bloodiness += bloodiness
	return ..()

/obj/effect/decal/cleanable/blood/splatter
	icon_state = "gibbl1"
	random_icon_states = list("gibbl1", "gibbl2", "gibbl3", "gibbl4", "gibbl5")

/obj/effect/decal/cleanable/blood/drip
	name = "drips of blood"
	desc = "It's red."
	icon_state = "drip5"
	random_icon_states = list("drip1","drip2","drip3","drip4","drip5")
	bloodiness = 0
	var/drips = 1