GLOBAL_LIST_EMPTY(hair_styles_list)
GLOBAL_LIST_EMPTY(hair_styles_male_list)
GLOBAL_LIST_EMPTY(hair_styles_female_list)
GLOBAL_LIST_EMPTY(facial_hair_styles_list)
GLOBAL_LIST_EMPTY(facial_hair_styles_male_list)
GLOBAL_LIST_EMPTY(facial_hair_styles_female_list)
GLOBAL_LIST_EMPTY(underwear_list)
GLOBAL_LIST_EMPTY(underwear_m)
GLOBAL_LIST_EMPTY(underwear_f)
GLOBAL_LIST_EMPTY(undershirt_list)
GLOBAL_LIST_EMPTY(undershirt_m)
GLOBAL_LIST_EMPTY(undershirt_f)
GLOBAL_LIST_EMPTY(socks_list)

GLOBAL_LIST_INIT(ghost_forms_with_directions_list, list("ghost"))

#define GBACKPACK "Grey Backpack"
#define GSATCHEL "Grey Satchel"
#define GDUFFELBAG "Grey Duffel Bag"
#define LSATCHEL "Leather Satchel"
#define DBACKPACK "Department Backpack"
#define DSATCHEL "Department Satchel"
#define DDUFFELBAG "Department Duffel Bag"
GLOBAL_LIST_INIT(backbaglist, list(DBACKPACK, DSATCHEL, DDUFFELBAG, GBACKPACK, GSATCHEL, GDUFFELBAG, LSATCHEL))

#define UPLINK_PDA		"PDA"
#define UPLINK_RADIO	"Radio"
#define UPLINK_PEN		"Pen"
GLOBAL_LIST_INIT(uplink_spawn_loc_list, list(UPLINK_PDA, UPLINK_RADIO, UPLINK_PEN))

GLOBAL_LIST_INIT(station_prefixes, world.file2list("strings/station_prefixes.txt") + "")

GLOBAL_LIST_INIT(station_names, world.file2list("strings/station_names.txt" + ""))

GLOBAL_LIST_INIT(station_suffixes, world.file2list("strings/station_suffixes.txt"))

GLOBAL_LIST_INIT(greek_letters, world.file2list("strings/greek_letters.txt"))

GLOBAL_LIST_INIT(phonetic_alphabet, world.file2list("strings/phonetic_alphabet.txt"))

GLOBAL_LIST_INIT(numbers_as_words, world.file2list("strings/numbers_as_words.txt"))