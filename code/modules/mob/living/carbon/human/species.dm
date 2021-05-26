GLOBAL_LIST_EMPTY(roundstart_races)

/datum/species
	var/id
	var/limbs_id
	var/name
	var/default_color = "#FFF"

	var/sexes = 1

	var/hair_color
	var/hair_alpha = 255

	var/use_skintones = 0
	var/list/no_equip = list()
	var/nojumpsuit = 0
	var/list/default_features = list()
	var/damage_overlay_type = "human"

	var/list/species_traits = list()

/datum/species/New()

	if(!limbs_id)
		limbs_id = id
	..()

/proc/generate_selectable_species()
	for(var/I in subtypesof(/datum/species))
		var/datum/species/S = new I
		if(S.check_roundstart_eligible())
			GLOB.roundstart_races += S.id
			qdel(S)
	if(!GLOB.roundstart_races.len)
		GLOB.roundstart_races += "human"

/datum/species/proc/check_roundstart_eligible()
	//if(id in (CONFIG_GET(keyed_list/roundstart_races)))
	//	return TRUE
	return FALSE

/datum/species/proc/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_name(gender)

	var/randname
	if(gender == MALE)
		randname = pick(GLOB.first_names_male)
	else
		randname = pick(GLOB.first_names_female)

	if(lastname)
		randname += " [lastname]"
	else
		randname += " [pick(GLOB.last_names)]"

	return randname

/datum/species/proc/handle_hair(mob/living/carbon/human/H, forced_colour)
	H.remove_overlay(HAIR_LAYER)
	var/obj/item/bodypart/head/HD = H.get_bodypart(BODY_ZONE_HEAD)
	if(!HD)
		return

	if(H.has_trait(TRAIT_HUSK))
		return
	var/datum/sprite_accessory/S
	var/list/standing = list()

	var/hair_hidden = FALSE
	var/facialhair_hidden = FALSE

	var/dynamic_hair_suffix = ""
	var/dynamic_fhair_suffix = ""

	if(HD.status == BODYPART_ROBOTIC)
		return

	if(H.head)
		var/obj/item/I = H.head
		//if(istype(I, /obj/item/clothing))
		//	var/obj/item/clothing/C = I
		//	dynamic_fhair_suffix = C.dynamic_fhair_suffix
		if(I.flags_inv & HIDEFACIALHAIR)
			facialhair_hidden = TRUE

	if(H.wear_mask)
		var/obj/item/clothing/mask/M = H.wear_mask
		//dynamic_fhair_suffix = M.dynamic_fhair_suffix
		if(M.flags_inv & HIDEFACIALHAIR)
			facialhair_hidden = TRUE

	if(H.facial_hair_style && (FACEHAIR in species_traits) && (!facialhair_hidden || dynamic_fhair_suffix))
		S = GLOB.facial_hair_styles_list[H.facial_hair_style]
		if(S)

			//var/static/list/fextensions
			//if(!fextensions)
			//	var/icon/fhair_extensions = icon('icons/mob/facialhair_extensions.dmi')
			//	fextensions = list()
			//	for(var/s in fhair_extensions.IconStates(1))
			//		fextensions[s] = TRUE
			//	qdel(fhair_extensions)

			var/fhair_state = S.icon_state
			var/fhair_file = S.icon
			//if(fextensions[fhair_state+dynamic_fhair_suffix])
			//	fhair_state += dynamic_fhair_suffix
			//	fhair_file = 'icons/mob/facialhair_extensions.dmi'

			var/mutable_appearance/facial_overlay = mutable_appearance(fhair_file, fhair_state, -HAIR_LAYER)

			if(!forced_colour)
				if(hair_color)
					if(hair_color == "mutcolor")
						facial_overlay.color = "#" + H.dna.features["mcolor"]
					else
						facial_overlay.color = "#" + hair_color
				else
					facial_overlay.color = "#" + H.facial_hair_color
			else
				facial_overlay.color = forced_colour

			facial_overlay.alpha = hair_alpha

			standing += facial_overlay

	if(H.head)
		var/obj/item/I = H.head
		//if(istype(I, /obj/item/clothing))
		//	var/obj/item/clothing/C = I
		//	dynamic_hair_suffix = C.dynamic_hair_suffix
		if(I.flags_inv & HIDEHAIR)
			hair_hidden = TRUE

	if(H.wear_mask)
		var/obj/item/clothing/mask/M = H.wear_mask
		//if(!dynamic_hair_suffix)
		//	dynamic_hair_suffix = M.dynamic_hair_suffix
		if(M.flags_inv & HIDEHAIR)
			hair_hidden = TRUE

	if(!hair_hidden || dynamic_hair_suffix)
		var/mutable_appearance/hair_overlay = mutable_appearance(layer = -HAIR_LAYER)
		//if(!hair_hidden && !H.getorgan(/obj/item/organ/brain))
		if(FALSE)//not_actual
			//if(!(NOBLOOD in species_traits))
			//	hair_overlay.icon = 'icons/mob/human_face.dmi'
			//	hair_overlay.icon_state = "debrained"

		else if(H.hair_style && (HAIR in species_traits))
			S = GLOB.hair_styles_list[H.hair_style]
			if(S)

				//var/static/list/extensions
				//if(!extensions)
				//	var/icon/hair_extensions = icon('icons/mob/hair_extensions.dmi')
				//	extensions = list()
				//	for(var/s in hair_extensions.IconStates(1))
				//		extensions[s] = TRUE
				//	qdel(hair_extensions)

				var/hair_state = S.icon_state
				var/hair_file = S.icon
				//if(extensions[hair_state+dynamic_hair_suffix])
				//	hair_state += dynamic_hair_suffix
				//	hair_file = 'icons/mob/hair_extensions.dmi'

				hair_overlay.icon = hair_file
				hair_overlay.icon_state = hair_state

				if(!forced_colour)
					if(hair_color)
						if(hair_color == "mutcolor")
							hair_overlay.color = "#" + H.dna.features["mcolor"]
						else
							hair_overlay.color = "#" + hair_color
					else
						hair_overlay.color = "#" + H.hair_color
				else
					hair_overlay.color = forced_colour
				hair_overlay.alpha = hair_alpha
				//if(OFFSET_FACE in H.dna.species.offset_features)
				//	hair_overlay.pixel_x += H.dna.species.offset_features[OFFSET_FACE][1]
				//	hair_overlay.pixel_y += H.dna.species.offset_features[OFFSET_FACE][2]
		if(hair_overlay.icon)
			standing += hair_overlay

	if(standing.len)
		H.overlays_standing[HAIR_LAYER] = standing

	H.apply_overlay(HAIR_LAYER)

/datum/species/proc/handle_body(mob/living/carbon/human/H)
	H.remove_overlay(BODY_LAYER)

	var/list/standing = list()

	//var/obj/item/bodypart/head/HD = H.get_bodypart(BODY_ZONE_HEAD)

	//if(HD && !(H.has_trait(TRAIT_HUSK)))
	if(!(H.has_trait(TRAIT_HUSK)))//not_actual
		if(H.lip_style && (LIPS in species_traits))
			var/mutable_appearance/lip_overlay = mutable_appearance('icons/mob/human_face.dmi', "lips_[H.lip_style]", -BODY_LAYER)
			lip_overlay.color = H.lip_color
			//if(OFFSET_FACE in H.dna.species.offset_features)
			//	lip_overlay.pixel_x += H.dna.species.offset_features[OFFSET_FACE][1]
			//	lip_overlay.pixel_y += H.dna.species.offset_features[OFFSET_FACE][2]
			standing += lip_overlay

		if(!(NOEYES in species_traits))
			//var/has_eyes = H.getorganslot(ORGAN_SLOT_EYES)
			var/mutable_appearance/eye_overlay
			//if(!has_eyes)
			if(FALSE)//not_actual
				eye_overlay = mutable_appearance('icons/mob/human_face.dmi', "eyes_missing", -BODY_LAYER)
			else
				eye_overlay = mutable_appearance('icons/mob/human_face.dmi', "eyes", -BODY_LAYER)
			//if((EYECOLOR in species_traits) && has_eyes)
			if((EYECOLOR in species_traits))//not_actual
				eye_overlay.color = "#" + H.eye_color
			//if(OFFSET_FACE in H.dna.species.offset_features)
			//	eye_overlay.pixel_x += H.dna.species.offset_features[OFFSET_FACE][1]
			//	eye_overlay.pixel_y += H.dna.species.offset_features[OFFSET_FACE][2]
			standing += eye_overlay

	if(!(NO_UNDERWEAR in species_traits))
		if(H.underwear)
			var/datum/sprite_accessory/underwear/underwear = GLOB.underwear_list[H.underwear]
			if(underwear)
				standing += mutable_appearance(underwear.icon, underwear.icon_state, -BODY_LAYER)

		if(H.undershirt)
			var/datum/sprite_accessory/undershirt/undershirt = GLOB.undershirt_list[H.undershirt]
			if(undershirt)
				//if(H.dna.species.sexes && H.gender == FEMALE)
				if(FALSE)//not_actual
					//standing += wear_female_version(undershirt.icon_state, undershirt.icon, BODY_LAYER)
				else
					standing += mutable_appearance(undershirt.icon, undershirt.icon_state, -BODY_LAYER)

		if(H.socks && H.get_num_legs(FALSE) >= 2 && !(DIGITIGRADE in species_traits))
			var/datum/sprite_accessory/socks/socks = GLOB.socks_list[H.socks]
			if(socks)
				standing += mutable_appearance(socks.icon, socks.icon_state, -BODY_LAYER)

	if(standing.len)
		H.overlays_standing[BODY_LAYER] = standing

	H.apply_overlay(BODY_LAYER)
	//handle_mutant_bodyparts(H)

/datum/species/proc/can_equip(obj/item/I, slot, disable_warning, mob/living/carbon/human/H, bypass_equip_delay_self = FALSE)
	if(slot in no_equip)
		//if(!I.species_exception || !is_type_in_list(src, I.species_exception))
		//	return FALSE
		return FALSE//not_actual

	var/num_arms = H.get_num_arms(FALSE)
	var/num_legs = H.get_num_legs(FALSE)

	switch(slot)
		if(SLOT_HANDS)
			if(H.get_empty_held_indexes())
				return TRUE
			return FALSE
		if(SLOT_WEAR_MASK)
			if(H.wear_mask)
				return FALSE
			if(!(I.slot_flags & ITEM_SLOT_MASK))
				return FALSE
			if(!H.get_bodypart(BODY_ZONE_HEAD))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_NECK)
			if(H.wear_neck)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_NECK) )
				return FALSE
			return TRUE
		if(SLOT_BACK)
			if(H.back)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_BACK) )
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_WEAR_SUIT)
			if(H.wear_suit)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_OCLOTHING) )
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_GLOVES)
			if(H.gloves)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_GLOVES) )
				return FALSE
			if(num_arms < 2)
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_SHOES)
			if(H.shoes)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_FEET) )
				return FALSE
			if(num_legs < 2)
				return FALSE
			if(DIGITIGRADE in species_traits)
				if(!disable_warning)
					to_chat(H, "<span class='warning'>The footwear around here isn't compatible with your feet!</span>")
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_BELT)
			if(H.belt)
				return FALSE

			var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_CHEST)

			if(!H.w_uniform && !nojumpsuit && (!O || O.status != BODYPART_ROBOTIC))
				if(!disable_warning)
					to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [I.name]!</span>")
				return FALSE
			if(!(I.slot_flags & ITEM_SLOT_BELT))
				return
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_GLASSES)
			if(H.glasses)
				return FALSE
			if(!(I.slot_flags & ITEM_SLOT_EYES))
				return FALSE
			if(!H.get_bodypart(BODY_ZONE_HEAD))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_HEAD)
			if(H.head)
				return FALSE
			if(!(I.slot_flags & ITEM_SLOT_HEAD))
				return FALSE
			if(!H.get_bodypart(BODY_ZONE_HEAD))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_EARS)
			if(H.ears)
				return FALSE
			if(!(I.slot_flags & ITEM_SLOT_EARS))
				return FALSE
			if(!H.get_bodypart(BODY_ZONE_HEAD))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_W_UNIFORM)
			if(H.w_uniform)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_ICLOTHING) )
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_WEAR_ID)
			if(H.wear_id)
				return FALSE

			var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_CHEST)
			if(!H.w_uniform && !nojumpsuit && (!O || O.status != BODYPART_ROBOTIC))
				if(!disable_warning)
					to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [I.name]!</span>")
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_ID) )
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_L_STORE)
			if(I.item_flags & NODROP)
				return FALSE
			if(H.l_store)
				return FALSE

			var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_L_LEG)

			if(!H.w_uniform && !nojumpsuit && (!O || O.status != BODYPART_ROBOTIC))
				if(!disable_warning)
					to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [I.name]!</span>")
				return FALSE
			if(I.slot_flags & ITEM_SLOT_DENYPOCKET)
				return FALSE
			if( I.w_class <= WEIGHT_CLASS_SMALL || (I.slot_flags & ITEM_SLOT_POCKET) )
				return TRUE
		if(SLOT_R_STORE)
			if(I.item_flags & NODROP)
				return FALSE
			if(H.r_store)
				return FALSE

			var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_R_LEG)

			if(!H.w_uniform && !nojumpsuit && (!O || O.status != BODYPART_ROBOTIC))
				if(!disable_warning)
					to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [I.name]!</span>")
				return FALSE
			if(I.slot_flags & ITEM_SLOT_DENYPOCKET)
				return FALSE
			if( I.w_class <= WEIGHT_CLASS_SMALL || (I.slot_flags & ITEM_SLOT_POCKET) )
				return TRUE
			return FALSE
		if(SLOT_S_STORE)
			if(I.item_flags & NODROP)
				return FALSE
			if(H.s_store)
				return FALSE
			if(!H.wear_suit)
				if(!disable_warning)
					to_chat(H, "<span class='warning'>You need a suit before you can attach this [I.name]!</span>")
				return FALSE
			if(!H.wear_suit.allowed)
				if(!disable_warning)
					to_chat(H, "You somehow have a suit with no defined allowed items for suit storage, stop that.")
				return FALSE
			if(I.w_class > WEIGHT_CLASS_BULKY)
				if(!disable_warning)
					to_chat(H, "The [I.name] is too big to attach.")
				return FALSE
			//if( istype(I, /obj/item/pda) || istype(I, /obj/item/pen) || is_type_in_list(I, H.wear_suit.allowed) )
			if( istype(I, /obj/item/pda))//not_actual
				return TRUE
			return FALSE
		if(SLOT_HANDCUFFED)
			if(H.handcuffed)
				return FALSE
			//if(!istype(I, /obj/item/restraints/handcuffs))
			//	return FALSE
			if(num_arms < 2)
				return FALSE
			return TRUE
		if(SLOT_LEGCUFFED)
			if(H.legcuffed)
				return FALSE
			//if(!istype(I, /obj/item/restraints/legcuffs))
			//	return FALSE
			if(num_legs < 2)
				return FALSE
			return TRUE
		if(SLOT_IN_BACKPACK)
			if(H.back)
				if(SEND_SIGNAL(H.back, COMSIG_TRY_STORAGE_CAN_INSERT, I, H, TRUE))
					return TRUE
			return FALSE
	return FALSE

/datum/species/proc/equip_delay_self_check(obj/item/I, mob/living/carbon/human/H, bypass_equip_delay_self)
	if(!I.equip_delay_self || bypass_equip_delay_self)
		return TRUE
	H.visible_message("<span class='notice'>[H] start putting on [I]...</span>", "<span class='notice'>You start putting on [I]...</span>")
	return do_after(H, I.equip_delay_self, target = H)

/datum/species/proc/update_health_hud(mob/living/carbon/human/H)
	return 0

/datum/species/proc/help(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(!((target.health < 0 || target.has_trait(TRAIT_FAKEDEATH)) && !(target.mobility_flags & MOBILITY_STAND)))
		target.help_shake_act(user)
		if(target != user)
			log_combat(user, target, "shaken")
		return 1
	else
		//var/we_breathe = !user.has_trait(TRAIT_NOBREATH)
		//var/we_lung = user.getorganslot(ORGAN_SLOT_LUNGS)

		//if(we_breathe && we_lung)
		//	user.do_cpr(target)
		//else if(we_breathe && !we_lung)
		//	to_chat(user, "<span class='warning'>You have no lungs to breathe with, so you cannot perform CPR.</span>")
		//else
		//	to_chat(user, "<span class='notice'>You do not breathe, so you cannot perform CPR.</span>")

/datum/species/proc/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style)
	if(!istype(M))
		return
	CHECK_DNA_AND_SPECIES(M)
	CHECK_DNA_AND_SPECIES(H)

	if(!istype(M))
		return
	//if(M.mind)
	//	attacker_style = M.mind.martial_art
	//if((M != H) && M.a_intent != INTENT_HELP && H.check_shields(M, 0, M.name, attack_type = UNARMED_ATTACK))
	//	log_combat(M, H, "attempted to touch")
	//	H.visible_message("<span class='warning'>[M] attempted to touch [H]!</span>")
	//	return 0
	SEND_SIGNAL(M, COMSIG_MOB_ATTACK_HAND, M, H, attacker_style)
	switch(M.a_intent)
		if("help")
			help(M, H, attacker_style)

		//if("grab")
		//	grab(M, H, attacker_style)

		//if("harm")
		//	harm(M, H, attacker_style)

		//if("disarm")
		//	disarm(M, H, attacker_style)