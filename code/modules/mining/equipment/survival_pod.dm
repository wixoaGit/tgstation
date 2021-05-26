/obj/structure/fans
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	icon_state = "fans"
	name = "environmental regulation system"
	desc = "A large machine releasing a constant gust of air."
	anchored = TRUE
	density = TRUE
	var/buildstacktype = /obj/item/stack/sheet/metal
	var/buildstackamount = 5
	CanAtmosPass = ATMOS_PASS_NO

/obj/structure/fans/deconstruct()
	if(!(flags_1 & NODECONSTRUCT_1))
		if(buildstacktype)
			new buildstacktype(loc,buildstackamount)
	qdel(src)

/obj/structure/fans/wrench_act(mob/living/user, obj/item/I)
	if(flags_1 & NODECONSTRUCT_1)
		return TRUE

	user.visible_message("<span class='warning'>[user] disassembles [src].</span>",
		"<span class='notice'>You start to disassemble [src]...</span>", "You hear clanking and banging noises.")
	if(I.use_tool(src, user, 20, volume=50))
		deconstruct()
	return TRUE

/obj/structure/fans/tiny
	name = "tiny fan"
	desc = "A tiny fan, releasing a thin gust of air."
	layer = ABOVE_NORMAL_TURF_LAYER
	density = FALSE
	icon_state = "fan_tiny"
	buildstackamount = 2

/obj/structure/fans/Initialize(mapload)
	. = ..()
	air_update_turf(1)

/obj/structure/fans/tiny/invisible
	name = "air flow blocker"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	invisibility = INVISIBILITY_ABSTRACT