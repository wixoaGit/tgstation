/proc/init_sprite_accessory_subtypes(prototype, list/L, list/male, list/female,var/roundstart = FALSE)
	if(!istype(L))
		L = list()
	if(!istype(male))
		male = list()
	if(!istype(female))
		female = list()

	for(var/path in typesof(prototype))
		if(path == prototype)
			continue
		//if(roundstart)
		//	var/datum/sprite_accessory/P = path
		//	if(initial(P.locked))
		//		continue
		var/datum/sprite_accessory/D = new path()

		if(D.icon_state)
			L[D.name] = D
		else
			L += D.name

		switch(D.gender)
			if(MALE)
				male += D.name
			if(FEMALE)
				female += D.name
			else
				male += D.name
				female += D.name
	return L

/datum/sprite_accessory
	var/icon
	var/icon_state
	var/name
	var/gender = NEUTER
	var/gender_specific
	//var/color_src = MUTCOLORS
	var/hasinner
	var/locked = FALSE
	var/dimension_x = 32
	var/dimension_y = 32
	var/center = FALSE

/datum/sprite_accessory/hair
	icon = 'icons/mob/human_face.dmi'

/datum/sprite_accessory/hair/afro
	name = "Afro"
	icon_state = "hair_afro"

/datum/sprite_accessory/hair/afro2
	name = "Afro 2"
	icon_state = "hair_afro2"

/datum/sprite_accessory/hair/afro_large
	name = "Afro (Large)"
	icon_state = "hair_bigafro"

/datum/sprite_accessory/hair/antenna
	name = "Ahoge"
	icon_state = "hair_antenna"

/datum/sprite_accessory/hair/bald
	name = "Bald"
	icon_state = null

/datum/sprite_accessory/hair/balding
	name = "Balding Hair"
	icon_state = "hair_e"

/datum/sprite_accessory/hair/bedhead
	name = "Bedhead"
	icon_state = "hair_bedhead"

/datum/sprite_accessory/hair/bedhead2
	name = "Bedhead 2"
	icon_state = "hair_bedheadv2"

/datum/sprite_accessory/hair/bedhead3
	name = "Bedhead 3"
	icon_state = "hair_bedheadv3"

/datum/sprite_accessory/hair/beehive
	name = "Beehive"
	icon_state = "hair_beehive"

/datum/sprite_accessory/hair/beehive2
	name = "Beehive 2"
	icon_state = "hair_beehivev2"

/datum/sprite_accessory/hair/bob
	name = "Bob Hair"
	icon_state = "hair_bob"

/datum/sprite_accessory/hair/bob2
	name = "Bob Hair 2"
	icon_state = "hair_bob2"

/datum/sprite_accessory/hair/bob3
	name = "Bob Hair 3"
	icon_state = "hair_bobcut"

/datum/sprite_accessory/hair/bobcurl
	name = "Bobcurl"
	icon_state = "hair_bobcurl"

/datum/sprite_accessory/hair/boddicker
	name = "Boddicker"
	icon_state = "hair_boddicker"

/datum/sprite_accessory/hair/bowl
	name = "Bowl"
	icon_state = "hair_bowlcut"

/datum/sprite_accessory/hair/braid
	name = "Braid (Floorlength)"
	icon_state = "hair_braid"

/datum/sprite_accessory/hair/braided
	name = "Braided"
	icon_state = "hair_braided"

/datum/sprite_accessory/hair/front_braid
	name = "Braided Front"
	icon_state = "hair_braidfront"

/datum/sprite_accessory/hair/not_floorlength_braid
	name = "Braid (High)"
	icon_state = "hair_braid2"

/datum/sprite_accessory/hair/lowbraid
	name = "Braid (Low)"
	icon_state = "hair_hbraid"

/datum/sprite_accessory/hair/shortbraid
	name = "Braid (Short)"
	icon_state = "hair_shortbraid"

/datum/sprite_accessory/hair/braidtail
	name = "Braided Tail"
	icon_state = "hair_braidtail"

/datum/sprite_accessory/hair/bun
	name = "Bun Head"
	icon_state = "hair_bun"

/datum/sprite_accessory/hair/bun2
	name = "Bun Head 2"
	icon_state = "hair_bunhead2"

/datum/sprite_accessory/hair/largebun
	name = "Bun (Large)"
	icon_state = "hair_largebun"

/datum/sprite_accessory/hair/business
	name = "Business Hair"
	icon_state = "hair_business"

/datum/sprite_accessory/hair/business2
	name = "Business Hair 2"
	icon_state = "hair_business2"

/datum/sprite_accessory/hair/business3
	name = "Business Hair 3"
	icon_state = "hair_business3"

/datum/sprite_accessory/hair/business4
	name = "Business Hair 4"
	icon_state = "hair_business4"

/datum/sprite_accessory/hair/buzz
	name = "Buzzcut"
	icon_state = "hair_buzzcut"

/datum/sprite_accessory/hair/combover
	name = "Combover"
	icon_state = "hair_combover"

/datum/sprite_accessory/hair/crew
	name = "Crewcut"
	icon_state = "hair_crewcut"

/datum/sprite_accessory/hair/curls
	name = "Curls"
	icon_state = "hair_curls"

/datum/sprite_accessory/hair/cut
	name = "Cut Hair"
	icon_state = "hair_c"

/datum/sprite_accessory/hair/devillock
	name = "Devil Lock"
	icon_state = "hair_devilock"

/datum/sprite_accessory/hair/dreadlocks
	name = "Dreadlocks"
	icon_state = "hair_dreads"

/datum/sprite_accessory/hair/drillhair
	name = "Drill Hair"
	icon_state = "hair_drillhair"

/datum/sprite_accessory/hair/drillhairextended
	name = "Drill Hair (Extended)"
	icon_state = "hair_drillhairextended"

/datum/sprite_accessory/hair/emo
	name = "Emo"
	icon_state = "hair_emo"

/datum/sprite_accessory/hair/feather
	name = "Feather"
	icon_state = "hair_feather"

/datum/sprite_accessory/hair/sargeant
	name = "Flat Top"
	icon_state = "hair_sargeant"

/datum/sprite_accessory/hair/bigflattop
	name = "Flat Top (Big)"
	icon_state = "hair_bigflattop"

/datum/sprite_accessory/hair/fag
	name = "Flow Hair"
	icon_state = "hair_f"

/datum/sprite_accessory/hair/gelled
	name = "Gelled Back"
	icon_state = "hair_gelled"

/datum/sprite_accessory/hair/gentle
	name = "Gentle"
	icon_state = "hair_gentle"

/datum/sprite_accessory/hair/halfbang
	name = "Half-banged Hair"
	icon_state = "hair_halfbang"

/datum/sprite_accessory/hair/halfbang2
	name = "Half-banged Hair 2"
	icon_state = "hair_halfbang2"

/datum/sprite_accessory/hair/hedgehog
	name = "Hedgehog Hair"
	icon_state = "hair_hedgehog"

/datum/sprite_accessory/hair/himecut
	name = "Hime Cut"
	icon_state = "hair_himecut"

/datum/sprite_accessory/hair/himecut2
	name = "Hime Cut 2"
	icon_state = "hair_himecut2"

/datum/sprite_accessory/hair/himeup
	name = "Hime Updo"
	icon_state = "hair_himeup"

/datum/sprite_accessory/hair/hitop
	name = "Hitop"
	icon_state = "hair_hitop"

/datum/sprite_accessory/hair/jensen
	name = "Jensen Hair"
	icon_state = "hair_jensen"

/datum/sprite_accessory/hair/keanu
	name = "Keanu Hair"
	icon_state = "hair_keanu"

/datum/sprite_accessory/hair/kusangi
	name = "Kusanagi Hair"
	icon_state = "hair_kusanagi"

/datum/sprite_accessory/hair/long
	name = "Long Hair 1"
	icon_state = "hair_long"

/datum/sprite_accessory/hair/long2
	name = "Long Hair 2"
	icon_state = "hair_long2"

/datum/sprite_accessory/hair/long3
	name = "Long Hair 3"
	icon_state = "hair_long3"

/datum/sprite_accessory/hair/long_over_eye
	name = "Long Over Eye"
	icon_state = "hair_longovereye"

/datum/sprite_accessory/hair/longbangs
	name = "Long Bangs"
	icon_state = "hair_lbangs"

/datum/sprite_accessory/hair/longemo
	name = "Long Emo"
	icon_state = "hair_longemo"

/datum/sprite_accessory/hair/longfringe
	name = "Long Fringe"
	icon_state = "hair_longfringe"

/datum/sprite_accessory/hair/sidepartlongalt
	name = "Long Side Part"
	icon_state = "hair_longsidepart"

/datum/sprite_accessory/hair/megaeyebrows
	name = "Mega Eyebrows"
	icon_state = "hair_megaeyebrows"

/datum/sprite_accessory/hair/messy
	name = "Messy"
	icon_state = "hair_messy"

/datum/sprite_accessory/hair/mohawk
	name = "Mohawk"
	icon_state = "hair_d"

/datum/sprite_accessory/hair/reversemohawk
	name = "Mohawk (Reverse)"
	icon_state = "hair_reversemohawk"

/datum/sprite_accessory/hair/odango
	name = "Odango"
	icon_state = "hair_odango"

/datum/sprite_accessory/hair/ombre
	name = "Ombre"
	icon_state = "hair_ombre"

/datum/sprite_accessory/hair/oneshoulder
	name = "One Shoulder"
	icon_state = "hair_oneshoulder"

/datum/sprite_accessory/hair/over_eye
	name = "Over Eye"
	icon_state = "hair_shortovereye"

/datum/sprite_accessory/hair/parted
	name = "Parted"
	icon_state = "hair_parted"

/datum/sprite_accessory/hair/partedside
	name = "Parted (Side)"
	icon_state = "hair_part"

/datum/sprite_accessory/hair/kagami
	name = "Pigtails"
	icon_state = "hair_kagami"

/datum/sprite_accessory/hair/pigtail
	name = "Pigtails 2"
	icon_state = "hair_pigtails"

/datum/sprite_accessory/hair/pigtail2
	name = "Pigtails 3"
	icon_state = "hair_pigtails2"

/datum/sprite_accessory/hair/pixie
	name = "Pixie Cut"
	icon_state = "hair_pixie"

/datum/sprite_accessory/hair/pompadour
	name = "Pompadour"
	icon_state = "hair_pompadour"

/datum/sprite_accessory/hair/bigpompadour
	name = "Pompadour (Big)"
	icon_state = "hair_bigpompadour"

/datum/sprite_accessory/hair/ponytail1
	name = "Ponytail"
	icon_state = "hair_ponytail"

/datum/sprite_accessory/hair/ponytail2
	name = "Ponytail 2"
	icon_state = "hair_ponytail2"

/datum/sprite_accessory/hair/ponytail3
	name = "Ponytail 3"
	icon_state = "hair_ponytail3"

/datum/sprite_accessory/hair/ponytail4
	name = "Ponytail 4"
	icon_state = "hair_ponytail4"

/datum/sprite_accessory/hair/ponytail5
	name = "Ponytail 5"
	icon_state = "hair_ponytail5"

/datum/sprite_accessory/hair/highponytail
	name = "Ponytail (High)"
	icon_state = "hair_highponytail"

/datum/sprite_accessory/hair/longponytail
	name = "Ponytail (Long)"
	icon_state = "hair_longstraightponytail"

/datum/sprite_accessory/hair/sidetail
	name = "Ponytail (Side)"
	icon_state = "hair_sidetail"

/datum/sprite_accessory/hair/sidetail2
	name = "Ponytail (Side) 2"
	icon_state = "hair_sidetail2"

/datum/sprite_accessory/hair/sidetail3
	name = "Ponytail (Side) 3"
	icon_state = "hair_sidetail3"

/datum/sprite_accessory/hair/sidetail4
	name = "Ponytail (Side) 4"
	icon_state = "hair_sidetail4"

/datum/sprite_accessory/hair/quiff
	name = "Quiff"
	icon_state = "hair_quiff"

/datum/sprite_accessory/hair/short
	name = "Short Hair"
	icon_state = "hair_a"

/datum/sprite_accessory/hair/shorthair2
	name = "Short Hair 2"
	icon_state = "hair_shorthair2"

/datum/sprite_accessory/hair/shorthair3
	name = "Short Hair 3"
	icon_state = "hair_shorthair3"

/datum/sprite_accessory/hair/shoulderlength
	name = "Shoulder-length Hair"
	icon_state = "hair_b"

/datum/sprite_accessory/hair/sidecut
	name = "Sidecut"
	icon_state = "hair_sidecut"

/datum/sprite_accessory/hair/skinhead
	name = "Skinhead"
	icon_state = "hair_skinhead"

/datum/sprite_accessory/hair/protagonist
	name = "Slightly Long Hair"
	icon_state = "hair_protagonist"

/datum/sprite_accessory/hair/spiky
	name = "Spiky"
	icon_state = "hair_spikey"

/datum/sprite_accessory/hair/spiky2
	name = "Spiky 2"
	icon_state = "hair_spiky"

/datum/sprite_accessory/hair/spiky3
	name = "Spiky 3"
	icon_state = "hair_spiky2"

/datum/sprite_accessory/hair/swept
	name = "Swept Back Hair"
	icon_state = "hair_swept"

/datum/sprite_accessory/hair/swept2
	name = "Swept Back Hair 2"
	icon_state = "hair_swept2"

/datum/sprite_accessory/hair/tressshoulder
	name = "Tress Shoulder"
	icon_state = "hair_tressshoulder"

/datum/sprite_accessory/hair/updo
	name = "Updo"
	icon_state = "hair_updo"

/datum/sprite_accessory/hair/longer
	name = "Very Long Hair"
	icon_state = "hair_vlong"

/datum/sprite_accessory/hair/longest
	name = "Very Long Hair 2"
	icon_state = "hair_longest"

/datum/sprite_accessory/hair/longest2
	name = "Very Long Over Eye"
	icon_state = "hair_longest2"

/datum/sprite_accessory/hair/longestalt
	name = "Very Long with Fringe"
	icon_state = "hair_vlongfringe"

/datum/sprite_accessory/facial_hair
	icon = 'icons/mob/human_face.dmi'
	gender = MALE

/datum/sprite_accessory/facial_hair/abe
	name = "Beard (Abraham Lincoln)"
	icon_state = "facial_abe"

/datum/sprite_accessory/facial_hair/brokenman
	name = "Beard (Broken Man)"
	icon_state = "facial_brokenman"

/datum/sprite_accessory/facial_hair/chinstrap
	name = "Beard (Chinstrap)"
	icon_state = "facial_chin"

/datum/sprite_accessory/facial_hair/dwarf
	name = "Beard (Dwarf)"
	icon_state = "facial_dwarf"

/datum/sprite_accessory/facial_hair/fiveoclock
	name = "Beard (Five o Clock Shadow)"
	icon_state = "facial_fiveoclock"

/datum/sprite_accessory/facial_hair/fullbeard
	name = "Beard (Full)"
	icon_state = "facial_fullbeard"

/datum/sprite_accessory/facial_hair/gt
	name = "Beard (Goatee)"
	icon_state = "facial_gt"

/datum/sprite_accessory/facial_hair/hip
	name = "Beard (Hipster)"
	icon_state = "facial_hip"

/datum/sprite_accessory/facial_hair/jensen
	name = "Beard (Jensen)"
	icon_state = "facial_jensen"

/datum/sprite_accessory/facial_hair/neckbeard
	name = "Beard (Neckbeard)"
	icon_state = "facial_neckbeard"

/datum/sprite_accessory/facial_hair/vlongbeard
	name = "Beard (Very Long)"
	icon_state = "facial_wise"

/datum/sprite_accessory/facial_hair/longbeard
	name = "Beard (Long)"
	icon_state = "facial_longbeard"

/datum/sprite_accessory/facial_hair/fu
	name = "Moustache (Fu Manchu)"
	icon_state = "facial_fumanchu"

/datum/sprite_accessory/facial_hair/hogan
	name = "Moustache (Hulk Hogan)"
	icon_state = "facial_hogan"

/datum/sprite_accessory/facial_hair/selleck
	name = "Moustache (Selleck)"
	icon_state = "facial_selleck"

/datum/sprite_accessory/facial_hair/chaplin
	name = "Moustache (Square)"
	icon_state = "facial_chaplin"

/datum/sprite_accessory/facial_hair/vandyke
	name = "Moustache (Van Dyke)"
	icon_state = "facial_vandyke"

/datum/sprite_accessory/facial_hair/watson
	name = "Moustache (Watson)"
	icon_state = "facial_watson"

/datum/sprite_accessory/facial_hair/shaved
	name = "Shaved"
	icon_state = null
	gender = NEUTER

/datum/sprite_accessory/facial_hair/elvis
	name = "Sideburns (Elvis)"
	icon_state = "facial_elvis"

/datum/sprite_accessory/underwear
	icon = 'icons/mob/underwear.dmi'

/datum/sprite_accessory/underwear/nude
	name = "Nude"
	icon_state = null
	gender = NEUTER

/datum/sprite_accessory/underwear/male_mankini
	name = "Mankini"
	icon_state = "male_mankini"
	gender = MALE

/datum/sprite_accessory/underwear/male_black
	name = "Men's Black"
	icon_state = "male_black"
	gender = MALE

/datum/sprite_accessory/underwear/male_blackalt
	name = "Men's Black Boxer"
	icon_state = "male_blackalt"
	gender = MALE

/datum/sprite_accessory/underwear/male_blue
	name = "Men's Blue"
	icon_state = "male_blue"
	gender = MALE

/datum/sprite_accessory/underwear/male_green
	name = "Men's Green"
	icon_state = "male_green"
	gender = MALE

/datum/sprite_accessory/underwear/male_grey
	name = "Men's Grey"
	icon_state = "male_grey"
	gender = MALE

/datum/sprite_accessory/underwear/male_greyalt
	name = "Men's Grey Boxer"
	icon_state = "male_greyalt"
	gender = MALE

/datum/sprite_accessory/underwear/male_hearts
	name = "Men's Hearts Boxer"
	icon_state = "male_hearts"
	gender = MALE

/datum/sprite_accessory/underwear/male_kinky
	name = "Men's Kinky"
	icon_state = "male_kinky"
	gender = MALE

/datum/sprite_accessory/underwear/male_red
	name = "Men's Red"
	icon_state = "male_red"
	gender = MALE

/datum/sprite_accessory/underwear/male_stripe
	name = "Men's Striped Boxer"
	icon_state = "male_stripe"
	gender = MALE

/datum/sprite_accessory/underwear/male_commie
	name = "Men's Striped Commie Boxer"
	icon_state = "male_commie"
	gender = MALE

/datum/sprite_accessory/underwear/male_usastripe
	name = "Men's Striped Freedom Boxer"
	icon_state = "male_assblastusa"
	gender = MALE

/datum/sprite_accessory/underwear/male_uk
	name = "Men's Striped UK Boxer"
	icon_state = "male_uk"
	gender = MALE

/datum/sprite_accessory/underwear/male_white
	name = "Men's White"
	icon_state = "male_white"
	gender = MALE

/datum/sprite_accessory/underwear/female_babydoll
	name = "Babydoll"
	icon_state = "female_babydoll"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_babyblue
	name = "Ladies' Baby-Blue"
	icon_state = "female_babyblue"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_black
	name = "Ladies' Black"
	icon_state = "female_black"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_black_neko
	name = "Ladies' Black Neko"
	icon_state = "female_neko_black"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_blackalt
	name = "Ladies' Black Sport"
	icon_state = "female_blackalt"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_blue
	name = "Ladies' Blue"
	icon_state = "female_blue"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_commie
	name = "Ladies' Commie"
	icon_state = "female_commie"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_usastripe
	name = "Ladies' Freedom"
	icon_state = "female_assblastusa"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_green
	name = "Ladies' Green"
	icon_state = "female_green"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_kinky
	name = "Ladies' Kinky"
	icon_state = "female_kinky"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_pink
	name = "Ladies' Pink"
	icon_state = "female_pink"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_red
	name = "Ladies' Red"
	icon_state = "female_red"
	gender = FEMALE

/datum/sprite_accessory/underwear/swimsuit
	name = "Ladies' Swimsuit (Black)"
	icon_state = "swim_black"
	gender = FEMALE

/datum/sprite_accessory/underwear/swimsuit_blue
	name = "Ladies' Swimsuit (Blue)"
	icon_state = "swim_blue"
	gender = FEMALE

/datum/sprite_accessory/underwear/swimsuit_green
	name = "Ladies' Swimsuit (Green)"
	icon_state = "swim_green"
	gender = FEMALE

/datum/sprite_accessory/underwear/swimsuit_purple
	name = "Ladies' Swimsuit (Purple)"
	icon_state = "swim_purple"
	gender = FEMALE

/datum/sprite_accessory/underwear/swimsuit_red
	name = "Ladies' Swimsuit (Red)"
	icon_state = "swim_red"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_thong
	name = "Ladies' Thong"
	icon_state = "female_thong"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_uk
	name = "Ladies' UK"
	icon_state = "female_uk"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_white
	name = "Ladies' White"
	icon_state = "female_white"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_white_neko
	name = "Ladies' White Neko"
	icon_state = "female_neko_white"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_whitealt
	name = "Ladies' White Sport"
	icon_state = "female_whitealt"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_yellow
	name = "Ladies' Yellow"
	icon_state = "female_yellow"
	gender = FEMALE

/datum/sprite_accessory/undershirt
	icon = 'icons/mob/underwear.dmi'

/datum/sprite_accessory/undershirt/nude
	name = "Nude"
	icon_state = null
	gender = NEUTER

/datum/sprite_accessory/undershirt/bluejersey
	name = "Jersey (Blue)"
	icon_state = "shirt_bluejersey"
	gender = NEUTER

/datum/sprite_accessory/undershirt/redjersey
	name = "Jersey (Red)"
	icon_state = "shirt_redjersey"
	gender = NEUTER

/datum/sprite_accessory/undershirt/bluepolo
	name = "Polo Shirt (Blue)"
	icon_state = "bluepolo"
	gender = NEUTER

/datum/sprite_accessory/undershirt/grayyellowpolo
	name = "Polo Shirt (Gray-Yellow)"
	icon_state = "grayyellowpolo"
	gender = NEUTER

/datum/sprite_accessory/undershirt/redpolo
	name = "Polo Shirt (Red)"
	icon_state = "redpolo"
	gender = NEUTER

/datum/sprite_accessory/undershirt/whitepolo
	name = "Polo Shirt (White)"
	icon_state = "whitepolo"
	gender = NEUTER

/datum/sprite_accessory/undershirt/alienshirt
	name = "Shirt (Alien)"
	icon_state = "shirt_alien"
	gender = NEUTER

/datum/sprite_accessory/undershirt/mondmondjaja
	name = "Shirt (Band)"
	icon_state = "band"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_black
	name = "Shirt (Black)"
	icon_state = "shirt_black"
	gender = NEUTER

/datum/sprite_accessory/undershirt/blueshirt
	name = "Shirt (Blue)"
	icon_state = "shirt_blue"
	gender = NEUTER

/datum/sprite_accessory/undershirt/clownshirt
	name = "Shirt (Clown)"
	icon_state = "shirt_clown"
	gender = NEUTER

/datum/sprite_accessory/undershirt/commie
	name = "Shirt (Commie)"
	icon_state = "shirt_commie"
	gender = NEUTER

/datum/sprite_accessory/undershirt/greenshirt
	name = "Shirt (Green)"
	icon_state = "shirt_green"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_grey
	name = "Shirt (Grey)"
	icon_state = "shirt_grey"
	gender = NEUTER

/datum/sprite_accessory/undershirt/ian
	name = "Shirt (Ian)"
	icon_state = "ian"
	gender = NEUTER

/datum/sprite_accessory/undershirt/ilovent
	name = "Shirt (I Love NT)"
	icon_state = "ilovent"
	gender = NEUTER

/datum/sprite_accessory/undershirt/lover
	name = "Shirt (Lover)"
	icon_state = "lover"
	gender = NEUTER

/datum/sprite_accessory/undershirt/matroska
	name = "Shirt (Matroska)"
	icon_state = "matroska"
	gender = NEUTER

/datum/sprite_accessory/undershirt/meat
	name = "Shirt (Meat)"
	icon_state = "shirt_meat"
	gender = NEUTER

/datum/sprite_accessory/undershirt/nano
	name = "Shirt (Nanotrasen)"
	icon_state = "shirt_nano"
	gender = NEUTER

/datum/sprite_accessory/undershirt/peace
	name = "Shirt (Peace)"
	icon_state = "peace"
	gender = NEUTER

/datum/sprite_accessory/undershirt/pacman
	name = "Shirt (Pogoman)"
	icon_state = "pogoman"
	gender = NEUTER

/datum/sprite_accessory/undershirt/question
	name = "Shirt (Question)"
	icon_state = "shirt_question"
	gender = NEUTER

/datum/sprite_accessory/undershirt/redshirt
	name = "Shirt (Red)"
	icon_state = "shirt_red"
	gender = NEUTER

/datum/sprite_accessory/undershirt/skull
	name = "Shirt (Skull)"
	icon_state = "shirt_skull"
	gender = NEUTER

/datum/sprite_accessory/undershirt/ss13
	name = "Shirt (SS13)"
	icon_state = "shirt_ss13"
	gender = NEUTER

/datum/sprite_accessory/undershirt/stripe
	name = "Shirt (Striped)"
	icon_state = "shirt_stripes"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tiedye
	name = "Shirt (Tie-dye)"
	icon_state = "shirt_tiedye"
	gender = NEUTER

/datum/sprite_accessory/undershirt/uk
	name = "Shirt (UK)"
	icon_state = "uk"
	gender = NEUTER

/datum/sprite_accessory/undershirt/usa
	name = "Shirt (USA)"
	icon_state = "shirt_assblastusa"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_white
	name = "Shirt (White)"
	icon_state = "shirt_white"
	gender = NEUTER

/datum/sprite_accessory/undershirt/blackshortsleeve
	name = "Short-sleeved Shirt (Black)"
	icon_state = "blackshortsleeve"
	gender = NEUTER

/datum/sprite_accessory/undershirt/blueshortsleeve
	name = "Short-sleeved Shirt (Blue)"
	icon_state = "blueshortsleeve"
	gender = NEUTER

/datum/sprite_accessory/undershirt/greenshortsleeve
	name = "Short-sleeved Shirt (Green)"
	icon_state = "greenshortsleeve"
	gender = NEUTER

/datum/sprite_accessory/undershirt/purpleshortsleeve
	name = "Short-sleeved Shirt (Purple)"
	icon_state = "purpleshortsleeve"
	gender = NEUTER

/datum/sprite_accessory/undershirt/whiteshortsleeve
	name = "Short-sleeved Shirt (White)"
	icon_state = "whiteshortsleeve"
	gender = NEUTER

/datum/sprite_accessory/undershirt/sports_bra
	name = "Sports Bra"
	icon_state = "sports_bra"
	gender = NEUTER

/datum/sprite_accessory/undershirt/sports_bra2
	name = "Sports Bra (Alt)"
	icon_state = "sports_bra_alt"
	gender = NEUTER

/datum/sprite_accessory/undershirt/blueshirtsport
	name = "Sports Shirt (Blue)"
	icon_state = "blueshirtsport"
	gender = NEUTER

/datum/sprite_accessory/undershirt/greenshirtsport
	name = "Sports Shirt (Green)"
	icon_state = "greenshirtsport"
	gender = NEUTER

/datum/sprite_accessory/undershirt/redshirtsport
	name = "Sports Shirt (Red)"
	icon_state = "redshirtsport"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tank_black
	name = "Tank Top (Black)"
	icon_state = "tank_black"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tankfire
	name = "Tank Top (Fire)"
	icon_state = "tank_fire"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tank_grey
	name = "Tank Top (Grey)"
	icon_state = "tank_grey"
	gender = NEUTER

/datum/sprite_accessory/undershirt/female_midriff
	name = "Tank Top (Midriff)"
	icon_state = "tank_midriff"
	gender = FEMALE

/datum/sprite_accessory/undershirt/tank_red
	name = "Tank Top (Red)"
	icon_state = "tank_red"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tankstripe
	name = "Tank Top (Striped)"
	icon_state = "tank_stripes"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tank_white
	name = "Tank Top (White)"
	icon_state = "tank_white"
	gender = NEUTER

/datum/sprite_accessory/undershirt/redtop
	name = "Top (Red)"
	icon_state = "redtop"
	gender = FEMALE

/datum/sprite_accessory/undershirt/whitetop
	name = "Top (White)"
	icon_state = "whitetop"
	gender = FEMALE

/datum/sprite_accessory/undershirt/tshirt_blue
	name = "T-Shirt (Blue)"
	icon_state = "blueshirt"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tshirt_green
	name = "T-Shirt (Green)"
	icon_state = "greenshirt"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tshirt_red
	name = "T-Shirt (Red)"
	icon_state = "redshirt"
	gender = NEUTER

/datum/sprite_accessory/undershirt/yellowshirt
	name = "T-Shirt (Yellow)"
	icon_state = "yellowshirt"
	gender = NEUTER

/datum/sprite_accessory/socks
	icon = 'icons/mob/underwear.dmi'

/datum/sprite_accessory/socks/nude
	name = "Nude"
	icon_state = null

/datum/sprite_accessory/socks/black_knee
	name = "Knee-high (Black)"
	icon_state = "black_knee"

/datum/sprite_accessory/socks/commie_knee
	name = "Knee-High (Commie)"
	icon_state = "commie_knee"

/datum/sprite_accessory/socks/usa_knee
	name = "Knee-High (Freedom)"
	icon_state = "assblastusa_knee"

/datum/sprite_accessory/socks/rainbow_knee
	name = "Knee-high (Rainbow)"
	icon_state = "rainbow_knee"

/datum/sprite_accessory/socks/striped_knee
	name = "Knee-high (Striped)"
	icon_state = "striped_knee"

/datum/sprite_accessory/socks/thin_knee
	name = "Knee-high (Thin)"
	icon_state = "thin_knee"

/datum/sprite_accessory/socks/uk_knee
	name = "Knee-High (UK)"
	icon_state = "uk_knee"

/datum/sprite_accessory/socks/white_knee
	name = "Knee-high (White)"
	icon_state = "white_knee"

/datum/sprite_accessory/socks/black_norm
	name = "Normal (Black)"
	icon_state = "black_norm"

/datum/sprite_accessory/socks/white_norm
	name = "Normal (White)"
	icon_state = "white_norm"

/datum/sprite_accessory/socks/pantyhose
	name = "Pantyhose"
	icon_state = "pantyhose"

/datum/sprite_accessory/socks/black_short
	name = "Short (Black)"
	icon_state = "black_short"

/datum/sprite_accessory/socks/white_short
	name = "Short (White)"
	icon_state = "white_short"

/datum/sprite_accessory/socks/black_thigh
	name = "Thigh-high (Black)"
	icon_state = "black_thigh"

/datum/sprite_accessory/socks/commie_thigh
	name = "Thigh-high (Commie)"
	icon_state = "commie_thigh"

/datum/sprite_accessory/socks/usa_thigh
	name = "Thigh-high (Freedom)"
	icon_state = "assblastusa_thigh"

/datum/sprite_accessory/socks/rainbow_thigh
	name = "Thigh-high (Rainbow)"
	icon_state = "rainbow_thigh"

/datum/sprite_accessory/socks/striped_thigh
	name = "Thigh-high (Striped)"
	icon_state = "striped_thigh"

/datum/sprite_accessory/socks/thin_thigh
	name = "Thigh-high (Thin)"
	icon_state = "thin_thigh"

/datum/sprite_accessory/socks/uk_thigh
	name = "Thigh-high (UK)"
	icon_state = "uk_thigh"

/datum/sprite_accessory/socks/white_thigh
	name = "Thigh-high (White)"
	icon_state = "white_thigh"