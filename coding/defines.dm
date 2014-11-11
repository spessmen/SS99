// Enable to log as simple text strings instead of HTML.
#define LOG_AS_TEXT

// Disables the 'click' function of the Keyboard library.
#define NO_CLICK

// Disables the 'key repeat' function of the Keyboard library.
// This is deliberately disabled because we don't want to introduce additional network overhead
// by having the client repeat keys to the server.
// Instead we should catch keydown and keyup events and repeat commands ourselves.
#define NO_KEY_REPEAT

var
	const
		// used to reference keyboard keys
#define K_RIGHT "east"
#define K_LEFT "west"
#define K_UP "north"
#define K_DOWN "south"