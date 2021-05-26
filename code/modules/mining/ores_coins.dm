#define ORESTACK_OVERLAYS_MAX 10

/obj/item/stack/ore
	name = "rock"
	icon = 'icons/obj/mining.dmi'
	icon_state = "ore"
	item_state = "ore"
	full_w_class = WEIGHT_CLASS_BULKY
	singular_name = "ore chunk"
	var/points = 0
	var/refined_type = null
	novariants = TRUE
	var/list/stack_overlays

/obj/item/stack/ore/update_icon()
	var/difference = min(ORESTACK_OVERLAYS_MAX, amount) - (LAZYLEN(stack_overlays)+1)
	if(difference == 0)
		return
	else if(difference < 0 && LAZYLEN(stack_overlays))
		cut_overlays()
		if (LAZYLEN(stack_overlays)-difference <= 0)
			stack_overlays = null;
		else
			stack_overlays.len += difference
	else if(difference > 0)
		cut_overlays()
		for(var/i in 1 to difference)
			var/mutable_appearance/newore = mutable_appearance(icon, icon_state)
			newore.pixel_x = rand(-8,8)
			newore.pixel_y = rand(-8,8)
			LAZYADD(stack_overlays, newore)
	if (stack_overlays)
		add_overlay(stack_overlays)

/obj/item/stack/ore/welder_act(mob/living/user, obj/item/I)
	if(!refined_type)
		return TRUE

	if(I.use_tool(src, user, 0, volume=50, amount=15))
		new refined_type(drop_location())
		use(1)

	return TRUE

///obj/item/stack/ore/fire_act(exposed_temperature, exposed_volume)
//	. = ..()
//	if(isnull(refined_type))
//		return
//	else
//		var/probability = (rand(0,100))/100
//		var/burn_value = probability*amount
//		var/amountrefined = round(burn_value, 1)
//		if(amountrefined < 1)
//			qdel(src)
//		else
//			new refined_type(drop_location(),amountrefined)
//			qdel(src)

/obj/item/stack/ore/uranium
	name = "uranium ore"
	icon_state = "Uranium ore"
	item_state = "Uranium ore"
	singular_name = "uranium ore chunk"
	points = 30
	materials = list(MAT_URANIUM=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/uranium

/obj/item/stack/ore/iron
	name = "iron ore"
	icon_state = "Iron ore"
	item_state = "Iron ore"
	singular_name = "iron ore chunk"
	points = 1
	materials = list(MAT_METAL=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/metal

/obj/item/stack/ore/glass
	name = "sand pile"
	icon_state = "Glass ore"
	item_state = "Glass ore"
	singular_name = "sand pile"
	points = 1
	materials = list(MAT_GLASS=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/glass
	w_class = WEIGHT_CLASS_TINY

GLOBAL_LIST_INIT(sand_recipes, list(\
		new /datum/stack_recipe("sandstone", /obj/item/stack/sheet/mineral/sandstone, 1, 1, 50)\
		))

/obj/item/stack/ore/glass/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.sand_recipes
	. = ..()

/obj/item/stack/ore/glass/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(..() || !ishuman(hit_atom))
		return
	var/mob/living/carbon/human/C = hit_atom
	if(C.is_eyes_covered())
		C.visible_message("<span class='danger'>[C]'s eye protection blocks the sand!</span>", "<span class='warning'>Your eye protection blocks the sand!</span>")
		return
	//C.adjust_blurriness(6)
	C.adjustStaminaLoss(15)
	//C.confused += 5
	to_chat(C, "<span class='userdanger'>\The [src] gets into your eyes! The pain, it burns!</span>")
	qdel(src)

/obj/item/stack/ore/glass/ex_act(severity, target)
	if (severity == EXPLODE_NONE)
		return
	qdel(src)

/obj/item/stack/ore/glass/basalt
	name = "volcanic ash"
	icon_state = "volcanic_sand"
	icon_state = "volcanic_sand"
	singular_name = "volcanic ash pile"

/obj/item/stack/ore/plasma
	name = "plasma ore"
	icon_state = "Plasma ore"
	item_state = "Plasma ore"
	singular_name = "plasma ore chunk"
	points = 15
	materials = list(MAT_PLASMA=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/plasma

/obj/item/stack/ore/plasma/welder_act(mob/living/user, obj/item/I)
	to_chat(user, "<span class='warning'>You can't hit a high enough temperature to smelt [src] properly!</span>")
	return TRUE

/obj/item/stack/ore/silver
	name = "silver ore"
	icon_state = "Silver ore"
	item_state = "Silver ore"
	singular_name = "silver ore chunk"
	points = 16
	materials = list(MAT_SILVER=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/silver

/obj/item/stack/ore/gold
	name = "gold ore"
	icon_state = "Gold ore"
	icon_state = "Gold ore"
	singular_name = "gold ore chunk"
	points = 18
	materials = list(MAT_GOLD=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/gold

/obj/item/stack/ore/diamond
	name = "diamond ore"
	icon_state = "Diamond ore"
	item_state = "Diamond ore"
	singular_name = "diamond ore chunk"
	points = 50
	materials = list(MAT_DIAMOND=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/diamond

/obj/item/stack/ore/bananium
	name = "bananium ore"
	icon_state = "Bananium ore"
	item_state = "Bananium ore"
	singular_name = "bananium ore chunk"
	points = 60
	materials = list(MAT_BANANIUM=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/bananium

/obj/item/stack/ore/titanium
	name = "titanium ore"
	icon_state = "Titanium ore"
	item_state = "Titanium ore"
	singular_name = "titanium ore chunk"
	points = 50
	materials = list(MAT_TITANIUM=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/titanium

/obj/item/stack/ore/slag
	name = "slag"
	desc = "Completely useless."
	icon_state = "slag"
	item_state = "slag"
	singular_name = "slag chunk"

/obj/item/stack/ore/Initialize()
	. = ..()
	pixel_x = rand(0,16)-8
	pixel_y = rand(0,8)-8

/obj/item/stack/ore/ex_act(severity, target)
	if (!severity || severity >= 2)
		return
	qdel(src)

/obj/item/coin
	icon = 'icons/obj/economy.dmi'
	name = "coin"
	icon_state = "coin__heads"
	flags_1 = CONDUCT_1
	force = 1
	throwforce = 2
	w_class = WEIGHT_CLASS_TINY
	var/string_attached
	var/list/sideslist = list("heads","tails")
	var/cmineral = null
	var/cooldown = 0
	var/value = 1
	var/coinflip

///obj/item/coin/get_item_credit_value()
//	return value

/obj/item/coin/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] contemplates suicide with \the [src]!</span>")
	if (!attack_self(user))
		user.visible_message("<span class='suicide'>[user] couldn't flip \the [src]!</span>")
		return SHAME
	addtimer(CALLBACK(src, .proc/manual_suicide, user), 10)
	return MANUAL_SUICIDE

/obj/item/coin/proc/manual_suicide(mob/living/user)
	var/index = sideslist.Find(coinflip)
	if (index==2)
		user.visible_message("<span class='suicide'>\the [src] lands on [coinflip]! [user] promptly falls over, dead!</span>")
		user.adjustOxyLoss(200)
		user.death(0)
	else
		user.visible_message("<span class='suicide'>\the [src] lands on [coinflip]! [user] keeps on living!</span>")

/obj/item/coin/Initialize()
	. = ..()
	pixel_x = rand(0,16)-8
	pixel_y = rand(0,8)-8

/obj/item/coin/examine(mob/user)
	..()
	if(value)
		to_chat(user, "<span class='info'>It's worth [value] credit\s.</span>")

/obj/item/coin/gold
	name = "gold coin"
	cmineral = "gold"
	icon_state = "coin_gold_heads"
	value = 25
	materials = list(MAT_GOLD = MINERAL_MATERIAL_AMOUNT*0.2)
	grind_results = list("gold" = 4)

/obj/item/coin/silver
	name = "silver coin"
	cmineral = "silver"
	icon_state = "coin_silver_heads"
	value = 10
	materials = list(MAT_SILVER = MINERAL_MATERIAL_AMOUNT*0.2)
	grind_results = list("silver" = 4)

/obj/item/coin/diamond
	name = "diamond coin"
	cmineral = "diamond"
	icon_state = "coin_diamond_heads"
	value = 100
	materials = list(MAT_DIAMOND = MINERAL_MATERIAL_AMOUNT*0.2)
	grind_results = list("carbon" = 4)

/obj/item/coin/iron
	name = "iron coin"
	cmineral = "iron"
	icon_state = "coin_iron_heads"
	value = 1
	materials = list(MAT_METAL = MINERAL_MATERIAL_AMOUNT*0.2)
	grind_results = list("iron" = 4)

/obj/item/coin/plasma
	name = "plasma coin"
	cmineral = "plasma"
	icon_state = "coin_plasma_heads"
	value = 40
	materials = list(MAT_PLASMA = MINERAL_MATERIAL_AMOUNT*0.2)
	grind_results = list("plasma" = 4)

/obj/item/coin/uranium
	name = "uranium coin"
	cmineral = "uranium"
	icon_state = "coin_uranium_heads"
	value = 25
	materials = list(MAT_URANIUM = MINERAL_MATERIAL_AMOUNT*0.2)
	grind_results = list("uranium" = 4)

/obj/item/coin/bananium
	name = "bananium coin"
	cmineral = "bananium"
	icon_state = "coin_bananium_heads"
	value = 200
	materials = list(MAT_BANANIUM = MINERAL_MATERIAL_AMOUNT*0.2)
	grind_results = list("banana" = 4)

/obj/item/coin/adamantine
	name = "adamantine coin"
	cmineral = "adamantine"
	icon_state = "coin_adamantine_heads"
	value = 100

/obj/item/coin/mythril
	name = "mythril coin"
	cmineral = "mythril"
	icon_state = "coin_mythril_heads"
	value = 300

/obj/item/coin/twoheaded
	cmineral = "iron"
	icon_state = "coin_iron_heads"
	desc = "Hey, this coin's the same on both sides!"
	sideslist = list("heads")
	materials = list(MAT_METAL = MINERAL_MATERIAL_AMOUNT*0.2)
	value = 1
	grind_results = list("iron" = 4)

/obj/item/coin/antagtoken
	name = "antag token"
	icon_state = "coin_valid_valid"
	cmineral = "valid"
	desc = "A novelty coin that helps the heart know what hard evidence cannot prove."
	sideslist = list("valid", "salad")
	value = 0
	grind_results = list("sodiumchloride" = 4)

/obj/item/coin/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/CC = W
		if(string_attached)
			to_chat(user, "<span class='warning'>There already is a string attached to this coin!</span>")
			return

		if (CC.use(1))
			add_overlay("coin_string_overlay")
			string_attached = 1
			to_chat(user, "<span class='notice'>You attach a string to the coin.</span>")
		else
			to_chat(user, "<span class='warning'>You need one length of cable to attach a string to the coin!</span>")
			return
	else
		..()

/obj/item/coin/wirecutter_act(mob/living/user, obj/item/I)
	if(!string_attached)
		return TRUE

	new /obj/item/stack/cable_coil(drop_location(), 1)
	overlays = list()
	string_attached = null
	to_chat(user, "<span class='notice'>You detach the string from the coin.</span>")
	return TRUE

/obj/item/coin/attack_self(mob/user)
	if(cooldown < world.time)
		if(string_attached)
			to_chat(user, "<span class='warning'>The coin won't flip very well with something attached!</span>" )
			return FALSE
		coinflip = pick(sideslist)
		cooldown = world.time + 15
		//flick("coin_[cmineral]_flip", src)
		icon_state = "coin_[cmineral]_[coinflip]"
		playsound(user.loc, 'sound/items/coinflip.ogg', 50, 1)
		var/oldloc = loc
		sleep(15)
		if(loc == oldloc && user && !user.incapacitated())
			user.visible_message("[user] has flipped [src]. It lands on [coinflip].", \
 							 "<span class='notice'>You flip [src]. It lands on [coinflip].</span>", \
							 "<span class='italics'>You hear the clattering of loose change.</span>")
	return TRUE


#undef ORESTACK_OVERLAYS_MAX