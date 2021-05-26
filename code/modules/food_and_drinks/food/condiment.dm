/obj/item/reagent_containers/food/condiment
	name = "condiment container"
	desc = "Just your average condiment container."
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "emptycondiment"
	reagent_flags = OPENCONTAINER
	possible_transfer_amounts = list(1, 5, 10, 15, 20, 25, 30, 50)
	volume = 50
	var/list/possible_states = list(
	 "ketchup" = list("ketchup", "ketchup bottle", "You feel more American already."),
	 "capsaicin" = list("hotsauce", "hotsauce bottle", "You can almost TASTE the stomach ulcers now!"),
	 "enzyme" = list("enzyme", "universal enzyme bottle", "Used in cooking various dishes"),
	 "soysauce" = list("soysauce", "soy sauce bottle", "A salty soy-based flavoring"),
	 "frostoil" = list("coldsauce", "coldsauce bottle", "Leaves the tongue numb in its passage"),
	 "sodiumchloride" = list("saltshakersmall", "salt shaker", "Salt. From space oceans, presumably"),
	 "blackpepper" = list("peppermillsmall", "pepper mill", "Often used to flavor food or make people sneeze"),
	 "cornoil" = list("oliveoil", "corn oil bottle", "A delicious oil used in cooking. Made from corn"),
	 "sugar" = list("emptycondiment", "sugar bottle", "Tasty spacey sugar!"),
	 "mayonnaise" = list("mayonnaise", "mayonnaise jar", "An oily condiment made from egg yolks."))
	var/originalname = "condiment"

/obj/item/reagent_containers/food/condiment/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] is trying to eat the entire [src]! It looks like [user.p_they()] forgot how food works!</span>")
	return OXYLOSS

/obj/item/reagent_containers/food/condiment/attack(mob/M, mob/user, def_zone)

	if(!reagents || !reagents.total_volume)
		to_chat(user, "<span class='warning'>None of [src] left, oh no!</span>")
		return 0

	if(!canconsume(M, user))
		return 0

	if(M == user)
		user.visible_message("<span class='notice'>[user] swallows some of contents of \the [src].</span>", "<span class='notice'>You swallow some of contents of \the [src].</span>")
	else
		user.visible_message("<span class='warning'>[user] attempts to feed [M] from [src].</span>")
		if(!do_mob(user, M))
			return
		if(!reagents || !reagents.total_volume)
			return
		user.visible_message("<span class='warning'>[user] feeds [M] from [src].</span>")
		log_combat(user, M, "fed", reagents.log_list())

	var/fraction = min(10/reagents.total_volume, 1)
	reagents.reaction(M, INGEST, fraction)
	reagents.trans_to(M, 10, transfered_by = user)
	playsound(M.loc,'sound/items/drink.ogg', rand(10,50), 1)
	return 1

/obj/item/reagent_containers/food/condiment/afterattack(obj/target, mob/user , proximity)
	. = ..()
	if(!proximity)
		return
	if(istype(target, /obj/structure/reagent_dispensers))

		if(!target.reagents.total_volume)
			to_chat(user, "<span class='warning'>[target] is empty!</span>")
			return

		if(reagents.total_volume >= reagents.maximum_volume)
			to_chat(user, "<span class='warning'>[src] is full!</span>")
			return

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this, transfered_by = user)
		to_chat(user, "<span class='notice'>You fill [src] with [trans] units of the contents of [target].</span>")

	else if(target.is_drainable() || istype(target, /obj/item/reagent_containers/food/snacks))
		if(!reagents.total_volume)
			to_chat(user, "<span class='warning'>[src] is empty!</span>")
			return
		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, "<span class='warning'>you can't add anymore to [target]!</span>")
			return
		var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this, transfered_by = user)
		to_chat(user, "<span class='notice'>You transfer [trans] units of the condiment to [target].</span>")

/obj/item/reagent_containers/food/condiment/on_reagent_change(changetype)
	//if(!possible_states.len)
	//	return
	//if(reagents.reagent_list.len > 0)
	//	var/main_reagent = reagents.get_master_reagent_id()
	//	if(main_reagent in possible_states)
	//		var/list/temp_list = possible_states[main_reagent]
	//		icon_state = temp_list[1]
	//		name = temp_list[2]
	//		desc = temp_list[3]

	//	else
	//		name = "[originalname] bottle"
	//		main_reagent = reagents.get_master_reagent_name()
	//		if (reagents.reagent_list.len==1)
	//			desc = "Looks like it is [lowertext(main_reagent)], but you are not sure."
	//		else
	//			desc = "A mixture of various condiments. [lowertext(main_reagent)] is one of them."
	//		icon_state = "mixedcondiments"
	//else
	//	icon_state = "emptycondiment"
	//	name = "condiment bottle"
	//	desc = "An empty condiment bottle."
	//	return

/obj/item/reagent_containers/food/condiment/sugar
	name = "sugar bottle"
	desc = "Tasty spacey sugar!"
	list_reagents = list("sugar" = 50)

/obj/item/reagent_containers/food/condiment/flour
	name = "flour sack"
	desc = "A big bag of flour. Good for baking!"
	icon_state = "flour"
	item_state = "flour"
	list_reagents = list("flour" = 30)
	possible_states = list()