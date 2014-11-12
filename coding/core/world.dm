/datum/hooks/world/proc/onNew()
/datum/hooks/world/proc/onDel()
/datum/hooks/world/proc/onReboot()

/world/fps = 50 // 50 fps -> 0.2 tick_lag
/world/map_format = SIDE_MAP
/world/cache_lifespan = 0
/world/view = 7

/world/New()
	Log.info("Starting SS99 v[VERSION]")

	// Global hooks. To define your own, override a world/onNew hook and call HookManager.addType
	HookManager.addType("world", /datum/hooks/world)
	HookManager.addType("client", /datum/hooks/client)
	HookManager.addType("mob", /datum/hooks/mob)

	. = ..()

	HookManager.callHook("world", "onNew")

	return .

/world/Del()
	HookManager.callHook("world", "onDel")

	return ..()

/world/Reboot(cause)
	HookManager.callHook("world", "onReboot", cause)

	return ..()