/datum/chemical_reaction/reagent_explosion
	name = "Generic explosive"
	id = "reagent_explosion"
	var/strengthdiv = 10
	var/modifier = 0

/datum/chemical_reaction/reagent_explosion/on_reaction(datum/reagents/holder, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	//var/inside_msg
	//if(ismob(holder.my_atom))
	//	var/mob/M = holder.my_atom
	//	inside_msg = " inside [ADMIN_LOOKUPFLW(M)]"
	//var/lastkey = holder.my_atom.fingerprintslast
	//var/touch_msg = "N/A"
	//if(lastkey)
	//	var/mob/toucher = get_mob_by_key(lastkey)
	//	touch_msg = "[ADMIN_LOOKUPFLW(toucher)]"
	//message_admins("Reagent explosion reaction occurred at [ADMIN_VERBOSEJMP(T)][inside_msg]. Last Fingerprint: [touch_msg].")
	//log_game("Reagent explosion reaction occurred at [AREACOORD(T)]. Last Fingerprint: [lastkey ? lastkey : "N/A"]." )
	var/datum/effect_system/reagents_explosion/e = new()
	e.set_up(modifier + round(created_volume/strengthdiv, 1), T, 0, 0)
	e.start()
	holder.clear_reagents()

/datum/chemical_reaction/reagent_explosion/potassium_explosion
	name = "Explosion"
	id = "potassium_explosion"
	required_reagents = list("water" = 1, "potassium" = 1)
	strengthdiv = 10

/datum/chemical_reaction/blackpowder
	name = "Black Powder"
	id = "blackpowder"
	results = list("blackpowder" = 3)
	required_reagents = list("saltpetre" = 1, "charcoal" = 1, "sulfur" = 1)

/datum/chemical_reaction/reagent_explosion/blackpowder_explosion
	name = "Black Powder Kaboom"
	id = "blackpowder_explosion"
	required_reagents = list("blackpowder" = 1)
	required_temp = 474
	strengthdiv = 6
	modifier = 1
	mix_message = "<span class='boldannounce'>Sparks start flying around the black powder!</span>"

/datum/chemical_reaction/reagent_explosion/blackpowder_explosion/on_reaction(datum/reagents/holder, created_volume)
	sleep(rand(50,100))
	..()