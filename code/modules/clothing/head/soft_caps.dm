/obj/item/clothing/head/soft
	name = "cargo cap"
	desc = "It's a baseball hat in a tasteless yellow colour."
	icon_state = "cargosoft"
	item_state = "helmet"
	item_color = "cargo"

	//dog_fashion = /datum/dog_fashion/head/cargo_tech

	var/flipped = 0

/obj/item/clothing/head/soft/AltClick(mob/user)
	..()
	if(!user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	else
		flip(user)

/obj/item/clothing/head/soft/proc/flip(mob/user)
	if(!user.incapacitated())
		src.flipped = !src.flipped
		if(src.flipped)
			icon_state = "[item_color]soft_flipped"
			to_chat(user, "<span class='notice'>You flip the hat backwards.</span>")
		else
			icon_state = "[item_color]soft"
			to_chat(user, "<span class='notice'>You flip the hat back in normal position.</span>")
		usr.update_inv_head()

/obj/item/clothing/head/soft/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Alt-click the cap to flip it [flipped ? "forwards" : "backwards"].</span>")

/obj/item/clothing/head/soft/mime
	name = "white cap"
	desc = "It's a baseball hat in a tasteless white colour."
	icon_state = "mimesoft"
	item_color = "mime"
	dog_fashion = null