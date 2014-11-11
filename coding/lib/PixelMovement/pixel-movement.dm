
// File:    pixel-movement.dm
// Library: Forum_account.PixelMovement
// Author:  Forum_account
//
// Contents:
//   This file contains the code to handle the actual
//   pixel movement (the pixel_move proc). It also has
//   some related functions: camera handling, density
//   checking, etc.
//
//   This file is the same as the old pixel-movement.dm
//   except it's surrounded by a #if statement so it is
//   only compiled when the library is told to use soft-
//   coded pixel movement.

var
	const
		// this is used to compare decimal values to see if they're
		// close enough to zero to treat them as zero (to avoid divide
		// by zero errors).
		EPSILON = 0.001

atom
	// we need these vars for turfs and mobs at least. We probably don't
	// need them for areas, but it's easy to define them for all atoms.
	var
		// px,py,pz is your position on the map in pixels
		px = 0
		py = 0

		// the fractional parts of your movements
		_px = 0
		_py = 0

		#ifndef TWO_DIMENSIONAL
		pz = 0
		_pz = 0
		#endif

		// pwidth/pheight/pdepth determine the dimensions of your bounding box
		pwidth = -1
		pheight = -1

		#ifndef TWO_DIMENSIONAL
		pdepth = -1
		#endif

		// This is used to define properties of the object that get
		// stored in the mob's on_ground, on_left, on_right, and
		// on_ceiling vars.
		flags = 0

		// These are flags for individual sides of the atom.
		flags_right = 0
		flags_left = 0
		flags_top = 0
		flags_bottom = 0
		flags_ground = 0

		#ifndef TWO_DIMENSIONAL
		ramp = 0
		ramp_dir = 0
		#endif

	New()
		..()

		if(PixelMovement.tile_width == -1)
			PixelMovement.set_icon_size()

		px = PixelMovement.tile_width * x
		py = PixelMovement.tile_height * y

		if(pwidth == -1)
			pwidth = PixelMovement.tile_width

		if(pheight == -1)
			pheight = PixelMovement.tile_height

		#ifndef TWO_DIMENSIONAL
		pz = pixel_z

		if(pdepth == -1)
			if(density)
				pdepth = 32
			else
				pdepth = 0
		#endif

	proc

#ifndef TWO_DIMENSIONAL
		height(qx, qy, qz, qw, qh, qd)

			if(ramp_dir == NORTH)
				. = pz + pdepth + ((qy + qh - py) / pheight) * ramp
				. = min(pz + pdepth + ramp, .)
				. = max(pz + pdepth, .)
			else if(ramp_dir == SOUTH)
				. = pz + pdepth + ((py + pheight - qy) / pheight) * ramp
				. = min(pz + pdepth + ramp, .)
				. = max(pz + pdepth, .)

			else if(ramp_dir == EAST)
				. = pz + pdepth + ((qx + qw - px) / pwidth) * ramp
				. = min(pz + pdepth + ramp, .)
				. = max(pz + pdepth, .)
			else if(ramp_dir == WEST)
				. = pz + pdepth + ((px + pwidth - qx) / pwidth) * ramp
				. = min(pz + pdepth + ramp, .)
				. = max(pz + pdepth, .)

			else
				return 0

			return round(.)

		// we don't want to take an atom as an argument because we'll be using
		// this proc to check if a move would put an object inside another, we
		// want to check if the move is ok without actually performing it.
		// So, we take the query point, which is defined by the point qx,qy and
		// the size of the atom's bounding box: qw x qh.
		inside6(qx,qy,qw,qh,qz,qd)
			if(qx <= px - qw) return 0
			if(qx >= px + pwidth) return 0
			if(qy <= py - qh) return 0
			if(qy >= py + pheight) return 0
			if(qz >= pz + pdepth) return 0
			if(qz <= pz - qd) return 0
			return 1
#endif

		inside4(qx,qy,qw,qh)
			if(qx <= px - qw) return 0
			if(qx >= px + pwidth) return 0
			if(qy <= py - qh) return 0
			if(qy >= py + pheight) return 0
			return 1

		over(qx,qy,qw,qh)
			if(qx <= px - qw) return 0
			if(qx >= px + pwidth) return 0
			if(qy <= py - qh) return 0
			if(qy >= py + pheight) return 0
			return 1

	#ifndef NO_STEPPED_ON
		stepped_on(mob/m)
		stepping_on(mob/m, t)
		stepped_off(mob/m)
	#endif

#ifndef TWO_DIMENSIONAL
turf
	inside6(qx,qy,qw,qh,qz,qd)
		if(qx <= px - qw) return 0
		if(qx >= px + pwidth) return 0
		if(qy <= py - qh) return 0
		if(qy >= py + pheight) return 0
		if(qz >= pz + pdepth + ramp) return 0
		return 1
#endif

atom
	movable
		New()
			// <EmpireModification>
			if (bound_width)
				pwidth = bound_width
			if (bound_height)
				pheight = bound_height

			if (bound_x)
				step_x += bound_x
			if (bound_y)
				step_y += bound_y
			// </EmpireModification>

			..()

			bound_width = pwidth
			bound_height = pheight

			pixel_x -= bound_x
			pixel_y -= bound_y

			bound_x = 0
			bound_y = 0

			px += step_x
			py += step_y

mob
	animate_movement = 0

	proc
		can_bump(atom/a)
			// Every turf is dense, they're just different heights. A floor turf
			// that you'd normally consider non-dense is actually dense - you can
			// walk on top of it. If you couldn't bump into them you'd fall right
			// through them.
			if(isturf(a))

				// In 2D mode you can only bump dense turfs, in 3D mode
				// you can bump any turf, it's just a question of how tall
				// the turf is that determines if you do hit it.
				#ifdef TWO_DIMENSIONAL
				return a.density
				#else
				return 1
				#endif

			else
				return a.density && density

			return 0

// Because the pixel_move proc changes so much between 2D
// and 3D modes, I just made a completely separate bit of
// code to handle 2D mode:
#ifdef TWO_DIMENSIONAL
		pixel_move(dpx, dpy)

			#ifdef LIBRARY_DEBUG
			if(trace) trace.event("[world.time]: start pixel_move: dpx = [dpx], dpy = [dpy]")
			#endif

			bound_width = pwidth
			bound_height = pheight

			// find the integer part of your move
			var/ipx = round(abs(dpx)) * ((dpx < 0) ? -1 : 1)
			var/ipy = round(abs(dpy)) * ((dpy < 0) ? -1 : 1)

			// accumulate the fractional parts of the move
			_px += (dpx - ipx)
			_py += (dpy - ipy)

			// ignore the fractional parts
			dpx = ipx
			dpy = ipy

			// increment the move if the fractions have added up
			while(_px > 0.5)
				_px -= 1
				dpx += 1
			while(_px < -0.5)
				_px += 1
				dpx -= 1

			while(_py > 0.5)
				_py -= 1
				dpy += 1
			while(_py < -0.5)
				_py += 1
				dpy -= 1

			move_x = dpx
			move_y = dpy

			var/bumped = 0

			if(on_left && move_x < 0)
				move_x = 0
				dpx = 0
				bumped |= WEST
			else if(on_right && move_x > 0)
				move_x = 0
				dpx = 0
				bumped |= EAST

			if(on_bottom && move_y < 0)
				move_y = 0
				dpy = 0
				bumped |= SOUTH
			else if(on_top && move_y > 0)
				move_y = 0
				dpy = 0
				bumped |= NORTH

			// var/dist = max(abs(dpx), abs(dpy))
			for(var/a in obounds(src, dpx, dpy, abs(dpx), abs(dpy)))

				// if the move has failed completely, we don't need to check
				// for any more collisions.
				if(dpx == 0 && dpy == 0) break
				if(!can_bump(a)) continue

				check_collision(a)

			set_pos(px + move_x, py + move_y)

			// if the resulting move was shorter than the attempted move, a bump occurred
			if(dpx > 0 && move_x < dpx)
				bumped |= EAST
			else if(dpx < 0 && move_x > dpx)
				bumped |= WEST

			if(dpy > 0 && move_y < dpy)
				bumped |= NORTH
			else if(dpy < 0 && move_y > dpy)
				bumped |= SOUTH

			// if any bump flags were set, call the bump proc for all atoms you're touching
			// in the flagged directions
			if(bumped & EAST)
				for(var/atom/a in right(1))
					if(can_bump(a))
						bump(a, EAST)
			else if(bumped & WEST)
				for(var/atom/a in left(1))
					if(can_bump(a))
						bump(a, WEST)

			if(bumped & NORTH)
				for(var/atom/a in top(1))
					if(can_bump(a))
						bump(a, NORTH)
			else if(bumped & SOUTH)
				for(var/atom/a in bottom(1))
					if(can_bump(a))
						bump(a, SOUTH)

			return bumped ? 0 : 1

// otherwise, we handle 3D movement
#else
		// The pixel_move proc moves a mob by (dpx, dpy, dpz) pixels.
		pixel_move(dpx, dpy, dpz = 0)

			bound_width = pwidth
			bound_height = pheight

			// find the integer part of your move
			var/ipx = round(abs(dpx)) * ((dpx < 0) ? -1 : 1)
			var/ipy = round(abs(dpy)) * ((dpy < 0) ? -1 : 1)
			var/ipz = round(abs(dpz)) * ((dpz < 0) ? -1 : 1)

			// accumulate the fractional parts of the move
			_px += (dpx - ipx)
			_py += (dpy - ipy)
			_pz += (dpz - ipz)

			// ignore the fractional parts
			dpx = ipx
			dpy = ipy
			dpz = ipz

			// increment the move if the fractions have added up
			while(_px > 0.5)
				_px -= 1
				dpx += 1
			while(_px < -0.5)
				_px += 1
				dpx -= 1

			while(_py > 0.5)
				_py -= 1
				dpy += 1
			while(_py < -0.5)
				_py += 1
				dpy -= 1

			while(_pz > 0.5)
				_pz -= 1
				dpz += 1
			while(_pz < -0.5)
				_pz += 1
				dpz -= 1

			//if(dpx == 0 && dpy == 0 && dpz == 0)
			//	set_pos(px, py, pz)
			//	return 1

			// We'll use this var later to check if we should "stick" to a ramp below us.
			// The reason we declare the variable here is because the value of dpy might
			// change in this proc but we want to use its initial value.
			var/stick_to_ramp = on_ground && (dpz <= 0)

			move_x = dpx
			move_y = dpy
			move_z = dpz

			var/bumped = 0

			if(on_left && move_x < 0)
				move_x = 0
				dpx = 0
				bumped |= WEST
			else if(on_right && move_x > 0)
				move_x = 0
				dpx = 0
				bumped |= EAST

			if(on_bottom && move_y < 0)
				move_y = 0
				dpy = 0
				bumped |= SOUTH
			else if(on_top && move_y > 0)
				move_y = 0
				dpy = 0
				bumped |= NORTH

			#ifdef LIBRARY_DEBUG
			if(trace) trace.event("[world.time]: start pixel_move: dpx = [dpx], dpy = [dpy], dpz = [dpz]")
			#endif

			// We could intelligently look for all nearby tiles that you might hit
			// based on your position and direction of the movement, but instead
			// we'll just check every nearby tile.
			// for(var/atom/t in oview(1,src))
			// world << "[bound_width] x [bound_height]"
			// var/dist = max(abs(dpx), abs(dpy))
			// for(var/atom/t in bounds(src, dist))
			for(var/a in obounds(src, dpx, dpy, abs(dpx), abs(dpy)))

				// if the move has failed completely, we don't need to check
				// for any more collisions.
				if(move_x == 0 && move_y == 0 && move_z == 0) break

				if(!can_bump(a)) continue

				check_collision(a)


			// stick_to_ramp will be true if you were on the ground before performing this
			// move and if you're not moving upwards (if you're moving upwards you shouldn't
			// stick to the ground).
			if(stick_to_ramp)
				// check all turfs within 8 pixels of your bottom (hehe)...
				for(var/turf/t in below(8))
					// only check turfs that you can bump and are ramps
					if(!can_bump(t)) continue
					if(!t.ramp) continue

					// t.height gives you the height of the top of the turf based on your mob.
					// You can think of it as, "if your mob fell straight down, at what height
					// would you hit the ramp". That's the heigh that t.height returns.
					var/h = t.height(px + move_x, py + move_y, pz + move_z, pwidth, pheight, pdepth)

					if(pz + move_z > h)
						// by setting dpy to h - py, we're making you move down just enough that
						// you'll end up on the ramp.
						move_z = h - pz

			// At this point we've clipped your move against all nearby tiles, so the
			// move (dpx,dpy,dpz) is a valid one at this point (both might be zero) so we
			// can perform the move.
			set_pos(px + move_x, py + move_y, pz + move_z)

			// if the resulting move was shorter than the attempted move, a bump occurred
			if(dpx > 0 && move_x < dpx)
				bumped |= EAST
			else if(dpx < 0 && move_x > dpx)
				bumped |= WEST

			if(dpy > 0 && move_y < dpy)
				bumped |= NORTH
			else if(dpy < 0 && move_y > dpy)
				bumped |= SOUTH

			if(dpz > 0 && move_z < dpz)
				bumped |= VERTICAL
			else if(dpz < 0 && move_z > dpz)
				bumped |= VERTICAL

			// if any bump flags were set, call the bump proc for all atoms you're touching
			// in the flagged directions
			if(bumped & EAST)
				for(var/atom/a in right(1))
					if(can_bump(a))
						bump(a, EAST)
			else if(bumped & WEST)
				for(var/atom/a in left(1))
					if(can_bump(a))
						bump(a, WEST)

			if(bumped & NORTH)
				for(var/atom/a in top(1))
					if(can_bump(a))
						bump(a, NORTH)
			else if(bumped & SOUTH)
				for(var/atom/a in bottom(1))
					if(can_bump(a))
						bump(a, SOUTH)

			if(bumped & VERTICAL)
				for(var/atom/a in below(1))
					if(can_bump(a))
						bump(a, VERTICAL)
				for(var/atom/a in above(1))
					if(can_bump(a))
						bump(a, VERTICAL)

			return bumped ? 0 : 1

#endif
// end of 3D pixel_move proc

		// Set pos computes your mob's x/y given your px/py, sets your loc, and manages the camera.
		set_pos(nx, ny, nz = 0,map_z = -1)

			#ifdef LIBRARY_DEBUG
			if(trace) trace.event("[world.time]: start set_pos: nx = [nx], ny = [ny], nz = [nz], map_z = [map_z]")
			#endif

			if(map_z == -1) map_z = z

			#ifdef TWO_DIMENSIONAL
			var/moved = (nx != px || ny != py || map_z != z)
			#else
			var/moved = (nx != px || ny != py || nz != pz || map_z != z)
			#endif

			if(moved)
				// If you call set_pos(50.1, 40) it'll ignore the
				// decimal, but if you are at (50, 40) and call
				// pixel_move(0.1, 0) it'll accumulate the decimal.
				px = round(nx)
				py = round(ny)
				#ifndef TWO_DIMENSIONAL
				pz = round(nz)
				#endif


				var/tx = round((nx + pwidth / 2) / PixelMovement.tile_width)
				var/ty = round((ny + pheight / 2) / PixelMovement.tile_height)

				var/turf/old_loc = loc
				var/turf/new_loc = locate(tx, ty, map_z)
				var/area/old_area = loc ? loc:loc : null

				if(new_loc != old_loc)

					Move(new_loc, dir)

					// for some reason this is necessary
					if(new_loc)
						new_loc.Entered(src)

					// In case Move failed we need to update your loc anyway.
					// If you want to prevent movement, don't do it through Move()
					loc = new_loc

					if(new_loc)
						var/area/new_area = new_loc.loc

						if(old_area != new_area)
							if(old_area) old_area.Exited(src)
							if(new_area) new_area.Entered(src)

				step_x = px - x * PixelMovement.tile_width
				step_y = py - y * PixelMovement.tile_height

				/*
				// ignore this:
				#ifdef TURF_ENTERED
				var/list/old_locs = locs
				#endif

				#ifdef AREA_ENTERED
				var/list/old_areas = list()
				for(var/turf/t in locs)
					if(!(t.loc in old_areas))
						old_areas += t.loc
				#endif

				step_x = px - x * icon_width
				step_y = py - y * icon_height

				while(step_x > icon_width / 2)
					x += 1
					step_x -= icon_width
				while(step_x < -icon_width / 2)
					x -= 1
					step_x += icon_width

				while(step_y > icon_height / 2)
					y += 1
					step_y -= icon_height
				while(step_y < -icon_height / 2)
					y -= 1
					step_y += icon_height

				#ifdef AREA_ENTERED
				var/list/areas = list()
				for(var/turf/t in locs)
					if(!(t.loc in areas))
						areas += t.loc
				#endif

				#ifdef TURF_ENTERED
				for(var/turf/t in old_locs - locs) t.Exited(src)
				#endif

				#ifdef AREA_ENTERED
				for(var/area/a in old_areas - areas)
					a.Exited(src)
				#endif

				#ifdef TURF_ENTERED
				for(var/turf/t in locs - old_locs) t.Entered(src)
				#endif

				#ifdef AREA_ENTERED
				for(var/area/a in areas - old_areas)
					a.Entered(src)
				#endif
				*/

				#ifndef TWO_DIMENSIONAL
				pixel_z = pz
				#endif


			if(client)
				// if the player isn't following a different mob, set
				// their camera.
				if(!watching || watching == src)
					set_camera()
					client.pixel_x = pixel_x + camera.px - px
					client.pixel_y = pixel_y + camera.py - py

			// if other mobs are watching this one, set their cameras.
			if(watching_me)
				for(var/mob/m in watching_me)
					m.set_camera()
					m.client.pixel_x = pixel_x + m.camera.px - px + 0.5
					m.client.pixel_y = pixel_y + m.camera.py - py + 0.5


			#ifndef NO_STEPPED_ON
			if(moved)
				// the way this is, set_pos should take about 50% of the
				// time that pixel_move takes.

				if(on_ground || was_on_ground)
					was_on_ground = on_ground

					// In 2D mode, the tiles you're standing on are the objects
					// inside of your bounding box. In 3D mode it's the obects
					// below you. In 2D mode there's no z direction so there's
					// no such thing as "below".
					#ifdef TWO_DIMENSIONAL
					var/list/_bottom = inside()
					#else
					var/list/_bottom = below(1)
					#endif

					for(var/atom/a in _bottom)

						// In 2D mode you are standing on tiles that you cannot
						// bump, so we always want this to execute. In 3D mode
						// you can only stand on tiles you can bump.
						#ifdef TWO_DIMENSIONAL
						if(1)
						#else
						if(can_bump(a))
						#endif
							if(a in bottom)
								bottom[a] += 1
								a.stepping_on(src, bottom[a])
							else
								bottom[a] = 1
								a.stepped_on(src)

					for(var/atom/a in bottom)
						if(!(a in _bottom))
							bottom -= a
							a.stepped_off(src)
			else
				for(var/atom/a in bottom)
					bottom[a] += 1
					a.stepping_on(src, bottom[a])
			#endif

			last_x = x
			last_y = y
			last_z = z

			#ifdef LIBRARY_DEBUG
			if(trace) trace.event("[world.time]: end set_pos: nx = [nx], ny = [ny], nz = [nz], map_z = [map_z]")
			#endif

			return moved

	var
		was_on_ground = 0
		list/bottom = list()

	proc
		set_flags()
			on_ground = 0
			on_left = 0
			on_right = 0
			on_top = 0
			on_bottom = 0

			#ifdef TWO_DIMENSIONAL

			var/b
			var/atom/a

			for(b in obounds(src))
				a = b
				on_ground |= (1 | a.flags | a.flags_ground)

			for(b in obounds(src, -1, 0, -pwidth + 1, 0))
				a = b
				if(can_bump(a))
					on_left |= (1 | a.flags | a.flags_right)

			for(b in obounds(src, pwidth, 0, -pwidth + 1, 0))
				a = b
				if(can_bump(a))
					on_right |= (1 | a.flags | a.flags_left)

			for(b in obounds(src, 0, pheight, 0, -pheight + 1))
				a = b
				if(can_bump(a))
					on_top |= (1 | a.flags | a.flags_right)

			for(b in obounds(src, 0, -1, 0, -pheight + 1))
				a = b
				if(can_bump(a))
					on_bottom |= (1 | a.flags | a.flags_left)

			#else

			var/b
			var/atom/a

			for(b in obounds(src))
				a = b

				if(a.ramp)
					if(pz > a.height(px,py,pz,pwidth,pheight,pdepth)) continue
				else
					if(pz != a.pz + a.pdepth) continue

				on_ground |= (1 | a.flags | a.flags_ground)

			for(b in obounds(src, -1, 0, -pwidth + 1, 0))
				a = b

				if(!can_bump(a)) continue
				if(a.pz >= pz + pdepth) continue
				if(a.pz + a.pdepth <= pz) continue
				on_left |= (1 | a.flags | a.flags_right)

			for(b in obounds(src, pwidth, 0, -pwidth + 1, 0))
				a = b

				if(!can_bump(a)) continue
				if(a.pz >= pz + pdepth) continue
				if(a.pz + a.pdepth <= pz) continue
				on_right |= (1 | a.flags | a.flags_left)

			for(b in obounds(src, 0, pheight, 0, -pheight + 1))
				a = b

				if(!can_bump(a)) continue
				if(a.pz >= pz + pdepth) continue
				if(a.pz + a.pdepth <= pz) continue
				on_top |= (1 | a.flags | a.flags_bottom)

			for(b in obounds(src, 0, -1, 0, -pheight + 1))
				a = b

				if(!can_bump(a)) continue
				if(a.pz >= pz + pdepth) continue
				if(a.pz + a.pdepth <= pz) continue
				on_bottom |= (1 | a.flags | a.flags_top)

			#endif

