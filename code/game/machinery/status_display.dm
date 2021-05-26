#define CHARS_PER_LINE 5
#define FONT_SIZE "5pt"
#define FONT_COLOR "#09f"
#define FONT_STYLE "Arial Black"
#define SCROLL_SPEED 2

#define SD_BLANK 0
#define SD_EMERGENCY 1
#define SD_MESSAGE 2
#define SD_PICTURE 3

#define SD_AI_EMOTE 1
#define SD_AI_BSOD 2

/obj/machinery/status_display
	name = "status display"
	desc = null
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	density = FALSE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10

	//maptext_height = 26
	//maptext_width = 32

	var/message1 = ""
	var/message2 = ""
	var/index1
	var/index2

/obj/machinery/status_display/evac
	var/frequency = FREQ_STATUS_DISPLAYS
	var/mode = SD_EMERGENCY
	var/friendc = FALSE
	var/last_picture

/obj/machinery/status_display/supply
	name = "supply display"

#undef CHARS_PER_LINE
#undef FONT_SIZE
#undef FONT_COLOR
#undef FONT_STYLE
#undef SCROLL_SPEED