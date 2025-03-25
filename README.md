## My Work On This Project

This project was completed as part of my Artificial Intelligence course. The instructions were provided by the course instructor. Modifications were made to the start state, changes are outlined in the `shakey.clp` file.

## How To Run

This project requires CLIPS.

In CLIPS, run:
```
(load "shakey.clp")
(reset)
(run)
```

To view a list of Shakey's possible actions at a given state, run:
```
(run 1)
(agenda)
```
--- 

[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/SVM8l8t6)
# AI-shakey-world
## Planning in Shakey's World
## Due March 14 by 23:59:59

## Introduction
Between 1966 and 1972, Shakey the robot was engineered to be the first robot that could reason about its own actions.  Shakey relied on computer vision and natural language processing to learn fact about its environment.  It was the first computer machine project to combine logical reasoning with physical actions.  Results of this research include the A* algorithm and the Hough transform used in image processing.

The original {Strips} planner was designed to control Shakey the robot.  Reference the included PDF file `shakey.pdf`.  In this version, Shakey’s world consists of six rooms lined up along a two hallways, where each room has a door and a light switch.  The actions in Shakey’s world include moving from place to place, pushing movable objects (such as boxes), climbing onto and down from rigid objects (such as boxes), and turning light switches on and off. The robot itself could not climb on a box or toggle a switch, but the original planner was capable of finding and printing out plans that were beyond the robot’s abilities.  

## Objective
The purpose of this programming project is to investigate how facts can trigger actions that can add more facts that can trigger other actions ...  For this project you will build a CLIPS knowledgebase (program) that generates (prints to standard output) a plan of actions Shakey must perform that moves Shakey from the start state to the goal state.

The inital state and goal state are provided in the file `shakey.pdf`.

## Capabilities
In this version, Shakey is a small robot.  It has 360 degree movement.  It has 360 degree vision but he cannot see in the dark (thus the need to turn on/off lights).  It has the capability of getting on top of a box (to turn on/off light switches with its robotic arm).  It can open doors and push boxes around on the floor, but it cannot lift them.

## Assignment
Design a CLIPS knowledgebase that:
1. Defines the start state.
2. Defines the goal state.
3. For every action Shakey must perform, output that action to standard output.
4. Implements, at a minimum, the following functions (or similar).
   - `Go(x, y, r)`, which requires that Shakey be At `x` and that `x` and `y` are locations `In` the same room `r`.  By convention a door between two rooms is in both of them.
   - Push a box `b` from location `x` to location `y` within the same room: `Push(b,x,y,r)`.  You will need the predicate `Box` and constants for the boxes.
   - Climb onto a box from position `x`: `ClimbUp(x,b)`; climb down from a box to position `x`: `ClimbDown(b,x)`.  We will need the predicate `On` and the constant `Floor`.
   - Turn a light switch on or off: `TurnOn(s,b)`; `TurnOff(s,b)`.  To turn a light on or off, Shakey must be on top of a box at the light switch’s location.
5. Start your simulation by adding the fact `Start`.
6. For program development, use an iterative, bottom-up design.  Start small.  Implement Shakey moving around one room.  Then add additional rooms until the goal state is complete.
7. There are *_many_* plans that can be developed.  You do not have to move the boxes in any kind of numerical order.
