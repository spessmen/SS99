var/datum/HookManager/HookManager = new

/datum/HookManager/var
	list/hooks = new/list()

/datum/HookManager/proc/addType(name, baseType)
	var
		datum/hooks/hook
		list/lst

	for (var/type in typesof(baseType))
		if (type != baseType)
			hook    = new type

			if (hook.parent_type != baseType)
				Log.error("HookManager: Skipping [type] as it contains subtypes.")
			else
				if (!hooks[name]) hooks[name] = new/list()

				lst = hooks[name]
				lst.Add(new type())

/datum/HookManager/proc/callHook(name, procname, ...)
	if (HookManager.hooks[name])
		var/list/arguments

		if (args.len > 2) arguments = args.Copy(3)

		for (var/datum/hooks/hook in HookManager.hooks[name]) call(hook, procname)(arglist(arguments))

/datum/hooks