
// File:    procs.dm
// Library: Forum_account.PixelMovement
// Author:  Forum_account
//
// Contents:
//   This file contains helper procs. These procs aren't
//   as essential as other procs in the library (the library
//   will run without most of them) but they're useful to
//   people who will use the library.

atom
	proc
		inside()
			// if the proc was passed no arguments return a list of all atoms inside src.
			if(!args || args.len == 0)

				#ifdef TWO_DIMENSIONAL
				return obounds(src)
				#else

				. = list()
				var/atom/a
				for(var/b in obounds(src))
					a = b
					if(a.pz > pz + pdepth) continue
					if(a.pz + a.pdepth < pz) continue
					. += a

				#endif

			// if the proc was passed a single argument return 1 if the argument (an atom)
			// is inside src and 0 otherwise.
			else if(args.len == 1)
				return bounds_dist(src, args[1]) < 0

		// Calls left, right, top, or bottom based on src's direction.
		front(d, w = 0)
			if(dir == NORTH)
				return top(d, w)
			else if(dir == SOUTH)
				return bottom(d, w)
			else if(dir == EAST)
				return right(d, w)
			else
				return left(d, w)

		// The left proc returns a list of all atoms
		// within w pixels of src's left side.
		//
		//     +---------+-----------+
		//     |         |           |
		//     |<-- w -->|           |
		//     |         |    src    |
		//     |         |           |
		//     |         |           |
		//     |         |           |
		//     +---------+-----------+
		left(w, h = 0)

			var/h_off = 0
			if(!h)
				h = pheight
			else
				h_off = (pheight - h) / 2

			#ifdef TWO_DIMENSIONAL
			return obounds(src, -w, h_off, -pwidth + w, h - pheight)
			// return obounds(src, -w, 0, -pwidth + w, 0)
			#else

			. = list()
			// for(var/atom/a in obounds(src, -w, 0, -pwidth + w, 0))
			var/atom/a
			for(var/b in obounds(src, -w, h_off, -pwidth + w, h - pheight))
				a = b
				if(a.pz > pz + pdepth) continue
				if(a.pz + a.pdepth < pz) continue
				. += a

			#endif

		// Returns a list of atoms within w pixels of src's right side.
		right(w, h = 0)

			var/h_off = 0
			if(!h)
				h = pheight
			else
				h_off = (pheight - h) / 2

			#ifdef TWO_DIMENSIONAL
			return obounds(src, pwidth, h_off, -pwidth + w, h - pheight)
			// return obounds(src, pwidth, 0, -pwidth + w, 0)
			#else

			. = list()
			// for(var/atom/a in obounds(src, pwidth, 0, -pwidth + w, 0))
			var/atom/a
			for(var/b in obounds(src, pwidth, h_off, -pwidth + w, h - pheight))
				a = b
				if(a.pz > pz + pdepth) continue
				if(a.pz + a.pdepth < pz) continue
				. += a

			#endif

		// Returns a list of atoms within h pixels of src's top side.
		top(h, w = 0)

			var/w_off = 0
			if(!w)
				w = pwidth
			else
				w_off = (pwidth - w) / 2

			#ifdef TWO_DIMENSIONAL
			return obounds(src, w_off, pheight, w - pwidth, -pheight + h)
			// return obounds(src, 0, pheight, 0, -pheight + h)
			#else

			. = list()
			// for(var/atom/a in obounds(src, 0, pheight, 0, -pheight + h))
			var/atom/a
			for(var/b in obounds(src, w_off, pheight, w - pwidth, -pheight + h))
				a = b
				if(a.pz > pz + pdepth) continue
				if(a.pz + a.pdepth < pz) continue
				. += a

			#endif

		// Returns a list of atoms within h pixels of src's bottom side.
		bottom(h, w = 0)
			var/w_off = 0
			if(!w)
				w = pwidth
			else
				w_off = (pwidth - w) / 2

			#ifdef TWO_DIMENSIONAL
			return obounds(src, w_off, -h, w - pwidth, -pheight + h)
			// return obounds(src, 0, -h, 0, -pheight + h)
			#else

			. = list()
			// for(var/atom/a in obounds(src, 0, -h, 0, -pheight + h))
			var/atom/a
			for(var/b in obounds(src, w_off, -h, w - pwidth, -pheight + h))
				a = b
				if(a.pz > pz + pdepth) continue
				if(a.pz + a.pdepth < pz) continue
				. += a

			#endif

		below(d)

			#ifdef TWO_DIMENSIONAL
			return inside()
			#else

			. = list()
			var/atom/a
			for(var/b in obounds(src))
				a = b

				if(a.ramp)
					if(pz - d > a.height(px,py,pz,pwidth,pheight,pdepth)) continue
				else
					if(a.pz > pz) continue
					if(a.pz + a.pdepth < pz - d) continue

				. += a

			#endif

		#ifndef TWO_DIMENSIONAL
		above(d)

			. = list()
			var/atom/a
			for(var/b in obounds(src))
				a = b
				if(a.pz > pz + pdepth + d) continue
				if(a.pz + a.pdepth < pz + pdepth) continue
				. += a

		#endif

		distance_to(atom/a)
			if(PixelMovement.distance == PixelMovement.EUCLIDEAN)
				var/dx = (px + pwidth / 2) - (a.px + a.pwidth / 2)
				var/dy = (py + pheight / 2) - (a.py + a.pheight / 2)
				return sqrt(dx * dx + dy * dy)
			else if(PixelMovement.distance == PixelMovement.BYOND)
				var/dx = (px + pwidth / 2) - (a.px + a.pwidth / 2)
				var/dy = (py + pheight / 2) - (a.py + a.pheight / 2)
				return max(abs(dx), abs(dy))
			else if(PixelMovement.distance == PixelMovement.MANHATTAN)
				var/dx = (px + pwidth / 2) - (a.px + a.pwidth / 2)
				var/dy = (py + pheight / 2) - (a.py + a.pheight / 2)
				return abs(dx) + abs(dy)

mob
	proc
		// Returns 1 if a list of atoms contains a single bumpable atom
		// and returns 0 otherwise.
		dense(list/l)
			for(var/atom/a in l)
				if(can_bump(a))
					return 1
			return 0
