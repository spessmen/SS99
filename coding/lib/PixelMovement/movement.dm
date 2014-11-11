
// File:    movement.dm
// Library: Forum_account.PixelMovement
// Author:  Forum_account
//
// Contents:
//   This file contains the default behavior for a mob's movement
//   in our pixel movement system. The actual movement and collision
//   detection are handled in pixel-movement.dm. This file handles
//   the movement behavior - what the keys do, how the mob speeds
//   up and slows down, etc.

var
	const
		VERTICAL = 64

		JUMPING = "jumping"
		STANDING = "standing"
		MOVING = "moving"

mob
	var
		vel_x = 0
		vel_y = 0

		#ifndef TWO_DIMENSIONAL
		vel_z = 0
		#endif

		on_ground = 0
		on_left = 0
		on_right = 0
		on_top = 0
		on_bottom = 0

		base_state = ""

		last_x = -1
		last_y = -1
		last_z = -1

		move_speed = 5

		accel = 1
		decel = 1

		#ifndef TWO_DIMENSIONAL
		gravity = 1
		fall_speed = 20
		jump_speed = 8
		#endif

		moved = 0

	proc
		bump(atom/a, d)

			#ifdef LIBRARY_DEBUG
			if(trace) trace.event("[world.time]: bump: a = [a] (\ref[a]), d = [d]")
			#endif

			if(d == EAST || d == WEST)
				vel_x = 0
			else if(d == NORTH || d == SOUTH)
				vel_y = 0
			#ifndef TWO_DIMENSIONAL
			if(d == VERTICAL)
				vel_z = 0

			/*
			// only jump if we bumped a wall, not when we bump the ground
			else if(destination || path)
				if(can_jump())
					jump()
			*/
			#endif

		#ifndef TWO_DIMENSIONAL
		can_jump()
			return on_ground

		jump()

			#ifdef LIBRARY_DEBUG
			if(trace) trace.event("[world.time]: jump:")
			#endif

			vel_z = jump_speed

		gravity()

			#ifdef LIBRARY_DEBUG
			if(trace) trace.event("[world.time]: gravity:")
			#endif

			if(on_ground) return

			vel_z -= gravity
			if(vel_z < -fall_speed)
				vel_z = -fall_speed
		#endif

		move(d)

			#ifdef LIBRARY_DEBUG
			if(trace) trace.event("[world.time]: move: d = [d]")
			#endif

			moved = d

			// We'll only enforce the overall velocity restriction if
			// this acceleration will put you over the limit. If you were
			// over the limit before the call to move, we don't bother
			// enforcing the limit.
			var/limit_speed = 0
			if(vel_x * vel_x + vel_y * vel_y <= move_speed * move_speed + 1)
				limit_speed = 1

			if(d & EAST)
				if(vel_x < move_speed)
					vel_x += accel
					if(vel_x > move_speed)
						vel_x = move_speed
			if(d & WEST)
				if(vel_x > -move_speed)
					vel_x -= accel
					if(vel_x < -move_speed)
						vel_x = -move_speed
			if(d & NORTH)
				if(vel_y < move_speed)
					vel_y += accel
					if(vel_y > move_speed)
						vel_y = move_speed
			if(d & SOUTH)
				if(vel_y > -move_speed)
					vel_y -= accel
					if(vel_y < -move_speed)
						vel_y = -move_speed

			if(limit_speed)
				var/len = sqrt(vel_x * vel_x + vel_y * vel_y)
				if(len > move_speed)
					vel_x = move_speed * vel_x / len
					vel_y = move_speed * vel_y / len

		set_state()
			var/base = base_state ? "[base_state]-" : ""
			var/new_state = ""

			// in 2D mode we don't need to check for a jumping state
			#ifdef TWO_DIMENSIONAL
			if(!moved)
				new_state = base + STANDING

			#else
			if(!on_ground)
				new_state = base + JUMPING
			else if(!moved)
				new_state = base + STANDING
			#endif

			else
				new_state = base + MOVING

			icon_state = new_state

		check_loc()
			if(x != last_x || y != last_y || z != last_z)

				#ifdef TWO_DIMENSIONAL
				set_pos(x * PixelMovement.tile_width, y * PixelMovement.tile_height, 0, z)

				#else
				var/turf/t = loc
				set_pos(x * PixelMovement.tile_width, y * PixelMovement.tile_height, t ? t.pz + t.pdepth : 0, z)
				#endif

		// This proc is automatically called every tick. It checks the
		// mob's current situation and keyboard input and calls a proc
		// to take the appropriate action (jump, move, climb).
		movement(t)
			#ifdef LIBRARY_DEBUG
			if(trace) trace.event("[world.time]: start movement:")
			#endif
			// if you don't have a location you're not on the map so we don't
			// need to worry about movement.
			if(!loc)
				#ifdef LIBRARY_DEBUG
				if(trace) trace.event("[world.time]: end movement:")
				#endif
				return

			// This sets the on_ground, on_ceiling, on_left, and on_right flags.
			set_flags()

			#ifndef TWO_DIMENSIONAL
			// apply the effect of gravity
			gravity()
			#endif

			// handle the movement action. This will handle the automatic behavior
			// that is triggered by calling move_to or move_towards. If the mob has
			// a client connected (and neither move_to/towards was called) keyboard
			// input will be processed.
			action(t)

			// set the mob's icon state
			set_state()

			#ifdef TWO_DIMENSIONAL
			// perform the movement
			pixel_move(vel_x, vel_y)

			#else
			// perform the movement
			pixel_move(vel_x, vel_y, vel_z)
			#endif

			#ifdef LIBRARY_DEBUG
			if(trace) trace.event("[world.time]: end movement:")
			#endif

		// The action proc is called by the mob's default movement proc. It doesn't do
		// anything new, it just splits up the code that was in the movement proc. This
		// is useful because the movement proc was quite long and this also lets you
		// override part of the mob's movement behavior without overriding it all. The
		// movement proc's default behavior calls gravity, set_flags, action, set_state,
		// and pixel_move. If you want to change just the part that is now action, you
		// used to have to override movement and remember to call gravity, set_flags,
		// set_state, and pixel_move. Now you can just override action.
		//
		// To be clear, there are still cases where you'd want to override movement. If
		// you want to create a bullet which travels in a straight line (isn't affected
		// by gravity) and doesn't change icon states, you can just override movement.
		// If you want to change how keyboard input is handled or you want to change the
		// mob's AI, you can override action() but leave movement() alone.
		action(t)
			#ifdef LIBRARY_DEBUG
			if(trace) trace.event("[world.time]: start action:")
			#endif

			if(path || destination)
				follow_path()

			else if(client)

				var/d = 0

				if(client.focus == src)
					if(client.keys[controls.up]) d += NORTH
					else if(client.keys[controls.down]) d += SOUTH
					if(client.keys[controls.left]) d += WEST
					else if(client.keys[controls.right]) d += EAST

				dir = d
				move(d)

				slow_down()

			else
				if(moved)
					moved = 0
				else
					slow_down()

			#ifdef LIBRARY_DEBUG
			if(trace) trace.event("[world.time]: end action:")
			#endif

		slow_down()
			// if you're moving faster than your move_speed, slow down
			// whether you're pressing an arrow key or not.
			if(vel_x > move_speed)
				vel_x -= 1
			else if(vel_x < -move_speed)
				vel_x += 1

			if(vel_y > move_speed)
				vel_y -= 1
			else if(vel_y < -move_speed)
				vel_y += 1

			// make mobs with clients slow down...
			if(client)
				// if you're not pressing left or right, you slow down in the x direction.
				if(client.focus != src || (!client.keys[controls.left] && !client.keys[controls.right]))
					if(vel_x > decel)
						vel_x -= decel
					else if(vel_x < -decel)
						vel_x += decel
					else
						vel_x = 0

				// if you're not pressing up or down, you slow down in the y direction.
				if(client.focus != src || (!client.keys[controls.up] && !client.keys[controls.down]))
					if(vel_y > decel)
						vel_y -= decel
					else if(vel_y < -decel)
						vel_y += decel
					else
						vel_y = 0

			else if(!moved)
				if(!(moved & EAST) && !(moved & WEST))
					if(vel_x > decel)
						vel_x -= decel
					else if(vel_x < -decel)
						vel_x += decel
					else
						vel_x = 0

				// if you're not pressing up or down, you slow
				// down in the y direction.
				if(!(moved & NORTH) && !(moved & SOUTH))
					if(vel_y > decel)
						vel_y -= decel
					else if(vel_y < -decel)
						vel_y += decel
					else
						vel_y = 0

client

	// Previously these procs displayed an error message. The reason
	// for doing that was because if client.North was called, it was
	// probably because macros weren't properly defined. The error
	// messages were sometimes shown when they shouldn't have been shown,
	// so the error message was removed.
	// We still want to override these procs so that they do nothing.
	// Input is handled by keyboard.dm, we don't need to use these procs.
	North() return 0
	South() return 0
	East() return 0
	West() return 0
	Southeast() return 0
	Southwest() return 0
	Northeast() return 0
	Northwest() return 0
