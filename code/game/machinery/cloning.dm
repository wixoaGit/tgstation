#define CLONE_INITIAL_DAMAGE     150
#define MINIMUM_HEAL_LEVEL 40

#define SPEAK(message) radio.talk_into(src, message, radio_channel, get_spans(), get_default_language())

/obj/machinery/clonepod
	name = "cloning pod"
	desc = "An electronically-lockable pod for growing organic tissue."
	density = TRUE
	icon = 'icons/obj/machines/cloning.dmi'
	icon_state = "pod_0"
	req_access = list(ACCESS_CLONING)
	verb_say = "states"
	circuit = /obj/item/circuitboard/machine/clonepod

	var/heal_level
	var/obj/machinery/computer/cloning/connected
	var/mess = FALSE
	var/attempting = FALSE
	var/speed_coeff
	var/efficiency

	var/datum/mind/clonemind
	var/grab_ghost_when = CLONER_MATURE_CLONE

	var/internal_radio = TRUE
	var/obj/item/radio/radio
	var/radio_key = /obj/item/encryptionkey/headset_med
	var/radio_channel = RADIO_CHANNEL_MEDICAL

	//var/obj/effect/countdown/clonepod/countdown

	var/list/unattached_flesh
	var/flesh_number = 0
	var/datum/bank_account/current_insurance
	fair_market_price = 5
	payment_department = ACCOUNT_MED
/obj/machinery/clonepod/Initialize()
	. = ..()

	//countdown = new(src)

	if(internal_radio)
		//radio = new(src)
		radio = new /obj/item/radio(src)//not_actual
		radio.keyslot = new radio_key
		radio.subspace_transmission = TRUE
		radio.canhear_range = 0
		radio.recalculateChannels()

/obj/machinery/clonepod/Destroy()
	go_out()
	QDEL_NULL(radio)
	//QDEL_NULL(countdown)
	if(connected)
		connected.DetachCloner(src)
	QDEL_LIST(unattached_flesh)
	. = ..()

/obj/machinery/clonepod/RefreshParts()
	speed_coeff = 0
	efficiency = 0
	for(var/obj/item/stock_parts/scanning_module/S in component_parts)
		efficiency += S.rating
	for(var/obj/item/stock_parts/manipulator/P in component_parts)
		speed_coeff += P.rating
	heal_level = (efficiency * 15) + 10
	if(heal_level < MINIMUM_HEAL_LEVEL)
		heal_level = MINIMUM_HEAL_LEVEL
	if(heal_level > 100)
		heal_level = 100

/obj/machinery/clonepod/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>The <i>linking</i> device can be <i>scanned<i> with a multitool.</span>")
	if(in_range(user, src) || isobserver(user))
		to_chat(user, "<span class='notice'>The status display reads: Cloning speed at <b>[speed_coeff*50]%</b>.<br>Predicted amount of cellular damage: <b>[100-heal_level]%</b>.<span>")
		if(efficiency > 5)
			to_chat(user, "<span class='notice'>Pod has been upgraded to support autoprocessing and apply beneficial mutations.<span>")

/obj/item/disk/data
	name = "cloning data disk"
	icon_state = "datadisk0"
	var/list/fields = list()
	var/list/mutations = list()
	var/max_mutations = 6
	var/read_only = FALSE

/obj/item/disk/data/Initialize()
	. = ..()
	icon_state = "datadisk[rand(0,6)]"
	add_overlay("datadisk_gene")

/obj/item/disk/data/attack_self(mob/user)
	read_only = !read_only
	to_chat(user, "<span class='notice'>You flip the write-protect tab to [read_only ? "protected" : "unprotected"].</span>")

/obj/item/disk/data/examine(mob/user)
	..()
	to_chat(user, "The write-protect tab is set to [read_only ? "protected" : "unprotected"].")

/obj/machinery/clonepod/examine(mob/user)
	..()
	var/mob/living/mob_occupant = occupant
	if(mess)
		to_chat(user, "It's filled with blood and viscera. You swear you can see it moving...")
	if(is_operational() && mob_occupant)
		if(mob_occupant.stat != DEAD)
			to_chat(user, "Current clone cycle is [round(get_completion())]% complete.")

/obj/machinery/clonepod/proc/get_completion()
	. = FALSE
	var/mob/living/mob_occupant = occupant
	if(mob_occupant)
		. = (100 * ((mob_occupant.health + 100) / (heal_level + 100)))

/obj/machinery/clonepod/attack_ai(mob/user)
	return examine(user)

/obj/machinery/clonepod/proc/go_out()
	//countdown.stop()
	var/mob/living/mob_occupant = occupant
	var/turf/T = get_turf(src)

	if(mess)
		//for(var/obj/fl in unattached_flesh)
		//	fl.forceMove(T)
		//unattached_flesh.Cut()
		mess = FALSE
		//new /obj/effect/gibspawner/generic(get_turf(src), mob_occupant)
		audible_message("<span class='italics'>You hear a splat.</span>")
		icon_state = "pod_0"
		return

	if(!mob_occupant)
		return
	current_insurance = null
	//mob_occupant.remove_trait(TRAIT_STABLEHEART, CLONING_POD_TRAIT)
	//mob_occupant.remove_trait(TRAIT_EMOTEMUTE, CLONING_POD_TRAIT)
	//mob_occupant.remove_trait(TRAIT_MUTE, CLONING_POD_TRAIT)
	//mob_occupant.remove_trait(TRAIT_NOCRITDAMAGE, CLONING_POD_TRAIT)
	//mob_occupant.remove_trait(TRAIT_NOBREATH, CLONING_POD_TRAIT)


	if(grab_ghost_when == CLONER_MATURE_CLONE)
		//mob_occupant.grab_ghost()
		to_chat(occupant, "<span class='notice'><b>There is a bright flash!</b><br><i>You feel like a new being.</i></span>")
		//mob_occupant.flash_act()

	mob_occupant.adjustBrainLoss(mob_occupant.getCloneLoss())

	occupant.forceMove(T)
	icon_state = "pod_0"
	//mob_occupant.domutcheck(1)
	for(var/fl in unattached_flesh)
		qdel(fl)
	unattached_flesh.Cut()

	occupant = null

/obj/machinery/clonepod/relaymove(mob/user)
	container_resist(user)

/obj/machinery/clonepod/container_resist(mob/living/user)
	if(user.stat == CONSCIOUS)
		go_out()

/obj/machinery/clonepod/ex_act(severity, target)
	..()
	if(!QDELETED(src))
		go_out()

/obj/machinery/clonepod/handle_atom_del(atom/A)
	if(A == occupant)
		occupant = null
		//countdown.stop()

/obj/machinery/clonepod/deconstruct(disassembled = TRUE)
	if(occupant)
		go_out()
	..()

#undef CLONE_INITIAL_DAMAGE
#undef SPEAK
#undef MINIMUM_HEAL_LEVEL