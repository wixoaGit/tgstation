/datum/datacore
	//var/medical[] = list()
	var/medical = list()//not_actual
	var/medicalPrintCount = 0
	//var/general[] = list()
	var/general = list()//not_actual
	//var/security[] = list()
	var/security = list()//not_actual
	var/securityPrintCount = 0
	var/securityCrimeCounter = 0
	//var/locked[] = list()
	var/locked = list()//not_actual

/datum/data
	var/name = "data"

/datum/data/record
	name = "record"
	var/list/fields = list()

/datum/data/record/Destroy()
	if(src in GLOB.data_core.medical)
		GLOB.data_core.medical -= src
	if(src in GLOB.data_core.security)
		GLOB.data_core.security -= src
	if(src in GLOB.data_core.general)
		GLOB.data_core.general -= src
	if(src in GLOB.data_core.locked)
		GLOB.data_core.locked -= src
	. = ..()

/datum/data/crime
	name = "crime"
	var/crimeName = ""
	var/crimeDetails = ""
	var/author = ""
	var/time = ""
	var/dataId = 0

/datum/datacore/proc/createCrimeEntry(cname = "", cdetails = "", author = "", time = "")
	var/datum/data/crime/c = new /datum/data/crime
	c.crimeName = cname
	c.crimeDetails = cdetails
	c.author = author
	c.time = time
	c.dataId = ++securityCrimeCounter
	return c

/datum/datacore/proc/addMinorCrime(id = "", datum/data/crime/crime)
	for(var/datum/data/record/R in security)
		if(R.fields["id"] == id)
			var/list/crimes = R.fields["mi_crim"]
			crimes |= crime
			return

/datum/datacore/proc/removeMinorCrime(id, cDataId)
	for(var/datum/data/record/R in security)
		if(R.fields["id"] == id)
			var/list/crimes = R.fields["mi_crim"]
			for(var/datum/data/crime/crime in crimes)
				if(crime.dataId == text2num(cDataId))
					crimes -= crime
					return

/datum/datacore/proc/removeMajorCrime(id, cDataId)
	for(var/datum/data/record/R in security)
		if(R.fields["id"] == id)
			var/list/crimes = R.fields["ma_crim"]
			for(var/datum/data/crime/crime in crimes)
				if(crime.dataId == text2num(cDataId))
					crimes -= crime
					return

/datum/datacore/proc/addMajorCrime(id = "", datum/data/crime/crime)
	for(var/datum/data/record/R in security)
		if(R.fields["id"] == id)
			var/list/crimes = R.fields["ma_crim"]
			crimes |= crime
			return

/datum/datacore/proc/manifest()
	for(var/mob/dead/new_player/N in GLOB.player_list)
		if(N.new_character)
			log_manifest(N.ckey,N.new_character.mind,N.new_character)
		if(ishuman(N.new_character))
			manifest_inject(N.new_character, N.client)
		CHECK_TICK

/datum/datacore/proc/manifest_inject(mob/living/carbon/human/H, client/C)
	set waitfor = FALSE
	var/static/list/show_directions = list(SOUTH, WEST)
	if(H.mind && (H.mind.assigned_role != H.mind.special_role))
		var/assignment
		if(H.mind.assigned_role)
			assignment = H.mind.assigned_role
		else if(H.job)
			assignment = H.job
		else
			assignment = "Unassigned"

		//var/static/record_id_num = 1001
		var/record_id_num = 1001//not_actual
		var/id = num2hex(record_id_num++,6)
		if(!C)
			C = H.client
		//var/image = get_id_photo(H, C, show_directions)
		//var/datum/picture/pf = new
		//var/datum/picture/ps = new
		//pf.picture_name = "[H]"
		//ps.picture_name = "[H]"
		//pf.picture_desc = "This is [H]."
		//ps.picture_desc = "This is [H]."
		//pf.picture_image = icon(image, dir = SOUTH)
		//ps.picture_image = icon(image, dir = WEST)
		//var/obj/item/photo/photo_front = new(null, pf)
		//var/obj/item/photo/photo_side = new(null, ps)

		var/datum/data/record/G = new()
		G.fields["id"]			= id
		G.fields["name"]		= H.real_name
		G.fields["rank"]		= assignment
		G.fields["age"]			= H.age
		G.fields["species"]	= H.dna.species.name
		//G.fields["fingerprint"]	= md5(H.dna.uni_identity)
		G.fields["fingerprint"]	= "UNIMPLEMENTED"//not_actual
		G.fields["p_stat"]		= "Active"
		G.fields["m_stat"]		= "Stable"
		G.fields["sex"]			= H.gender
		//G.fields["photo_front"]	= photo_front
		//G.fields["photo_side"]	= photo_side
		general += G

		var/datum/data/record/M = new()
		M.fields["id"]			= id
		M.fields["name"]		= H.real_name
		//M.fields["blood_type"]	= H.dna.blood_type
		//M.fields["b_dna"]		= H.dna.unique_enzymes
		M.fields["mi_dis"]		= "None"
		M.fields["mi_dis_d"]	= "No minor disabilities have been declared."
		M.fields["ma_dis"]		= "None"
		M.fields["ma_dis_d"]	= "No major disabilities have been diagnosed."
		M.fields["alg"]			= "None"
		M.fields["alg_d"]		= "No allergies have been detected in this patient."
		M.fields["cdi"]			= "None"
		M.fields["cdi_d"]		= "No diseases have been diagnosed at the moment."
		M.fields["notes"]		= "No notes."
		medical += M

		var/datum/data/record/S = new()
		S.fields["id"]			= id
		S.fields["name"]		= H.real_name
		S.fields["criminal"]	= "None"
		S.fields["mi_crim"]		= list()
		S.fields["ma_crim"]		= list()
		S.fields["notes"]		= "No notes."
		security += S

		var/datum/data/record/L = new()
		//L.fields["id"]			= md5("[H.real_name][H.mind.assigned_role]")
		L.fields["id"]			= "UNIMPLEMENTED:[H.real_name][H.mind.assigned_role]"//not_actual
		L.fields["name"]		= H.real_name
		L.fields["rank"] 		= H.mind.assigned_role
		L.fields["age"]			= H.age
		L.fields["sex"]			= H.gender
		//L.fields["blood_type"]	= H.dna.blood_type
		//L.fields["b_dna"]		= H.dna.unique_enzymes
		//L.fields["identity"]	= H.dna.uni_identity
		L.fields["species"]		= H.dna.species.type
		//L.fields["features"]	= H.dna.features
		//L.fields["image"]		= image
		L.fields["mindref"]		= H.mind
		locked += L
	return