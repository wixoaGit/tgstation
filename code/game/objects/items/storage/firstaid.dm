/obj/item/storage/firstaid
	name = "first-aid kit"
	desc = "It's an emergency medical kit for those serious boo-boos."
	icon_state = "firstaid"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	throw_speed = 3
	throw_range = 7
	var/empty = FALSE

/obj/item/storage/firstaid/regular
	icon_state = "firstaid"
	desc = "A first aid kit with the ability to heal common types of injuries."

/obj/item/storage/firstaid/regular/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins giving [user.p_them()]self aids with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS

/obj/item/storage/firstaid/regular/PopulateContents()
	if(empty)
		return
	//var/static/items_inside = list(
	//	/obj/item/stack/medical/gauze = 1,
	//	/obj/item/stack/medical/bruise_pack = 2,
	//	/obj/item/stack/medical/ointment = 2,
	//	/obj/item/reagent_containers/hypospray/medipen = 1,
	//	/obj/item/healthanalyzer = 1)
	//not_actual
	var/items_inside = list(/obj/item/healthanalyzer = 1)
	generate_items_inside(items_inside,src)