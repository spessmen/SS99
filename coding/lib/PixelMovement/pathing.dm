
// File:    pathing.dm
// Library: Forum_account.PixelMovement
// Author:  Forum_account
//
// Contents:
//   This file contains pathfinding features. It defines the
//   mob.move_to and mob.move_towards procs which are similar
//   to DM's built-in walk_to and walk_towards procs.

// The /Path datum is used to contain all A* pathfinding code.
// You never need to access this directly, mob.move_to handles
// all the details.
//
// The implementation is almost directly copied from:
//   http://en.wikipedia.org/wiki/A*_search_algorithm
Path
	var
		turf/destination
		mob/mover
		list/tiles

		list/closed
		list/fringe
		list/parent
		turf/current

		list/f_score
		list/g_score
		list/h_score

		limit = 0

	New(mob/m, turf/t)
		mover = m
		destination = t

		compute()

	proc
		// The add proc is called to add a node to the fringe. If the node already
		// exists in the fringe, it's g() and h() values are updated (if appropriate).
		add(turf/t)
			if(!t) return
			if(t.density) return
			if(t in closed) return 0

			var/tentative_g_score = g_score[current] + distance(current, t)
			var/tentative_is_better = 0

			if(!(t in fringe))
				fringe += t
				tentative_is_better = 1
			else if(tentative_g_score < g_score[t])
				tentative_is_better = 1

			if(tentative_is_better)
				parent[t] = current

				g_score[t] = tentative_g_score
				h_score[t] = heuristic(t)
				f_score[t] = g_score[t] + h_score[t]

			return 1

		// this proc controls the distance metric used by the search algorithm.
		distance(turf/a, turf/b)
			return abs(a.x - b.x) + abs(a.y - b.y)

		// the heuristic is simply the distance from the turf to the destination.
		heuristic(turf/t)
			return distance(t, destination)

		compute()

			closed = list()
			fringe = list(mover.loc)
			parent = list()

			f_score = list()
			g_score = list()
			h_score = list()

			g_score[mover.loc] = 0
			h_score[mover.loc] = heuristic(mover.loc)
			f_score[mover.loc] = h_score[mover.loc]

			parent[mover.loc] = null

			var/found_path = 0

			while(fringe.len)

				// if there's a limit to how many turfs you'll check
				if(limit)
					// and if you've reached that limit, stop
					if(closed.len >= limit)
						break

				// find the node with the lowest f-score
				current = fringe[1]

				for(var/turf/t in fringe)
					if(f_score[t] < f_score[current])
						current = t

				// If this node is the destination, we're done.
				if(current == destination)
					found_path = 1
					break

				fringe -= current
				closed += current

				var/move_right = add(locate(current.x + 1, current.y, current.z))
				var/move_up    = add(locate(current.x, current.y + 1, current.z))
				var/move_left  = add(locate(current.x - 1, current.y, current.z))
				var/move_down  = add(locate(current.x, current.y - 1, current.z))

				if(move_right)
					if(move_up)
						add(locate(current.x + 1, current.y + 1, current.z))
					if(move_down)
						add(locate(current.x + 1, current.y - 1, current.z))

				if(move_left)
					if(move_up)
						add(locate(current.x - 1, current.y + 1, current.z))
					if(move_down)
						add(locate(current.x - 1, current.y - 1, current.z))

			// At this point we're outside of the loop and we've
			// either found a path or exhausted all options.

			if(!found_path)
				del src

			// at this point we know a path exists, we just have to identify it.
			// we use the "parent" list to trace the path.
			var/turf/t = destination
			tiles = list()

			while(t)
				tiles.Insert(1, t)
				t = parent[t]

mob
	var
		Path/path
		turf/destination
		turf/next_step

		__stuck_counter = 0

	proc
		// The follow_path proc is called from the mob's default movement proc if
		// either path or destination is set to a non-null value (in other words,
		// follow_path is called if move_to or move_towards was called). Because
		// this proc is called from movement, all we need to do is determine what
		// calls to move, jump, or climb (not implemented yet) should be made.
		follow_path()

			// If the mob is following a planned path...
			if(path)

				if(loc == path.destination)
					moved_to(path.destination)
					stop()
					return 1

				// check to see if the mob is "stuck", the stuck counter
				// is reset to zero when the mob advances a tile. If the
				// mob spends 50 ticks at the same tile, they're "stuck".
				__stuck_counter += 1

				if(__stuck_counter > 50)
					__stuck_counter = 0
					path = new(src, path.destination)

					if(!path)
						return 0

				next_step = null
				while(next_step == null)
					if(!path.tiles.len)
						next_step = path.destination
						break

					next_step = path.tiles[1]

					// if we've reached the next tile, remove it from
					// the path and reset the stuck counter
					if(next_step in locs)
						path.tiles.Cut(1,2)
						next_step = null
						__stuck_counter = 0

				// now that the library supports 8-directional moves, we can
				// do it this way:
				var/move_east = (px < next_step.px - vel_x)
				var/move_west = move_east ? 0 : (px + pwidth + vel_x > next_step.px + next_step.pwidth)
				var/move_north = (py < next_step.py - vel_y)
				var/move_south = move_north ? 0 : (py + pheight + vel_y > next_step.py + next_step.pheight)

				if(move_east)
					if(move_north)
						move(NORTHEAST)
						dir = NORTHEAST
					else if(move_south)
						move(SOUTHEAST)
						dir = SOUTHEAST
					else
						move(EAST)
						dir = EAST

				else if(move_west)
					if(move_north)
						move(NORTHWEST)
						dir = NORTHWEST
					else if(move_south)
						move(SOUTHWEST)
						dir = SOUTHWEST
					else
						move(WEST)
						dir = WEST

				else
					if(move_north)
						move(NORTH)
						dir = NORTH
					else if(move_south)
						move(SOUTH)
						dir = SOUTH
					else
						moved_to(path.destination)
						stop()

			// if the mob is moving towards a destination...
			else if(destination)

				var/bounds_dist = bounds_dist(src, destination)
				if(bounds_dist < -8)
					moved_towards(destination)
					stop()
					return 1
				else if(bounds_dist < 1 && can_bump(destination))
					moved_towards(destination)
					stop()
					return 1

				// I made the same changes to these if statements as the ones
				// in the case for following a path.
				var/slow_down = 0
				if(px < destination.px)
					move(EAST)
					dir = EAST
				else if(px +pwidth > destination.px + destination.pwidth)
					move(WEST)
					dir = WEST
				else
					slow_down += 1

				if(py < destination.py)
					move(NORTH)
					dir = NORTH
				else if(py + pheight > destination.py + destination.pheight)
					move(SOUTH)
					dir = SOUTH
				else
					slow_down += 1

				if(slow_down == 2)
					slow_down()

			else
				return 0

	proc
		// calling the stop proc will halt any movement that was
		// triggered by a call to move_to or move_towards.
		stop()
			destination = null
			path = null

		// This is the pixel movement equivalent of DM's built-in walk_towards
		// proc. The behavior takes some obstacles into account (it'll try to
		// jump over obstacles) but it doesn't plan a path. It's CPU usage is
		// lower than move_to but the behavior may not be sufficiently smart.
		move_towards(atom/a)

			stop()

			// calling move_towards(null) will stop the current movement but
			// not trigger a new one, so it's just like calling stop().
			if(!a) return 0

			destination = a

			return 1

		moved_to(turf/t)
		moved_towards(atom/a)

		// move_to is the pixel movement equivalent of DM's built-in walk_to proc.
		// It uses the A* algorithm to plan a path to the destination and the
		// follow_path proc handles the details of following the path.
		move_to(turf/t)

			stop()

			if(istype(t, /atom/movable))
				t = t.loc

			// calling move_to(null) will stop the current movement but
			// not trigger a new one, so it's just like calling stop().
			if(!t) return 0

			// Because we're creating a new path we can reset this counter.
			__stuck_counter = 0

			path = new(src, t)

			if(path)
				next_step = path.tiles[1]
				return 1
			else
				stop()
				return 0

