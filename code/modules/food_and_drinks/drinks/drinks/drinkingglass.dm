/obj/item/reagent_containers/food/drinks/drinkingglass
	name = "drinking glass"
	desc = "Your standard drinking glass."
	custom_price = 5
	icon_state = "glass_empty"
	amount_per_transfer_from_this = 10
	volume = 50
	materials = list(MAT_GLASS=500)
	max_integrity = 20
	spillable = TRUE
	resistance_flags = ACID_PROOF
	obj_flags = UNIQUE_RENAME

/obj/item/reagent_containers/food/drinks/drinkingglass/on_reagent_change(changetype)
	cut_overlays()
	if(reagents.reagent_list.len)
		var/datum/reagent/R = reagents.get_master_reagent()
		if(!renamedByPlayer)
			name = R.glass_name
			desc = R.glass_desc
		if(R.glass_icon_state)
			icon_state = R.glass_icon_state
		else
			var/mutable_appearance/reagent_overlay = mutable_appearance(icon, "glassoverlay")
			reagent_overlay.color = mix_color_from_reagents(reagents.reagent_list)
			add_overlay(reagent_overlay)
	else
		icon_state = "glass_empty"
		renamedByPlayer = FALSE

/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass
	name = "shot glass"
	desc = "A shot glass - the universal symbol for bad decisions."
	custom_price = 5
	icon_state = "shotglass"
	gulp_size = 15
	amount_per_transfer_from_this = 15
	possible_transfer_amounts = list()
	volume = 15
	materials = list(MAT_GLASS=100)

/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass/on_reagent_change(changetype)
	cut_overlays()

	if (gulp_size < 15)
		gulp_size = 15
	else
		gulp_size = max(round(reagents.total_volume / 15), 15)

	if (reagents.reagent_list.len > 0)
		var/datum/reagent/largest_reagent = reagents.get_master_reagent()
		name = "filled shot glass"
		desc = "The challenge is not taking as many as you can, but guessing what it is before you pass out."

		if(largest_reagent.shot_glass_icon_state)
			icon_state = largest_reagent.shot_glass_icon_state
		else
			icon_state = "shotglassclear"
			var/mutable_appearance/shot_overlay = mutable_appearance(icon, "shotglassoverlay")
			shot_overlay.color = mix_color_from_reagents(reagents.reagent_list)
			add_overlay(shot_overlay)


	else
		icon_state = "shotglass"
		name = "shot glass"
		desc = "A shot glass - the universal symbol for bad decisions."
		return

/obj/item/reagent_containers/food/drinks/drinkingglass/filled/Initialize()
	. = ..()
	on_reagent_change(ADD_REAGENT)

/obj/item/reagent_containers/food/drinks/drinkingglass/filled/soda
	name = "Soda Water"
	//list_reagents = list("sodawater" = 50)

/obj/item/reagent_containers/food/drinks/drinkingglass/filled/cola
	name = "Space Cola"
	//list_reagents = list("cola" = 50)

/obj/item/reagent_containers/food/drinks/drinkingglass/filled/nuka_cola
	name = "Nuka Cola"
	//list_reagents = list("nuka_cola" = 50)
	
/obj/item/reagent_containers/food/drinks/drinkingglass/attackby(obj/item/I, mob/user, params)
	//if(istype(I, /obj/item/reagent_containers/food/snacks/egg))
	if(FALSE)//not_actual
		//var/obj/item/reagent_containers/food/snacks/egg/E = I
		//if(reagents)
		//	if(reagents.total_volume >= reagents.maximum_volume)
		//		to_chat(user, "<span class='notice'>[src] is full.</span>")
		//	else
		//		to_chat(user, "<span class='notice'>You break [E] in [src].</span>")
		//		reagents.add_reagent("eggyolk", 5)
		//		qdel(E)
		//	return
	else
		..()

/obj/item/reagent_containers/food/drinks/drinkingglass/attack(obj/target, mob/user)
	if(user.a_intent == INTENT_HARM && ismob(target) && target.reagents && reagents.total_volume)
		target.visible_message("<span class='danger'>[user] splashes the contents of [src] onto [target]!</span>", \
						"<span class='userdanger'>[user] splashes the contents of [src] onto [target]!</span>")
		log_combat(user, target, "splashed", src)
		reagents.reaction(target, TOUCH)
		reagents.clear_reagents()
		return
	..()

/obj/item/reagent_containers/food/drinks/drinkingglass/afterattack(obj/target, mob/user, proximity)
	. = ..()
	if((!proximity) || !check_allowed_items(target,target_self=1))
		return

	else if(reagents.total_volume && user.a_intent == INTENT_HARM)
		user.visible_message("<span class='danger'>[user] splashes the contents of [src] onto [target]!</span>", \
							"<span class='notice'>You splash the contents of [src] onto [target].</span>")
		reagents.reaction(target, TOUCH)
		reagents.clear_reagents()
		return