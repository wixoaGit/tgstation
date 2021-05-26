/obj/item/clothing/under/rank/bartender
	desc = "It looks like it could use some more flair."
	name = "bartender's uniform"
	icon_state = "barman"
	item_state = "bar_suit"
	item_color = "barman"
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/captain
	desc = "It's a blue jumpsuit with some gold markings denoting the rank of \"Captain\"."
	name = "captain's jumpsuit"
	icon_state = "captain"
	item_state = "b_suit"
	item_color = "captain"

/obj/item/clothing/under/rank/cargo
	name = "quartermaster's jumpsuit"
	desc = "It's a jumpsuit worn by the quartermaster. It's specially designed to prevent back injuries caused by pushing paper."
	icon_state = "qm"
	item_state = "lb_suit"
	item_color = "qm"

/obj/item/clothing/under/rank/cargotech
	name = "cargo technician's jumpsuit"
	desc = "Shooooorts! They're comfy and easy to wear!"
	icon_state = "cargotech"
	item_state = "lb_suit"
	item_color = "cargo"
	body_parts_covered = CHEST|GROIN|ARMS
	mutantrace_variation = MUTANTRACE_VARIATION
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/chef
	name = "cook's suit"
	desc = "A suit which is given only to the most <b>hardcore</b> cooks in space."
	icon_state = "chef"
	item_color = "chef"
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/head_of_personnel
	desc = "It's a jumpsuit worn by someone who works in the position of \"Head of Personnel\"."
	name = "head of personnel's jumpsuit"
	icon_state = "hop"
	item_state = "b_suit"
	item_color = "hop"
	can_adjust = FALSE

/obj/item/clothing/under/rank/hydroponics
	desc = "It's a jumpsuit designed to protect against minor plant-related hazards."
	name = "botanist's jumpsuit"
	icon_state = "hydroponics"
	item_state = "g_suit"
	item_color = "hydroponics"
	permeability_coefficient = 0.5

/obj/item/clothing/under/rank/janitor
	desc = "It's the official uniform of the station's janitor. It has minor protection from biohazards."
	name = "janitor's jumpsuit"
	icon_state = "janitor"
	item_color = "janitor"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 0)

/obj/item/clothing/under/rank/miner
	desc = "It's a snappy jumpsuit with a sturdy set of overalls. It is very dirty."
	name = "shaft miner's jumpsuit"
	icon_state = "miner"
	item_state = "miner"
	item_color = "miner"

/obj/item/clothing/under/rank/miner/lavaland
	desc = "A green uniform for operating in hazardous environments."
	name = "shaft miner's jumpsuit"
	icon_state = "explorer"
	item_state = "explorer"
	item_color = "explorer"
	can_adjust = FALSE