
// File:    keyboard.dm
// Library: Forum_account.PixelMovement
// Author:  Forum_account
//
// Contents:
//   This file handles keyboard input. It adds keyboard macros
//   at runtime which call the KeyUp and KeyDown verbs. These
//   verbs call the key_up and key_down procs which you can
//   override to create new input behavior.

var
	const
		// used to reference keyboard keys
		K_RIGHT = "east"
		K_LEFT = "west"
		K_UP = "north"
		K_DOWN = "south"
		K_SPACE = "space"

Controls
	var
		up = K_UP
		down = K_DOWN
		left = K_LEFT
		right = K_RIGHT
		jump = K_SPACE

client
	New()
		..()

		// by default, the Keyboard library sets the focus to
		// the client, we need to set it to the mob so the mob's
		// key_up and key_down procs are called.
		focus = mob

mob
	var
		Controls/controls = new()

	// implement the default key_up and key_down behavior
	key_down(k, client/c)
		#ifndef TWO_DIMENSIONAL
		if(k == controls.jump)
			if(can_jump())
				jump()
		#endif

	key_up(k, client/c)
