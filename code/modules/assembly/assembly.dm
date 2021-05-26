#define WIRE_RECEIVE		(1<<0)
#define WIRE_PULSE			(1<<1)
#define WIRE_PULSE_SPECIAL	(1<<2)
#define WIRE_RADIO_RECEIVE	(1<<3)
#define WIRE_RADIO_PULSE	(1<<4)
#define ASSEMBLY_BEEP_VOLUME 5

/obj/item/assembly
	name = "assembly"
	desc = "A small electronic device that should never exist."
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = ""
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=100)
	throwforce = 2
	throw_speed = 3
	throw_range = 7

	var/is_position_sensitive = FALSE
	var/secured = TRUE
	var/list/attached_overlays = null
	var/obj/item/assembly_holder/holder = null
	var/wire_type = WIRE_RECEIVE | WIRE_PULSE
	var/attachable = FALSE
	var/datum/wires/connected = null

	var/next_activate = 0

/obj/item/assembly/get_part_rating()
	return 1

/obj/item/assembly/proc/pulsed(radio = FALSE)
	if(wire_type & WIRE_RECEIVE)
		INVOKE_ASYNC(src, .proc/activate)
	if(radio && (wire_type & WIRE_RADIO_RECEIVE))
		INVOKE_ASYNC(src, .proc/activate)
	return TRUE

/obj/item/assembly/proc/activate()
	if(QDELETED(src) || !secured || (next_activate > world.time))
		return FALSE
	next_activate = world.time + 30
	return TRUE

/obj/item/assembly/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>\The [src] [secured? "is secured and ready to be used!" : "can be attached to other things."]</span>")