/client/var/desired_dir = 0
/client/var/desired_velocity = 0

/client/proc/checkMovement()
	if (mob)
		if (src.desired_dir)
			mob.setVelocityAndDirection(10, src.desired_dir)
		else
			mob.stopMovement()

/atom/movable/var/velocity = 0
/atom/movable/var/tmp/datum/looper/movement_looper

/atom/movable/proc/setVelocityAndDirection(velocity, direction)
	walk(src, direction, 1, step_size * (velocity / 10))

/atom/movable/proc/stopMovement()
	src.setVelocityAndDirection(0, 0)