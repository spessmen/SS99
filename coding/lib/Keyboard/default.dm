
// File:    default.dm
// Library: Forum_account.Keyboard
// Author:  Forum_account
//
// Contents:
//   This file contains the default behavior for keyboard input
//   when the client's focus is set to the client. By default,
//   all events (key down, up, and repeat) trigger the client's
//   North(), South(), Center(), etc. procs.

client
	var
		// map keys to the client procs they call
		__default_action = list(
			"north" = "North",
			"south" = "South",
			"east" = "East",
			"west" = "West",
			"southeast" = "Southeast",
			"southwest" = "Southwest",
			"northeast" = "Northeast",
			"northwest" = "Northwest",
			"center" = "Center")

	// we have to define these procs here because clients don't
	// inherit from /datum.
	proc
		key_up(k, client/c)

		key_down(k, client/c)
			__default_action(k)

		#ifndef NO_KEY_REPEAT
		key_repeat(k, client/c)
			__default_action(k)
		#endif

		#ifndef NO_CLICK
		click(object, client/c)
		#endif

		__default_action(k)
			// if the key has a default action, trigger it
			if(k in __default_action)
				var/proc_name = __default_action[k]
				call(src, proc_name)()
