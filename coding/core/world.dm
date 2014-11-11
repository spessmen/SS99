/world/fps = 40
/world/map_format = SIDE_MAP

/world/New()
	Log.info("Starting SS99 v[VERSION]")

	. = ..()

	return .

/world/Del()
	return ..()