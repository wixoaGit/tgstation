/obj/item/clothing/mask/gas/sechailer
	name = "security gas mask"
	desc = "A standard issue Security gas mask with integrated 'Compli-o-nator 3000' device. Plays over a dozen pre-recorded compliance phrases designed to get scumbags to stand still whilst you tase them. Do not tamper with the device."
	//actions_types = list(/datum/action/item_action/halt, /datum/action/item_action/adjust)
	icon_state = "sechailer"
	item_state = "sechailer"
	clothing_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	flags_inv = HIDEFACIALHAIR|HIDEFACE
	w_class = WEIGHT_CLASS_SMALL
	visor_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	visor_flags_inv = HIDEFACE
	flags_cover = MASKCOVERSMOUTH
	visor_flags_cover = MASKCOVERSMOUTH
	var/aggressiveness = 2
	var/cooldown_special
	var/recent_uses = 0
	var/broken_hailer = 0
	var/safety = TRUE