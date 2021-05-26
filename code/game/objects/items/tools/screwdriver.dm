/obj/item/screwdriver
	name = "screwdriver"
	desc = "You can be totally screwy with this."
	icon = 'icons/obj/tools.dmi'
	icon_state = "screwdriver_map"
	item_state = "screwdriver"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	force = 5
	w_class = WEIGHT_CLASS_TINY
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	materials = list(MAT_METAL=75)
	attack_verb = list("stabbed")
	hitsound = 'sound/weapons/bladeslice.ogg'
	usesound = list('sound/items/screwdriver.ogg', 'sound/items/screwdriver2.ogg')
	tool_behaviour = TOOL_SCREWDRIVER
	toolspeed = 1
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 30)
	var/random_color = TRUE
	//var/static/list/screwdriver_colors = list(
	//	"blue" = rgb(24, 97, 213),
	//	"red" = rgb(255, 0, 0),
	//	"pink" = rgb(213, 24, 141),
	//	"brown" = rgb(160, 82, 18),
	//	"green" = rgb(14, 127, 27),
	//	"cyan" = rgb(24, 162, 213),
	//	"yellow" = rgb(255, 165, 0)
	//)

/obj/item/screwdriver/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is stabbing [src] into [user.p_their()] [pick("temple", "heart")]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return(BRUTELOSS)

/obj/item/screwdriver/Initialize()
	. = ..()
	//if(random_color)
	//	icon_state = "screwdriver"
	//	var/our_color = pick(screwdriver_colors)
	//	add_atom_colour(screwdriver_colors[our_color], FIXED_COLOUR_PRIORITY)
	//	update_icon()
	if(prob(75))
		pixel_y = rand(0, 16)

/obj/item/screwdriver/power
	name = "hand drill"
	desc = "A simple powered hand drill. It's fitted with a screw bit."
	icon_state = "drill_screw"
	item_state = "drill"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	materials = list(MAT_METAL=150,MAT_SILVER=50,MAT_TITANIUM=25)
	force = 8
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 8
	throw_speed = 2
	throw_range = 3
	attack_verb = list("drilled", "screwed", "jabbed","whacked")
	hitsound = 'sound/items/drill_hit.ogg'
	usesound = 'sound/items/drill_use.ogg'
	toolspeed = 0.7
	random_color = FALSE

/obj/item/screwdriver/power/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is putting [src] to [user.p_their()] temple. It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return(BRUTELOSS)

/obj/item/screwdriver/power/attack_self(mob/user)
	playsound(get_turf(user),'sound/items/change_drill.ogg',50,1)
	var/obj/item/wrench/power/b_drill = new /obj/item/wrench/power(drop_location())
	to_chat(user, "<span class='notice'>You attach the bolt driver bit to [src].</span>")
	qdel(src)
	user.put_in_active_hand(b_drill)