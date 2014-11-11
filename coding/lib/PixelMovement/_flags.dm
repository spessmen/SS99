
// File:    _flags.dm
// Library: Forum_account.PixelMovement
// Author:  Forum_account
//
// Contents:
//   This file contains descriptions of all compile-time flags the
//   library provides to customize its features. These flags change
//   the code that gets compiled. By excluding features at compile
//   time you improve performance at runtime.
//
//   To use these flags you must define them in the library. If you
//   include this library in another project, to add a flag you have to:
//
//     1. Double-click on the library in Dream Maker to open it.
//     2. Uncomment the #define line in this file.
//     3. Recompile.
//
//   Putting #define LIBRARY_DEBUG in your project won't effect the
//   library, you have to define it here.

// The library can use either BYOND's built-in pixel movement feature
// or it's own pixel movement implementation. The #define statement is
// necessary because different code gets compiled depending on which
// method is used.

// Enabling the TWO_DIMENSIONAL flag (by uncommenting the #define line)
// will make the movement system purely 2D - players will not be able to
// move in the z direction (i.e. no jumping). Collisions will be based
// on 2D bounding boxes.
//
// You should set this flag when your game doesn't use 3D movement (no
// jumping, no tall walls, no ramps, etc.). It can drastically improve
// performance in these situations.
#define TWO_DIMENSIONAL


// Enabling the LIBRARY_DEBUG flag (by uncommenting the #define line)
// will enable the library's debugging features (mob.start_trace, debug
// statpanel). The PIXEL_MOVEMENT_DEBUG var exists whether the flag is
// set or not, but the statpanel will only appear if the flag is set.
//
// The reason to have this flag is that enabling it will actually change
// the DM code that gets compiled. Many of the movement procs check
// "if(trace)" to see if the debugging trace is enabled - these checks
// take time (not much, but it adds up). By having this flag not set you're
// removing these checks from the code.
//#define LIBRARY_DEBUG


// Enabling the NO_STEPPED_ON flag will make the library exclude the definitions
// of the atom.stepped_on, stepped_off, and stepping_on procs. It can be costly
// to check which atoms a mob is stepping on, so enabling this flag can improve
// performance drastically. If you're not using any of these procs, you should
// enable this flag.
// #define NO_STEPPED_ON




// Ignore this, it's not being used anymore:
/*
// The library doesn't use the Move() proc to perform a mob's movement,
// so it has to manually check to see if a turf or area's Entered() and
// Exited() procs should be called. These checks can be costy - they're
// happening 40 times per second for every mob. If you don't use these
// procs then you don't need to check for them, so the library would be
// wasting CPU time to check.
//
// If you do need to use the turf and area Entered/Exited events, include
// these #define statements by either uncommenting these lines or by
// adding these statements to the .dme file of the project that uses the
// pixel movement library.
// #define TURF_ENTERED
// #define AREA_ENTERED
*/