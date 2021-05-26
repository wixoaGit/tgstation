#define json_load(FILE) (json_decode(file2text(FILE)))

GLOBAL_LIST(string_cache)
GLOBAL_VAR(string_filename_current_key)

/proc/strings(filename as text, key as text, directory = "strings")
	load_strings_file(filename, directory)
	if((filename in GLOB.string_cache) && (key in GLOB.string_cache[filename]))
		return GLOB.string_cache[filename][key]
	else
		CRASH("strings list not found: [directory]/[filename], index=[key]")

/proc/load_strings_file(filename, directory = "strings")
	GLOB.string_filename_current_key = filename
	if(filename in GLOB.string_cache)
		return

	if(!GLOB.string_cache)
		GLOB.string_cache = new

	if(fexists("[directory]/[filename]"))
		GLOB.string_cache[filename] = json_load("[directory]/[filename]")
	else
		CRASH("file not found: [directory]/[filename]")