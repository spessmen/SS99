
// File:    world.dm
// Library: Forum_account.PixelMovement
// Author:  Forum_account
//
// Contents:
//   This file contains the global movement loop, some
//   other global things (variables), and other stuff.

// <EmpireModification>
/*
world
	tick_lag = 0.25
*/
// </EmpireModification>

var
	PixelMovement/PixelMovement = new()

PixelMovement
	var
		const
			EUCLIDEAN = 1
			BYOND = 2
			MANHATTAN = 3

		// tells the library what distance metric to use.
		distance = EUCLIDEAN

		// enables/disables the debugging statpanel. to enable
		// the movement trace feature, see _flags.dm.
		debug = 0

		tile_width = 32
		tile_height = 32

		tick_count = 0

	New()
		set_icon_size()

		..()

		spawn(world.tick_lag)
			movement_loop()

	proc
		// This is the global movement loop. It calls world.movement
		// every tick. If you want to change the behavior of the global
		// movement loop, override world.movement, not movement_loop.
		movement_loop()
			movement()
			spawn(world.tick_lag)
				movement_loop()

			tick_count += 1
			if(tick_count >= 1000)
				tick_count -= 1000

		movement()
			for(var/mob/m in world)
				m.check_loc()
				m.movement(tick_count)

		set_icon_size()

			var/icon_width = 0
			var/icon_height = 0

			if(isnum(world.icon_size))
				icon_width = world.icon_size
				icon_height = world.icon_size
			else
				var/p = findtext(world.icon_size, "x")
				icon_width = text2num(copytext(world.icon_size, 1, p))
				icon_height = text2num(copytext(world.icon_size, p + 1))

			// set the values used by the library
			tile_width = icon_width
			tile_height = icon_height

			// and make it work for isometric maps
			if(world.map_format == ISOMETRIC_MAP)
				if(tile_height > tile_width)
					tile_height = tile_width
