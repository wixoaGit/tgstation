/mob/living/carbon/human/UnarmedAttack(atom/A, proximity)
	
	if(!has_active_hand())
		to_chat(src, "<span class='notice'>You look at your arm and sigh.</span>")
		return

	//var/obj/item/clothing/gloves/G = gloves
	//if(proximity && istype(G) && G.Touch(A,1))
	//	return

	var/override = 0

	//for(var/datum/mutation/human/HM in dna.mutations)
	//	override += HM.on_attack_hand(A, proximity)

	if(override)
		return

	SEND_SIGNAL(src, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, A)
	A.attack_hand(src)

/atom/proc/attack_hand(mob/user)
	. = FALSE
	if(!(interaction_flags_atom & INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND))
		add_fingerprint(user)
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_HAND, user) & COMPONENT_NO_ATTACK_HAND)
		. = TRUE
	if(interaction_flags_atom & INTERACT_ATOM_ATTACK_HAND)
		. = _try_interact(user)

/atom/proc/_try_interact(mob/user)
	if(IsAdminGhost(user))
		return interact(user)
	if(can_interact(user))
		return interact(user)
	return FALSE

/atom/proc/can_interact(mob/user)
	if(!user.can_interact_with(src))
		return FALSE
	if((interaction_flags_atom & INTERACT_ATOM_REQUIRES_DEXTERITY) && !user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return FALSE
	if(!(interaction_flags_atom & INTERACT_ATOM_IGNORE_INCAPACITATED) && user.incapacitated((interaction_flags_atom & INTERACT_ATOM_IGNORE_RESTRAINED), !(interaction_flags_atom & INTERACT_ATOM_CHECK_GRAB)))
		return FALSE
	return TRUE

/atom/proc/interact(mob/user)
	if(interaction_flags_atom & INTERACT_ATOM_NO_FINGERPRINT_INTERACT)
		add_hiddenprint(user)
	else
		add_fingerprint(user)
	if(interaction_flags_atom & INTERACT_ATOM_UI_INTERACT)
		return ui_interact(user)
	return FALSE

///mob/living/carbon/monkey/UnarmedAttack(atom/A)
//	A.attack_paw(src)

/atom/proc/attack_paw(mob/user)
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_PAW, user) & COMPONENT_NO_ATTACK_HAND)
		return TRUE
	return FALSE

/mob/dead/new_player/ClickOn()
	return