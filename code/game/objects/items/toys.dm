/obj/item/toy
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	force = 0

/obj/item/toy/nuke
	name = "\improper Nuclear Fission Explosive toy"
	desc = "A plastic model of a Nuclear Fission Explosive."
	icon = 'icons/obj/toy.dmi'
	icon_state = "nuketoyidle"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0

/obj/item/toy/nuke/attack_self(mob/user)
	if (cooldown < world.time)
		cooldown = world.time + 1800
		user.visible_message("<span class='warning'>[user] presses a button on [src].</span>", "<span class='notice'>You activate [src], it plays a loud noise!</span>", "<span class='italics'>You hear the click of a button.</span>")
		sleep(5)
		icon_state = "nuketoy"
		playsound(src, 'sound/machines/alarm.ogg', 100, 0)
		sleep(135)
		icon_state = "nuketoycool"
		sleep(cooldown - world.time)
		icon_state = "nuketoyidle"
	else
		var/timeleft = (cooldown - world.time)
		to_chat(user, "<span class='alert'>Nothing happens, and '</span>[round(timeleft/10)]<span class='alert'>' appears on a small display.</span>")