#define TEXT_NORTH			"[NORTH]"
#define TEXT_SOUTH			"[SOUTH]"
#define TEXT_EAST			"[EAST]"
#define TEXT_WEST			"[WEST]"

#define MUTATIONS_LAYER			28
#define BODY_BEHIND_LAYER		27
#define BODYPARTS_LAYER			26
#define BODY_ADJ_LAYER			25
#define BODY_LAYER				24
#define FRONT_MUTATIONS_LAYER	23
#define DAMAGE_LAYER			22
#define UNIFORM_LAYER			21
#define ID_LAYER				20
#define HANDS_PART_LAYER		19
#define GLOVES_LAYER			18
#define SHOES_LAYER				17
#define EARS_LAYER				16
#define SUIT_LAYER				15
#define GLASSES_LAYER			14
#define BELT_LAYER				13
#define SUIT_STORE_LAYER		12
#define NECK_LAYER				11
#define BACK_LAYER				10
#define HAIR_LAYER				9
#define FACEMASK_LAYER			8
#define HEAD_LAYER				7
#define HANDCUFF_LAYER			6
#define LEGCUFF_LAYER			5
#define HANDS_LAYER				4
#define BODY_FRONT_LAYER		3
#define SMELL_LAYER				2
#define FIRE_LAYER				1
#define TOTAL_LAYERS			28

#define SEC_LEVEL_GREEN	0
#define SEC_LEVEL_BLUE	1
#define SEC_LEVEL_RED	2
#define SEC_LEVEL_DELTA	3

#define PROCESS_KILL 26

#define MANIFEST_ERROR_CHANCE		5
#define MANIFEST_ERROR_NAME			1
#define MANIFEST_ERROR_CONTENTS		2
#define MANIFEST_ERROR_ITEM			4

#define TRANSITIONEDGE			7

#define BE_CLOSE TRUE
#define NO_DEXTERY TRUE
#define NO_TK TRUE

#define GAME_STATE_STARTUP		0
#define GAME_STATE_PREGAME		1
#define GAME_STATE_SETTING_UP	2
#define GAME_STATE_PLAYING		3
#define GAME_STATE_FINISHED		4

#define MAX_SHOE_BLOODINESS			100
#define BLOODY_FOOTPRINT_BASE_ALPHA	150
#define BLOOD_GAIN_PER_STEP			100
#define BLOOD_LOSS_PER_STEP			5
#define BLOOD_LOSS_IN_SPREAD		20
#define BLOOD_AMOUNT_PER_DECAL		20

#define BLOOD_STATE_HUMAN			"blood"
#define BLOOD_STATE_XENO			"xeno"
#define BLOOD_STATE_OIL				"oil"
#define BLOOD_STATE_NOT_BLOODY		"no blood whatsoever"

#define TURF_DRY		0
#define TURF_WET_WATER	1
#define TURF_WET_PERMAFROST	2
#define TURF_WET_ICE 4
#define TURF_WET_LUBE	8

#define MAXIMUM_WET_TIME 5 MINUTES

#define subtypesof(typepath) ( typesof(typepath) - typepath )

#define get_turf(A) (get_step(A, 0))

#define GHOST_ORBIT_CIRCLE		"circle"
#define GHOST_ORBIT_TRIANGLE	"triangle"
#define GHOST_ORBIT_HEXAGON		"hexagon"
#define GHOST_ORBIT_SQUARE		"square"
#define GHOST_ORBIT_PENTAGON	"pentagon"

#define GHOST_ACCS_NONE		1
#define GHOST_ACCS_DIR		50
#define GHOST_ACCS_FULL		100

#define GHOST_ACCS_NONE_NAME		"default sprites"
#define GHOST_ACCS_DIR_NAME			"only directional sprites"
#define GHOST_ACCS_FULL_NAME		"full accessories"

#define GHOST_ACCS_DEFAULT_OPTION	GHOST_ACCS_FULL

#define GHOST_OTHERS_SIMPLE 			1
#define GHOST_OTHERS_DEFAULT_SPRITE		50
#define GHOST_OTHERS_THEIR_SETTING 		100

#define GHOST_OTHERS_SIMPLE_NAME 			"white ghost"
#define GHOST_OTHERS_DEFAULT_SPRITE_NAME 	"default sprites"
#define GHOST_OTHERS_THEIR_SETTING_NAME 	"their setting"

#define GHOST_OTHERS_DEFAULT_OPTION			GHOST_OTHERS_THEIR_SETTING

#define MONO		"Monospaced"
#define VT			"VT323"
#define ORBITRON	"Orbitron"
#define SHARE		"Share Tech Mono"

#define PEN_FONT "Verdana"
#define FOUNTAIN_PEN_FONT "Segoe Script"
#define CRAYON_FONT "Comic Sans MS"
#define PRINTER_FONT "Times New Roman"
#define SIGNFONT "Times New Roman"

#define ADMIN_COLOUR_PRIORITY 		1
#define TEMPORARY_COLOUR_PRIORITY 	2
#define WASHABLE_COLOUR_PRIORITY 	3
#define FIXED_COLOUR_PRIORITY 		4
#define COLOUR_PRIORITY_AMOUNT 4

#define SPACE_ICON_STATE "[((x + y) ^ ~(x * y) + z) % 25]"

#define MAP_MINX 1
#define MAP_MINY 2
#define MAP_MINZ 3
#define MAP_MAXX 4
#define MAP_MAXY 5
#define MAP_MAXZ 6

#define DEFIB_TIME_LIMIT 120
#define DEFIB_TIME_LOSS 60

#define FIRST_DIAG_STEP 1
#define SECOND_DIAG_STEP 2

#define DEADCHAT_ARRIVALRATTLE "arrivalrattle"
#define DEADCHAT_DEATHRATTLE "deathrattle"
#define DEADCHAT_REGULAR "regular-deadchat"

#define EXPLOSION_BLOCK_PROC -1

#define SYRINGE_DRAW 0
#define SYRINGE_INJECT 1

#define NO_SPAWN 0
#define HOSTILE_SPAWN 1
#define FRIENDLY_SPAWN 2

#define STACK_CHECK_CARDINALS "cardinals"
#define STACK_CHECK_ADJACENT "adjacent"

#define ION_FILE "ion_laws.json"

#define FULLSCREEN_OVERLAY_RESOLUTION_X 15
#define FULLSCREEN_OVERLAY_RESOLUTION_Y 15

#define PDAIMG(what) {"<span class="pda16x16 [#what]"></span>"}

#define STANDARD_GRAVITY 1