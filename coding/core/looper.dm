/datum/looper/var
	state = 0
	delay
	source
	procname
	arguments

/datum/looper/New(delay, source, procname, ...)
	if (args.len > 2)
		var/list/arguments = new/list()

		for (var/i = 3 to args.len)
			arguments.Add(args[i])

		src.arguments = arguments

	src.delay = max(world.tick_lag, delay)
	src.source = source
	src.procname = procname

/datum/looper/proc/start()
	if (src.state == 0)
		src.state = 2

		spawn (-1)
			while (src.state == 2)
				call(src.source, src.procname)(arglist(src.arguments))

				sleep (delay)

			src.state = 0

		return TRUE
	else
		return src.state == 2

/datum/looper/proc/stop()
	if (src.state == 2)
		src.state = 1
		return TRUE
	else
		return src.state == 0