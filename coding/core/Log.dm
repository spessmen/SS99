var/datum/Log/Log = new

/datum/Log/proc/info(text)
	#ifdef LOG_AS_TEXT
	world.log << "\[[time2text(world.realtime, "YYYY-MM-DD")] [time2text(world.timeofday, "hh:mm:ss")]\] INFO: [text]"
	#else
	world.log << "\[[time2text(world.realtime, "YYYY-MM-DD")] [time2text(world.timeofday, "hh:mm:ss")]\] INFO: [text]<br />"
	#endif

/datum/Log/proc/warn(text)
	#ifdef LOG_AS_TEXT
	world.log << "\[[time2text(world.realtime, "YYYY-MM-DD")] [time2text(world.timeofday, "hh:mm:ss")]\] WARN: [text]"
	#else
	world.log << "<font color=\"#990000\">\[[time2text(world.realtime, "YYYY-MM-DD")] [time2text(world.timeofday, "hh:mm:ss")]\] WARN: [text]</font><br />"
	#endif

/datum/Log/proc/error(text)
	#ifdef LOG_AS_TEXT
	world.log << "\[[time2text(world.realtime, "YYYY-MM-DD")] [time2text(world.timeofday, "hh:mm:ss")]\] ERROR: [text]"
	#else
	world.log << "<font color=\"#FF0000\">\[[time2text(world.realtime, "YYYY-MM-DD")] [time2text(world.timeofday, "hh:mm:ss")]\] ERROR: [text]</font><br />"
	#endif