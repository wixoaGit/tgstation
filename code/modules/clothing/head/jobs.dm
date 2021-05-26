/obj/item/clothing/head/chefhat
	name = "chef's hat"
	item_state = "chef"
	icon_state = "chef"
	desc = "The commander in chef's head wear."
	strip_delay = 10
	equip_delay_other = 10
	dynamic_hair_suffix = ""
	//dog_fashion = /datum/dog_fashion/head/chef

/obj/item/clothing/head/chefhat/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is donning [src]! It looks like [user.p_theyre()] trying to become a chef.</span>")
	user.say("Bork Bork Bork!", forced = "chef hat suicide")
	sleep(20)
	user.visible_message("<span class='suicide'>[user] climbs into an imaginary oven!</span>")
	user.say("BOOORK!", forced = "chef hat suicide")
	playsound(user, 'sound/machines/ding.ogg', 50, 1)
	return(FIRELOSS)

/obj/item/clothing/head/caphat
	name = "captain's hat"
	desc = "It's good being the king."
	icon_state = "captain"
	item_state = "that"

/obj/item/clothing/head/hopcap
	name = "head of personnel's cap"
	icon_state = "hopcap"
	desc = "The symbol of true bureaucratic micromanagement."
	armor = list("melee" = 25, "bullet" = 15, "laser" = 25, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	//dog_fashion = /datum/dog_fashion/head/hop