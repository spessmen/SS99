
turf
	var
		angled = 0

mob
	var
		move_x
		move_y

		#ifndef TWO_DIMENSIONAL
		move_z
		#endif

	proc
		check_collision(atom/a)

			#ifdef TWO_DIMENSIONAL

			// in 2D mode there are no ramps, so all collisions are block collisions
			block_collision(a)

			/*
			// I started adding angled walls but never finished
			if(isturf(a) && a:angled)
				world << "angled_collision"
				angled_collision(a)
			else
			*/

			#else

			// in 3D mode, not all ramp collisions have to be treated as ramp collisions
			if(a.ramp && pz + move_z >= a.pz)
				ramp_collision(a)
			else
				block_collision(a)

			#endif

	#ifdef TWO_DIMENSIONAL

		/*
		// 2D block collision
		angled_collision(turf/t)
			if(t.angled & NORTH)
				if(t.angled & EAST)
					if(py + pheight > t.py + icon_height)
						block_collision(t)
					else if(px + pwidth > t.px + icon_width)
						block_collision(t)
				else

			else
				if(t.angled & EAST)
				else
		*/

		// 2D block collision
		block_collision(atom/a)

			// You cannot be inside t already, so if the move doesn't put you
			// inside t then we can ignore that turf.
			// if(!a.inside4(px + move_x, py + move_y, pwidth, pheight)) continue

			// ix, iy, and iz measure how far you are inside the turf in each direction.
			var/ix = 0
			var/iy = 0

			// If you draw pictures showing a mob hitting a dense turf from the left
			// side and label px, dpx, pwidth, and t.px it's easy to see how you
			// compute ix. The same can be done for hitting a dense turf from the right.
			if(move_x > 0)
				ix = px + move_x + pwidth - a.px
			else if(move_x < 0)
				ix = (px + move_x) - (a.px + a.pwidth)

			// Same as the ix calculations except we swap y for x and height for width.
			if(move_y > 0)
				iy = py + move_y + pheight - a.py
			else if(move_y < 0)
				iy = (py + move_y) - (a.py + a.pheight)

			// tx, ty, and tz measure the fraction of the move that it takes
			// for you to hit the turf in each direction.
			var/tx = (abs(move_x) < EPSILON) ? 1000 : ix / move_x
			var/ty = (abs(move_y) < EPSILON) ? 1000 : iy / move_y

			if(ty == min(tx, ty, 999))
				move_y -= iy
			else if(tx == min(tx,ty,999))
				move_x -= ix

	#else
		// 3D block collision
		block_collision(atom/a)
			// You cannot be inside t already, so if the move doesn't put you
			// inside t then we can ignore that turf.
			if(!a.inside6(px + move_x, py + move_y, pwidth, pheight, pz + move_z, pdepth)) return

			// ix, iy, and iz measure how far you are inside the turf in each direction.
			var/ix = 0
			var/iy = 0
			var/iz = 0

			// If you draw pictures showing a mob hitting a dense turf from the left
			// side and label px, dpx, pwidth, and t.px it's easy to see how you
			// compute ix. The same can be done for hitting a dense turf from the right.
			if(move_x > 0)
				ix = px + move_x + pwidth - a.px
			else if(move_x < 0)
				ix = (px + move_x) - (a.px + a.pwidth)

			// Same as the ix calculations except we swap y for x and height for width.
			if(move_y > 0)
				iy = py + move_y + pheight - a.py
			else if(move_y < 0)
				iy = (py + move_y) - (a.py + a.pheight)

			// we only care about iz if we're falling. there are no ceilings
			if(move_z > 0)
				iz = pz + move_z + pdepth - a.pz
			else if(move_z < 0)
				iz = (pz + move_z) - (a.pz + a.pdepth)

			// tx, ty, and tz measure the fraction of the move that it takes
			// for you to hit the turf in each direction.
			var/tx = (abs(move_x) < EPSILON) ? 1000 : ix / move_x
			var/ty = (abs(move_y) < EPSILON) ? 1000 : iy / move_y
			var/tz = (abs(move_z) < EPSILON) ? 1000 : iz / move_z

			// We use tx, ty, and tz to determine if you first hit the object in the x, y, or z
			// direction. We modify dpx, dpy, and/or dpz based on how you bumped the turf.
			if(tz == min(tx,ty,tz,999))
				move_z -= iz

			if(pz + move_z < a.pz + a.pdepth)
				if(ty == min(tx,ty,tz,999))
					move_y -= iy
				else if(tx == min(tx,ty,tz,999))
					move_x -= ix

		// 3D ramp collision
		ramp_collision(atom/a)
			// if your move won't put you over top of the tile, we can ignore it
			if(!a.over(px + move_x, py + move_y, pwidth, pheight)) return

			// if the move still leaves you above the top of the ramp, we can ignore it
			if(pz + move_z >= a.pz + a.pdepth + a.ramp) return

			// we need to check if the mob was over top of the ramp to begin with.
			// if you're already on the ramp we handle things differently.
			var/over = 1
			if(px + pwidth <= a.px)
				over = 0
			else if(px >= a.px + a.pwidth)
				over = 0
			else if(py + pheight <= a.py)
				over = 0
			else if(py >= a.py + a.pheight)
				over = 0

			// if you're not over top of the tile to begin with...
			if(!over)
				// We need to determine if you're entering the tile from it's low
				// side, if you are you'll walk up the ramp, otherwise you'll bump
				// into the side of the ramp.

				var/h = a.height(px + move_x, py + move_y, pz + move_z, pwidth, pheight, pdepth)

				if(pz + move_z < h)

					var/bump_side = 1

					// if you're below the level where the ramp even begins, of course
					// you'll bump the side of the tile and we don't have to do this check.
					if(pz >= a.pz + a.pdepth)

						// if the ramp rises to the NORTH
						if(a.ramp_dir == NORTH)
							// if you're to the south of the tile, you won't bump its side.
							if(py + pheight <= a.py) bump_side = 0

						// same for each direction...
						else if(a.ramp_dir == SOUTH)
							if(py >= a.py + a.pheight) bump_side = 0
						else if(a.ramp_dir == EAST)
							if(px + pwidth <= a.px) bump_side = 0
						else if(a.ramp_dir == WEST)
							if(px >= a.px + a.pwidth) bump_side = 0

					// if you'll bump into the side of the ramp, handle that collision
					if(bump_side)

						// this is copied from the handling of collisions with regular tiles,
						// but we ignore the z collisions here because we know they're not an issue.
						var/ix = 0
						var/iy = 0

						if(move_x > 0)
							ix = px + move_x + pwidth - a.px
						else if(move_x < 0)
							ix = (px + move_x) - (a.px + a.pwidth)

						// Same as the ix calculations except we swap y for x and height for width.
						if(move_y > 0)
							iy = py + move_y + pheight - a.py
						else if(move_y < 0)
							iy = (py + move_y) - (a.py + a.pheight)

						// tx, ty, and tz measure the fraction of the move that it takes
						// for you to hit the turf in each direction.
						var/tx = (move_x == 0) ? 1000 : ix / move_x
						var/ty = (move_y == 0) ? 1000 : iy / move_y

						if(ty == min(tx, ty, 999))
							move_y -= iy
						else if(tx == min(tx,ty,999))
							move_x -= ix

					// this handles the case where you'll move up the ramp's incline.
					else
						move_z = h - pz

			// this is the case for handling collisions when you were on the ramp's incline
			// in the first place. In this case, you'll end up on top of the ramp.
			else
				var/h = a.height(px + move_x, py + move_y, pz + move_z, pwidth, pheight, pdepth)

				if(pz + move_z < h)
					move_z = h - pz

	#endif
