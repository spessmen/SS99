/client/var/desired_velocity_x = 0
/client/var/desired_velocity_y = 0

/client/proc/checkMovement()
	if (mob)
		var/x,y

		if (mob.velocity_x != src.desired_velocity_x) x = src.desired_velocity_x
		else                                          x = mob.velocity_x

		if (mob.velocity_y != src.desired_velocity_y) y = src.desired_velocity_y
		else                                          y = mob.velocity_y

		mob.setVelocity(x, y)

/atom/movable/var/velocity_x = 0
/atom/movable/var/velocity_y = 0
/atom/movable/var/tmp/datum/looper/movement_looper

/atom/movable/proc/setVelocity(x = 0, y = 0)
	src.velocity_x = x
	src.velocity_y = y

	if (src.velocity_x == 0 && src.velocity_y == 0)
		if (src.movement_looper)
			// The reason for this 5 second delay is for cases where the velocity is immediately changed to a non-zero value.
			// Normally the looper would be stopped at that point, which would cause a small delay.
			spawn (50)
				if (src.velocity_x == 0 && src.velocity_y == 0) src.movement_looper.stop()
	else
		if (!src.movement_looper) src.movement_looper = new(1, src, "pixelMove")

		while (!src.movement_looper.start()) sleep

/atom/movable/proc/pixelMove()
	if (src.velocity_x != 0 || src.velocity_y != 0)
		var/sx                   = src.step_x
		var/sy                   = src.step_y
		var/sloc                 = src.loc

		var/vx                   = src.velocity_x
		var/vy                   = src.velocity_y

		var/dx                   = sx + vx
		var/dy                   = sy + vy

		var/turf/dloc            = sloc

		while (dx > world.icon_size)
			dloc                 = get_step(dloc, EAST)
			dx                   = dx - world.icon_size

		while (dx < 0)
			dloc                 = get_step(dloc, WEST)
			dx                   = dx + world.icon_size

		while (dy > world.icon_size)
			dloc                 = get_step(dloc, NORTH)
			dy                   = dy - world.icon_size

		while (dy < 0)
			dloc                 = get_step(dloc, SOUTH)
			dy                   = dy + world.icon_size

		if (dloc)
			var/dir              = 0

			if (vx > 0)          dir = dir | EAST
			else if (vx < 0)     dir = dir | WEST

			if (vy > 0)          dir = dir | NORTH
			else if (vy < 0)     dir = dir | SOUTH

			src.dir              = dir

			if (src.density)
				var/list/objects = obounds(src, vx, vy)

				for (var/atom/atom in objects)
					if (atom.density)
						return

			src.loc              = dloc
			src.step_x           = dx
			src.step_y           = dy