<!-- vim: set ft=markdown tw=80 cc=80 ts=4 sw=4 et: -->
# Jumping Jack - for the tms9918A

https://www.youtube.com/watch?v=PlbsruwV_k0

Player starts at the bottom of the screen and has to jump up through gaps in the
sliding platforms above.  Each floor has one or two holes in it that move from
left to right or right to left in a continuous loop.  The player can only jump
through the holes.

The floor moves under the player so if a hole appears under the players feet,
the player falls through to the floor below.

If a player hits their head on a floor during a jump, they die.

Goal to reach the top of the screen.

There are floors.  Each floor has its own speed and direction.  These can be
determined in level data.

Later levels of the game introduced hazards such as an AXE or a snake that
appears on the player's floor usually at floor 2 and then when it reaches the
end of the floor it moves up to the next floor until it gets to the roof where
it will then go back to the player's floor. Starting at least 20 blocks away
from the player.

```text
^ ______________     ______________________
|
| __________________  ________  ___________
|
| ___________________    __________________
|
| ___________  ______________  ____________
|
| ________________________      ___________
| 
| __________   ____________________________
|
| ___________________    __________________
|
v 31  PLAYER START AND SCORE.  Player can move over score.
```

## Mapping the floor

When you think about it, the floor map is really just a bunch of solid lines.
The holes in the floor are what move giving the shifting floor appearance.  From
a software perspective, the game needs to calculate the new position of the hole
on each floor, fill in the old hole and draw the new one on each game frame.

## Player movement

When the player jumps, the sprite is moved upwards at a few pixels each frame.
The floors continue to shift during the jump animation and collision checks are
done each time the player is in a new location.

## Holes

The floors must be drawn as a tilemap.  This means that the holes are going to
consist of a sub width tile at the start and end of of the hole.  Like this:

```text

________|___.....|........|..______|________|________|________ >> EOL

```

Here you can see the start of the hole has the pattern masked.  When the hole
moves to the left, the bitmask will be different at the start and end of the
hole.  This pattern repeats until the hole dissappears off the left side of the
screen.  When that happens, the hole begins to form on the right side of the
screen.

There are 8 floors. Four of the gaps move from left to right and down the
screen.  The other 4 gaps move from right to left and up the screen. When a gap
reaches the end of a line, it simply shows up at the beginning of the next line.
This happens because of the way video ram is arranged.

For the gaps that move from right to left, when they reach the front of a line,
they move up to the end of the line above.  Again because of the way video ram
is arranged.

At the beginning of the game, the four gaps moving in a particular direction are
overalaid on top of each other.  When Jack completes a successful jump one of
the gaps is relocated which gives the appearance of a new gap being inserted
into the game.

Gaps can cross over each other.

## FRAME ANIMATION

The original game is animated in groups of 4 frames.  The player has 4 animation
states for each of it's movement types.  The gaps also have 4 frames of
animation.

```text
                 |< Start Gap               End Gap >|
=========|=======|========|........|........|........|======== F0
=========|=======|======..|........|........|......==|======== F1
=========|=======|====....|........|........|....====|======== F2
=========|=======|==......|........|........|..======|======== F3
         |< Start Gap              End Gap >|
=========|=======|........|........|........|========|======== F0
```

The gap is moved to the left by one tile width at the beginning of frame F0.
The intermediate frames dot not move, only the first and last cells are updated
to give the appearence of moving.

## JACK STATE

Jack has various states that define his animation and actions within the game.
These are:

1. Idle
2. Running right
3. Running left
4. Jumping
5. Falling
6. Stunned (landed on floor below)
7. Crashing (hit head)

When Jack is running, he wraps around to the other side of the screen if he
leaves the edge of the screen.

Jumping is a 3 phase affair.

1. Jump animation for 4 frames, move jack up 8 pixels.
2. Good Jump
    2.1. Repeat jump animation for 4 frames, move jack up 8 pixels.
    2.2. Repeat jump animation for 4 frames, move jack up 8 pixels.
    2.3. Set jack to idle state.
3. Bad Jump
    3.1. Repeat jump animation for 4 frames, move jack up 8 pixels.
    3.2. switch to crash animation for 4 frames., Jack doesn't move.
    3.3. switch to fall animation for 4 frames. move jack down 8 pixels.
