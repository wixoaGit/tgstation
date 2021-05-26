#define BRUTE		"brute"
#define BURN		"fire"
#define TOX			"tox"
#define OXY			"oxy"
#define CLONE		"clone"
#define STAMINA 	"stamina"
#define BRAIN		"brain"

#define BRUTELOSS 		(1<<0)
#define FIRELOSS 		(1<<1)
#define TOXLOSS 		(1<<2)
#define OXYLOSS 		(1<<3)
#define SHAME 			(1<<4)
#define MANUAL_SUICIDE	(1<<5)

#define EFFECT_STUN			"stun"
#define EFFECT_KNOCKDOWN	"knockdown"
#define EFFECT_UNCONSCIOUS	"unconscious"
#define EFFECT_PARALYZE		"paralyze"
#define EFFECT_IMMOBILIZE	"immobilize"
#define EFFECT_IRRADIATE	"irradiate"
#define EFFECT_STUTTER		"stutter"
#define EFFECT_SLUR 		"slur"
#define EFFECT_EYE_BLUR		"eye_blur"
#define EFFECT_DROWSY		"drowsy"
#define EFFECT_JITTER		"jitter"

#define CANSTUN			(1<<0)
#define CANKNOCKDOWN	(1<<1)
#define CANUNCONSCIOUS	(1<<2)
#define CANPUSH			(1<<3)
#define GODMODE			(1<<4)

#define HEALTH_THRESHOLD_CRIT 0
#define HEALTH_THRESHOLD_FULLCRIT -30
#define HEALTH_THRESHOLD_DEAD -100

#define CLICK_CD_MELEE 8
#define CLICK_CD_RANGE 4
#define CLICK_CD_RAPID 2
#define CLICK_CD_CLICK_ABILITY 6
#define CLICK_CD_BREAKOUT 100
#define CLICK_CD_HANDCUFFED 10
#define CLICK_CD_RESIST 20
#define CLICK_CD_GRABBING 10

#define GRAB_PASSIVE				0
#define GRAB_AGGRESSIVE				1
#define GRAB_NECK					2
#define GRAB_KILL					3

#define SOFTCRIT_ADD_SLOWDOWN 2

#define CRAWLING_ADD_SLOWDOWN 4

#define ATTACK_EFFECT_PUNCH		"punch"
#define ATTACK_EFFECT_KICK		"kick"
#define ATTACK_EFFECT_SMASH		"smash"
#define ATTACK_EFFECT_CLAW		"claw"
#define ATTACK_EFFECT_DISARM	"disarm"
#define ATTACK_EFFECT_BITE		"bite"
#define ATTACK_EFFECT_MECHFIRE	"mech_fire"
#define ATTACK_EFFECT_MECHTOXIN	"mech_toxin"
#define ATTACK_EFFECT_BOOP		"boop"

#define INTENT_HELP   "help"
#define INTENT_GRAB   "grab"
#define INTENT_DISARM "disarm"
#define INTENT_HARM   "harm"

#define INTENT_HOTKEY_LEFT  "left"
#define INTENT_HOTKEY_RIGHT "right"

#define COMBAT_MESSAGE_RANGE 3

#define WEAPON_LIGHT 1
#define WEAPON_MEDIUM 2
#define WEAPON_HEAVY 3

#define TRIGGER_GUARD_ALLOW_ALL -1
#define TRIGGER_GUARD_NONE 0
#define TRIGGER_GUARD_NORMAL 1

#define REFLECT_NORMAL 				(1<<0)
#define REFLECT_FAKEPROJECTILE		(1<<1)

#define IS_BLUNT			0
#define IS_SHARP			1
#define IS_SHARP_ACCURATE	2

#define EXPLODE_NONE 0
#define EXPLODE_DEVASTATE 1
#define EXPLODE_HEAVY 2
#define EXPLODE_LIGHT 3

#define EMP_HEAVY 1
#define EMP_LIGHT 2

#define BODY_ZONE_HEAD		"head"
#define BODY_ZONE_CHEST		"chest"
#define BODY_ZONE_L_ARM		"l_arm"
#define BODY_ZONE_R_ARM		"r_arm"
#define BODY_ZONE_L_LEG		"l_leg"
#define BODY_ZONE_R_LEG		"r_leg"

#define BODY_ZONE_PRECISE_EYES		"eyes"
#define BODY_ZONE_PRECISE_MOUTH		"mouth"
#define BODY_ZONE_PRECISE_GROIN		"groin"
#define BODY_ZONE_PRECISE_L_HAND	"l_hand"
#define BODY_ZONE_PRECISE_R_HAND	"r_hand"
#define BODY_ZONE_PRECISE_L_FOOT	"l_foot"
#define BODY_ZONE_PRECISE_R_FOOT	"r_foot"

#define DAMAGE_PRECISION 0.1
