/datum/data/vending_product
	name = "generic"
	var/product_path = null
	var/amount = 0
	var/max_amount = 0
	var/display_color = "blue"
	var/custom_price
	var/custom_premium_price

/obj/machinery/vending
	name = "\improper Vendomat"
	desc = "A generic vending machine."
	icon = 'icons/obj/vending.dmi'
	icon_state = "generic"
	layer = BELOW_OBJ_LAYER
	density = TRUE
	verb_say = "beeps"
	verb_ask = "beeps"
	verb_exclaim = "beeps"
	max_integrity = 300
	integrity_failure = 100
	armor = list("melee" = 20, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 70)
	circuit = /obj/item/circuitboard/machine/vendor
	payment_department = ACCOUNT_SRV
	var/active = 1
	var/vend_ready = 1

	var/list/products	= list()
	var/list/contraband	= list()
	var/list/premium 	= list()

	var/product_slogans = ""
	var/product_ads = ""
	var/list/product_records = list()
	var/list/hidden_records = list()
	var/list/coin_records = list()
	var/list/slogan_list = list()
	var/list/small_ads = list()
	var/vend_reply	
	var/last_reply = 0
	var/last_slogan = 0
	var/slogan_delay = 6000
	var/icon_vend
	var/icon_deny
	var/seconds_electrified = MACHINE_NOT_ELECTRIFIED
	var/shoot_inventory = 0
	var/shoot_inventory_chance = 2
	var/shut_up = 0
	var/extended_inventory = 0
	var/scan_id = 1
	//var/obj/item/coin/coin
	//var/obj/item/stack/spacecash/bill
	var/chef_price = 10
	var/default_price = 25
	var/extra_price = 50
	var/onstation = TRUE

	var/dish_quants = list()

	//var/obj/item/vending_refill/refill_canister = null

/obj/item/circuitboard
	var/onstation = TRUE

/obj/machinery/vending/Initialize(mapload)
	var/build_inv = FALSE
	//if(!refill_canister)
	if(TRUE)//not_actual
		circuit = null
		build_inv = TRUE
	. = ..()
	//wires = new /datum/wires/vending(src)
	if(build_inv)
		build_inventory(products, product_records)
		build_inventory(contraband, hidden_records)
		build_inventory(premium, coin_records)

	slogan_list = splittext(product_slogans, ";")
	last_slogan = world.time + rand(0, slogan_delay)
	power_change()

	if(mapload)
		if(!is_station_level(z))
			onstation = FALSE
			if(circuit)
				circuit.onstation = onstation
	else if(circuit && (circuit.onstation != onstation))
		onstation = circuit.onstation

/obj/machinery/vending/Destroy()
	//QDEL_NULL(wires)
	//QDEL_NULL(coin)
	//QDEL_NULL(bill)
	return ..()

/obj/machinery/vending/can_speak()
	return !shut_up

/obj/machinery/vending/RefreshParts()
	if(!component_parts)
		return

	product_records = list()
	hidden_records = list()
	coin_records = list()
	build_inventory(products, product_records, start_empty = TRUE)
	build_inventory(contraband, hidden_records, start_empty = TRUE)
	build_inventory(premium, coin_records, start_empty = TRUE)
	//for(var/obj/item/vending_refill/VR in component_parts)
	//	restock(VR)

/obj/machinery/vending/deconstruct(disassembled = TRUE)
	//if(!refill_canister)
	if(TRUE)//not_actual
		//if(!(flags_1 & NODECONSTRUCT_1))
		//	new /obj/item/stack/sheet/metal(loc, 3)
		qdel(src)
	else
		..()

/obj/machinery/vending/obj_break(damage_flag)
	if(!(stat & BROKEN) && !(flags_1 & NODECONSTRUCT_1))
		stat |= BROKEN
		icon_state = "[initial(icon_state)]-broken"

		var/dump_amount = 0
		var/found_anything = TRUE
		while (found_anything)
			found_anything = FALSE
			for(var/record in shuffle(product_records))
				var/datum/data/vending_product/R = record
				if(R.amount <= 0)
					continue
				var/dump_path = R.product_path
				if(!dump_path)
					continue
				R.amount--
				if(found_anything && prob(80))
					continue

				var/obj/O = new dump_path(loc)
				step(O, pick(GLOB.alldirs))
				found_anything = TRUE
				dump_amount++
				if (dump_amount >= 16)
					return

/obj/machinery/vending/proc/build_inventory(list/productlist, list/recordlist, start_empty = FALSE)
	for(var/typepath in productlist)
		var/amount = productlist[typepath]
		if(isnull(amount))
			amount = 0

		var/atom/temp = typepath
		var/datum/data/vending_product/R = new /datum/data/vending_product()
		R.name = initial(temp.name)
		R.product_path = typepath
		if(!start_empty)
			R.amount = amount
		R.max_amount = amount
		R.display_color = pick("#ff8080","#80ff80","#8080ff")
		R.custom_price = initial(temp.custom_price)
		R.custom_premium_price = initial(temp.custom_premium_price)
		recordlist += R

/obj/machinery/vending/crowbar_act(mob/living/user, obj/item/I)
	if(!component_parts)
		return FALSE
	default_deconstruction_crowbar(I)
	return TRUE

/obj/machinery/vending/wrench_act(mob/living/user, obj/item/I)
	if(panel_open)
		default_unfasten_wrench(user, I, time = 60)
	return TRUE

/obj/machinery/vending/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(anchored)
		default_deconstruction_screwdriver(user, icon_state, icon_state, I)
		cut_overlays()
		if(panel_open)
			add_overlay("[initial(icon_state)]-panel")
		updateUsrDialog()
	else
		to_chat(user, "<span class='warning'>You must first secure [src].</span>")
	return TRUE

/obj/machinery/vending/attackby(obj/item/I, mob/user, params)
	//if(panel_open && is_wire_tool(I))
	//	wires.interact(user)
	//	return
	//if(refill_canister && istype(I, refill_canister))
	if(FALSE)//not_actual
		//if (!panel_open)
		//	to_chat(user, "<span class='notice'>You should probably unscrew the service panel first.</span>")
		//else if (stat & (BROKEN|NOPOWER))
		//	to_chat(user, "<span class='notice'>[src] does not respond.</span>")
		//else
		//	var/obj/item/vending_refill/canister = I
		//	if(canister.get_part_rating() == 0)
		//		to_chat(user, "<span class='notice'>[canister] is empty!</span>")
		//	else
		//		var/transferred = restock(canister)
		//		if(transferred)
		//			to_chat(user, "<span class='notice'>You loaded [transferred] items in [src].</span>")
		//		else
		//			to_chat(user, "<span class='notice'>There's nothing to restock!</span>")
		//	return
	else
		return ..()

/obj/machinery/vending/on_deconstruction()
	//update_canister()
	. = ..()

/obj/machinery/vending/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	to_chat(user, "<span class='notice'>You short out the product lock on [src].</span>")

/obj/machinery/vending/_try_interact(mob/user)
	//if(seconds_electrified && !(stat & NOPOWER))
	//	if(shock(user, 100))
	//		return
	return ..()

/obj/machinery/vending/ui_interact(mob/user)
	var/dat = ""
	var/datum/bank_account/account
	var/mob/living/carbon/human/H
	var/obj/item/card/id/C
	if(ishuman(user))
		H = user
		C = H.get_idcard(TRUE)

	if(!C)
		dat += "<font color = 'red'><h3>No ID Card detected!</h3></font>"
	else if (!C.registered_account)
		dat += "<font color = 'red'><h3>No account on registered ID card!</h3></font>"
	if(onstation && C && C.registered_account)
		account = C.registered_account
	dat += "<h3>Select an item</h3>"
	dat += "<div class='statusDisplay'>"
	if(!product_records.len)
		dat += "<font color = 'red'>No product loaded!</font>"
	else
		var/list/display_records = product_records + coin_records
		if(extended_inventory)
			display_records = product_records + coin_records + hidden_records
		dat += "<ul>"
		for (var/datum/data/vending_product/R in display_records)
			var/price_listed = "$[default_price]"
			var/is_hidden = hidden_records.Find(R)
			if(is_hidden && !extended_inventory)
				continue
			if(R.custom_price)
				price_listed = "$[R.custom_price]"
			if(!onstation || account && account.account_job && account.account_job.paycheck_department == payment_department)
				price_listed = "FREE"
			if(coin_records.Find(R) || is_hidden)
				price_listed = "$[R.custom_premium_price ? R.custom_premium_price : extra_price]"
			dat += "<li>"
			if(R.amount > 0 && ((C && C.registered_account && onstation) || (!onstation && isliving(user))))
				dat += "<a href='byond://?src=[REF(src)];vend=[REF(R)]'>Vend</a> "
			else
				dat += "<span class='linkOff'>Not Available</span> "
			dat += "<font color = '[R.display_color]'><b>[sanitize(R.name)] ([price_listed])</b>:</font>"
			dat += " <b>[R.amount]</b>"
			dat += "</li>"
		dat += "</ul>"
	dat += "</div>"
	if(onstation && C && C.registered_account)
		dat += "<b>Balance: $[account.account_balance]</b>"
	//if(istype(src, /obj/machinery/vending/snack))
	//	dat += "<h3>Chef's Food Selection</h3>"
	//	dat += "<div class='statusDisplay'>"
	//	for (var/O in dish_quants)
	//		if(dish_quants[O] > 0)
	//			var/N = dish_quants[O]
	//			dat += "<a href='byond://?src=[REF(src)];dispense=[sanitize(O)]'>Dispense</A> "
	//			dat += "<B>[capitalize(O)] ($[default_price]): [N]</B><br>"
	//	dat += "</div>"

	var/datum/browser/popup = new(user, "vending", (name))
	popup.set_content(dat)
	//popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.open()

/obj/machinery/vending/Topic(href, href_list)
	if(..())
		return

	usr.set_machine(src)

	if((href_list["dispense"]) && (vend_ready))
		var/N = href_list["dispense"]
		if(dish_quants[N] <= 0)
			return
		vend_ready = 0
		if(ishuman(usr) && onstation)
			var/mob/living/carbon/human/H = usr
			var/obj/item/card/id/C = H.get_idcard(TRUE)

			if(!C)
				say("No card found.")
				//flick(icon_deny,src)
				vend_ready = 1
				return
			else if (!C.registered_account)
				say("No account found.")
				//flick(icon_deny,src)
				vend_ready = 1
				return
			var/datum/bank_account/account = C.registered_account
			if(!account.adjust_money(-chef_price))
				say("You do not possess the funds to purchase this meal.")
		//var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_SRV)
		//if(D)
		//	D.adjust_money(chef_price)
		use_power(5)

		dish_quants[N] = max(dish_quants[N] - 1, 0)
		for(var/obj/O in contents)
			if(O.name == N)
				say("Thank you for supporting your local kitchen and purchasing [O]!")
				O.forceMove(drop_location())
				break
		vend_ready = 1
		updateUsrDialog()
		return

	if((href_list["vend"]) && (vend_ready))
		if(panel_open)
			to_chat(usr, "<span class='notice'>The vending machine cannot dispense products while its service panel is open!</span>")
			return

		vend_ready = 0

		var/datum/data/vending_product/R = locate(href_list["vend"])
		var/list/record_to_check = product_records + coin_records
		if(extended_inventory)
			record_to_check = product_records + coin_records + hidden_records
		if(!R || !istype(R) || !R.product_path)
			vend_ready = 1
			return
		var/price_to_use = default_price
		if(R.custom_price)
			price_to_use = R.custom_price
		if(R in hidden_records)
			if(!extended_inventory)
				vend_ready = 1
				return

		else if (!(R in record_to_check))
			vend_ready = 1
			//message_admins("Vending machine exploit attempted by [ADMIN_LOOKUPFLW(usr)]!")
			return
		if (R.amount <= 0)
			say("Sold out of [R.name].")
			//flick(icon_deny,src)
			vend_ready = 1
			return
		if(onstation && ishuman(usr))
			var/mob/living/carbon/human/H = usr
			var/obj/item/card/id/C = H.get_idcard(TRUE)

			if(!C)
				say("No card found.")
				//flick(icon_deny,src)
				vend_ready = 1
				return
			else if (!C.registered_account)
				say("No account found.")
				//flick(icon_deny,src)
				vend_ready = 1
				return
			var/datum/bank_account/account = C.registered_account
			if(account.account_job && account.account_job.paycheck_department == payment_department)
				price_to_use = 0
			if(coin_records.Find(R) || hidden_records.Find(R))
				price_to_use = R.custom_premium_price ? R.custom_premium_price : extra_price
			if(price_to_use && !account.adjust_money(-price_to_use))
				say("You do not possess the funds to purchase [R.name].")
				//flick(icon_deny,src)
				vend_ready = 1
				return
			//var/datum/bank_account/D = SSeconomy.get_dep_account(payment_department)
			//if(D)
			//	D.adjust_money(price_to_use)
		say("Thank you for shopping with [src]!")
		use_power(5)
		//if(icon_vend)
		//	flick(icon_vend,src)
		new R.product_path(get_turf(src))
		R.amount--
		//SSblackbox.record_feedback("nested tally", "vending_machine_usage", 1, list("[type]", "[R.product_path]"))
		vend_ready = 1

	else if(href_list["togglevoice"] && panel_open)
		shut_up = !shut_up

	updateUsrDialog()

/obj/machinery/vending/process()
	if(stat & (BROKEN|NOPOWER))
		return PROCESS_KILL
	if(!active)
		return

	if(seconds_electrified > MACHINE_NOT_ELECTRIFIED)
		seconds_electrified--

	if(last_slogan + slogan_delay <= world.time && slogan_list.len > 0 && !shut_up && prob(5))
		var/slogan = pick(slogan_list)
		speak(slogan)
		last_slogan = world.time

	if(shoot_inventory && prob(shoot_inventory_chance))
		throw_item()

/obj/machinery/vending/proc/speak(message)
	if(stat & (BROKEN|NOPOWER))
		return
	if(!message)
		return

	say(message)

/obj/machinery/vending/power_change()
	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
	else
		if(powered())
			icon_state = initial(icon_state)
			stat &= ~NOPOWER
			START_PROCESSING(SSmachines, src)
		else
			icon_state = "[initial(icon_state)]-off"
			stat |= NOPOWER

/obj/machinery/vending/proc/throw_item()
	//var/obj/throw_item = null
	//var/mob/living/target = locate() in view(7,src)
	//if(!target)
	//	return 0

	//for(var/datum/data/vending_product/R in shuffle(product_records))
	//	if(R.amount <= 0)
	//		continue
	//	var/dump_path = R.product_path
	//	if(!dump_path)
	//		continue

	//	R.amount--
	//	throw_item = new dump_path(loc)
	//	break
	//if(!throw_item)
	//	return 0

	//pre_throw(throw_item)

	//throw_item.throw_at(target, 16, 3)
	//visible_message("<span class='danger'>[src] launches [throw_item] at [target]!</span>")
	return 1

/obj/machinery/vending/proc/pre_throw(obj/item/I)
	return

/obj/machinery/vending/proc/shock(mob/user, prb)
	if(stat & (BROKEN|NOPOWER))
		return FALSE
	if(!prob(prb))
		return FALSE
	do_sparks(5, TRUE, src)
	//var/check_range = TRUE
	//if(electrocute_mob(user, get_area(src), src, 0.7, check_range))
	//	return TRUE
	//else
	//	return FALSE
	return FALSE//not_actual

///obj/machinery/vending/onTransitZ()
//	return