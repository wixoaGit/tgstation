/proc/sanitize_simple(t,list/repl_chars = list("\n"="#","\t"="#"))
	for(var/char in repl_chars)
		var/index = findtext(t, char)
		while(index)
			t = copytext(t, 1, index) + repl_chars[char] + copytext(t, index+1)
			index = findtext(t, char, index+1)
	return t

/proc/sanitize_filename(t)
	return sanitize_simple(t, list("\n"="", "\t"="", "/"="", "\\"="", "?"="", "%"="", "*"="", ":"="", "|"="", "\""="", "<"="", ">"=""))

/proc/sanitize(t,list/repl_chars = null)
	return html_encode(sanitize_simple(t,repl_chars))

/proc/reject_bad_text(text, max_length=512)
	if(length(text) > max_length)
		return
	var/non_whitespace = 0
	for(var/i=1, i<=length(text), i++)
		//switch(text2ascii(text,i))
		//	if(62,60,92,47)
		//		return
		//	if(127 to 255)
		//		return
		//	if(0 to 31)
		//		return
		//	if(32)
		//		continue
		//	else
		//		non_whitespace = 1
		//not_actual
		var/t2a = text2ascii(text, i)
		if (t2a == 62 || t2a == 60 || t2a == 92 || t2a == 47 || (t2a >= 127 && t2a <= 255) || (t2a >= 0 && t2a <= 31))
			return
		else if (t2a == 32)
			continue
		else
			non_whitespace = 1
	if(non_whitespace)
		return text

/proc/stripped_input(mob/user, message = "", title = "", default = "", max_length=MAX_MESSAGE_LEN, no_trim=FALSE)
	var/name = input(user, message, title, default) as text|null
	if(no_trim)
		return copytext(html_encode(name), 1, max_length)
	else
		return trim(html_encode(name), max_length)

/proc/stripped_multiline_input(mob/user, message = "", title = "", default = "", max_length=MAX_MESSAGE_LEN, no_trim=FALSE)
	var/name = input(user, message, title, default) as message|null
	if(no_trim)
		return copytext(html_encode(name), 1, max_length)
	else
		return trim(html_encode(name), max_length)

/proc/reject_bad_name(t_in, allow_numbers=0, max_length=MAX_NAME_LEN)
	if(!t_in || length(t_in) > max_length)
		return

	//var/number_of_alphanumeric	= 0
	//var/last_char_group			= 0
	//var/t_out = ""

	//for(var/i=1, i<=length(t_in), i++)
	//	var/ascii_char = text2ascii(t_in,i)
	//	switch(ascii_char)
	//		if(65 to 90)
	//			t_out += ascii2text(ascii_char)
	//			number_of_alphanumeric++
	//			last_char_group = 4

	//		if(97 to 122)
	//			if(last_char_group<2)
	//				t_out += ascii2text(ascii_char-32)
	//			else
	//				t_out += ascii2text(ascii_char)
	//			number_of_alphanumeric++
	//			last_char_group = 4

	//		if(48 to 57)
	//			if(!last_char_group)
	//				continue
	//			if(!allow_numbers)
	//				continue
	//			t_out += ascii2text(ascii_char)
	//			number_of_alphanumeric++
	//			last_char_group = 3

	//		if(39,45,46)
	//			if(!last_char_group)
	//				continue
	//			t_out += ascii2text(ascii_char)
	//			last_char_group = 2

	//		if(126,124,64,58,35,36,37,38,42,43)
	//			if(!last_char_group)
	//				continue
	//			if(!allow_numbers)
	//				continue
	//			t_out += ascii2text(ascii_char)
	//			last_char_group = 2

	//		if(32)
	//			if(last_char_group <= 1)
	//				continue
	//			t_out += ascii2text(ascii_char)
	//			last_char_group = 1
	//		else
	//			return

	//if(number_of_alphanumeric < 2)
	//	return

	//if(last_char_group == 1)
	//	t_out = copytext(t_out,1,length(t_out))

	//for(var/bad_name in list("space","floor","wall","r-wall","monkey","unknown","inactive ai"))
	//	if(cmptext(t_out,bad_name))
	//		return

	//return t_out
	return t_in//not_actual

/proc/dd_hasprefix(text, prefix)
	var/start = 1
	var/end = length(prefix) + 1
	return findtext(text, prefix, start, end)

/proc/add_zero(t, u)
	while (length(t) < u)
		t = "0[t]"
	return t

/proc/add_lspace(t, u)
	while(length(t) < u)
		t = " [t]"
	return t

/proc/add_tspace(t, u)
	while(length(t) < u)
		t = "[t] "
	return t

/proc/trim_left(text)
	for (var/i = 1 to length(text))
		if (text2ascii(text, i) > 32)
			return copytext(text, i)
	return ""

/proc/trim_right(text)
	for (var/i = length(text), i > 0, i--)
		if (text2ascii(text, i) > 32)
			return copytext(text, 1, i + 1)

	return ""

/proc/trim(text, max_length)
	if(max_length)
		text = copytext(text, 1, max_length)
	return trim_left(trim_right(text))

/proc/capitalize(t as text)
	return uppertext(copytext(t, 1, 2)) + copytext(t, 2)

GLOBAL_LIST_INIT(zero_character_only, list("0"))
GLOBAL_LIST_INIT(hex_characters, list("0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"))
GLOBAL_LIST_INIT(alphabet, list("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"))
GLOBAL_LIST_INIT(binary, list("0","1"))
/proc/random_string(length, list/characters)
	. = ""
	for(var/i=1, i<=length, i++)
		. += pick(characters)

/proc/repeat_string(times, string="")
	. = ""
	for(var/i=1, i<=times, i++)
		. += string

/proc/random_short_color()
	return random_string(3, GLOB.hex_characters)

/proc/findchar(haystack, needles, start=1, end=0)
	var/temp
	var/len = length(needles)
	for(var/i=1, i<=len, i++)
		temp = findtextEx(haystack, ascii2text(text2ascii(needles,i)), start, end)
		if(temp)
			end = temp
	return end

/proc/apply_text_macros(string)
	var/next_backslash = findtext(string, "\\")
	if(!next_backslash)
		return string

	var/leng = length(string)

	var/next_space = findtext(string, " ", next_backslash + 1)
	if(!next_space)
		next_space = leng - next_backslash

	if(!next_space)
		return string

	var/base = next_backslash == 1 ? "" : copytext(string, 1, next_backslash)
	var/macro = lowertext(copytext(string, next_backslash + 1, next_space))
	var/rest = next_backslash > leng ? "" : copytext(string, next_space + 1)

	//switch(macro)
	//	if("the")
	//		rest = text("\the []", rest)
	//	if("a")
	//		rest = text("\a []", rest)
	//	if("an")
	//		rest = text("\an []", rest)
	//	if("proper")
	//		rest = text("\proper []", rest)
	//	if("improper")
	//		rest = text("\improper []", rest)
	//	if("roman")
	//		rest = text("\roman []", rest)
	//	if("th")
	//		base = text("[]\th", rest)
	//	if("s")
	//		base = text("[]\s", rest)
	//	if("he")
	//		base = text("[]\he", rest)
	//	if("she")
	//		base = text("[]\she", rest)
	//	if("his")
	//		base = text("[]\his", rest)
	//	if("himself")
	//		base = text("[]\himself", rest)
	//	if("herself")
	//		base = text("[]\herself", rest)
	//	if("hers")
	//		base = text("[]\hers", rest)

	. = base
	//if(rest)
	//	. += .(rest)