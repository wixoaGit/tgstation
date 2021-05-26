/datum/job
	var/title = "NOPE"

	var/list/minimal_access = list()
	var/list/access = list()

	var/department_head = list()

	var/list/head_announce = null

	var/flag = 0
	var/department_flag = 0

	var/faction = "None"
	
	var/total_positions = 0

	var/spawn_positions = 0

	var/current_positions = 0

	var/supervisors = ""

	var/selection_color = "#ffffff"

	var/req_admin_notify

	var/minimal_player_age = 0

	var/outfit = null

	var/exp_requirements = 0

	var/exp_type = ""
	var/exp_type_department = ""

	var/antag_rep = 10

	var/paycheck = PAYCHECK_MINIMAL
	var/paycheck_department = ACCOUNT_CIV

	var/list/mind_traits

/datum/job/proc/announce(mob/living/carbon/human/H)
	if(head_announce)
		announce_head(H, head_announce)

/datum/job/proc/equip(mob/living/carbon/human/H, visualsOnly = FALSE, announce = TRUE, latejoin = FALSE, datum/outfit/outfit_override = null, client/preference_source)
	if(!H)
		return FALSE
	//if(!visualsOnly)
	//	var/datum/bank_account/bank_account = new(H.real_name, src)
	//	bank_account.payday(STARTING_PAYCHECKS, TRUE)
	//	H.account_id = bank_account.account_id
	//if(CONFIG_GET(flag/enforce_human_authority) && (title in GLOB.command_positions))
	//	if(H.dna.species.id != "human")
	//		H.set_species(/datum/species/human)
	//		H.apply_pref_name("human", preference_source)

	//H.dna.species.before_equip_job(src, H, visualsOnly)

	if(outfit_override || outfit)
		H.equipOutfit(outfit_override ? outfit_override : outfit, visualsOnly)

	//H.dna.species.after_equip_job(src, H, visualsOnly)

	if(!visualsOnly && announce)
		announce(H)

/datum/job/proc/get_access()
	//if(!config)
	//	return src.minimal_access.Copy()

	. = list()

	if(CONFIG_GET(flag/jobs_have_minimal_access))
		. = src.minimal_access.Copy()
	else
		. = src.access.Copy()

	if(CONFIG_GET(flag/everyone_has_maint_access))
		. |= list(ACCESS_MAINT_TUNNELS)

/datum/job/proc/announce_head(var/mob/living/carbon/human/H, var/channels)
	//if(H && GLOB.announcement_systems.len)
	//	SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, .proc/addtimer, CALLBACK(pick(GLOB.announcement_systems), /obj/machinery/announcement_system/proc/announce, "NEWHEAD", H.real_name, H.job, channels), 1))

/datum/outfit/job
	name = "Standard Gear"
	
	var/jobtype = null

	uniform = /obj/item/clothing/under/color/grey
	id = /obj/item/card/id
	ears = /obj/item/radio/headset
	belt = /obj/item/pda
	back = /obj/item/storage/backpack
	shoes = /obj/item/clothing/shoes/sneakers/black
	box = /obj/item/storage/box/survival

	//var/backpack = /obj/item/storage/backpack
	//var/satchel  = /obj/item/storage/backpack/satchel
	//var/duffelbag = /obj/item/storage/backpack/duffelbag

	var/pda_slot = SLOT_BELT

/datum/outfit/job/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return
	
	var/datum/job/J = null//SSjob.GetJobType(jobtype) not_actual
	if(!J)
		J = SSjob.GetJob(H.job)
	
	var/obj/item/card/id/C = H.wear_id
	if(istype(C))
		C.access = J.get_access()
		//shuffle_inplace(C.access)
		C.registered_name = H.real_name
		C.assignment = J.title
		C.update_label()
		for(var/A in SSeconomy.bank_accounts)
			var/datum/bank_account/B = A
			if(B.account_id == H.account_id)
				C.registered_account = B
				B.bank_cards += C
				break
		//H.sec_hud_set_ID()
	
	var/obj/item/pda/PDA = H.get_item_by_slot(pda_slot)
	if(istype(PDA))
		PDA.owner = H.real_name
		PDA.ownjob = J.title
		PDA.update_label()