/obj/item/stock_parts/cell
	name = "power cell"
	desc = "A rechargeable electrochemical power cell."
	icon = 'icons/obj/power.dmi'
	icon_state = "cell"
	item_state = "cell"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	force = 5
	throwforce = 5
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	var/charge = 0
	var/maxcharge = 1000
	materials = list(MAT_METAL=700, MAT_GLASS=50)
	grind_results = list("lithium" = 15, "iron" = 5, "silicon" = 5)
	var/rigged = FALSE
	var/chargerate = 100
	var/self_recharge = 0
	var/ratingdesc = TRUE
	var/grown_battery = FALSE

/obj/item/stock_parts/cell/get_cell()
	return src

/obj/item/stock_parts/cell/Initialize(mapload, override_maxcharge)
	. = ..()
	START_PROCESSING(SSobj, src)
	create_reagents(5, INJECTABLE | DRAINABLE)
	if (override_maxcharge)
		maxcharge = override_maxcharge
	charge = maxcharge
	if(ratingdesc)
		desc += " This one has a rating of [DisplayEnergy(maxcharge)], and you should not swallow it."
	update_icon()

/obj/item/stock_parts/cell/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/stock_parts/cell/process()
	if(self_recharge)
		give(chargerate * 0.25)
	else
		return PROCESS_KILL

/obj/item/stock_parts/cell/update_icon()
	cut_overlays()
	if(grown_battery)
		add_overlay(image('icons/obj/power.dmi',"grown_wires"))
	if(charge < 0.01)
		return
	else if(charge/maxcharge >=0.995)
		add_overlay("cell-o2")
	else
		add_overlay("cell-o1")

/obj/item/stock_parts/cell/proc/percent()
	return 100*charge/maxcharge

/obj/item/stock_parts/cell/use(amount)
	if(rigged && amount > 0)
		explode()
		return 0
	if(charge < amount)
		return 0
	charge = (charge - amount)
	//if(!istype(loc, /obj/machinery/power/apc))
	//	SSblackbox.record_feedback("tally", "cell_used", 1, type)
	return 1

/obj/item/stock_parts/cell/proc/give(amount)
	if(rigged && amount > 0)
		explode()
		return 0
	if(maxcharge < amount)
		amount = maxcharge
	var/power_used = min(maxcharge-charge,amount)
	charge += power_used
	return power_used

/obj/item/stock_parts/cell/examine(mob/user)
	..()
	if(rigged)
		to_chat(user, "<span class='danger'>This power cell seems to be faulty!</span>")
	else
		to_chat(user, "The charge meter reads [round(src.percent() )]%.")

/obj/item/stock_parts/cell/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is licking the electrodes of [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (FIRELOSS)

/obj/item/stock_parts/cell/proc/explode()
	var/turf/T = get_turf(src.loc)
	if (charge==0)
		return
	var/devastation_range = -1
	var/heavy_impact_range = round(sqrt(charge)/60)
	var/light_impact_range = round(sqrt(charge)/30)
	var/flash_range = light_impact_range
	if (light_impact_range==0)
		rigged = FALSE
		corrupt()
		return
	explosion(T, devastation_range, heavy_impact_range, light_impact_range, flash_range)
	qdel(src)

/obj/item/stock_parts/cell/proc/corrupt()
	charge /= 2
	maxcharge = max(maxcharge/2, chargerate)
	if (prob(10))
		rigged = TRUE

/obj/item/stock_parts/cell/empty/Initialize()
	. = ..()
	charge = 0

/obj/item/stock_parts/cell/upgraded
	name = "upgraded power cell"
	desc = "A power cell with a slightly higher capacity than normal!"
	maxcharge = 2500
	materials = list(MAT_GLASS=50)
	chargerate = 1000

/obj/item/stock_parts/cell/high
	name = "high-capacity power cell"
	icon_state = "hcell"
	maxcharge = 10000
	materials = list(MAT_GLASS=60)
	chargerate = 1500

/obj/item/stock_parts/cell/infinite
	name = "infinite-capacity power cell!"
	icon_state = "icell"
	maxcharge = 30000
	materials = list(MAT_GLASS=1000)
	rating = 100
	chargerate = 30000

/obj/item/stock_parts/cell/infinite/use()
	return 1

/obj/item/stock_parts/cell/emergency_light
	name = "miniature power cell"
	desc = "A tiny power cell with a very low power capacity. Used in light fixtures to power them in the event of an outage."
	maxcharge = 120
	materials = list(MAT_GLASS = 20)
	w_class = WEIGHT_CLASS_TINY

/obj/item/stock_parts/cell/emergency_light/Initialize()
	. = ..()
	var/area/A = get_area(src)
	if(!A.lightswitch || !A.light_power)
		charge = 0