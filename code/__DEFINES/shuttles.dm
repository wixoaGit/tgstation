#define SHUTTLE_IDLE		"idle"
#define SHUTTLE_IGNITING	"igniting"
#define SHUTTLE_RECALL		"recall"
#define SHUTTLE_CALL		"call"
#define SHUTTLE_DOCKED		"docked"
#define SHUTTLE_STRANDED	"stranded"
#define SHUTTLE_ESCAPE		"escape"
#define SHUTTLE_ENDGAME		"endgame: game over"

#define EMERGENCY_ESCAPED_OR_ENDGAMED (SSshuttle.emergency && ((SSshuttle.emergency.mode == SHUTTLE_ESCAPE) || (SSshuttle.emergency.mode == SHUTTLE_ENDGAME)))

#define SHUTTLE_CAN_DOCK "can_dock"
#define SHUTTLE_NOT_A_DOCKING_PORT "not a docking port"
#define SHUTTLE_DWIDTH_TOO_LARGE "docking width too large"
#define SHUTTLE_WIDTH_TOO_LARGE "width too large"
#define SHUTTLE_DHEIGHT_TOO_LARGE "docking height too large"
#define SHUTTLE_HEIGHT_TOO_LARGE "height too large"
#define SHUTTLE_ALREADY_DOCKED "we are already docked"
#define SHUTTLE_SOMEONE_ELSE_DOCKED "someone else docked"

#define NOLAUNCH -1
#define UNLAUNCHED 0
#define ENDGAME_LAUNCHED 1
#define EARLY_LAUNCHED 2
#define ENDGAME_TRANSIT 3

#define SHUTTLE_RIPPLE_TIME 100

#define TRANSIT_REQUEST 1
#define TRANSIT_READY 2

#define SHUTTLE_TRANSIT_BORDER 8

#define PARALLAX_LOOP_TIME 25
#define HYPERSPACE_END_TIME 5

#define HYPERSPACE_WARMUP 1
#define HYPERSPACE_LAUNCH 2
#define HYPERSPACE_END 3

#define CALL_SHUTTLE_REASON_LENGTH 12

#define DOCKING_SUCCESS				0
#define DOCKING_BLOCKED				(1<<0)
#define DOCKING_IMMOBILIZED			(1<<1)
#define DOCKING_AREA_EMPTY			(1<<2)
#define DOCKING_NULL_DESTINATION	(1<<3)
#define DOCKING_NULL_SOURCE			(1<<4)

#define MOVE_TURF 1
#define MOVE_AREA 2
#define MOVE_CONTENTS 4

#define ROTATE_DIR 		1
#define ROTATE_SMOOTH 	2
#define ROTATE_OFFSET	4

#define SHUTTLE_DEFAULT_SHUTTLE_AREA_TYPE /area/shuttle
#define SHUTTLE_DEFAULT_UNDERLYING_AREA /area/space