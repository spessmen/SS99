/datum/hooks/mob/proc/onLogin(mob/mob, client/client)
/datum/hooks/mob/proc/onLogout(mob/mob, client/client)

/mob/var/tmp/client/old_client

/mob/Login()
	. = ..()

	src.old_client = src.client

	HookManager.callHook("mob", "onLogin", src, src.old_client)

/mob/Logout()
	. = ..()

	HookManager.callHook("mob", "onLogout", src, src.old_client)

	src.old_client = null