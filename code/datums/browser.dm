/datum/browser
	var/mob/user
	var/title
	var/window_id
	var/width = 0
	var/height = 0
	var/atom/ref = null
	var/window_options = "can_close=1;can_minimize=1;can_maximize=0;can_resize=1;titlebar=1;"
	//var/stylesheets[0]
	//var/scripts[0]
	var/list/stylesheets = list()//not_actual
	var/list/scripts = list()//not_actual
	var/title_image
	var/head_elements
	var/body_elements
	var/head_content = ""
	var/content = ""

/datum/browser/New(nuser, nwindow_id, ntitle = 0, nwidth = 0, nheight = 0, var/atom/nref = null)

	user = nuser
	window_id = nwindow_id
	if (ntitle)
		title = format_text(ntitle)
	if (nwidth)
		width = nwidth
	if (nheight)
		height = nheight
	if (nref)
		ref = nref
	add_stylesheet("common", 'html/browser/common.css')

/datum/browser/proc/add_head_content(nhead_content)
	head_content = nhead_content

/datum/browser/proc/set_window_options(nwindow_options)
	window_options = nwindow_options

/datum/browser/proc/set_title_image(ntitle_image)
	title_image = ntitle_image

/datum/browser/proc/add_stylesheet(name, file)
	stylesheets["[ckey(name)].css"] = file
	register_asset("[ckey(name)].css", file)

/datum/browser/proc/add_script(name, file)
	scripts["[ckey(name)].js"] = file
	register_asset("[ckey(name)].js", file)

/datum/browser/proc/set_content(ncontent)
	content = ncontent

/datum/browser/proc/add_content(ncontent)
	content += ncontent

/datum/browser/proc/get_header()
	var/file
	for (file in stylesheets)
		head_content += "<link rel='stylesheet' type='text/css' href='[file]'>"

	for (file in scripts)
		head_content += "<script type='text/javascript' src='[file]'></script>"

	var/title_attributes = "class='uiTitle'"
	if (title_image)
		title_attributes = "class='uiTitle icon' style='background-image: url([title_image]);'"

	return {"<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<head>
		[head_content]
	</head>
	<body scroll=auto>
		<div class='uiWrapper'>
			[title ? "<div class='uiTitleWrapper'><div [title_attributes]><tt>[title]</tt></div></div>" : ""]
			<div class='uiContent'>
	"}

/datum/browser/proc/get_footer()
	return {"
			</div>
		</div>
	</body>
</html>"}

/datum/browser/proc/get_content()
	return {"
	[get_header()]
	[content]
	[get_footer()]
	"}

/datum/browser/proc/open(use_onclose = TRUE)
	if(isnull(window_id))
		WARNING("Browser [title] tried to open with a null ID")
		to_chat(user, "<span class='userdanger'>The [title] browser you tried to open failed a sanity check! Please report this on github!</span>")
		return
	var/window_size = ""
	if (width && height)
		window_size = "size=[width]x[height];"
	if (stylesheets.len)
		send_asset_list(user, stylesheets, verify=FALSE)
	if (scripts.len)
		send_asset_list(user, scripts, verify=FALSE)
	user << browse(get_content(), "window=[window_id];[window_size][window_options]")
	if (use_onclose)
		setup_onclose()

/datum/browser/proc/setup_onclose()
	set waitfor = 0
	//for (var/i in 1 to 10)
	//	if (user && winexists(user, window_id))
	//		onclose(user, window_id, ref)
	//		break

/datum/browser/proc/close()
	if(!isnull(window_id))
		user << browse(null, "window=[window_id]")
	else
		WARNING("Browser [title] tried to close with a null ID")

/proc/onclose(mob/user, windowid, atom/ref=null)
	if(!user.client)
		return
	var/param = "null"
	if(ref)
		param = "[REF(ref)]"

	winset(user, windowid, "on-close=\".windowclose [param]\"")

/client/verb/windowclose(atomref as text)
	set hidden = 1
	set name = ".windowclose"

	if(atomref!="null")
		var/hsrc = locate(atomref)
		var/href = "close=1"
		if(hsrc)
			usr = src.mob
			src.Topic(href, params2list(href), hsrc)
			return

	if(src && src.mob)
		src.mob.unset_machine()