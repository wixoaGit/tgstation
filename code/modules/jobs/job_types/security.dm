/datum/job/proc/check_config_for_sec_maint()
	//if(CONFIG_GET(flag/security_has_maint_access))
	//	return list(ACCESS_MAINT_TUNNELS)
	return list()

/datum/job/hos
	title = "Head of Security"
	flag = HOS
	department_head = list("Captain")
	department_flag = ENGSEC
	head_announce = list(RADIO_CHANNEL_SECURITY)
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffdddd"
	req_admin_notify = 1
	minimal_player_age = 14
	exp_requirements = 300
	exp_type = EXP_TYPE_CREW
	exp_type_department = EXP_TYPE_SECURITY

	outfit = /datum/outfit/job/hos
	//mind_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_COURT, ACCESS_WEAPONS, ACCESS_MECH_SECURITY,
			            ACCESS_FORENSICS_LOCKERS, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS, ACCESS_ALL_PERSONAL_LOCKERS,
			            ACCESS_RESEARCH, ACCESS_ENGINE, ACCESS_MINING, ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_MAILSORTING,
			            ACCESS_HEADS, ACCESS_HOS, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_GATEWAY, ACCESS_MAINT_TUNNELS, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_COURT, ACCESS_WEAPONS, ACCESS_MECH_SECURITY,
			            ACCESS_FORENSICS_LOCKERS, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS, ACCESS_ALL_PERSONAL_LOCKERS,
			            ACCESS_RESEARCH, ACCESS_ENGINE, ACCESS_MINING, ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_MAILSORTING,
			            ACCESS_HEADS, ACCESS_HOS, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_GATEWAY, ACCESS_MAINT_TUNNELS, ACCESS_MINERAL_STOREROOM)
	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_SEC
/datum/outfit/job/hos
	name = "Head of Security"
	jobtype = /datum/job/hos

	id = /obj/item/card/id/silver
	//belt = /obj/item/pda/heads/hos
	//ears = /obj/item/radio/headset/heads/hos/alt
	//uniform = /obj/item/clothing/under/rank/head_of_security
	//shoes = /obj/item/clothing/shoes/jackboots
	//suit = /obj/item/clothing/suit/armor/hos/trenchcoat
	//gloves = /obj/item/clothing/gloves/color/black/hos
	//head = /obj/item/clothing/head/HoS/beret
	//glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	//suit_store = /obj/item/gun/energy/e_gun
	//r_pocket = /obj/item/assembly/flash/handheld
	//l_pocket = /obj/item/restraints/handcuffs
	//backpack_contents = list(/obj/item/melee/baton/loaded=1, /obj/item/card/id/departmental_budget/sec=1)

	//backpack = /obj/item/storage/backpack/security
	//satchel = /obj/item/storage/backpack/satchel/sec
	//duffelbag = /obj/item/storage/backpack/duffelbag/sec
	//box = /obj/item/storage/box/security

	//implants = list(/obj/item/implant/mindshield)

	//chameleon_extras = list(/obj/item/gun/energy/e_gun/hos, /obj/item/stamp/hos)

/datum/outfit/job/hos/hardsuit
	name = "Head of Security (Hardsuit)"

	//mask = /obj/item/clothing/mask/gas/sechailer
	//suit = /obj/item/clothing/suit/space/hardsuit/security/hos
	//suit_store = /obj/item/tank/internals/oxygen
	//backpack_contents = list(/obj/item/melee/baton/loaded=1, /obj/item/gun/energy/e_gun=1)

/datum/job/warden
	title = "Warden"
	flag = WARDEN
	department_head = list("Head of Security")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of security"
	selection_color = "#ffeeee"
	minimal_player_age = 7
	exp_requirements = 300
	exp_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/warden

	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_COURT, ACCESS_MECH_SECURITY, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_WEAPONS, ACCESS_FORENSICS_LOCKERS, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_MECH_SECURITY, ACCESS_COURT, ACCESS_WEAPONS, ACCESS_MINERAL_STOREROOM)
	paycheck = PAYCHECK_HARD
	paycheck_department = ACCOUNT_SEC
	//mind_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

///datum/job/warden/get_access()
//	var/list/L = list()
//	L = ..() | check_config_for_sec_maint()
//	return L

/datum/outfit/job/warden
	name = "Warden"
	jobtype = /datum/job/warden

	//belt = /obj/item/pda/warden
	//ears = /obj/item/radio/headset/headset_sec/alt
	//uniform = /obj/item/clothing/under/rank/warden
	//shoes = /obj/item/clothing/shoes/jackboots
	//suit = /obj/item/clothing/suit/armor/vest/warden/alt
	//gloves = /obj/item/clothing/gloves/color/black
	//head = /obj/item/clothing/head/warden
	//glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	//r_pocket = /obj/item/assembly/flash/handheld
	//l_pocket = /obj/item/restraints/handcuffs
	//suit_store = /obj/item/gun/energy/e_gun/advtaser
	//backpack_contents = list(/obj/item/melee/baton/loaded=1)

	//backpack = /obj/item/storage/backpack/security
	//satchel = /obj/item/storage/backpack/satchel/sec
	//duffelbag = /obj/item/storage/backpack/duffelbag/sec
	//box = /obj/item/storage/box/security

	//implants = list(/obj/item/implant/mindshield)

	//chameleon_extras = /obj/item/gun/ballistic/shotgun/automatic/combat/compact