#define ALL (~0)
#define NONE 0

#define ENABLE_BITFIELD(variable, flag) (variable |= (flag))
#define DISABLE_BITFIELD(variable, flag) (variable &= ~(flag))
#define CHECK_BITFIELD(variable, flag) (variable & flag)

#define CHECK_MULTIPLE_BITFIELDS(flagvar, flags) ((flagvar & (flags)) == flags)

GLOBAL_LIST_INIT(bitflags, list(1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768))

#define DF_USE_TAG		(1<<0)
#define DF_VAR_EDITED	(1<<1)
#define DF_ISPROCESSING (1<<2)

#define HEAR_1						(1<<3)
#define CHECK_RICOCHET_1			(1<<4)
#define CONDUCT_1					(1<<5)
#define NODECONSTRUCT_1				(1<<7)
#define OVERLAY_QUEUED_1			(1<<8)
#define ON_BORDER_1					(1<<9)
#define PREVENT_CLICK_UNDER_1		(1<<11)
#define HOLOGRAM_1					(1<<12)
#define TESLA_IGNORE_1				(1<<13)
#define INITIALIZED_1				(1<<14)
#define ADMIN_SPAWNED_1			(1<<15)

#define NOJAUNT_1					(1<<0)
#define UNUSED_RESERVATION_TURF_1	(1<<1)
#define CAN_BE_DIRTY_1				(1<<2)
#define NO_LAVA_GEN_1				(1<<6)
#define NO_RUINS_1					(1<<10)

#define PASSTABLE		(1<<0)
#define PASSGLASS		(1<<1)
#define PASSGRILLE		(1<<2)
#define PASSBLOB		(1<<3)
#define PASSMOB			(1<<4)
#define PASSCLOSEDTURF	(1<<5)
#define LETPASSTHROW	(1<<6)

#define GROUND			(1<<0)
#define FLYING			(1<<1)
#define VENTCRAWLING	(1<<2)
#define FLOATING		(1<<3)
#define UNSTOPPABLE		(1<<4)

#define LAVA_PROOF		(1<<0)
#define FIRE_PROOF		(1<<1)
#define FLAMMABLE		(1<<2)
#define ON_FIRE			(1<<3)
#define UNACIDABLE		(1<<4)
#define ACID_PROOF		(1<<5)
#define INDESTRUCTIBLE	(1<<6)
#define FREEZE_PROOF	(1<<7)

/obj/item/proc/clothing_resistance_flag_examine_message(mob/user)
	if(resistance_flags & INDESTRUCTIBLE)
		to_chat(user, "[src] seems extremely robust! It'll probably withstand anything that could happen to it!")
		return
	if(resistance_flags & LAVA_PROOF)
		to_chat(user, "[src] is made of an extremely heat-resistant material, it'd probably be able to withstand lava!")
	if(resistance_flags & (ACID_PROOF | UNACIDABLE))
		to_chat(user, "[src] looks pretty robust! It'd probably be able to withstand acid!")
	if(resistance_flags & FREEZE_PROOF)
		to_chat(user, "[src] is made of cold-resistant materials.")
	if(resistance_flags & FIRE_PROOF)
		to_chat(user, "[src] is made of fire-retardant materials.")
		return TRUE

/obj/item/clothing/clothing_resistance_flag_examine_message(mob/user)
	. = ..()
	if(.)
		return
	if(max_heat_protection_temperature == FIRE_IMMUNITY_MAX_TEMP_PROTECT)
		to_chat(user, "[src] is made of fire-retardant materials.")
		return TRUE

/obj/item/clothing/head/clothing_resistance_flag_examine_message(mob/user)
	. = ..()
	if(.)
		return
	if(max_heat_protection_temperature == (HELMET_MAX_TEMP_PROTECT || SPACE_HELM_MAX_TEMP_PROTECT || FIRE_HELM_MAX_TEMP_PROTECT))
		to_chat(user, "[src] is made of thermally insulated materials and offers some protection to fire.")
		return TRUE

/obj/item/clothing/gloves/clothing_resistance_flag_examine_message(mob/user)
	. = ..()
	if(.)
		return
	if(max_heat_protection_temperature == GLOVES_MAX_TEMP_PROTECT)
		to_chat(user, "[src] is made of thermally insulated materials and offers some protection to fire.")
		return TRUE

/obj/item/clothing/shoes/clothing_resistance_flag_examine_message(mob/user)
	. = ..()
	if(.)
		return
	if(max_heat_protection_temperature == SHOES_MAX_TEMP_PROTECT)
		to_chat(user, "[src] is made of thermally insulated materials and offers some protection to fire.")
		return TRUE

/obj/item/clothing/suit/clothing_resistance_flag_examine_message(mob/user)
	. = ..()
	if(.)
		return
	if(max_heat_protection_temperature == SPACE_SUIT_MAX_TEMP_PROTECT)
		to_chat(user, "[src] is made of thermally insulated materials and offers some protection to fire.")
		return TRUE

#define EMP_PROTECT_SELF (1<<0)
#define EMP_PROTECT_CONTENTS (1<<1)
#define EMP_PROTECT_WIRES (1<<2)

#define MOBILITY_MOVE			(1<<0)
#define MOBILITY_STAND			(1<<1)
#define MOBILITY_PICKUP			(1<<2)
#define MOBILITY_USE			(1<<3)
#define MOBILITY_UI				(1<<4)
#define MOBILITY_STORAGE		(1<<5)
#define MOBILITY_PULL			(1<<6)

#define MOBILITY_FLAGS_DEFAULT (MOBILITY_MOVE | MOBILITY_STAND | MOBILITY_PICKUP | MOBILITY_USE | MOBILITY_UI | MOBILITY_STORAGE | MOBILITY_PULL)
#define MOBILITY_FLAGS_INTERACTION (MOBILITY_USE | MOBILITY_PICKUP | MOBILITY_UI | MOBILITY_STORAGE)