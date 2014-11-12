/world/fps = 50 // 50 fps -> 0.2 tick_lag
/world/map_format = SIDE_MAP
/world/cache_lifespan = 0

/world/New()
	Log.info("Starting SS99 v[VERSION]")

	. = ..()

	return .

/world/Del()
	return ..()