#define HIJACK_SYNDIE 1
#define RUSKY_PARTY 2
#define SPIDER_GIFT 3
#define DEPARTMENT_RESUPPLY 4
#define ANTIDOTE_NEEDED 5
#define PIZZA_DELIVERY 6
#define ITS_HIP_TO 7
#define MY_GOD_JC 8

/datum/round_event/shuttle_loan
	announceWhen = 1
	endWhen = 500
	var/dispatched = 0
	var/dispatch_type = 0
	var/bonus_points = 10000
	var/thanks_msg = "The cargo shuttle should return in five minutes. Have some supply points for your trouble."

/datum/round_event/shuttle_loan/proc/loan_shuttle()
	priority_announce(thanks_msg, "Cargo shuttle commandeered by CentCom.")

	dispatched = 1
	var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
	if(D)
		D.adjust_money(bonus_points)
	endWhen = activeFor + 1

	SSshuttle.supply.mode = SHUTTLE_CALL
	SSshuttle.supply.destination = SSshuttle.getDock("supply_home")
	SSshuttle.supply.setTimer(3000)

	switch(dispatch_type)
		if(HIJACK_SYNDIE)
			SSshuttle.centcom_message += "Syndicate hijack team incoming."
		if(RUSKY_PARTY)
			SSshuttle.centcom_message += "Partying Russians incoming."
		if(SPIDER_GIFT)
			SSshuttle.centcom_message += "Spider Clan gift incoming."
		if(DEPARTMENT_RESUPPLY)
			SSshuttle.centcom_message += "Department resupply incoming."
		if(ANTIDOTE_NEEDED)
			SSshuttle.centcom_message += "Virus samples incoming."
		if(PIZZA_DELIVERY)
			SSshuttle.centcom_message += "Pizza delivery for [station_name()]"
		if(ITS_HIP_TO)
			SSshuttle.centcom_message += "Biohazard cleanup incoming."
		if(MY_GOD_JC)
			SSshuttle.centcom_message += "Live explosive ordnance incoming. Exercise extreme caution."