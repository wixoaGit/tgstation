/datum/language
	var/name = "an unknown language"
	var/desc = "A language."
	var/speech_verb = "says"
	var/ask_verb = "asks"
	var/exclaim_verb = "exclaims"
	var/whisper_verb = "whispers"
	var/list/signlang_verb = list("signs", "gestures")
	var/key
	var/flags
	var/list/syllables
	var/sentence_chance = 5
	var/space_chance = 55
	var/list/spans = list()
	var/list/scramble_cache = list()
	var/default_priority = 0

	var/icon = 'icons/misc/language.dmi'
	var/icon_state = "popcorn"