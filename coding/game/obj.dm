/obj/machinery/computer
	icon = 'icons/game/obj/machinery/computer.dmi'
	density = 1

/obj/machinery/computer/communications
	icon_state = "comm"

/obj/machinery/computer/communications/var
	datum/html_interface/nanotrasen/hi

/obj/machinery/computer/communications/New()
	. = ..()

	src.hi = new(src, "Nanotrasen Communications Terminal", 500, 300)
	spawn src.updateInterface()

// Loop intended to update the content so that the user sees the red/green eye update when moving closer or farther away from the terminal.
/obj/machinery/computer/communications/proc/updateInterface()
	spawn
		while (1)
			src.hi.updateContent("content", "<p>Select an action from the list below.</p><div><a href=\"byond://\" class=\"btn btn-default\">Call the shuttle</a></div>")
			sleep(10)

/obj/machinery/computer/communications/onClick()
	hi.show(usr)