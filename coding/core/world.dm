/world/fps = 40

/world/New()
	Log.info("Starting SS99 v[VERSION]")
	. = ..()

	return .

/world/Del()
	return ..()