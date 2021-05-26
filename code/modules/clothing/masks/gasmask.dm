/obj/item/clothing/mask/gas
	name = "gas mask"
	desc = "A face-covering mask that can be connected to an air supply. While good for concealing your identity, it isn't good for blocking gas flow."
	icon_state = "gas_alt"
	clothing_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEFACIALHAIR
	w_class = WEIGHT_CLASS_NORMAL
	item_state = "gas_alt"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	flags_cover = MASKCOVERSEYES | MASKCOVERSMOUTH
	resistance_flags = NONE