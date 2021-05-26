/datum/reagent/water
	name = "Water"
	id = "water"
	description = "An ubiquitous chemical substance that is composed of hydrogen and oxygen."
	color = "#AAAAAA77"
	taste_description = "water"
	var/cooling_temperature = 2
	glass_icon_state = "glass_clear"
	glass_name = "glass of water"
	glass_desc = "The father of all refreshments."
	shot_glass_icon_state = "shotglassclear"

/datum/reagent/lube
	name = "Space Lube"
	id = "lube"
	description = "Lubricant is a substance introduced between two moving surfaces to reduce the friction and wear between them. giggity."
	color = "#009CA8"
	taste_description = "cherry"

/datum/reagent/lube/reaction_turf(turf/open/T, reac_volume)
	if (!istype(T))
		return
	//if(reac_volume >= 1)
	//	T.MakeSlippery(TURF_WET_LUBE, 15 SECONDS, min(reac_volume * 2 SECONDS, 120))

/datum/reagent/oxygen
	name = "Oxygen"
	id = "oxygen"
	description = "A colorless, odorless gas. Grows on trees but is still pretty valuable."
	reagent_state = GAS
	color = "#808080"
	taste_mult = 0

/datum/reagent/copper
	name = "Copper"
	id = "copper"
	description = "A highly ductile metal. Things made out of copper aren't very durable, but it makes a decent material for electrical wiring."
	reagent_state = SOLID
	color = "#6E3B08"
	taste_description = "metal"

/datum/reagent/nitrogen
	name = "Nitrogen"
	id = "nitrogen"
	description = "A colorless, odorless, tasteless gas. A simple asphyxiant that can silently displace vital oxygen."
	reagent_state = GAS
	color = "#808080"
	taste_mult = 0

/datum/reagent/hydrogen
	name = "Hydrogen"
	id = "hydrogen"
	description = "A colorless, odorless, nonmetallic, tasteless, highly combustible diatomic gas."
	reagent_state = GAS
	color = "#808080"
	taste_mult = 0

/datum/reagent/potassium
	name = "Potassium"
	id = "potassium"
	description = "A soft, low-melting solid that can easily be cut with a knife. Reacts violently with water."
	reagent_state = SOLID
	color = "#A0A0A0"
	taste_description = "sweetness"

/datum/reagent/mercury
	name = "Mercury"
	id = "mercury"
	description = "A curious metal that's a liquid at room temperature. Neurodegenerative and very bad for the mind."
	color = "#484848"
	taste_mult = 0

/datum/reagent/sulfur
	name = "Sulfur"
	id = "sulfur"
	description = "A sickly yellow solid mostly known for its nasty smell. It's actually much more helpful than it looks in biochemisty."
	reagent_state = SOLID
	color = "#BF8C00"
	taste_description = "rotten eggs"

/datum/reagent/carbon
	name = "Carbon"
	id = "carbon"
	description = "A crumbly black solid that, while unexciting on a physical level, forms the base of all known life. Kind of a big deal."
	reagent_state = SOLID
	color = "#1C1300"
	taste_description = "sour chalk"

/datum/reagent/chlorine
	name = "Chlorine"
	id = "chlorine"
	description = "A pale yellow gas that's well known as an oxidizer. While it forms many harmless molecules in its elemental form it is far from harmless."
	reagent_state = GAS
	color = "#808080"
	taste_description = "chlorine"

/datum/reagent/fluorine
	name = "Fluorine"
	id = "fluorine"
	description = "A comically-reactive chemical element. The universe does not want this stuff to exist in this form in the slightest."
	reagent_state = GAS
	color = "#808080"
	taste_description = "acid"

/datum/reagent/sodium
	name = "Sodium"
	id = "sodium"
	description = "A soft silver metal that can easily be cut with a knife. It's not salt just yet, so refrain from putting in on your chips."
	reagent_state = SOLID
	color = "#808080"
	taste_description = "salty metal"

/datum/reagent/phosphorus
	name = "Phosphorus"
	id = "phosphorus"
	description = "A ruddy red powder that burns readily. Though it comes in many colors, the general theme is always the same."
	reagent_state = SOLID
	color = "#832828"
	taste_description = "vinegar"

/datum/reagent/lithium
	name = "Lithium"
	id = "lithium"
	description = "A silver metal, its claim to fame is its remarkably low density. Using it is a bit too effective in calming oneself down."
	reagent_state = SOLID
	color = "#808080"
	taste_description = "metal"

/datum/reagent/iron
	name = "Iron"
	id = "iron"
	description = "Pure iron is a metal."
	reagent_state = SOLID
	taste_description = "iron"

	color = "#C8A5DC"

/datum/reagent/silver
	name = "Silver"
	id = "silver"
	description = "A soft, white, lustrous transition metal, it has the highest electrical conductivity of any element and the highest thermal conductivity of any metal."
	reagent_state = SOLID
	color = "#D0D0D0"
	taste_description = "expensive yet reasonable metal"

/datum/reagent/uranium
	name ="Uranium"
	id = "uranium"
	description = "A silvery-white metallic chemical element in the actinide series, weakly radioactive."
	reagent_state = SOLID
	color = "#B8B8C0"
	taste_description = "the inside of a reactor"
	var/irradiation_level = 1

///datum/reagent/uranium/on_mob_life(mob/living/carbon/M)
//	M.apply_effect(irradiation_level/M.metabolism_efficiency,EFFECT_IRRADIATE,0)
//	..()

///datum/reagent/uranium/reaction_turf(turf/T, reac_volume)
//	if(reac_volume >= 3)
//		if(!isspaceturf(T))
//			var/obj/effect/decal/cleanable/greenglow/GG = locate() in T.contents
//			if(!GG)
//				GG = new/obj/effect/decal/cleanable/greenglow(T)
//			GG.reagents.add_reagent(id, reac_volume)

/datum/reagent/uranium/radium
	name = "Radium"
	id = "radium"
	description = "Radium is an alkaline earth metal. It is extremely radioactive."
	reagent_state = SOLID
	color = "#C7C7C7"
	taste_description = "the colour blue and regret"
	irradiation_level = 2*REM

/datum/reagent/aluminium
	name = "Aluminium"
	id = "aluminium"
	description = "A silvery white and ductile member of the boron group of chemical elements."
	reagent_state = SOLID
	color = "#A8A8A8"
	taste_description = "metal"

/datum/reagent/silicon
	name = "Silicon"
	id = "silicon"
	description = "A tetravalent metalloid, silicon is less reactive than its chemical analog carbon."
	reagent_state = SOLID
	color = "#A8A8A8"
	taste_mult = 0

/datum/reagent/fuel
	name = "Welding fuel"
	id = "welding_fuel"
	description = "Required for welders. Flammable."
	color = "#660000"
	taste_description = "gross metal"
	glass_icon_state = "dr_gibb_glass"
	glass_name = "glass of welder fuel"
	glass_desc = "Unless you're an industrial tool, this is probably not safe for consumption."

/datum/reagent/fluorosurfactant
	name = "Fluorosurfactant"
	id = "fluorosurfactant"
	description = "A perfluoronated sulfonic acid that forms a foam when mixed with water."
	color = "#9E6B38"
	taste_description = "metal"

/datum/reagent/foaming_agent
	name = "Foaming agent"
	id = "foaming_agent"
	description = "An agent that yields metallic foam when mixed with light metal and a strong acid."
	reagent_state = SOLID
	color = "#664B63"
	taste_description = "metal"

/datum/reagent/ammonia
	name = "Ammonia"
	id = "ammonia"
	description = "A caustic substance commonly used in fertilizer or household cleaners."
	reagent_state = GAS
	color = "#404030"
	taste_description = "mordant"

/datum/reagent/diethylamine
	name = "Diethylamine"
	id = "diethylamine"
	description = "A secondary amine, mildly corrosive."
	color = "#604030"
	taste_description = "iron"

/datum/reagent/plantnutriment
	name = "Generic nutriment"
	id = "plantnutriment"
	description = "Some kind of nutriment. You can't really tell what it is. You should probably report it, along with how you obtained it."
	color = "#000000"
	var/tox_prob = 0
	taste_description = "plant food"

///datum/reagent/plantnutriment/on_mob_life(mob/living/carbon/M)
//	if(prob(tox_prob))
//		M.adjustToxLoss(1*REM, 0)
//		. = 1
//	..()

/datum/reagent/plantnutriment/eznutriment
	name = "E-Z-Nutrient"
	id = "eznutriment"
	description = "Cheap and extremely common type of plant nutriment."
	color = "#376400"
	tox_prob = 10

/datum/reagent/oil
	name = "Oil"
	id = "oil"
	description = "Burns in a small smoky fire, mostly used to get Ash."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "oil"

/datum/reagent/stable_plasma
	name = "Stable Plasma"
	id = "stable_plasma"
	description = "Non-flammable plasma locked into a liquid form that cannot ignite or become gaseous/solid."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "bitterness"
	taste_mult = 1.5

/datum/reagent/iodine
	name = "Iodine"
	id = "iodine"
	description = "Commonly added to table salt as a nutrient. On its own it tastes far less pleasing."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "metal"

/datum/reagent/bromine
	name = "Bromine"
	id = "bromine"
	description = "A brownish liquid that's highly reactive. Useful for stopping free radicals, but not intended for human consumption."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "chemicals"

/datum/reagent/ash
	name = "Ash"
	id = "ash"
	description = "Supposedly phoenixes rise from these, but you've never seen it."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "ash"

/datum/reagent/acetone
	name = "Acetone"
	id = "acetone"
	description = "A slick, slightly carcinogenic liquid. Has a multitude of mundane uses in everyday life."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "acid"

/datum/reagent/saltpetre
	name = "Saltpetre"
	id = "saltpetre"
	description = "Volatile. Controversial. Third Thing."
	reagent_state = LIQUID
	color = "#60A584"
	taste_description = "cool salt"