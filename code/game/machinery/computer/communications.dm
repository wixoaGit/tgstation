//not_actual these should be constants, not defines
#define STATE_DEFAULT 1
#define STATE_CALLSHUTTLE 2
#define STATE_CANCELSHUTTLE 3
#define STATE_MESSAGELIST 4
#define STATE_VIEWMESSAGE 5
#define STATE_DELMESSAGE 6
#define STATE_STATUSDISPLAY 7
#define STATE_ALERT_LEVEL 8
#define STATE_CONFIRM_LEVEL 9
#define STATE_TOGGLE_EMERGENCY 10
#define STATE_PURCHASE 11

/obj/machinery/computer/communications
	name = "communications console"
	desc = "A console used for high-priority announcements and emergencies."
	icon_screen = "comm"
	icon_keyboard = "tech_key"
	req_access = list(ACCESS_HEADS)
	var/authenticated = 0
	var/auth_id = "Unknown"
	var/state = STATE_DEFAULT
	var/tmp_alertlevel = 0
	//var/const/STATE_DEFAULT = 1
	//var/const/STATE_CALLSHUTTLE = 2
	//var/const/STATE_CANCELSHUTTLE = 3
	//var/const/STATE_MESSAGELIST = 4
	//var/const/STATE_VIEWMESSAGE = 5
	//var/const/STATE_DELMESSAGE = 6
	//var/const/STATE_STATUSDISPLAY = 7
	//var/const/STATE_ALERT_LEVEL = 8
	//var/const/STATE_CONFIRM_LEVEL = 9
	//var/const/STATE_TOGGLE_EMERGENCY = 10
	//var/const/STATE_PURCHASE = 11

/obj/machinery/computer/communications/Initialize()
	. = ..()
	//GLOB.shuttle_caller_list += src

/obj/machinery/computer/communications/Topic(href, href_list)
	if(..())
		return
	if(!usr.canUseTopic(src))
		return
	if(!is_station_level(z) && !is_reserved_level(z))
		to_chat(usr, "<span class='boldannounce'>Unable to establish a connection</span>: \black You're too far away from the station!")
		return
	usr.set_machine(src)

	if(!href_list["operation"])
		return
	switch(href_list["operation"])
		if("main")
			state = STATE_DEFAULT
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		if("login")
			var/mob/M = usr

			var/obj/item/card/id/I = M.get_idcard(TRUE)

			if(I && istype(I))
				if(check_access(I))
					authenticated = 1
					auth_id = "[I.registered_name] ([I.assignment])"
					if((20 in I.access))
						authenticated = 2
					playsound(src, 'sound/machines/terminal_on.ogg', 50, 0)
				if(obj_flags & EMAGGED)
					authenticated = 2
					auth_id = "Unknown"
					to_chat(M, "<span class='warning'>[src] lets out a quiet alarm as its login is overridden.</span>")
					playsound(src, 'sound/machines/terminal_on.ogg', 50, 0)
					playsound(src, 'sound/machines/terminal_alert.ogg', 25, 0)
					//if(prob(25))
					//	for(var/mob/living/silicon/ai/AI in active_ais())
					//		SEND_SOUND(AI, sound('sound/machines/terminal_alert.ogg', volume = 10))
		if("logout")
			authenticated = 0
			playsound(src, 'sound/machines/terminal_off.ogg', 50, 0)
		
		if("swipeidseclevel")
			var/mob/M = usr
			var/obj/item/card/id/I = M.get_active_held_item()
			if (istype(I, /obj/item/pda))
				var/obj/item/pda/pda = I
				I = pda.id
			if (I && istype(I))
				if(ACCESS_CAPTAIN in I.access)
					var/old_level = GLOB.security_level
					if(!tmp_alertlevel)
						tmp_alertlevel = SEC_LEVEL_GREEN
					if(tmp_alertlevel < SEC_LEVEL_GREEN)
						tmp_alertlevel = SEC_LEVEL_GREEN
					if(tmp_alertlevel > SEC_LEVEL_BLUE)
						tmp_alertlevel = SEC_LEVEL_BLUE
					set_security_level(tmp_alertlevel)
					if(GLOB.security_level != old_level)
						to_chat(usr, "<span class='notice'>Authorization confirmed. Modifying security level.</span>")
						playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)

						var/security_level = get_security_level()
						//log_game("[key_name(usr)] has changed the security level to [security_level] with [src] at [AREACOORD(usr)].")
						//message_admins("[ADMIN_LOOKUPFLW(usr)] has changed the security level to [security_level] with [src] at [AREACOORD(usr)].")
						//deadchat_broadcast("<span class='deadsay'><span class='name'>[usr.real_name]</span> has changed the security level to [security_level] with [src] at <span class='name'>[get_area_name(usr, TRUE)]</span>.</span>", usr)
					tmp_alertlevel = 0
				else
					to_chat(usr, "<span class='warning'>You are not authorized to do this!</span>")
					playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
					tmp_alertlevel = 0
				state = STATE_DEFAULT
			else
				to_chat(usr, "<span class='warning'>You need to swipe your ID!</span>")
				playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		
		if("announce")
			if(authenticated==2)
				playsound(src, 'sound/machines/terminal_prompt.ogg', 50, 0)
				make_announcement(usr)
		
		if("callshuttle")
			state = STATE_DEFAULT
			if(authenticated)
				state = STATE_CALLSHUTTLE
		if("callshuttle2")
			if(authenticated)
				SSshuttle.requestEvac(usr, href_list["call"])
				if(SSshuttle.emergency.timer)
					post_status("shuttle")
			state = STATE_DEFAULT
		if("securitylevel")
			tmp_alertlevel = text2num( href_list["newalertlevel"] )
			if(!tmp_alertlevel)
				tmp_alertlevel = 0
			state = STATE_CONFIRM_LEVEL
		if("changeseclevel")
			state = STATE_ALERT_LEVEL
	
	updateUsrDialog()

/obj/machinery/computer/communications/ui_interact(mob/user)
	. = ..()
	if (z > 6)
		to_chat(user, "<span class='boldannounce'>Unable to establish a connection</span>: \black You're too far away from the station!")
		return

	var/dat = ""
	if(SSshuttle.emergency.mode == SHUTTLE_CALL)
		var/timeleft = SSshuttle.emergency.timeLeft()
		dat += "<B>Emergency shuttle</B>\n<BR>\nETA: [timeleft / 60 % 60]:[add_zero(num2text(timeleft % 60), 2)]"


	var/datum/browser/popup = new(user, "communications", "Communications Console", 400, 500)
	//popup.set_title_image(user.browse_rsc_icon(icon, icon_state))

	//if(issilicon(user))
	//	var/dat2 = interact_ai(user)
	//	if(dat2)
	//		dat +=  dat2
	//		popup.set_content(dat)
	//		popup.open()
	//	return

	switch(state)
		if(STATE_DEFAULT)
			if (authenticated)
				if(SSshuttle.emergencyCallAmount)
					if(SSshuttle.emergencyLastCallLoc)
						dat += "Most recent shuttle call/recall traced to: <b>[format_text(SSshuttle.emergencyLastCallLoc.name)]</b><BR>"
					else
						dat += "Unable to trace most recent shuttle call/recall signal.<BR>"
				dat += "Logged in as: [auth_id]"
				dat += "<BR>"
				dat += "<BR>\[ <A HREF='?src=[REF(src)];operation=logout'>Log Out</A> \]<BR>"
				dat += "<BR><B>General Functions</B>"
				dat += "<BR>\[ <A HREF='?src=[REF(src)];operation=messagelist'>Message List</A> \]"
				switch(SSshuttle.emergency.mode)
					if(SHUTTLE_IDLE, SHUTTLE_RECALL)
						dat += "<BR>\[ <A HREF='?src=[REF(src)];operation=callshuttle'>Call Emergency Shuttle</A> \]"
					else
						dat += "<BR>\[ <A HREF='?src=[REF(src)];operation=cancelshuttle'>Cancel Shuttle Call</A> \]"

				dat += "<BR>\[ <A HREF='?src=[REF(src)];operation=status'>Set Status Display</A> \]"
				if (authenticated==2)
					dat += "<BR><BR><B>Captain Functions</B>"
					dat += "<BR>\[ <A HREF='?src=[REF(src)];operation=announce'>Make a Captain's Announcement</A> \]"
					//var/cross_servers_count = length(CONFIG_GET(keyed_list/cross_server))
					//if(cross_servers_count)
					//	dat += "<BR>\[ <A HREF='?src=[REF(src)];operation=crossserver'>Send a message to [cross_servers_count == 1 ? "an " : ""]allied station[cross_servers_count > 1 ? "s" : ""]</A> \]"
					//if(SSmapping.config.allow_custom_shuttles)
					//	dat += "<BR>\[ <A HREF='?src=[REF(src)];operation=purchase_menu'>Purchase Shuttle</A> \]"
					dat += "<BR>\[ <A HREF='?src=[REF(src)];operation=changeseclevel'>Change Alert Level</A> \]"
					dat += "<BR>\[ <A HREF='?src=[REF(src)];operation=emergencyaccess'>Emergency Maintenance Access</A> \]"
					dat += "<BR>\[ <A HREF='?src=[REF(src)];operation=nukerequest'>Request Nuclear Authentication Codes</A> \]"
					if(!(obj_flags & EMAGGED))
						dat += "<BR>\[ <A HREF='?src=[REF(src)];operation=MessageCentCom'>Send Message to CentCom</A> \]"
					else
						dat += "<BR>\[ <A HREF='?src=[REF(src)];operation=MessageSyndicate'>Send Message to \[UNKNOWN\]</A> \]"
						dat += "<BR>\[ <A HREF='?src=[REF(src)];operation=RestoreBackup'>Restore Backup Routing Data</A> \]"
			else
				dat += "<BR>\[ <A HREF='?src=[REF(src)];operation=login'>Log In</A> \]"
		if(STATE_CALLSHUTTLE)
			dat += get_call_shuttle_form()
			playsound(src, 'sound/machines/terminal_prompt.ogg', 50, 0)
		if(STATE_ALERT_LEVEL)
			dat += "Current alert level: [get_security_level()]<BR>"
			if(GLOB.security_level == SEC_LEVEL_DELTA)
				dat += "<font color='red'><b>The self-destruct mechanism is active. Find a way to deactivate the mechanism to lower the alert level or evacuate.</b></font>"
			else
				dat += "<A HREF='?src=[REF(src)];operation=securitylevel;newalertlevel=[SEC_LEVEL_BLUE]'>Blue</A><BR>"
				dat += "<A HREF='?src=[REF(src)];operation=securitylevel;newalertlevel=[SEC_LEVEL_GREEN]'>Green</A>"
		if(STATE_CONFIRM_LEVEL)
			dat += "Current alert level: [get_security_level()]<BR>"
			dat += "Confirm the change to: [num2seclevel(tmp_alertlevel)]<BR>"
			dat += "<A HREF='?src=[REF(src)];operation=swipeidseclevel'>Swipe ID</A> to confirm change.<BR>"

	popup.set_content(dat)
	popup.open()
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/communications/proc/get_javascript_header(form_id)
	var/dat = {"<script type="text/javascript">
						function getLength(){
							var reasonField = document.getElementById('reasonfield');
							if(reasonField.value.length >= [CALL_SHUTTLE_REASON_LENGTH]){
								reasonField.style.backgroundColor = "#DDFFDD";
							}
							else {
								reasonField.style.backgroundColor = "#FFDDDD";
							}
						}
						function submit() {
							document.getElementById('[form_id]').submit();
						}
					</script>"}
	return dat

/obj/machinery/computer/communications/proc/get_call_shuttle_form(ai_interface = 0)
	var/form_id = "callshuttle"
	var/dat = get_javascript_header(form_id)
	dat += "<form name='callshuttle' id='[form_id]' action='?src=[REF(src)]' method='get' style='display: inline'>"
	dat += "<input type='hidden' name='src' value='[REF(src)]'>"
	dat += "<input type='hidden' name='operation' value='[ai_interface ? "ai-callshuttle2" : "callshuttle2"]'>"
	dat += "<b>Nature of emergency:</b><BR> <input type='text' id='reasonfield' name='call' style='width:250px; background-color:#FFDDDD; onkeydown='getLength() onkeyup='getLength()' onkeypress='getLength()'>"
	dat += "<BR>Are you sure you want to call the shuttle? \[ <a href='#' onclick='submit()'>Call</a> \]"
	return dat

/obj/machinery/computer/communications/proc/make_announcement(mob/living/user, is_silicon)
	if(!SScommunications.can_announce(user, is_silicon))
		to_chat(user, "Intercomms recharging. Please stand by.")
		return
	var/input = stripped_input(user, "Please choose a message to announce to the station crew.", "What?")
	if(!input || !user.canUseTopic(src))
		return
	SScommunications.make_announcement(user, is_silicon, input)
	deadchat_broadcast("<span class='deadsay'><span class='name'>[user.real_name]</span> made a priority announcement from <span class='name'>[get_area_name(usr, TRUE)]</span>.</span>", user)

/obj/machinery/computer/communications/proc/post_status(command, data1, data2)

	//var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)

	//if(!frequency)
	//	return

	//var/datum/signal/status_signal = new(list("command" = command))
	//switch(command)
	//	if("message")
	//		status_signal.data["msg1"] = data1
	//		status_signal.data["msg2"] = data2
	//	if("alert")
	//		status_signal.data["picture_state"] = data1

	//frequency.post_signal(src, status_signal)

/obj/machinery/computer/communications/Destroy()
	//GLOB.shuttle_caller_list -= src
	//SSshuttle.autoEvac()
	return ..()