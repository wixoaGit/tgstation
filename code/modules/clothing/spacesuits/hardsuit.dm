/obj/item/clothing/head/helmet/space/hardsuit
	name = "hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
	icon_state = "hardsuit0-engineering"
	item_state = "eng_helm"
	max_integrity = 300
	armor = list("melee" = 10, "bullet" = 5, "laser" = 10, "energy" = 5, "bomb" = 10, "bio" = 100, "rad" = 75, "fire" = 50, "acid" = 75)
	var/basestate = "hardsuit"
	var/brightness_on = 4
	var/on = FALSE
	var/obj/item/clothing/suit/space/hardsuit/suit
	item_color = "engineering"
	//actions_types = list(/datum/action/item_action/toggle_helmet_light)

	var/rad_count = 0
	var/rad_record = 0
	var/grace_count = 0
	//var/datum/looping_sound/geiger/soundloop

/obj/item/clothing/head/helmet/space/hardsuit/Initialize()
	. = ..()
	//soundloop = new(list(), FALSE, TRUE)
	//soundloop.volume = 5
	START_PROCESSING(SSobj, src)

/obj/item/clothing/head/helmet/space/hardsuit/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/clothing/suit/space/hardsuit
	name = "hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
	icon_state = "hardsuit-engineering"
	item_state = "eng_hardsuit"
	max_integrity = 300
	armor = list("melee" = 10, "bullet" = 5, "laser" = 10, "energy" = 5, "bomb" = 10, "bio" = 100, "rad" = 75, "fire" = 50, "acid" = 75)
	//allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/t_scanner, /obj/item/construction/rcd, /obj/item/pipe_dispenser)
	siemens_coefficient = 0
	var/obj/item/clothing/head/helmet/space/hardsuit/helmet
	actions_types = list(/datum/action/item_action/toggle_helmet)
	var/helmettype = /obj/item/clothing/head/helmet/space/hardsuit
	//var/obj/item/tank/jetpack/suit/jetpack = null


/obj/item/clothing/suit/space/hardsuit/Initialize()
	//if(jetpack && ispath(jetpack))
	//	jetpack = new jetpack(src)
	. = ..()

/obj/item/clothing/suit/space/hardsuit/attack_self(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	..()

/obj/item/clothing/suit/space/hardsuit/attackby(obj/item/I, mob/user, params)
	//if(istype(I, /obj/item/tank/jetpack/suit))
	//	if(jetpack)
	//		to_chat(user, "<span class='warning'>[src] already has a jetpack installed.</span>")
	//		return
	//	if(src == user.get_item_by_slot(SLOT_WEAR_SUIT))
	//		to_chat(user, "<span class='warning'>You cannot install the upgrade to [src] while wearing it.</span>")
	//		return

	//	if(user.transferItemToLoc(I, src))
	//		jetpack = I
	//		to_chat(user, "<span class='notice'>You successfully install the jetpack into [src].</span>")
	//		return
	//else if(I.tool_behaviour == TOOL_SCREWDRIVER)
	//	if(!jetpack)
	//		to_chat(user, "<span class='warning'>[src] has no jetpack installed.</span>")
	//		return
	//	if(src == user.get_item_by_slot(SLOT_WEAR_SUIT))
	//		to_chat(user, "<span class='warning'>You cannot remove the jetpack from [src] while wearing it.</span>")
	//		return

	//	jetpack.turn_off(user)
	//	jetpack.forceMove(drop_location())
	//	jetpack = null
	//	to_chat(user, "<span class='notice'>You successfully remove the jetpack from [src].</span>")
	//	return
	return ..()

/obj/item/clothing/suit/space/hardsuit/equipped(mob/user, slot)
	..()
	//if(jetpack)
	//	if(slot == SLOT_WEAR_SUIT)
	//		for(var/X in jetpack.actions)
	//			var/datum/action/A = X
	//			A.Grant(user)

/obj/item/clothing/suit/space/hardsuit/dropped(mob/user)
	..()
	//if(jetpack)
	//	for(var/X in jetpack.actions)
	//		var/datum/action/A = X
	//		A.Remove(user)

/obj/item/clothing/suit/space/hardsuit/item_action_slot_check(slot)
	if(slot == SLOT_WEAR_SUIT)
		return 1

/obj/item/clothing/head/helmet/space/hardsuit/engine
	name = "engineering hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
	icon_state = "hardsuit0-engineering"
	item_state = "eng_helm"
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 5, "bomb" = 10, "bio" = 100, "rad" = 75, "fire" = 100, "acid" = 75)
	item_color = "engineering"
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/space/hardsuit/engine
	name = "engineering hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
	icon_state = "hardsuit-engineering"
	item_state = "eng_hardsuit"
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 5, "bomb" = 10, "bio" = 100, "rad" = 75, "fire" = 100, "acid" = 75)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/engine
	resistance_flags = FIRE_PROOF

/obj/item/clothing/head/helmet/space/hardsuit/engine/elite
	name = "advanced hardsuit helmet"
	desc = "An advanced helmet designed for work in a hazardous, low pressure environment. Shines with a high polish."
	icon_state = "hardsuit0-white"
	item_state = "ce_helm"
	item_color = "white"
	armor = list("melee" = 40, "bullet" = 5, "laser" = 10, "energy" = 5, "bomb" = 50, "bio" = 100, "rad" = 90, "fire" = 100, "acid" = 90)
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/obj/item/clothing/suit/space/hardsuit/engine/elite
	icon_state = "hardsuit-white"
	name = "advanced hardsuit"
	desc = "An advanced suit that protects against hazardous, low pressure environments. Shines with a high polish."
	item_state = "ce_hardsuit"
	armor = list("melee" = 40, "bullet" = 5, "laser" = 10, "energy" = 5, "bomb" = 50, "bio" = 100, "rad" = 90, "fire" = 100, "acid" = 90)
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/engine/elite
	//jetpack = /obj/item/tank/jetpack/suit

/obj/item/clothing/head/helmet/space/hardsuit/swat
	name = "\improper MK.II SWAT Helmet"
	icon_state = "swat2helm"
	item_state = "swat2helm"
	desc = "A tactical SWAT helmet MK.II."
	armor = list("melee" = 40, "bullet" = 50, "laser" = 50, "energy" = 25, "bomb" = 50, "bio" = 100, "rad" = 50, "fire" = 100, "acid" = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	//actions_types = list()

/obj/item/clothing/head/helmet/space/hardsuit/swat/attack_self()

/obj/item/clothing/suit/space/hardsuit/swat
	name = "\improper MK.II SWAT Suit"
	desc = "A MK.II SWAT suit with streamlined joints and armor made out of superior materials, insulated against intense heat. The most advanced tactical armor available."
	icon_state = "swat2"
	item_state = "swat2"
	armor = list("melee" = 40, "bullet" = 50, "laser" = 50, "energy" = 25, "bomb" = 50, "bio" = 100, "rad" = 50, "fire" = 100, "acid" = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/swat

/obj/item/clothing/suit/space/hardsuit/swat/Initialize()
	. = ..()
	//allowed = GLOB.security_hardsuit_allowed

/obj/item/clothing/head/helmet/space/hardsuit/swat/captain
	name = "captain's hardsuit helmet"
	icon_state = "capspace"
	item_state = "capspacehelmet"
	desc = "A tactical MK.II SWAT helmet boasting better protection and a horrible fashion sense."

/obj/item/clothing/suit/space/hardsuit/swat/captain
	name = "captain's SWAT suit"
	desc = "A MK.II SWAT suit with streamlined joints and armor made out of superior materials, insulated against intense heat. The most advanced tactical armor available. Usually reserved for heavy hitter corporate security, this one has a regal finish in Nanotrasen company colors. Better not let the assistants get a hold of it."
	icon_state = "caparmor"
	item_state = "capspacesuit"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/swat/captain