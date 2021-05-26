/obj/item/instrument
	name = "generic instrument"
	resistance_flags = FLAMMABLE
	force = 10
	max_integrity = 100
	icon = 'icons/obj/musician.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/instruments_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/instruments_righthand.dmi'
	var/datum/song/handheld/song
	var/instrumentId = "generic"
	var/instrumentExt = "mid"

/obj/item/instrument/Initialize()
	. = ..()
	song = new(instrumentId, src, instrumentExt)

/obj/item/instrument/Destroy()
	QDEL_NULL(song)
	. = ..()

/obj/item/instrument/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] begins to play 'Gloomy Sunday'! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (BRUTELOSS)

/obj/item/instrument/Initialize(mapload)
	. = ..()
	if(mapload)
		song.tempo = song.sanitize_tempo(song.tempo)

/obj/item/instrument/attack_self(mob/user)
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return 1
	interact(user)

/obj/item/instrument/interact(mob/user)
	ui_interact(user)

/obj/item/instrument/ui_interact(mob/living/user)
	if(!isliving(user) || user.stat || user.restrained() || !(user.mobility_flags & MOBILITY_STAND))
		return

	user.set_machine(src)
	song.interact(user)

/obj/item/instrument/guitar
	name = "guitar"
	desc = "It's made of wood and has bronze strings."
	icon_state = "guitar"
	item_state = "guitar"
	instrumentExt = "ogg"
	attack_verb = list("played metal on", "serenaded", "crashed", "smashed")
	hitsound = 'sound/weapons/stringsmash.ogg'
	instrumentId = "guitar"

/obj/item/instrument/eguitar
	name = "electric guitar"
	desc = "Makes all your shredding needs possible."
	icon_state = "eguitar"
	item_state = "eguitar"
	force = 12
	attack_verb = list("played metal on", "shredded", "crashed", "smashed")
	hitsound = 'sound/weapons/stringsmash.ogg'
	instrumentId = "eguitar"
	instrumentExt = "ogg"

/obj/item/instrument/bikehorn
	name = "gilded bike horn"
	desc = "An exquisitely decorated bike horn, capable of honking in a variety of notes."
	icon_state = "bike_horn"
	item_state = "bike_horn"
	lefthand_file = 'icons/mob/inhands/equipment/horns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/horns_righthand.dmi'
	attack_verb = list("beautifully honks")
	instrumentId = "bikehorn"
	instrumentExt = "ogg"
	w_class = WEIGHT_CLASS_TINY
	force = 0
	throw_speed = 3
	throw_range = 15
	hitsound = 'sound/items/bikehorn.ogg'