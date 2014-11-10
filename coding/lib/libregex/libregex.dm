#ifndef LIBREGEX_LIBRARY
	#define LIBREGEX_LIBRARY "libregex"
#endif

#ifndef LIBREGEX_LIBRARY_UNIX
	#define LIBREGEX_LIBRARY_UNIX "libregex"
#endif

proc
	regex_match(str, exp)
		var/params = call(world.system_type == MS_WINDOWS ? LIBREGEX_LIBRARY : LIBREGEX_LIBRARY_UNIX, "regex_match")(str, exp)
		return (params && new/match_results(params))

	regex_imatch(str, exp)
		var/params = call(world.system_type == MS_WINDOWS ? LIBREGEX_LIBRARY : LIBREGEX_LIBRARY_UNIX, "regex_imatch")(str, exp)
		return (params && new/match_results(params))

	regex_search(str, exp)
		var/params = call(world.system_type == MS_WINDOWS ? LIBREGEX_LIBRARY : LIBREGEX_LIBRARY_UNIX, "regex_search")(str, exp)
		return (params && new/match_results(params))

	regex_isearch(str, exp)
		var/params = call(world.system_type == MS_WINDOWS ? LIBREGEX_LIBRARY : LIBREGEX_LIBRARY_UNIX, "regex_isearch")(str, exp)
		return (params && new/match_results(params))

	regex_replace(str, exp, fmt)
		return call(world.system_type == MS_WINDOWS ? LIBREGEX_LIBRARY : LIBREGEX_LIBRARY_UNIX, "regex_replace")(str, exp, fmt)

	regex_ireplace(str, exp, fmt)
		return call(world.system_type == MS_WINDOWS ? LIBREGEX_LIBRARY : LIBREGEX_LIBRARY_UNIX, "regex_ireplace")(str,exp, fmt)