/turf/floor
	icon = 'icons/game/turf/floors.dmi'
	icon_state = "floor"

/turf/wall
	icon = 'icons/game/turf/walls.dmi'
	density = 1
	opacity = 1

/turf/space
	icon = 'icons/game/turf/space.dmi'
	icon_state = "0"
	New()
		. = ..()
		icon_state = "[rand(0, 25)]"