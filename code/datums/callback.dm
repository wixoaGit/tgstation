/datum/callback
	var/object = null
	var/delegate
	var/list/arguments

/datum/callback/New(thingtocall, proctocall/*, ...*/)
	if (thingtocall)
		object = thingtocall
	delegate = proctocall
	if (length(args) > 2)
		arguments = args.Copy(3)
	//if(usr)
	//	user = WEAKREF(usr)

/world/proc/ImmediateInvokeAsync(thingtocall, proctocall, ...)
	set waitfor = FALSE

	if (!thingtocall)
		return

	var/list/calling_arguments = length(args) > 2 ? args.Copy(3) : null

	if (thingtocall == GLOBAL_PROC)
		call(proctocall)(arglist(calling_arguments))
	else
		call(thingtocall, proctocall)(arglist(calling_arguments))

/datum/callback/proc/Invoke(/*...*/)
	if (!object)
		return
		
	var/list/calling_arguments = arguments
	if (length(args))
		if (length(arguments))
			calling_arguments = calling_arguments + args
		else
			calling_arguments = args
	//if(datum_flags & DF_VAR_EDITED)
	//	return WrapAdminProcCall(object, delegate, calling_arguments)
	if (object == GLOBAL_PROC)
		return call(delegate)(arglist(calling_arguments))
	return call(object, delegate)(arglist(calling_arguments))

/datum/callback/proc/InvokeAsync(...)
	set waitfor = FALSE

	//(!usr)
	//	var/datum/weakref/W = user
	//	if(W)
	//		var/mob/M = W.resolve()
	//		if(M)
	//			if (length(args))
	//				return world.PushUsr(arglist(list(M, src) + args))
	//			return world.PushUsr(M, src)

	if (!object)
		return

	var/list/calling_arguments = arguments
	if (length(args))
		if (length(arguments))
			calling_arguments = calling_arguments + args
		else
			calling_arguments = args
	//if(datum_flags & DF_VAR_EDITED)
	//	return WrapAdminProcCall(object, delegate, calling_arguments)
	if (object == GLOBAL_PROC)
		return call(delegate)(arglist(calling_arguments))
	return call(object, delegate)(arglist(calling_arguments))