Beerholder's sneaky ladder. WIP name: [MOD] Sneaky [sneaky]

Tried to get a sneak elevator to work again, until I found out the
devs re-added the sneak glitch -_- Posting it on GitHub just in
case someone is interested. This is just sample code, currently
working for singleplayer only! If you would like to use this, you
will have to put a bit more effort in it depending on your needs.

Funny thing is, this mod glitches too, just in a different way.
It does not always capture the sneaky block underneath the player
I think, meaning you crash to death if you are not careful ...

To sneak climb we need to consider either something, then air above
it and then something again, or air, something and air above it.
This pattern needs to be anywhere next to the player.

Diagrammatic climb ("x" something " " air "p" player):

 2  x         2
 1     p  OR  1  x
 0  x         0     p

To sneak hover we need to consider air below and then something on top.

Diagrammatic hover (x something a air p player):

 0  x  p
-1
-2  x

We use a transparent (airlike) dummy node to stand/ hover on. We set
the selection box to something ridiculously small so one cannot see it.
It looks something like this ("s" = the sneaky block, sneakily hiding
underneath you):

 0  x  p
-1     s
-2  x
-3
-4  x
-5
