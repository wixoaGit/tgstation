GLOBAL_LIST_EMPTY(allCasters)

/obj/item/wallframe/newscaster
	name = "newscaster frame"
	desc = "Used to build newscasters, just secure to the wall."
	icon_state = "newscaster"
	materials = list(MAT_METAL=14000, MAT_GLASS=8000)
	result_path = /obj/machinery/newscaster


/obj/machinery/newscaster
	name = "newscaster"
	desc = "A standard Nanotrasen-licensed newsfeed handler for use in commercial space stations. All the news you absolutely have no use for, in one place!"
	icon = 'icons/obj/terminals.dmi'
	icon_state = "newscaster_normal"
	verb_say = "beeps"
	verb_ask = "beeps"
	verb_exclaim = "beeps"
	armor = list("melee" = 50, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 30)
	max_integrity = 200
	integrity_failure = 50
	var/screen = 0
	var/paper_remaining = 15
	var/securityCaster = 0
	var/unit_no = 0
	var/alert_delay = 500
	var/alert = FALSE
	var/scanned_user = "Unknown"
	var/msg = ""
	//var/datum/picture/picture
	var/channel_name = ""
	var/c_locked=0
	//var/datum/newscaster/feed_channel/viewing_channel = null
	var/allow_comments = 1

/obj/machinery/newscaster/security_unit
	name = "security newscaster"
	securityCaster = 1

/obj/machinery/newscaster/Initialize(mapload, ndir, building)
	. = ..()
	if(building)
		setDir(ndir)
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -32 : 32)
		pixel_y = (dir & 3)? (dir ==1 ? -32 : 32) : 0

	GLOB.allCasters += src
	unit_no = GLOB.allCasters.len
	update_icon()

/obj/machinery/newscaster/Destroy()
	GLOB.allCasters -= src
	//viewing_channel = null
	//picture = null
	return ..()

/obj/machinery/newscaster/update_icon()
	cut_overlays()
	if(stat & (NOPOWER|BROKEN))
		icon_state = "newscaster_off"
	else
		//if(GLOB.news_network.wanted_issue.active)
		if(FALSE)//not_actual
			icon_state = "newscaster_wanted"
		else
			icon_state = "newscaster_normal"
			if(alert)
				add_overlay("newscaster_alert")
	var/hp_percent = obj_integrity * 100 /max_integrity
	//switch(hp_percent)
	//	if(75 to 100)
	//		return
	//	if(50 to 75)
	//		add_overlay("crack1")
	//	if(25 to 50)
	//		add_overlay("crack2")
	//	else
	//		add_overlay("crack3")
	//not_actual
	if (hp_percent < 25)
		add_overlay("crack3")
	else if (hp_percent <= 50)
		add_overlay("crack2")
	else if (hp_percent <= 75)
		add_overlay("crack3")


/obj/machinery/newscaster/power_change()
	if(stat & BROKEN)
		return
	if(powered())
		stat &= ~NOPOWER
		update_icon()
	else
		spawn(rand(0, 15))
			stat |= NOPOWER
			update_icon()

/obj/machinery/newscaster/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	update_icon()

/obj/item/newspaper
	name = "newspaper"
	desc = "An issue of The Griffon, the newspaper circulating aboard Nanotrasen Space Stations."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "newspaper"
	lefthand_file = 'icons/mob/inhands/misc/books_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/books_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("bapped")
	var/screen = 0
	var/pages = 0
	var/curr_page = 0
	//var/list/datum/newscaster/feed_channel/news_content = list()
	var/scribble=""
	var/scribble_page = null
	var/wantedAuthor
	var/wantedCriminal
	var/wantedBody
	var/wantedPhoto
	var/creationTime

/obj/item/newspaper/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is focusing intently on [src]! It looks like [user.p_theyre()] trying to commit sudoku... until [user.p_their()] eyes light up with realization!</span>")
	user.say(";JOURNALISM IS MY CALLING! EVERYBODY APPRECIATES UNBIASED REPORTI-GLORF", forced="newspaper suicide")
	var/mob/living/carbon/human/H = user
	//var/obj/W = new /obj/item/reagent_containers/food/drinks/bottle/whiskey(H.loc)
	//playsound(H.loc, 'sound/items/drink.ogg', rand(10,50), 1)
	//W.reagents.trans_to(H, W.reagents.total_volume, transfered_by = user)
	//user.visible_message("<span class='suicide'>[user] downs the contents of [W.name] in one gulp! Shoulda stuck to sudoku!</span>")

	return(TOXLOSS)

/obj/item/newspaper/attack_self(mob/user)
	if(ishuman(user))
		//var/mob/living/carbon/human/human_user = user
		//var/dat
		//pages = 0
		//switch(screen)
		//	if(0)
		//		dat+="<DIV ALIGN='center'><B><FONT SIZE=6>The Griffon</FONT></B></div>"
		//		dat+="<DIV ALIGN='center'><FONT SIZE=2>Nanotrasen-standard newspaper, for use on Nanotrasen? Space Facilities</FONT></div><HR>"
		//		if(isemptylist(news_content))
		//			if(wantedAuthor)
		//				dat+="Contents:<BR><ul><B><FONT COLOR='red'>**</FONT>Important Security Announcement<FONT COLOR='red'>**</FONT></B> <FONT SIZE=2>\[page [pages+2]\]</FONT><BR></ul>"
		//			else
		//				dat+="<I>Other than the title, the rest of the newspaper is unprinted...</I>"
		//		else
		//			dat+="Contents:<BR><ul>"
		//			for(var/datum/newscaster/feed_channel/NP in news_content)
		//				pages++
		//			if(wantedAuthor)
		//				dat+="<B><FONT COLOR='red'>**</FONT>Important Security Announcement<FONT COLOR='red'>**</FONT></B> <FONT SIZE=2>\[page [pages+2]\]</FONT><BR>"
		//			var/temp_page=0
		//			for(var/datum/newscaster/feed_channel/NP in news_content)
		//				temp_page++
		//				dat+="<B>[NP.channel_name]</B> <FONT SIZE=2>\[page [temp_page+1]\]</FONT><BR>"
		//			dat+="</ul>"
		//		if(scribble_page==curr_page)
		//			dat+="<BR><I>There is a small scribble near the end of this page... It reads: \"[scribble]\"</I>"
		//		dat+= "<HR><DIV STYLE='float:right;'><A href='?src=[REF(src)];next_page=1'>Next Page</A></DIV> <div style='float:left;'><A href='?src=[REF(human_user)];mach_close=newspaper_main'>Done reading</A></DIV>"
		//	if(1)
		//		for(var/datum/newscaster/feed_channel/NP in news_content)
		//			pages++
		//		var/datum/newscaster/feed_channel/C = news_content[curr_page]
		//		dat += "<FONT SIZE=4><B>[C.channel_name]</B></FONT><FONT SIZE=1> \[created by: <FONT COLOR='maroon'>[C.returnAuthor(notContent(C.authorCensorTime))]</FONT>\]</FONT><BR><BR>"
		//		if(notContent(C.DclassCensorTime))
		//			dat+="This channel was deemed dangerous to the general welfare of the station and therefore marked with a <B><FONT COLOR='red'>D-Notice</B></FONT>. Its contents were not transferred to the newspaper at the time of printing."
		//		else
		//			if(isemptylist(C.messages))
		//				dat+="No Feed stories stem from this channel..."
		//			else
		//				var/i = 0
		//				for(var/datum/newscaster/feed_message/MESSAGE in C.messages)
		//					if(MESSAGE.creationTime > creationTime)
		//						if(i == 0)
		//							dat+="No Feed stories stem from this channel..."
		//						break
		//					if(i == 0)
		//						dat+="<ul>"
		//					i++
		//					dat+="-[MESSAGE.returnBody(notContent(MESSAGE.bodyCensorTime))] <BR>"
		//					if(MESSAGE.img)
		//						user << browse_rsc(MESSAGE.img, "tmp_photo[i].png")
		//						dat+="<img src='tmp_photo[i].png' width = '180'><BR>"
		//					dat+="<FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.returnAuthor(notContent(MESSAGE.authorCensorTime))]</FONT>\]</FONT><BR><BR>"
		//				dat+="</ul>"
		//		if(scribble_page==curr_page)
		//			dat+="<BR><I>There is a small scribble near the end of this page... It reads: \"[scribble]\"</I>"
		//		dat+= "<BR><HR><DIV STYLE='float:left;'><A href='?src=[REF(src)];prev_page=1'>Previous Page</A></DIV> <DIV STYLE='float:right;'><A href='?src=[REF(src)];next_page=1'>Next Page</A></DIV>"
		//	if(2)
		//		for(var/datum/newscaster/feed_channel/NP in news_content)
		//			pages++
		//		if(wantedAuthor!=null)
		//			dat+="<DIV STYLE='float:center;'><FONT SIZE=4><B>Wanted Issue:</B></FONT SIZE></DIV><BR><BR>"
		//			dat+="<B>Criminal name</B>: <FONT COLOR='maroon'>[wantedCriminal]</FONT><BR>"
		//			dat+="<B>Description</B>: [wantedBody]<BR>"
		//			dat+="<B>Photo:</B>: "
		//			if(wantedPhoto)
		//				user << browse_rsc(wantedPhoto, "tmp_photow.png")
		//				dat+="<BR><img src='tmp_photow.png' width = '180'>"
		//			else
		//				dat+="None"
		//		else
		//			dat+="<I>Apart from some uninteresting classified ads, there's nothing on this page...</I>"
		//		if(scribble_page==curr_page)
		//			dat+="<BR><I>There is a small scribble near the end of this page... It reads: \"[scribble]\"</I>"
		//		dat+= "<HR><DIV STYLE='float:left;'><A href='?src=[REF(src)];prev_page=1'>Previous Page</A></DIV>"
		//dat+="<BR><HR><div align='center'>[curr_page+1]</div>"
		//human_user << browse(dat, "window=newspaper_main;size=300x400")
		//onclose(human_user, "newspaper_main")
	else
		to_chat(user, "The paper is full of unintelligible symbols!")

/obj/item/newspaper/proc/notContent(list/L)
	if(!L.len)
		return 0
	for(var/i=L.len;i>0;i--)
		var/num = abs(L[i])
		if(creationTime <= num)
			continue
		else
			if(L[i] > 0)
				return 1
			else
				return 0
	return 0

/obj/item/newspaper/Topic(href, href_list)
	var/mob/living/U = usr
	..()
	//if((src in U.contents) || (isturf(loc) && in_range(src, U)))
	//	U.set_machine(src)
	//	if(href_list["next_page"])
	//		if(curr_page == pages+1)
	//			return
	//		if(curr_page == pages)
	//			screen = 2
	//		else
	//			if(curr_page == 0)
	//				screen=1
	//		curr_page++
	//		playsound(loc, "pageturn", 50, 1)
	//	else if(href_list["prev_page"])
	//		if(curr_page == 0)
	//			return
	//		if(curr_page == 1)
	//			screen = 0
	//		else
	//			if(curr_page == pages+1)
	//				screen = 1
	//		curr_page--
	//		playsound(loc, "pageturn", 50, 1)
	//	if(ismob(loc))
	//		attack_self(loc)

/obj/item/newspaper/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/pen))
		//if(!user.is_literate())
		//	to_chat(user, "<span class='notice'>You scribble illegibly on [src]!</span>")
		//	return
		//if(scribble_page == curr_page)
		//	to_chat(user, "<span class='notice'>There's already a scribble in this page... You wouldn't want to make things too cluttered, would you?</span>")
		//else
		//	var/s = stripped_input(user, "Write something", "Newspaper")
		//	if (!s)
		//		return
		//	if(!user.canUseTopic(src, BE_CLOSE))
		//		return
		//	scribble_page = curr_page
		//	scribble = s
		//	attack_self(user)
	else
		return ..()