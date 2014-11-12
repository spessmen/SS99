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

	HookManager.callHook("client", "onNew", src)

	. = ..()

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

// Global keyup and keydown handlers for clients.
/client/proc
	key_up(key, client/client)
		if (key == K_LEFT || key == K_RIGHT || key == K_UP || key == K_DOWN)
			if      (key == K_LEFT)  src.desired_dir = src.desired_dir &~ WEST
			else if (key == K_RIGHT) src.desired_dir = src.desired_dir &~ EAST
			else if (key == K_DOWN)  src.desired_dir = src.desired_dir &~ SOUTH
			else if (key == K_UP)    src.desired_dir = src.desired_dir &~ NORTH

			src.checkMovement()

	key_down(key, client/client)
		if (key == K_LEFT || key == K_RIGHT || key == K_UP || key == K_DOWN)
			if (key == K_LEFT)       src.desired_dir = src.desired_dir | WEST
			else if (key == K_RIGHT) src.desired_dir = src.desired_dir | EAST
			else if (key == K_DOWN)  src.desired_dir = src.desired_dir | SOUTH
			else if (key == K_UP)    src.desired_dir = src.desired_dir | NORTH
			else                     CRASH("Unknown key: [key].")

			src.checkMovement()