/datum/hooks/client/proc/onNew(client/client)
/datum/hooks/client/proc/onDel(client/client)

/client/var
	// core/modules/html_interface: last known position of previous window
	hi_last_pos

/client/New()
	spawn (-1)
		// Preload the HTML interface. This needs to be done due to BYOND bug http://www.byond.com/forum/?post=1487244
		var/datum/html_interface/hi
		for (var/type in typesof(/datum/html_interface))
			hi = new type(null)
			hi.sendResources(src)

/*
proc
		set_macros()
			// this should get us the list of all macro sets that
			// are used by all windows in the interface.
			var/macros = params2list(winget(src, null, "macro"))

			// if the keys var is a string, split it into key names
			if(istext(keys))
				// <SS99>
				/*
				keys = split(keys, "|")
				*/
				keys = CO.split(keys, "|", FALSE)
				// </SS99>

			// define three macros (key press, release, and repeat)
			// for every key in every macro set.
			for(var/m in macros)
				for(var/k in keys)

					// It's possible to get empty strings in the list if the keys
					// var was set to ARROWS+NUMBERS, there may be "||" in the string
					// which turns into "" when split.
					if(!k) continue

					// By default the key isn't being held
					keys[k] = 0

					var/escaped = list2params(list("[k]"))

					// Create the necessary macros for this key.
					winset(src, "[m][k]Down", "parent=[m];name=[escaped];command=KeyDown+[escaped]")
					winset(src, "[m][k]Up", "parent=[m];name=[escaped]+UP;command=KeyUp+[escaped]")

					#ifndef NO_KEY_REPEAT
					winset(src, "[m][k]Repeat", "parent=[m];name=[escaped]+REP;command=KeyRepeat+\"[escaped]\"")
					#endif
*/

	HookManager.callHook("client", "onNew", src)

	. = ..()

	spawn (-1)
		var/str
		for (var/dir in CO.CARDINAL_DIRECTIONS)
			str = CO.directionToString(dir)

			winset(src, "macro|[str]|down", "parent=macro;name=[CO.toProperCase(str)];command=\".move [dir] 1\"")
			winset(src, "macro|[str]|up", "parent=macro;name=[CO.toProperCase(str)]+UP;command=\".move [dir] 0\"")

	return .

/client/Del()
	HookManager.callHook("client", "onDel", src)

	return ..()

// Disable the built-in macros for movement.
// Even if the macros are disabled in the skin, this must be overruled to prevent the built-in commands (such as ".north") from working.
/client/North()     return
/client/South()     return
/client/East()      return
/client/West()      return
/client/Northeast() return
/client/Northwest() return
/client/Southeast() return
/client/Southwest() return
/client/Center()    return

// Required to bypass a BYOND bug that causes .winset to not work on the client when called from an on-close event on a window element.
/client/verb/_swinset(var/x as text)
	set name = ".swinset"
	set hidden = 1
	winset(src, null, x)

/client/verb/move(var/dir as num, var/on as num)
	set name = ".move"
	set instant = 1

	if (on)
		switch (dir)
			if (WEST)  src.desired_dir = src.desired_dir | WEST
			if (EAST)  src.desired_dir = src.desired_dir | EAST
			if (SOUTH) src.desired_dir = src.desired_dir | SOUTH
			if (NORTH) src.desired_dir = src.desired_dir | NORTH
	else
		switch (dir)
			if (WEST)  src.desired_dir = src.desired_dir &~ WEST
			if (EAST)  src.desired_dir = src.desired_dir &~ EAST
			if (SOUTH) src.desired_dir = src.desired_dir &~ SOUTH
			if (NORTH) src.desired_dir = src.desired_dir &~ NORTH

	src.checkMovement()