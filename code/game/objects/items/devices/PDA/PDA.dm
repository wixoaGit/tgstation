GLOBAL_LIST_EMPTY(PDAs)

#define PDA_SCANNER_NONE		0
#define PDA_SCANNER_MEDICAL		1
#define PDA_SCANNER_FORENSICS	2
#define PDA_SCANNER_REAGENT		3
#define PDA_SCANNER_HALOGEN		4
#define PDA_SCANNER_GAS			5
#define PDA_SPAM_DELAY		    2 MINUTES

/obj/item/pda
	name = "\improper PDA"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. Functionality determined by a preprogrammed ROM cartridge."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pda"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_TINY
	slot_flags = ITEM_SLOT_ID | ITEM_SLOT_BELT

	var/owner = null
	var/default_cartridge = 0
	var/obj/item/cartridge/cartridge = null
	var/mode = 0
	var/font_index = 0
	var/font_mode = "font-family:monospace;"
	var/background_color = "#808000"

	#define FONT_MONO "font-family:monospace;"
	#define FONT_SHARE "font-family:\"Share Tech Mono\", monospace;letter-spacing:0px;"
	#define FONT_ORBITRON "font-family:\"Orbitron\", monospace;letter-spacing:0px; font-size:15px"
	#define FONT_VT "font-family:\"VT323\", monospace;letter-spacing:1px;"
	#define MODE_MONO 0
	#define MODE_SHARE 1
	#define MODE_ORBITRON 2
	#define MODE_VT 3

	var/scanmode = PDA_SCANNER_NONE
	var/fon = FALSE
	var/f_lum = 2.3
	var/silent = FALSE
	var/toff = FALSE
	var/tnote = null
	var/last_noise
	var/ttone = "beep"
	var/honkamt = 0
	var/note = "Congratulations, your station has chosen the Thinktronic 5230 Personal Data Assistant!"
	var/notehtml = ""
	var/notescanned = FALSE
	var/detonatable = TRUE

	var/obj/item/card/id/id = null
	var/ownjob = null

	var/obj/item/paicard/pai = null

	var/obj/item/inserted_item
	var/overlays_x_offset = 0

	var/underline_flag = TRUE

/obj/item/pda/examine(mob/user)
	..()
	if(!id && !inserted_item)
		return

	if(id)
		to_chat(user, "<span class='notice'>Alt-click to remove the id.</span>")

	if(inserted_item && (!isturf(loc)))
		to_chat(user, "<span class='notice'>Ctrl-click to remove [inserted_item].</span>")

/obj/item/pda/Initialize()
	. = ..()
	if(fon)
		set_light(f_lum)

	GLOB.PDAs += src
	if(default_cartridge)
		cartridge = new default_cartridge(src)
	if(inserted_item)
		inserted_item = new inserted_item(src)
	//else
	//	inserted_item =	new /obj/item/pen(src)
	update_icon()

/obj/item/pda/proc/update_label()
	name = "PDA-[owner] ([ownjob])"

/obj/item/pda/GetAccess()
	if(id)
		return id.GetAccess()
	else
		return ..()

/obj/item/pda/GetID()
	return id

/obj/item/pda/update_icon()
	cut_overlays()
	var/mutable_appearance/overlay = new()
	overlay.pixel_x = overlays_x_offset
	if(id)
		overlay.icon_state = "id_overlay"
		add_overlay(new /mutable_appearance(overlay))
	if(inserted_item)
		overlay.icon_state = "insert_overlay"
		add_overlay(new /mutable_appearance(overlay))
	if(fon)
		overlay.icon_state = "light_overlay"
		add_overlay(new /mutable_appearance(overlay))
	//if(pai)
	//	if(pai.pai)
	//		overlay.icon_state = "pai_overlay"
	//		add_overlay(new /mutable_appearance(overlay))
	//	else
	//		overlay.icon_state = "pai_off_overlay"
	//		add_overlay(new /mutable_appearance(overlay))

/obj/item/pda/interact(mob/user)
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	..()

	//var/datum/asset/spritesheet/assets = get_asset_datum(/datum/asset/spritesheet/simple/pda)
	//assets.send(user)

	user.set_machine(src)

	var/dat = "<!DOCTYPE html><html><head><title>Personal Data Assistant</title><link href=\"https://fonts.googleapis.com/css?family=Orbitron|Share+Tech+Mono|VT323\" rel=\"stylesheet\"></head><body bgcolor=\"" + background_color + "\"><style>body{" + font_mode + "}ul,ol{list-style-type: none;}a, a:link, a:visited, a:active, a:hover { color: #000000;text-decoration:none; }img {border-style:none;}a img{padding-right: 9px;}</style>"
	//dat += assets.css_tag()

	dat += "<a href='byond://?src=[REF(src)];choice=Refresh'>[PDAIMG(refresh)]Refresh</a>"

	if ((!isnull(cartridge)) && (mode == 0))
		dat += " | <a href='byond://?src=[REF(src)];choice=Eject'>[PDAIMG(eject)]Eject [cartridge]</a>"
	if (mode)
		dat += " | <a href='byond://?src=[REF(src)];choice=Return'>[PDAIMG(menu)]Return</a>"

	if (mode == 0)
		dat += "<div align=\"center\">"
		dat += "<br><a href='byond://?src=[REF(src)];choice=Toggle_Font'>Toggle Font</a>"
		dat += " | <a href='byond://?src=[REF(src)];choice=Change_Color'>Change Color</a>"
		dat += " | <a href='byond://?src=[REF(src)];choice=Toggle_Underline'>Toggle Underline</a>"

		dat += "</div>"

	dat += "<br>"

	if (!owner)
		dat += "Warning: No owner information entered.  Please swipe card.<br><br>"
		dat += "<a href='byond://?src=[REF(src)];choice=Refresh'>[PDAIMG(refresh)]Retry</a>"
	else
		switch (mode)
			if (0)
				dat += "<h2>PERSONAL DATA ASSISTANT v.1.2</h2>"
				dat += "Owner: [owner], [ownjob]<br>"
				dat += text("ID: <a href='?src=[REF(src)];choice=Authenticate'>[id ? "[id.registered_name], [id.assignment]" : "----------"]")
				dat += text("<br><a href='?src=[REF(src)];choice=UpdateInfo'>[id ? "Update PDA Info" : ""]</A><br><br>")

				dat += "[station_time_timestamp()]<br>"
				dat += "[time2text(world.realtime, "MMM DD")] [GLOB.year_integer+540]"

				dat += "<br><br>"

				dat += "<h4>General Functions</h4>"
				dat += "<ul>"
				dat += "<li><a href='byond://?src=[REF(src)];choice=1'>[PDAIMG(notes)]Notekeeper</a></li>"
				dat += "<li><a href='byond://?src=[REF(src)];choice=2'>[PDAIMG(mail)]Messenger</a></li>"

				if (cartridge)
					if (cartridge.access & CART_CLOWN)
						dat += "<li><a href='byond://?src=[REF(src)];choice=Honk'>[PDAIMG(honk)]Honk Synthesizer</a></li>"
						dat += "<li><a href='byond://?src=[REF(src)];choice=Trombone'>[PDAIMG(honk)]Sad Trombone</a></li>"
					if (cartridge.access & CART_MANIFEST)
						dat += "<li><a href='byond://?src=[REF(src)];choice=41'>[PDAIMG(notes)]View Crew Manifest</a></li>"
					if(cartridge.access & CART_STATUS_DISPLAY)
						dat += "<li><a href='byond://?src=[REF(src)];choice=42'>[PDAIMG(status)]Set Status Display</a></li>"
					dat += "</ul>"
					if (cartridge.access & CART_ENGINE)
						dat += "<h4>Engineering Functions</h4>"
						dat += "<ul>"
						dat += "<li><a href='byond://?src=[REF(src)];choice=43'>[PDAIMG(power)]Power Monitor</a></li>"
						dat += "</ul>"
					if (cartridge.access & CART_MEDICAL)
						dat += "<h4>Medical Functions</h4>"
						dat += "<ul>"
						dat += "<li><a href='byond://?src=[REF(src)];choice=44'>[PDAIMG(medical)]Medical Records</a></li>"
						dat += "<li><a href='byond://?src=[REF(src)];choice=Medical Scan'>[PDAIMG(scanner)][scanmode == 1 ? "Disable" : "Enable"] Medical Scanner</a></li>"
						dat += "</ul>"
					if (cartridge.access & CART_SECURITY)
						dat += "<h4>Security Functions</h4>"
						dat += "<ul>"
						dat += "<li><a href='byond://?src=[REF(src)];choice=45'>[PDAIMG(cuffs)]Security Records</A></li>"
						dat += "</ul>"
					if(cartridge.access & CART_QUARTERMASTER)
						dat += "<h4>Quartermaster Functions:</h4>"
						dat += "<ul>"
						dat += "<li><a href='byond://?src=[REF(src)];choice=47'>[PDAIMG(crate)]Supply Records</A></li>"
						dat += "<li><a href='byond://?src=[REF(src)];choice=48'>[PDAIMG(crate)]Ore Silo Logs</a></li>"
						dat += "</ul>"
				dat += "</ul>"

				dat += "<h4>Utilities</h4>"
				dat += "<ul>"
				if (cartridge)
					if(cartridge.bot_access_flags)
						dat += "<li><a href='byond://?src=[REF(src)];choice=54'>[PDAIMG(medbot)]Bots Access</a></li>"
					if (cartridge.access & CART_JANITOR)
						dat += "<li><a href='byond://?src=[REF(src)];choice=49'>[PDAIMG(bucket)]Custodial Locator</a></li>"
					//if (istype(cartridge.radio))
					//	dat += "<li><a href='byond://?src=[REF(src)];choice=40'>[PDAIMG(signaler)]Signaler System</a></li>"
					if (cartridge.access & CART_NEWSCASTER)
						dat += "<li><a href='byond://?src=[REF(src)];choice=53'>[PDAIMG(notes)]Newscaster Access </a></li>"
					if (cartridge.access & CART_REAGENT_SCANNER)
						dat += "<li><a href='byond://?src=[REF(src)];choice=Reagent Scan'>[PDAIMG(reagent)][scanmode == 3 ? "Disable" : "Enable"] Reagent Scanner</a></li>"
					if (cartridge.access & CART_ENGINE)
						dat += "<li><a href='byond://?src=[REF(src)];choice=Halogen Counter'>[PDAIMG(reagent)][scanmode == 4 ? "Disable" : "Enable"] Halogen Counter</a></li>"
					if (cartridge.access & CART_ATMOS)
						dat += "<li><a href='byond://?src=[REF(src)];choice=Gas Scan'>[PDAIMG(reagent)][scanmode == 5 ? "Disable" : "Enable"] Gas Scanner</a></li>"
					if (cartridge.access & CART_REMOTE_DOOR)
						dat += "<li><a href='byond://?src=[REF(src)];choice=Toggle Door'>[PDAIMG(rdoor)]Toggle Remote Door</a></li>"
					if (cartridge.access & CART_DRONEPHONE)
						dat += "<li><a href='byond://?src=[REF(src)];choice=Drone Phone'>[PDAIMG(dronephone)]Drone Phone</a></li>"
				
				dat += "<li><a href='byond://?src=[REF(src)];choice=3'>[PDAIMG(atmos)]Atmospheric Scan</a></li>"
				dat += "<li><a href='byond://?src=[REF(src)];choice=Light'>[PDAIMG(flashlight)][fon ? "Disable" : "Enable"] Flashlight</a></li>"
				if (pai)
					if(pai.loc != src)
						pai = null
						update_icon()
					else
						dat += "<li><a href='byond://?src=[REF(src)];choice=pai;option=1'>pAI Device Configuration</a></li>"
						dat += "<li><a href='byond://?src=[REF(src)];choice=pai;option=2'>Eject pAI Device</a></li>"
				dat += "</ul>"

			if (1)
				dat += "<h4>[PDAIMG(notes)] Notekeeper V2.2</h4>"
				dat += "<a href='byond://?src=[REF(src)];choice=Edit'>Edit</a><br>"
				if(notescanned)
					dat += "(This is a scanned image, editing it may cause some text formatting to change.)<br>"
				dat += "<HR><font face=\"[PEN_FONT]\">[(!notehtml ? note : notehtml)]</font>"

			if (2)
				dat += "<h4>[PDAIMG(mail)] SpaceMessenger V3.9.6</h4>"
				dat += "<a href='byond://?src=[REF(src)];choice=Toggle Ringer'>[PDAIMG(bell)]Ringer: [silent == 1 ? "Off" : "On"]</a> | "
				dat += "<a href='byond://?src=[REF(src)];choice=Toggle Messenger'>[PDAIMG(mail)]Send / Receive: [toff == 1 ? "Off" : "On"]</a> | "
				dat += "<a href='byond://?src=[REF(src)];choice=Ringtone'>[PDAIMG(bell)]Set Ringtone</a> | "
				dat += "<a href='byond://?src=[REF(src)];choice=21'>[PDAIMG(mail)]Messages</a><br>"

				if(cartridge)
					dat += cartridge.message_header()

				dat += "<h4>[PDAIMG(menu)] Detected PDAs</h4>"

				dat += "<ul>"
				var/count = 0

				/*if (!toff)
					for (var/obj/item/pda/P in sortNames(get_viewable_pdas()))
						if (P == src)
							continue
						dat += "<li><a href='byond://?src=[REF(src)];choice=Message;target=[REF(P)]'>[P]</a>"
						if(cartridge)
							dat += cartridge.message_special(P)
						dat += "</li>"
						count++*/
				dat += "</ul>"
				if (count == 0)
					dat += "None detected.<br>"
				//else if(cartridge && cartridge.spam_enabled)
				//	dat += "<a href='byond://?src=[REF(src)];choice=MessageAll'>Send To All</a>"

			if(21)
				dat += "<h4>[PDAIMG(mail)] SpaceMessenger V3.9.6</h4>"
				dat += "<a href='byond://?src=[REF(src)];choice=Clear'>[PDAIMG(blank)]Clear Messages</a>"

				dat += "<h4>[PDAIMG(mail)] Messages</h4>"

				dat += tnote
				dat += "<br>"

			if (3)
				dat += "<h4>[PDAIMG(atmos)] Atmospheric Readings</h4>"

				var/turf/T = user.loc
				if (isnull(T))
					dat += "Unable to obtain a reading.<br>"
				else
					var/datum/gas_mixture/environment = T.return_air()
					var/list/env_gases = environment.gases

					var/pressure = environment.return_pressure()
					var/total_moles = environment.total_moles()

					dat += "Air Pressure: [round(pressure,0.1)] kPa<br>"

					if (total_moles)
						for(var/id in env_gases)
							var/gas_level = env_gases[id][MOLES]/total_moles
							if(gas_level > 0)
								dat += "[env_gases[id][GAS_META][META_GAS_NAME]]: [round(gas_level*100, 0.01)]%<br>"

					dat += "Temperature: [round(environment.temperature-T0C)]&deg;C<br>"
				dat += "<br>"
			else
				dat += cartridge.generate_menu()

	dat += "</body></html>"

	if (underline_flag)
		dat = replacetext(dat, "text-decoration:none", "text-decoration:underline")
	if (!underline_flag)
		dat = replacetext(dat, "text-decoration:underline", "text-decoration:none")

	user << browse(dat, "window=pda;size=400x450;border=1;can_resize=1;can_minimize=0")
	//onclose(user, "pda", src)

/obj/item/pda/Topic(href, href_list)
	..()
	var/mob/living/U = usr

	if(usr.canUseTopic(src) && !href_list["close"])
		add_fingerprint(U)
		U.set_machine(src)

		switch(href_list["choice"])
			if("Refresh")

			if ("Toggle_Font")
				font_index = (font_index + 1) % 4

				switch(font_index)
					if (MODE_MONO)
						font_mode = FONT_MONO
					if (MODE_SHARE)
						font_mode = FONT_SHARE
					if (MODE_ORBITRON)
						font_mode = FONT_ORBITRON
					if (MODE_VT)
						font_mode = FONT_VT
			if ("Change_Color")
				var/new_color = input("Please enter a color name or hex value (Default is \'#808000\').",background_color)as color
				background_color = new_color

			if ("Toggle_Underline")
				underline_flag = !underline_flag

			if("Return")
				if(mode<=9)
					mode = 0
				else
					mode = round(mode/10)
					if(mode==4 || mode == 5)
						mode = 0
			if ("Authenticate")
				id_check(U)
			if("UpdateInfo")
				ownjob = id.assignment
				if(istype(id, /obj/item/card/id/syndicate))
					owner = id.registered_name
				update_label()
			if("Eject")
				if (!isnull(cartridge))
					U.put_in_hands(cartridge)
					to_chat(U, "<span class='notice'>You remove [cartridge] from [src].</span>")
					scanmode = PDA_SCANNER_NONE
					cartridge.host_pda = null
					cartridge = null
					update_icon()

			if("0")
				mode = 0
			if("1")
				mode = 1
			if("2")
				mode = 2
			if("21")
				mode = 21
			if("3")
				mode = 3
			if("4")
				mode = 0

			if("Light")
				toggle_light()
			if("Medical Scan")
				if(scanmode == PDA_SCANNER_MEDICAL)
					scanmode = PDA_SCANNER_NONE
				else if((!isnull(cartridge)) && (cartridge.access & CART_MEDICAL))
					scanmode = PDA_SCANNER_MEDICAL
			if("Reagent Scan")
				if(scanmode == PDA_SCANNER_REAGENT)
					scanmode = PDA_SCANNER_NONE
				else if((!isnull(cartridge)) && (cartridge.access & CART_REAGENT_SCANNER))
					scanmode = PDA_SCANNER_REAGENT
			if("Halogen Counter")
				if(scanmode == PDA_SCANNER_HALOGEN)
					scanmode = PDA_SCANNER_NONE
				else if((!isnull(cartridge)) && (cartridge.access & CART_ENGINE))
					scanmode = PDA_SCANNER_HALOGEN
			if("Honk")
				if ( !(last_noise && world.time < last_noise + 20) )
					playsound(src, 'sound/items/bikehorn.ogg', 50, 1)
					last_noise = world.time
			if("Trombone")
				if ( !(last_noise && world.time < last_noise + 20) )
					//playsound(src, 'sound/misc/sadtrombone.ogg', 50, 1)
					last_noise = world.time
			if("Gas Scan")
				if(scanmode == PDA_SCANNER_GAS)
					scanmode = PDA_SCANNER_NONE
				else if((!isnull(cartridge)) && (cartridge.access & CART_ATMOS))
					scanmode = PDA_SCANNER_GAS
			if("Drone Phone")
				var/alert_s = input(U,"Alert severity level","Ping Drones",null) as null|anything in list("Low","Medium","High","Critical")
				var/area/A = get_area(U)
				//if(A && alert_s && !QDELETED(U))
				//	var/msg = "<span class='boldnotice'>NON-DRONE PING: [U.name]: [alert_s] priority alert in [A.name]!</span>"
				//	_alert_drones(msg, TRUE, U)
				//	to_chat(U, msg)

			if ("Edit")
				var/n = stripped_multiline_input(U, "Please enter message", name, note)
				if (in_range(src, U) && loc == U)
					if (mode == 1 && n)
						note = n
						//notehtml = parsemarkdown(n, U)
						notescanned = FALSE
				else
					U << browse(null, "window=pda")
					return

			if("Toggle Messenger")
				toff = !toff
			if("Toggle Ringer")
				silent = !silent
			if("Clear")
				tnote = null
			if("Ringtone")
				var/t = input(U, "Please enter new ringtone", name, ttone) as text
				if(in_range(src, U) && loc == U && t)
					if(SEND_SIGNAL(src, COMSIG_PDA_CHANGE_RINGTONE, U, t) & COMPONENT_STOP_RINGTONE_CHANGE)
						U << browse(null, "window=pda")
						return
					else
						ttone = copytext(sanitize(t), 1, 20)
				else
					U << browse(null, "window=pda")
					return
			if("Message")
				//create_message(U, locate(href_list["target"]) in GLOB.PDAs)

			if("MessageAll")
				//send_to_all(U)

			if("cart")
				if(cartridge)
					//cartridge.special(U, href_list)
				else
					U << browse(null, "window=pda")
					return

			//if("Toggle Door")
			//	if(cartridge && cartridge.access & CART_REMOTE_DOOR)
			//		for(var/obj/machinery/door/poddoor/M in GLOB.machines)
			//			if(M.id == cartridge.remote_door_id)
			//				if(M.density)
			//					M.open()
			//				else
			//					M.close()

			if("pai")
				switch(href_list["option"])
					if("1")
						pai.attack_self(U)
					if("2")
						var/turf/T = get_turf(loc)
						if(T)
							pai.forceMove(T)

			else
				mode = max(text2num(href_list["choice"]), 0)

	else
		U.unset_machine()
		U << browse(null, "window=pda")
		return

	if (mode == 2 || mode == 21)
		update_icon()

	if ((honkamt > 0) && (prob(60)))
		honkamt--
		playsound(src, 'sound/items/bikehorn.ogg', 30, 1)

	if(U.machine == src && href_list["skiprefresh"]!="1")
		attack_self(U)
	else
		U.unset_machine()
		U << browse(null, "window=pda")
	return

/obj/item/pda/proc/remove_id()

	if(issilicon(usr) || !usr.canUseTopic(src, BE_CLOSE))
		return

	if (id)
		usr.put_in_hands(id)
		to_chat(usr, "<span class='notice'>You remove the ID from the [name].</span>")
		id = null
		update_icon()
		//if(ishuman(loc))
		//	var/mob/living/carbon/human/H = loc
		//	if(H.wear_id == src)
		//		H.sec_hud_set_ID()

/obj/item/pda/AltClick()
	..()

	if(id)
		remove_id()
	else
		remove_pen()

/obj/item/pda/CtrlClick()
	..()

	if(isturf(loc))
		return

	remove_pen()

/obj/item/pda/proc/toggle_light()
	if(issilicon(usr) || !usr.canUseTopic(src, BE_CLOSE))
		return
	if(fon)
		fon = FALSE
		set_light(0)
	else if(f_lum)
		fon = TRUE
		set_light(f_lum)
	update_icon()

/obj/item/pda/proc/remove_pen()

	if(issilicon(usr) || !usr.canUseTopic(src, BE_CLOSE))
		return

	if(inserted_item)
		usr.put_in_hands(inserted_item)
		to_chat(usr, "<span class='notice'>You remove [inserted_item] from [src].</span>")
		inserted_item = null
		update_icon()
	else
		to_chat(usr, "<span class='warning'>This PDA does not have a pen in it!</span>")

/obj/item/pda/proc/id_check(mob/user, obj/item/card/id/I)
	if(!I)
		if(id && (src in user.contents))
			remove_id()
			return TRUE
		else
			var/obj/item/card/id/C = user.get_active_held_item()
			if(istype(C))
				I = C

	if(I && I.registered_name)
		if(!user.transferItemToLoc(I, src))
			return FALSE
		var/obj/old_id = id
		id = I
		//if(ishuman(loc))
		//	var/mob/living/carbon/human/H = loc
		//	if(H.wear_id == src)
		//		H.sec_hud_set_ID()
		if(old_id)
			user.put_in_hands(old_id)
		update_icon()
	return TRUE

/obj/item/pda/attackby(obj/item/C, mob/user, params)
	if(istype(C, /obj/item/cartridge) && !cartridge)
		if(!user.transferItemToLoc(C, src))
			return
		cartridge = C
		cartridge.host_pda = src
		to_chat(user, "<span class='notice'>You insert [cartridge] into [src].</span>")
		update_icon()

	else if(istype(C, /obj/item/card/id))
		var/obj/item/card/id/idcard = C
		if(!idcard.registered_name)
			to_chat(user, "<span class='warning'>\The [src] rejects the ID!</span>")
			return
		if(!owner)
			owner = idcard.registered_name
			ownjob = idcard.assignment
			update_label()
			to_chat(user, "<span class='notice'>Card scanned.</span>")
		else
			//if(((src in user.contents) || (isturf(loc) && in_range(src, user))) && (C in user.contents))
			if(((src in user.contents) || (isturf(loc) && TRUE)) && (C in user.contents))//not_actual
				if(!id_check(user, idcard))
					return
				to_chat(user, "<span class='notice'>You put the ID into \the [src]'s slot.</span>")
				updateSelfDialog()
			return
		updateSelfDialog()
	else if(istype(C, /obj/item/paicard) && !pai)
		if(!user.transferItemToLoc(C, src))
			return
		pai = C
		to_chat(user, "<span class='notice'>You slot \the [C] into [src].</span>")
		update_icon()
		updateUsrDialog()
	//else if(is_type_in_list(C, contained_item))
	//	if(inserted_item)
	//		to_chat(user, "<span class='warning'>There is already \a [inserted_item] in \the [src]!</span>")
	//	else
	//		if(!user.transferItemToLoc(C, src))
	//			return
	//		to_chat(user, "<span class='notice'>You slide \the [C] into \the [src].</span>")
	//		inserted_item = C
	//		update_icon()
	//else if(istype(C, /obj/item/photo))
	//	var/obj/item/photo/P = C
	//	picture = P.picture
	//	to_chat(user, "<span class='notice'>You scan \the [C].</span>")
	else
		return ..()

#undef PDA_SCANNER_NONE
#undef PDA_SCANNER_MEDICAL
#undef PDA_SCANNER_FORENSICS
#undef PDA_SCANNER_REAGENT
#undef PDA_SCANNER_HALOGEN
#undef PDA_SCANNER_GAS
#undef PDA_SPAM_DELAY