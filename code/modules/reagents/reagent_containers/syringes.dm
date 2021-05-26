/obj/item/reagent_containers/syringe
	name = "syringe"
	desc = "A syringe that can hold up to 15 units."
	icon = 'icons/obj/syringe.dmi'
	item_state = "syringe_0"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	icon_state = "0"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list()
	volume = 15
	var/mode = SYRINGE_DRAW
	var/busy = FALSE
	var/proj_piercing = 0
	materials = list(MAT_METAL=10, MAT_GLASS=20)
	reagent_flags = TRANSPARENT

/obj/item/reagent_containers/syringe/Initialize()
	. = ..()
	if(list_reagents)
		mode = SYRINGE_INJECT
		update_icon()

/obj/item/reagent_containers/syringe/on_reagent_change(changetype)
	update_icon()

/obj/item/reagent_containers/syringe/pickup(mob/user)
	..()
	update_icon()

/obj/item/reagent_containers/syringe/dropped(mob/user)
	..()
	update_icon()

/obj/item/reagent_containers/syringe/attack_self(mob/user)
	mode = !mode
	update_icon()

/obj/item/reagent_containers/syringe/attack_hand()
	. = ..()
	update_icon()

/obj/item/reagent_containers/syringe/attack_paw(mob/user)
	return attack_hand(user)

/obj/item/reagent_containers/syringe/attackby(obj/item/I, mob/user, params)
	return

/obj/item/reagent_containers/syringe/afterattack(atom/target, mob/user , proximity)
	. = ..()
	if(busy)
		return
	if(!proximity)
		return
	if(!target.reagents)
		return

	var/mob/living/L
	if(isliving(target))
		L = target
		if(!L.can_inject(user, 1))
			return

	//if(ismonkey(target) && prob(MONKEY_SYRINGE_RETALIATION_PROB))
	//	var/mob/living/carbon/monkey/M
	//	M = target
	//	M.retaliate(user)

	switch(mode)
		if(SYRINGE_DRAW)

			if(reagents.total_volume >= reagents.maximum_volume)
				to_chat(user, "<span class='notice'>The syringe is full.</span>")
				return

			if(L)
				var/drawn_amount = reagents.maximum_volume - reagents.total_volume
				if(target != user)
					target.visible_message("<span class='danger'>[user] is trying to take a blood sample from [target]!</span>", \
									"<span class='userdanger'>[user] is trying to take a blood sample from [target]!</span>")
					busy = TRUE
					//if(!do_mob(user, target, extra_checks=CALLBACK(L, /mob/living/proc/can_inject, user, TRUE)))
					if(!do_mob(user, target))//not_actual
						busy = FALSE
						return
					if(reagents.total_volume >= reagents.maximum_volume)
						return
				busy = FALSE
				if(L.transfer_blood_to(src, drawn_amount))
					user.visible_message("[user] takes a blood sample from [L].")
				else
					to_chat(user, "<span class='warning'>You are unable to draw any blood from [L]!</span>")

			else
				if(!target.reagents.total_volume)
					to_chat(user, "<span class='warning'>[target] is empty!</span>")
					return

				if(!target.is_drawable(user))
					to_chat(user, "<span class='warning'>You cannot directly remove reagents from [target]!</span>")
					return

				var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this, transfered_by = user)

				to_chat(user, "<span class='notice'>You fill [src] with [trans] units of the solution. It now contains [reagents.total_volume] units.</span>")
			if (reagents.total_volume >= reagents.maximum_volume)
				mode=!mode
				update_icon()

		if(SYRINGE_INJECT)
			var/contained = reagents.log_list()
			log_combat(user, target, "attempted to inject", src, addition="which had [contained]")

			if(!reagents.total_volume)
				to_chat(user, "<span class='notice'>[src] is empty.</span>")
				return

			if(!L && !target.is_injectable(user))
				to_chat(user, "<span class='warning'>You cannot directly fill [target]!</span>")
				return

			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				to_chat(user, "<span class='notice'>[target] is full.</span>")
				return

			if(L)
				if(!L.can_inject(user, TRUE))
					return
				if(L != user)
					L.visible_message("<span class='danger'>[user] is trying to inject [L]!</span>", \
											"<span class='userdanger'>[user] is trying to inject [L]!</span>")
					//if(!do_mob(user, L, extra_checks=CALLBACK(L, /mob/living/proc/can_inject, user, TRUE)))
					if(!do_mob(user, L))//not_actual
						return
					if(!reagents.total_volume)
						return
					if(L.reagents.total_volume >= L.reagents.maximum_volume)
						return
					L.visible_message("<span class='danger'>[user] injects [L] with the syringe!", \
									"<span class='userdanger'>[user] injects [L] with the syringe!</span>")

				if(L != user)
					log_combat(user, L, "injected", src, addition="which had [contained]")
				//else
				//	L.log_message("injected themselves ([contained]) with [src.name]", LOG_ATTACK, color="orange")
			var/fraction = min(amount_per_transfer_from_this/reagents.total_volume, 1)
			reagents.reaction(L, INJECT, fraction)
			reagents.trans_to(target, amount_per_transfer_from_this, transfered_by = user)
			to_chat(user, "<span class='notice'>You inject [amount_per_transfer_from_this] units of the solution. The syringe now contains [reagents.total_volume] units.</span>")
			if (reagents.total_volume <= 0 && mode==SYRINGE_INJECT)
				mode = SYRINGE_DRAW
				update_icon()

/obj/item/reagent_containers/syringe/update_icon()
	cut_overlays()
	var/rounded_vol
	if(reagents && reagents.total_volume)
		rounded_vol = CLAMP(round((reagents.total_volume / volume * 15),5), 1, 15)
		var/image/filling_overlay = mutable_appearance('icons/obj/reagentfillings.dmi', "syringe[rounded_vol]")
		filling_overlay.color = mix_color_from_reagents(reagents.reagent_list)
		add_overlay(filling_overlay)
	else
		rounded_vol = 0
	icon_state = "[rounded_vol]"
	item_state = "syringe_[rounded_vol]"
	if(ismob(loc))
		var/mob/M = loc
		var/injoverlay
		switch(mode)
			if (SYRINGE_DRAW)
				injoverlay = "draw"
			if (SYRINGE_INJECT)
				injoverlay = "inject"
		add_overlay(injoverlay)
		M.update_inv_hands()