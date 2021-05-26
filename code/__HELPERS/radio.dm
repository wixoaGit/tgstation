/proc/sanitize_frequency(frequency, free = FALSE)
	. = round(frequency)
	if(free)
		. = CLAMP(frequency, MIN_FREE_FREQ, MAX_FREE_FREQ)
	else
		. = CLAMP(frequency, MIN_FREQ, MAX_FREQ)
	if(!(. % 2))
		. += 1

/proc/format_frequency(frequency)
	frequency = text2num(frequency)
	return "[round(frequency / 10)].[frequency % 10]"
