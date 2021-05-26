/mob/var/suiciding = 0

/mob/proc/set_suicide(suicide_state)
	suiciding = suicide_state
	//if(suicide_state)
	//	GLOB.suicided_mob_list += src
	//else
	//	GLOB.suicided_mob_list -= src

/mob/living/carbon/set_suicide(suicide_state)
	. = ..()
	//var/obj/item/organ/brain/B = getorganslot(ORGAN_SLOT_BRAIN)
	//if(B)
	//	B.suicided = suicide_state

/mob/living/carbon/human/verb/suicide()
	//set hidden = 1
	//if(!canSuicide())
	//	return
	var/oldkey = ckey
	//var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")
	var/confirm = "Yes"//not_actual
	if(ckey != oldkey)
		return
	//if(!canSuicide())
	//	return
	if(confirm == "Yes")
		set_suicide(TRUE)
		var/obj/item/held_item = get_active_held_item()
		if(held_item)
			var/damagetype = held_item.suicide_act(src)
			if(damagetype)
				if(damagetype & SHAME)
					adjustStaminaLoss(200)
					set_suicide(FALSE)
					//SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "shameful_suicide", /datum/mood_event/shameful_suicide)
					return

				//suicide_log()

				var/damage_mod = 0
				for(var/T in list(BRUTELOSS, FIRELOSS, TOXLOSS, OXYLOSS))
					damage_mod += (T & damagetype) ? 1 : 0
				damage_mod = max(1, damage_mod)

				if(damagetype & BRUTELOSS)
					adjustBruteLoss(200/damage_mod)

				if(damagetype & FIRELOSS)
					adjustFireLoss(200/damage_mod)

				if(damagetype & TOXLOSS)
					adjustToxLoss(200/damage_mod)

				if(damagetype & OXYLOSS)
					adjustOxyLoss(200/damage_mod)

				if(damagetype & MANUAL_SUICIDE)
					return

				//if(!(damagetype & (BRUTELOSS | FIRELOSS | TOXLOSS | OXYLOSS) ))
				//	adjustOxyLoss(max(200 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))

				death(FALSE)

				return

		var/suicide_message

		if(a_intent == INTENT_DISARM)
			suicide_message = pick("[src] is attempting to push [p_their()] own head off [p_their()] shoulders! It looks like [p_theyre()] trying to commit suicide.", \
								"[src] is pushing [p_their()] thumbs into [p_their()] eye sockets! It looks like [p_theyre()] trying to commit suicide.", \
								"[src] is ripping [p_their()] own arms off! It looks like [p_theyre()] trying to commit suicide.")
		if(a_intent == INTENT_GRAB)
			suicide_message = pick("[src] is attempting to pull [p_their()] own head off! It looks like [p_theyre()] trying to commit suicide.", \
									"[src] is aggressively grabbing [p_their()] own neck! It looks like [p_theyre()] trying to commit suicide.", \
									"[src] is pulling [p_their()] eyes out of their sockets! It looks like [p_theyre()] trying to commit suicide.")
		if(a_intent == INTENT_HELP)
			suicide_message = pick("[src] is hugging [p_them()]self to death! It looks like [p_theyre()] trying to commit suicide.", \
									"[src] is high-fiving [p_them()]self to death! It looks like [p_theyre()] trying to commit suicide.", \
									"[src] is getting too high on life! It looks like [p_theyre()] trying to commit suicide.")
		else
			suicide_message = pick("[src] is attempting to bite [p_their()] tongue off! It looks like [p_theyre()] trying to commit suicide.", \
								"[src] is jamming [p_their()] thumbs into [p_their()] eye sockets! It looks like [p_theyre()] trying to commit suicide.", \
								"[src] is twisting [p_their()] own neck! It looks like [p_theyre()] trying to commit suicide.", \
								"[src] is holding [p_their()] breath! It looks like [p_theyre()] trying to commit suicide.")

		visible_message("<span class='danger'>[suicide_message]</span>", "<span class='userdanger'>[suicide_message]</span>")

		//suicide_log()

		adjustOxyLoss(max(200 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
		death(FALSE)