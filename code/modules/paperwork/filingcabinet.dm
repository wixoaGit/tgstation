/obj/structure/filingcabinet
	name = "filing cabinet"
	desc = "A large cabinet with drawers."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "filingcabinet"
	density = TRUE
	anchored = TRUE

/obj/structure/filingcabinet/chestdrawer
	name = "chest drawer"
	icon_state = "chestdrawer"

/obj/structure/filingcabinet/chestdrawer/wheeled
	name = "rolling chest drawer"
	desc = "A small cabinet with drawers. This one has wheels!"
	anchored = FALSE

/obj/structure/filingcabinet/filingcabinet
	icon_state = "tallcabinet"

/obj/structure/filingcabinet/Initialize(mapload)
	. = ..()
	if(mapload)
		for(var/obj/item/I in loc)
			if(istype(I, /obj/item/paper) || istype(I, /obj/item/folder) || istype(I, /obj/item/photo))
				I.forceMove(src)

/obj/structure/filingcabinet/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/metal(loc, 2)
		for(var/obj/item/I in src)
			I.forceMove(loc)
	qdel(src)

/obj/structure/filingcabinet/attackby(obj/item/P, mob/user, params)
	if(istype(P, /obj/item/paper) || istype(P, /obj/item/folder) || istype(P, /obj/item/photo) || istype(P, /obj/item/documents))
		if(!user.transferItemToLoc(P, src))
			return
		to_chat(user, "<span class='notice'>You put [P] in [src].</span>")
		icon_state = "[initial(icon_state)]-open"
		sleep(5)
		icon_state = initial(icon_state)
		updateUsrDialog()
	else if(P.tool_behaviour == TOOL_WRENCH)
		to_chat(user, "<span class='notice'>You begin to [anchored ? "unwrench" : "wrench"] [src].</span>")
		if(P.use_tool(src, user, 20, volume=50))
			to_chat(user, "<span class='notice'>You successfully [anchored ? "unwrench" : "wrench"] [src].</span>")
			anchored = !anchored
	else if(user.a_intent != INTENT_HARM)
		to_chat(user, "<span class='warning'>You can't put [P] in [src]!</span>")
	else
		return ..()

/obj/structure/filingcabinet/ui_interact(mob/user)
	. = ..()
	if(contents.len <= 0)
		to_chat(user, "<span class='notice'>[src] is empty.</span>")
		return

	var/dat = "<center><table>"
	var/i
	for(i=contents.len, i>=1, i--)
		var/obj/item/P = contents[i]
		dat += "<tr><td><a href='?src=[REF(src)];retrieve=[REF(P)]'>[P.name]</a></td></tr>"
	dat += "</table></center>"
	user << browse("<html><head><title>[name]</title></head><body>[dat]</body></html>", "window=filingcabinet;size=350x300")

///obj/structure/filingcabinet/attack_tk(mob/user)
//	if(anchored)
//		attack_self_tk(user)
//	else
//		..()

///obj/structure/filingcabinet/attack_self_tk(mob/user)
//	if(contents.len)
//		if(prob(40 + contents.len * 5))
//			var/obj/item/I = pick(contents)
//			I.forceMove(loc)
//			if(prob(25))
//				step_rand(I)
//			to_chat(user, "<span class='notice'>You pull \a [I] out of [src] at random.</span>")
//			return
//	to_chat(user, "<span class='notice'>You find nothing in [src].</span>")

/obj/structure/filingcabinet/Topic(href, href_list)
	if(!usr.canUseTopic(src, BE_CLOSE, ismonkey(usr)))
		return
	if(href_list["retrieve"])
		usr << browse("", "window=filingcabinet")

		var/obj/item/P = locate(href_list["retrieve"]) in src
		if(istype(P) && in_range(src, usr))
			usr.put_in_hands(P)
			updateUsrDialog()
			icon_state = "[initial(icon_state)]-open"
			sleep(5)
			icon_state = initial(icon_state)