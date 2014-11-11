/obj/machinery/computer
	icon = 'icons/game/obj/machinery/computer.dmi'
	density = 1

/obj/machinery/computer/communications
	icon_state = "comm"

/obj/machinery/computer/communications/var
	datum/html_interface/nanotrasen/hi

/obj/machinery/computer/communications/New()
	. = ..()

	src.hi = new(src)

/obj/machinery/computer/communications/Click()
	hi.show(usr)