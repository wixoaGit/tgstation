/obj/item/reagent_containers/food/snacks
	name = "snack"
	desc = "Yummy."
	icon = 'icons/obj/food/food.dmi'
	icon_state = null
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	obj_flags = UNIQUE_RENAME
	grind_results = list()
	var/bitesize = 2
	var/bitecount = 0
	var/trash = null
	var/slice_path
	var/slices_num
	var/eatverb
	var/dried_type = null
	var/dry = 0
	var/cooked_type = null
	var/filling_color = "#FFFFFF"
	var/custom_food_type = null
	var/junkiness = 0
	var/list/bonus_reagents
	var/customfoodfilling = 1
	var/list/tastes

/obj/item/reagent_containers/food/snacks/add_initial_reagents()
	if(tastes && tastes.len)
		if(list_reagents)
			for(var/rid in list_reagents)
				var/amount = list_reagents[rid]
				if(rid == "nutriment" || rid == "vitamin")
					reagents.add_reagent(rid, amount, tastes.Copy())
				else
					reagents.add_reagent(rid, amount)
	else
		..()

/obj/item/reagent_containers/food/snacks/proc/On_Consume(mob/living/eater)
	if(!eater)
		return
	if(!reagents.total_volume)
		var/obj/item/trash_item = generate_trash(eater)
		qdel(src)
		eater.put_in_hands(trash_item)

/obj/item/reagent_containers/food/snacks/attack_self(mob/user)
	return


/obj/item/reagent_containers/food/snacks/attack(mob/living/M, mob/living/user, def_zone)
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(!eatverb)
		eatverb = pick("bite","chew","nibble","gnaw","gobble","chomp")
	if(!reagents.total_volume)
		to_chat(user, "<span class='notice'>None of [src] left, oh no!</span>")
		qdel(src)
		return FALSE
	if(iscarbon(M))
		if(!canconsume(M, user))
			return FALSE

		var/fullness = M.nutrition + 10
		for(var/datum/reagent/consumable/C in M.reagents.reagent_list)
			fullness += C.nutriment_factor * C.volume / C.metabolization_rate

		if(M == user)
			if(junkiness && M.satiety < -150 && M.nutrition > NUTRITION_LEVEL_STARVING + 50 && !user.has_trait(TRAIT_VORACIOUS))
				to_chat(M, "<span class='notice'>You don't feel like eating any more junk food at the moment.</span>")
				return FALSE
			else if(fullness <= 50)
				user.visible_message("<span class='notice'>[user] hungrily [eatverb]s \the [src], gobbling it down!</span>", "<span class='notice'>You hungrily [eatverb] \the [src], gobbling it down!</span>")
			else if(fullness > 50 && fullness < 150)
				user.visible_message("<span class='notice'>[user] hungrily [eatverb]s \the [src].</span>", "<span class='notice'>You hungrily [eatverb] \the [src].</span>")
			else if(fullness > 150 && fullness < 500)
				user.visible_message("<span class='notice'>[user] [eatverb]s \the [src].</span>", "<span class='notice'>You [eatverb] \the [src].</span>")
			else if(fullness > 500 && fullness < 600)
				user.visible_message("<span class='notice'>[user] unwillingly [eatverb]s a bit of \the [src].</span>", "<span class='notice'>You unwillingly [eatverb] a bit of \the [src].</span>")
			else if(fullness > (600 * (1 + M.overeatduration / 2000)))
				user.visible_message("<span class='warning'>[user] cannot force any more of \the [src] to go down [user.p_their()] throat!</span>", "<span class='warning'>You cannot force any more of \the [src] to go down your throat!</span>")
				return FALSE
			if(M.has_trait(TRAIT_VORACIOUS))
				M.changeNext_move(CLICK_CD_MELEE * 0.5)
		else
			if(!isbrain(M))
				if(fullness <= (600 * (1 + M.overeatduration / 1000)))
					M.visible_message("<span class='danger'>[user] attempts to feed [M] [src].</span>", \
										"<span class='userdanger'>[user] attempts to feed [M] [src].</span>")
				else
					M.visible_message("<span class='warning'>[user] cannot force any more of [src] down [M]'s throat!</span>", \
										"<span class='warning'>[user] cannot force any more of [src] down [M]'s throat!</span>")
					return FALSE

				if(!do_mob(user, M))
					return
				log_combat(user, M, "fed", reagents.log_list())
				M.visible_message("<span class='danger'>[user] forces [M] to eat [src].</span>", \
									"<span class='userdanger'>[user] forces [M] to eat [src].</span>")

			else
				to_chat(user, "<span class='warning'>[M] doesn't seem to have a mouth!</span>")
				return

		if(reagents)
			if(M.satiety > -200)
				M.satiety -= junkiness
			playsound(M.loc,'sound/items/eatfood.ogg', rand(10,50), 1)
			if(reagents.total_volume)
				SEND_SIGNAL(src, COMSIG_FOOD_EATEN, M, user)
				var/fraction = min(bitesize / reagents.total_volume, 1)
				reagents.reaction(M, INGEST, fraction)
				reagents.trans_to(M, bitesize, transfered_by = user)
				bitecount++
				On_Consume(M)
				checkLiked(fraction, M)
				return TRUE

	return 0

/obj/item/reagent_containers/food/snacks/examine(mob/user)
	..()
	if(bitecount == 0)
		return
	else if(bitecount == 1)
		to_chat(user, "[src] was bitten by someone!")
	else if(bitecount <= 3)
		to_chat(user, "[src] was bitten [bitecount] times!")
	else
		to_chat(user, "[src] was bitten multiple times!")

/obj/item/reagent_containers/food/snacks/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/storage))
		..()
		return 0
	if(istype(W, /obj/item/reagent_containers/food/snacks))
		var/obj/item/reagent_containers/food/snacks/S = W
		if(custom_food_type && ispath(custom_food_type))
			if(S.w_class > WEIGHT_CLASS_SMALL)
				to_chat(user, "<span class='warning'>[S] is too big for [src]!</span>")
				return 0
			//if(!S.customfoodfilling || istype(W, /obj/item/reagent_containers/food/snacks/customizable) || istype(W, /obj/item/reagent_containers/food/snacks/pizzaslice/custom) || istype(W, /obj/item/reagent_containers/food/snacks/cakeslice/custom))
			//	to_chat(user, "<span class='warning'>[src] can't be filled with [S]!</span>")
			//	return 0
			if(contents.len >= 20)
				to_chat(user, "<span class='warning'>You can't add more ingredients to [src]!</span>")
				return 0
			//var/obj/item/reagent_containers/food/snacks/customizable/C = new custom_food_type(get_turf(src))
			//C.initialize_custom_food(src, S, user)
			return 0
	var/sharp = W.is_sharp()
	if(sharp)
		if(slice(sharp, W, user))
			return 1
	else
		..()

/obj/item/reagent_containers/food/snacks/proc/slice(accuracy, obj/item/W, mob/user)
	if((slices_num <= 0 || !slices_num) || !slice_path)
		return FALSE

	if ( \
			!isturf(src.loc) || \
			!(locate(/obj/structure/table) in src.loc) && \
			!(locate(/obj/structure/table/optable) in src.loc) && \
			!(locate(/obj/item/storage/bag/tray) in src.loc) \
		)
		to_chat(user, "<span class='warning'>You cannot slice [src] here! You need a table or at least a tray.</span>")
		return FALSE

	var/slices_lost = 0
	if (accuracy >= IS_SHARP_ACCURATE)
		user.visible_message( \
			"[user] slices [src].", \
			"<span class='notice'>You slice [src].</span>" \
		)
	else
		user.visible_message( \
			"[user] inaccurately slices [src] with [W]!", \
			"<span class='notice'>You inaccurately slice [src] with your [W]!</span>" \
		)
		slices_lost = rand(1,min(1,round(slices_num/2)))

	var/reagents_per_slice = reagents.total_volume/slices_num
	//for(var/i=1 to (slices_num-slices_lost))
	for(var/i=1, i<=(slices_num-slices_lost), i++)//not_actual
		var/obj/item/reagent_containers/food/snacks/slice = new slice_path (loc)
		initialize_slice(slice, reagents_per_slice)
	qdel(src)
	return TRUE

/obj/item/reagent_containers/food/snacks/proc/initialize_slice(obj/item/reagent_containers/food/snacks/slice, reagents_per_slice)
	slice.create_reagents(slice.volume)
	reagents.trans_to(slice,reagents_per_slice)
	if(name != initial(name))
		slice.name = "slice of [name]"
	if(desc != initial(desc))
		slice.desc = "[desc]"
	if(foodtype != initial(foodtype))
		slice.foodtype = foodtype

/obj/item/reagent_containers/food/snacks/proc/generate_trash(atom/location)
	if(trash)
		if(ispath(trash, /obj/item))
			. = new trash(location)
			trash = null
			return
		else if(isitem(trash))
			var/obj/item/trash_item = trash
			trash_item.forceMove(location)
			. = trash
			trash = null
			return

/obj/item/reagent_containers/food/snacks/proc/initialize_cooked_food(obj/item/reagent_containers/food/snacks/S, cooking_efficiency = 1)
	S.create_reagents(S.volume)
	if(reagents)
		reagents.trans_to(S, reagents.total_volume)
	if(S.bonus_reagents && S.bonus_reagents.len)
		for(var/r_id in S.bonus_reagents)
			var/amount = S.bonus_reagents[r_id] * cooking_efficiency
			if(r_id == "nutriment" || r_id == "vitamin")
				S.reagents.add_reagent(r_id, amount, tastes)
			else
				S.reagents.add_reagent(r_id, amount)

/obj/item/reagent_containers/food/snacks/microwave_act(obj/machinery/microwave/M)
	var/turf/T = get_turf(src)
	var/obj/item/result

	if(cooked_type)
		result = new cooked_type(T)
		if(istype(M))
			initialize_cooked_food(result, M.efficiency)
		else
			initialize_cooked_food(result, 1)
		//SSblackbox.record_feedback("tally", "food_made", 1, result.type)
	else
		result = new /obj/item/reagent_containers/food/snacks/badrecipe(T)
		if(istype(M) && M.dirty < 100)
			M.dirty++
	qdel(src)

	return result

/obj/item/reagent_containers/food/snacks/Destroy()
	if(contents)
		for(var/atom/movable/something in contents)
			something.forceMove(drop_location())
	return ..()