/obj/item/reagent_containers/food/drinks
	name = "drink"
	desc = "yummy"
	icon = 'icons/obj/drinks.dmi'
	icon_state = null
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	reagent_flags = OPENCONTAINER
	var/gulp_size = 5
	possible_transfer_amounts = list(5,10,15,20,25,30,50)
	volume = 50
	resistance_flags = NONE
	var/isGlass = TRUE

/obj/item/reagent_containers/food/drinks/on_reagent_change(changetype)
	if (gulp_size < 5)
		gulp_size = 5
	else
		gulp_size = max(round(reagents.total_volume / 5), 5)

/obj/item/reagent_containers/food/drinks/attack(mob/living/M, mob/user, def_zone)

	if(!reagents || !reagents.total_volume)
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return 0

	if(!canconsume(M, user))
		return 0

	if (!is_drainable())
		to_chat(user, "<span class='warning'>[src]'s lid hasn't been opened!</span>")
		return 0

	if(M == user)
		user.visible_message("<span class='notice'>[user] swallows a gulp of [src].</span>", "<span class='notice'>You swallow a gulp of [src].</span>")
		if(M.has_trait(TRAIT_VORACIOUS))
			M.changeNext_move(CLICK_CD_MELEE * 0.5)

	else
		M.visible_message("<span class='danger'>[user] attempts to feed the contents of [src] to [M].</span>", "<span class='userdanger'>[user] attempts to feed the contents of [src] to [M].</span>")
		if(!do_mob(user, M))
			return
		if(!reagents || !reagents.total_volume)
			return
		M.visible_message("<span class='danger'>[user] feeds the contents of [src] to [M].</span>", "<span class='userdanger'>[user] feeds the contents of [src] to [M].</span>")
		log_combat(user, M, "fed", reagents.log_list())

	var/fraction = min(gulp_size/reagents.total_volume, 1)
	checkLiked(fraction, M)
	reagents.reaction(M, INGEST, fraction)
	reagents.trans_to(M, gulp_size, transfered_by = user)
	playsound(M.loc,'sound/items/drink.ogg', rand(10,50), 1)
	return 1

/obj/item/reagent_containers/food/drinks/afterattack(obj/target, mob/user , proximity)
	. = ..()
	if(!proximity)
		return

	if(target.is_refillable() && is_drainable())
		if(!reagents.total_volume)
			to_chat(user, "<span class='warning'>[src] is empty.</span>")
			return

		if(target.reagents.holder_full())
			to_chat(user, "<span class='warning'>[target] is full.</span>")
			return

		var/refill = reagents.get_master_reagent_id()
		var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this, transfered_by = user)
		to_chat(user, "<span class='notice'>You transfer [trans] units of the solution to [target].</span>")

		//if(iscyborg(user)) 
		//	var/mob/living/silicon/robot/bro = user
		//	bro.cell.use(30)
		//	addtimer(CALLBACK(reagents, /datum/reagents.proc/add_reagent, refill, trans), 600)

	else if(target.is_drainable())
		if (!is_refillable())
			to_chat(user, "<span class='warning'>[src]'s tab isn't open!</span>")
			return

		if(!target.reagents.total_volume)
			to_chat(user, "<span class='warning'>[target] is empty.</span>")
			return

		if(reagents.holder_full())
			to_chat(user, "<span class='warning'>[src] is full.</span>")
			return

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this, transfered_by = user)
		to_chat(user, "<span class='notice'>You fill [src] with [trans] units of the contents of [target].</span>")

/obj/item/reagent_containers/food/drinks/attackby(obj/item/I, mob/user, params)
	var/hotness = I.is_hot()
	if(hotness && reagents)
		reagents.expose_temperature(hotness)
		to_chat(user, "<span class='notice'>You heat [name] with [I]!</span>")
	..()

/obj/item/reagent_containers/food/drinks/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(!.)
		//smash(hit_atom, throwingdatum?.thrower, TRUE)
		smash(hit_atom, !isnull(throwingdatum) ? throwingdatum.thrower : null, TRUE)//not_actual

/obj/item/reagent_containers/food/drinks/proc/smash(atom/target, mob/thrower, ranged = FALSE)
	if(!isGlass)
		return
	if(QDELING(src) || !target)
		return
	if(bartender_check(target) && ranged)
		return
	var/obj/item/broken_bottle/B = new (loc)
	B.icon_state = icon_state
	//var/icon/I = new('icons/obj/drinks.dmi', src.icon_state)
	//I.Blend(B.broken_outline, ICON_OVERLAY, rand(5), 1)
	//I.SwapColor(rgb(255, 0, 220, 255), rgb(0, 0, 0, 0))
	//B.icon = I
	B.name = "broken [name]"
	if(prob(33))
		var/obj/item/shard/S = new(drop_location())
		target.Bumped(S)
	playsound(src, "shatter", 70, 1)
	transfer_fingerprints_to(B)
	qdel(src)
	target.Bumped(B)