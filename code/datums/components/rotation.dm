#define ROTATION_ALTCLICK			(1<<0)
#define ROTATION_WRENCH				(1<<1)
#define ROTATION_VERBS				(1<<2)
#define ROTATION_COUNTERCLOCKWISE	(1<<3)
#define ROTATION_CLOCKWISE			(1<<4)
#define ROTATION_FLIP				(1<<5)

/datum/component/simple_rotation
	var/datum/callback/can_user_rotate
	var/datum/callback/can_be_rotated
	var/datum/callback/after_rotation

	var/rotation_flags = NONE
	var/default_rotation_direction = ROTATION_CLOCKWISE

/datum/component/simple_rotation/Initialize(rotation_flags = NONE ,can_user_rotate,can_be_rotated,after_rotation)
	if(!ismovableatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.rotation_flags = rotation_flags

	if(can_user_rotate)
		src.can_user_rotate = can_user_rotate
	else
		src.can_user_rotate = CALLBACK(src,.proc/default_can_user_rotate)

	if(can_be_rotated)
		src.can_be_rotated = can_be_rotated
	else
		src.can_be_rotated = CALLBACK(src,.proc/default_can_be_rotated)

	if(after_rotation)
		src.after_rotation = after_rotation
	else
		src.after_rotation = CALLBACK(src,.proc/default_after_rotation)

	if(src.rotation_flags & ROTATION_FLIP)
		default_rotation_direction = ROTATION_FLIP
	if(src.rotation_flags & ROTATION_COUNTERCLOCKWISE)
		default_rotation_direction = ROTATION_COUNTERCLOCKWISE
	if(src.rotation_flags & ROTATION_CLOCKWISE)
		default_rotation_direction = ROTATION_CLOCKWISE

	if(src.rotation_flags & ROTATION_ALTCLICK)
		RegisterSignal(parent, COMSIG_CLICK_ALT, .proc/HandRot)
		RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/ExamineMessage)
	if(src.rotation_flags & ROTATION_WRENCH)
		RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/WrenchRot)

	if(src.rotation_flags & ROTATION_VERBS)
		var/atom/movable/AM = parent
		if(src.rotation_flags & ROTATION_FLIP)
			AM.verbs += /atom/movable/proc/simple_rotate_flip
		if(src.rotation_flags & ROTATION_CLOCKWISE)
			AM.verbs += /atom/movable/proc/simple_rotate_clockwise
		if(src.rotation_flags & ROTATION_COUNTERCLOCKWISE)
			AM.verbs += /atom/movable/proc/simple_rotate_counterclockwise

/datum/component/simple_rotation/proc/remove_verbs()
	if(parent)
		var/atom/movable/AM = parent
		AM.verbs -= /atom/movable/proc/simple_rotate_flip
		AM.verbs -= /atom/movable/proc/simple_rotate_clockwise
		AM.verbs -= /atom/movable/proc/simple_rotate_counterclockwise

/datum/component/simple_rotation/Destroy()
	remove_verbs()
	QDEL_NULL(can_user_rotate)
	QDEL_NULL(can_be_rotated)
	QDEL_NULL(after_rotation)
	. = ..()

/datum/component/simple_rotation/RemoveComponent()
	remove_verbs()
	. = ..()

/datum/component/simple_rotation/proc/ExamineMessage(datum/source, mob/user)
	if(rotation_flags & ROTATION_ALTCLICK)
		to_chat(user, "<span class='notice'>Alt-click to rotate it clockwise.</span>")

/datum/component/simple_rotation/proc/HandRot(datum/source, mob/user, rotation = default_rotation_direction)
	if(!can_be_rotated.Invoke(user, rotation) || !can_user_rotate.Invoke(user, rotation))
		return
	BaseRot(user, rotation)

/datum/component/simple_rotation/proc/WrenchRot(datum/source, obj/item/I, mob/living/user)
	if(!can_be_rotated.Invoke(user,default_rotation_direction) || !can_user_rotate.Invoke(user,default_rotation_direction))
		return
	if(I.tool_behaviour == TOOL_WRENCH)
		BaseRot(user,default_rotation_direction)
		return COMPONENT_NO_AFTERATTACK

/datum/component/simple_rotation/proc/BaseRot(mob/user,rotation_type)
	var/atom/movable/AM = parent
	var/rot_degree
	switch(rotation_type)
		//if(ROTATION_CLOCKWISE)
		if(16)//not_actual
			rot_degree = -90
		//if(ROTATION_COUNTERCLOCKWISE)
		if(8)//not_actual
			rot_degree = 90
		//if(ROTATION_FLIP)
		if(32)//not_actual
			rot_degree = 180
	AM.setDir(turn(AM.dir,rot_degree))
	after_rotation.Invoke(user,rotation_type)

/datum/component/simple_rotation/proc/default_can_user_rotate(mob/living/user, rotation_type)
	if(!istype(user) || !user.canUseTopic(parent, BE_CLOSE, NO_DEXTERY))
		return FALSE
	return TRUE

/datum/component/simple_rotation/proc/default_can_be_rotated(mob/user, rotation_type)
	var/atom/movable/AM = parent
	return !AM.anchored

/datum/component/simple_rotation/proc/default_after_rotation(mob/user, rotation_type)
	to_chat(user,"<span class='notice'>You [rotation_type == ROTATION_FLIP ? "flip" : "rotate"] [parent].</span>")

/atom/movable/proc/simple_rotate_clockwise()
	set name = "Rotate Clockwise"
	set category = "Object"
	//set src in oview(1)
	GET_COMPONENT(rotcomp,/datum/component/simple_rotation)
	if(rotcomp)
		rotcomp.HandRot(null,usr,ROTATION_CLOCKWISE)

/atom/movable/proc/simple_rotate_counterclockwise()
	set name = "Rotate Counter-Clockwise"
	set category = "Object"
	//set src in oview(1)
	GET_COMPONENT(rotcomp,/datum/component/simple_rotation)
	if(rotcomp)
		rotcomp.HandRot(null,usr,ROTATION_COUNTERCLOCKWISE)

/atom/movable/proc/simple_rotate_flip()
	set name = "Flip"
	set category = "Object"
	//set src in oview(1)
	GET_COMPONENT(rotcomp,/datum/component/simple_rotation)
	if(rotcomp)
		rotcomp.HandRot(null,usr,ROTATION_FLIP)