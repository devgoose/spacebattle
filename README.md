# Space Battle Processing Simulation

![art1](/images/1.jpg)
![art2](/images/art1.jpg)
![art3](/images/3.jpg)

"Space Battle" is an interactive simulation of...well, a battle in space. It began as a project in the University of Minnesota's
5611 Interaction and Graphics course as a basic implementation of "Boid" movement of objects in a 2D space, and was expanded upon to
make this simulation.

The battle simulates two armies of spaceships fighting in a solar system, with several different camera and interaction modes. The simulation
is designed in Processing.

## Features

- 3D simulation of hundreds to thousands of agents interacting with each other
- Implementation of a configurable particle system, used for bullets/explosions
- Complex velocity-based interactions and targeting system
- Several different game states and control systems
- Geometrically correct orientation of all 3D objects
- Player-controlled ship that can fight in the battle

#### Instructions

There are three camera modes, switched with the keys 1: default, 2: boid, 3: game

On default mode, the simulation runs as normal and you can move the camera around. Several keys also control boid movement parameters and these are printed to the console so you know what they are.
W/S: Accelerate forward/backward
A/D: Accelerate left/right
E/Q: Accelerate up/down
LEFT/RIGHT: Turn left/right
UP/DOWN: Turn up/down
T/F: Increment maximum boid speed up and down
Y/G: Increment maximum boid acceleration up and down
U/H: Increment the how influential a nearby enemy boid is to each boid's movement
I/J: Increment how well a boid can aim at a target
SPACE: Pause the simulation! Fly around and can still switch camera modes, while everything is still

In boid mode, the camera is affixed to a boid, so you can view the boid from it's perspective.
LEFT/RIGHT: change boid to follow

In game mode, the camera is fixed to a green ship, and you can control the ship.
W/S: Accelerate forward/backward
A/D: Yaw left/right
LEFT/RIGHT: Roll left/right
UP/DOWN: Pitch up/down (inverted)
SPACE: Hold to shoot
The ship's rotational velocity will decelerate automatically, but its forward velocity does not (because it's in space.)
The ship acts as an object just like all the boids. Every boid in the scene will try to target you if it can. You can
destroy boids by shooting them as well.

## Video demonstration

https://www.youtube.com/watch?v=WmY4zTw1Bcw&feature=youtu.be

| Time | Feature                              |
| ---- | ------------------------------------ |
| 0:00 | Basic 3D Flocking                    |
| 0:09 | Boid Orientation                     |
| 0:19 | Camera Movement                      |
| 0:32 | Obstacle Avoidance                   |
| 0:56 | Benchmarks                           |
| 1:07 | Boundary                             |
| 1:13 | Particle System: Bullets             |
| 1:34 | Particle System: Explosion           |
| 1:41 | Variable Statistics User Interaction |
| 2:06 | Enemy Flocks                         |
| 2:21 | Targeting System                     |
| 3:14 | Particle Collision                   |
| 3:30 | Simulation Context                   |
| 3:43 | Multiple Obstacles                   |
| 4:03 | Obstacle Collision                   |
| 4:25 | Boid Camera Mode                     |
| 4:53 | Player Camera Mode                   |

![art4](/images/art2.jpg)

## Credit

Original code, hosted on university account (with some extra stuff on other branches):
https://github.umn.edu/walte735/5611-p1

Processing:
https://processing.org/
Planet models and textures from user "3dShard" on CGTrader:
https://www.cgtrader.com/free-3d-models/space/planet/alien-grey-planet
https://www.cgtrader.com/free-3d-models/space/planet/pink-alien-planet
https://www.cgtrader.com/free-3d-models/space/planet/blue-water-planet
https://www.cgtrader.com/free-3d-models/space/planet/natural-planet

Blue planet and sun texture from:
https://www.solarsystemscope.com/textures/

Spaceship models from:
https://www.cgtrader.com/free-3d-models/space/spaceship/spaceships-pack

Paper airplane model from:
https://www.cgtrader.com/free-3d-models/sports/toy/paper-plane-8a4daa54-6700-4e17-9e19-8feb6acdcd67

Music from:
https://www.bensound.com/royalty-free-music/track/new-dawn
Star Fox (SNES)
"Trouble on Mercury" : https://soundimage.org/sci-fi/

Video edited with: https://fxhome.com/hitfilm-express
