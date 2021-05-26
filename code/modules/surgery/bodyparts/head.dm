/obj/item/bodypart/head
	name = BODY_ZONE_HEAD
	desc = "Didn't make sense not to live for fun, your brain gets smart but your head gets dumb."
	icon = 'icons/mob/human_parts.dmi'
	icon_state = "default_human_head"
	max_damage = 200
	body_zone = BODY_ZONE_HEAD
	body_part = HEAD

/obj/item/bodypart/head/get_limb_icon(dropped)
	cut_overlays()
	. = ..()
	//if(dropped)

	//	if(status != BODYPART_ROBOTIC)
	//		if(facial_hair_style)
	//			var/datum/sprite_accessory/S = GLOB.facial_hair_styles_list[facial_hair_style]
	//			if(S)
	//				var/image/facial_overlay = image(S.icon, "[S.icon_state]", -HAIR_LAYER, SOUTH)
	//				facial_overlay.color = "#" + facial_hair_color
	//				facial_overlay.alpha = hair_alpha
	//				. += facial_overlay

	//		if(!brain)
	//			var/image/debrain_overlay = image(layer = -HAIR_LAYER, dir = SOUTH)
	//			if(animal_origin == ALIEN_BODYPART)
	//				debrain_overlay.icon = 'icons/mob/animal_parts.dmi'
	//				debrain_overlay.icon_state = "debrained_alien"
	//			else if(animal_origin == LARVA_BODYPART)
	//				debrain_overlay.icon = 'icons/mob/animal_parts.dmi'
	//				debrain_overlay.icon_state = "debrained_larva"
	//			else if(!(NOBLOOD in species_flags_list))
	//				debrain_overlay.icon = 'icons/mob/human_face.dmi'
	//				debrain_overlay.icon_state = "debrained"
	//			. += debrain_overlay
	//		else
	//			var/datum/sprite_accessory/S2 = GLOB.hair_styles_list[hair_style]
	//			if(S2)
	//				var/image/hair_overlay = image(S2.icon, "[S2.icon_state]", -HAIR_LAYER, SOUTH)
	//				hair_overlay.color = "#" + hair_color
	//				hair_overlay.alpha = hair_alpha
	//				. += hair_overlay


		//if(lip_style)
		//	var/image/lips_overlay = image('icons/mob/human_face.dmi', "lips_[lip_style]", -BODY_LAYER, SOUTH)
		//	lips_overlay.color = lip_color
		//	. += lips_overlay

		//var/image/eyes_overlay = image('icons/mob/human_face.dmi', "eyes", -BODY_LAYER, SOUTH)
		//. += eyes_overlay
		//if(!eyes)
		//	eyes_overlay.icon_state = "eyes_missing"

		//else if(eyes.eye_color)
		//	eyes_overlay.color = "#" + eyes.eye_color