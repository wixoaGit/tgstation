#define HOLOPAD_PASSIVE_POWER_USAGE 1
#define HOLOGRAM_POWER_USAGE 2

/obj/machinery/holopad
	name = "holopad"
	desc = "It's a floor-mounted device for projecting holographic images."
	icon_state = "holopad0"
	layer = LOW_OBJ_LAYER
	plane = FLOOR_PLANE
	flags_1 = HEAR_1
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 100
	max_integrity = 300
	armor = list("melee" = 50, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 0)
	circuit = /obj/item/circuitboard/machine/holopad
	var/list/masters
	var/list/holorays
	var/last_request = 0
	var/holo_range = 5
	var/temp = ""
	var/list/holo_calls
	//var/datum/holocall/outgoing_call
	//var/obj/item/disk/holodisk/disk
	var/replay_mode = FALSE
	var/loop_mode = FALSE
	var/record_mode = FALSE
	var/record_start = 0
	var/record_user
	//var/obj/effect/overlay/holo_pad_hologram/replay_holo
	//var/static/force_answer_call = FALSE
	//var/static/list/holopads = list()
	//var/obj/effect/overlay/holoray/ray
	var/ringing = FALSE
	var/offset = FALSE
	var/on_network = TRUE

/obj/machinery/holopad/Initialize()
	. = ..()
	//if(on_network)
	//	holopads += src

/obj/machinery/holopad/Destroy()
	//if(outgoing_call)
	//	outgoing_call.ConnectionFailure(src)

	//for(var/I in holo_calls)
	//	var/datum/holocall/HC = I
	//	HC.ConnectionFailure(src)

	//for (var/I in masters)
	//	clear_holo(I)

	///if(replay_mode)
	///	replay_stop()
	///if(record_mode)
	///	record_stop()

	//QDEL_NULL(disk)

	//holopads -= src
	return ..()

/obj/machinery/holopad/power_change()
	if (powered())
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
		//if(replay_mode)
		//	replay_stop()
		//if(record_mode)
		//	record_stop()
		//if(outgoing_call)
		//	outgoing_call.ConnectionFailure(src)

/obj/machinery/holopad/obj_break()
	. = ..()
	//if(outgoing_call)
	//	outgoing_call.ConnectionFailure(src)

/obj/machinery/holopad/RefreshParts()
	var/holograph_range = 4
	for(var/obj/item/stock_parts/capacitor/B in component_parts)
		holograph_range += 1 * B.rating
	holo_range = holograph_range

/obj/machinery/holopad/examine(mob/user)
	..()
	if(in_range(user, src) || isobserver(user))
		to_chat(user, "<span class='notice'>The status display reads: Current projection range: <b>[holo_range]</b> units.<span>")

/obj/machinery/holopad/attackby(obj/item/P, mob/user, params)
	if(default_deconstruction_screwdriver(user, "holopad_open", "holopad0", P))
		return

	if(default_pry_open(P))
		return

	if(default_unfasten_wrench(user, P))
		return

	if(default_deconstruction_crowbar(P))
		return

	//if(istype(P,/obj/item/disk/holodisk))
	//	if(disk)
	//		to_chat(user,"<span class='notice'>There's already a disk inside [src]</span>")
	//		return
	//	if (!user.transferItemToLoc(P,src))
	//		return
	//	to_chat(user,"<span class='notice'>You insert [P] into [src]</span>")
	//	disk = P
	//	updateDialog()
	//	return

	return ..()

/obj/machinery/holopad/ui_interact(mob/living/carbon/human/user)
	. = ..()
	if(!istype(user))
		return

	//if(outgoing_call || user.incapacitated() || !is_operational())
	if(user.incapacitated() || !is_operational())//not_actual
		return

	user.set_machine(src)
	var/dat
	if(temp)
		dat = temp
	else
		if(on_network)
			dat += "<a href='?src=[REF(src)];AIrequest=1'>Request an AI's presence</a><br>"
			dat += "<a href='?src=[REF(src)];Holocall=1'>Call another holopad</a><br>"
		//if(disk)
		//	if(disk.record)
		//		dat += "<a href='?src=[REF(src)];replay_start=1'>Replay disk recording</a><br>"
		//		dat += "<a href='?src=[REF(src)];loop_start=1'>Loop disk recording</a><br>"
		//		dat += "<a href='?src=[REF(src)];record_clear=1'>Clear disk recording</a><br>"
		//	else
		//		dat += "<a href='?src=[REF(src)];record_start=1'>Start new recording</a><br>"
		//	dat += "<a href='?src=[REF(src)];disk_eject=1'>Eject disk</a><br>"

		//if(LAZYLEN(holo_calls))
		//	dat += "=====================================================<br>"

		if(on_network)
			var/one_answered_call = FALSE
			var/one_unanswered_call = FALSE
			//for(var/I in holo_calls)
			//	var/datum/holocall/HC = I
			//	if(HC.connected_holopad != src)
			//		dat += "<a href='?src=[REF(src)];connectcall=[REF(HC)]'>Answer call from [get_area(HC.calling_holopad)]</a><br>"
			//		one_unanswered_call = TRUE
			//	else
			//		one_answered_call = TRUE

			if(one_answered_call && one_unanswered_call)
				dat += "=====================================================<br>"
			//for(var/I in holo_calls)
			//	var/datum/holocall/HC = I
			//	if(HC.connected_holopad == src)
			//		dat += "<a href='?src=[REF(src)];disconnectcall=[REF(HC)]'>Disconnect call from [HC.user]</a><br>"


	var/datum/browser/popup = new(user, "holopad", name, 300, 175)
	popup.set_content(dat)
	//popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/machinery/holopad/update_icon()
	var/total_users = LAZYLEN(masters) + LAZYLEN(holo_calls)
	if(ringing)
		icon_state = "holopad_ringing"
	else if(total_users || replay_mode)
		icon_state = "holopad1"
	else
		icon_state = "holopad0"

#undef HOLOPAD_PASSIVE_POWER_USAGE
#undef HOLOGRAM_POWER_USAGE