#define ARMORID "armor-[melee]-[bullet]-[laser]-[energy]-[bomb]-[bio]-[rad]-[fire]-[acid]-[magic]"

/proc/getArmor(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 0, acid = 0, magic = 0)
  //. = locate(ARMORID)
  if (!.)
    . = new /datum/armor(melee, bullet, laser, energy, bomb, bio, rad, fire, acid, magic)

/datum/armor
  datum_flags = DF_USE_TAG
  var/melee
  var/bullet
  var/laser
  var/energy
  var/bomb
  var/bio
  var/rad
  var/fire
  var/acid
  var/magic

/datum/armor/New(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 0, acid = 0, magic = 0)
  src.melee = melee
  src.bullet = bullet
  src.laser = laser
  src.energy = energy
  src.bomb = bomb
  src.bio = bio
  src.rad = rad
  src.fire = fire
  src.acid = acid
  src.magic = magic
  tag = ARMORID

/datum/armor/proc/setRating(melee, bullet, laser, energy, bomb, bio, rad, fire, acid, magic)
  return getArmor((isnull(melee) ? src.melee : melee),\
                  (isnull(bullet) ? src.bullet : bullet),\
                  (isnull(laser) ? src.laser : laser),\
                  (isnull(energy) ? src.energy : energy),\
                  (isnull(bomb) ? src.bomb : bomb),\
                  (isnull(bio) ? src.bio : bio),\
                  (isnull(rad) ? src.rad : rad),\
                  (isnull(fire) ? src.fire : fire),\
                  (isnull(acid) ? src.acid : acid),\
				  (isnull(magic) ? src.magic : magic))

/datum/armor/proc/getRating(rating)
  return vars[rating]

#undef ARMORID