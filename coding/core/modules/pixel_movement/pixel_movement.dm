/client/var/desired_dir = 0
/client/var/desired_velocity = 0

/client/proc/checkMovement()
	if (mob)
		if (src.desired_dir)
			mob.setVelocityAndDirection(1.5, src.desired_dir)
		else
			mob.stopMovement()

/atom/movable/var/velocity = 0
/atom/movable/var/tmp/datum/looper/movement_looper

/atom/movable/proc/setVelocityAndDirection(velocity, direction)
	walk(src, direction, max(world.tick_lag, velocity != 0 ? 1 / velocity : 0), step_size)

/atom/movable/proc/stopMovement()
	src.setVelocityAndDirection(0, 0)