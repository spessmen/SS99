/client/var
	// core/modules/html_interface: last known position of previous window
	hi_last_pos

/client/New()
	. = ..()

	spawn
		// Preload the HTML interface. This needs to be done due to BYOND bug http://www.byond.com/forum/?post=1487244
		var/datum/html_interface/hi
		for (var/type in typesof(/datum/html_interface))
			hi = new type(null)
			hi.sendResources(src)

	return .

/client/Del()
	return ..()

// Required to bypass a BYOND bug that causes .winset to not work on the client when called from an on-close event on a window element.
/client/verb/_swinset(var/x as text)
	set name = ".swinset"
	set hidden = 1
	winset(src, null, x)