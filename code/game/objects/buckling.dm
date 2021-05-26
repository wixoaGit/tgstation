/atom/movable
	var/can_buckle = 0
	var/buckle_lying = -1
	var/buckle_requires_restraints = 0
	var/list/mob/living/buckled_mobs = null
	var/max_buckled_mobs = 1
	var/buckle_prevents_pull = FALSE

/atom/movable/proc/has_buckled_mobs()
	if(!buckled_mobs)
		return FALSE
	if(buckled_mobs.len)
		return TRUE