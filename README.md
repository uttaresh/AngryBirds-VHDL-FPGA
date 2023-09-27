# AngryBirds-VHDL-FPGA

## Acknowledgment
* This project was done for school in collaboration with my teammate, Lauren.
* We leveraged helper code for coloring and display that was provided for help by course staff.

## Intro
For this project, we re-created a dumbed-down version of the game Angry Birds. The real game is probably built on some modern gaming engine optimized for iOS and Android (think Unity). Our goal is not to build anything like that -- rather it's a tribute to the game by building a very retro, simplified, single-level "70's" version of the game.

The game would consist of a circuit implemented on an Altera DE2 FPGA board, with user-based interaction from the keyboard and display on a VGA monitor. The player launches a bird (or an object) at the target – the pig. The goal is to destroy all pigs on the display by hitting them directly or by knocking down their building.

To make it all work, we needed to program the following circuits on our FPGA:
* User input receiver via keyboard
* Physics engine to calculate the trajectory of the objects, impact of gravity, simulation of "time"
* Launch and impact modules to control the birds being thrown and the pigs being hit.
* Display unit: The circuit logic to display our game on screen (we used my TV)

## Learnings

In this project, we:
- Applied our knowledge of VHDL to a practical, interesting use-case. 
- Were forced to think creatively to tackle issues, including:
  -  floating point calculation for sine and cosine values
  -  imitating the effects of gravity for projectile motion
-  Learned the value of a modular approach for circuit building
-  Improved our VHDL, FPGA, and circuit debugging techniques.

## Gameplay

Essentially, our game works just like a level of the real game Angry Birds:
- Start off with a still, red angry bird on top of a slingshot on the bottom-left corner of the screen.
- The gamer selects a launch angle using the keyboard between -90° and 90° ('w' for up, 's' for down).
- The gamer selects a launch velocity between 0 and 7 ('a' for decrease, 'd' for increase).
- Once they are ready to launch, the gamer presses the spacebar and the bird is released at the selected angle and velocity.
- The bird stops moving when:
  - it runs out of energy. 50% loss each time the bird hits an object or the ground
  - it hits a pig
  - it goes out of the playing area
- The goal of the game is to hit and eliminate all pigs on the screen.

## Limitations

We were restricted by timing, resources, and limitations of VHDL and our FPGA board. Our game is much simpler than the real Angry Birds game. Some major gaps in our game include:
- Graphics: We were limited to bare bone graphics with the use of sprites and simple geometrical shapes and objects.
- Sound: Our game does not include sound effects.
- Multiple levels and birds: Our game consists solely of one simple level and one red bird.
- Advanced animations and effects: We did not include advanced effects, such as the pigs laughing, the birds blinking, shadows, wind, clouds, etc.
- Object interaction: You cannot interact with background or foreground items. You cannot topple bricks on top of pigs to kill them, make them fall off ledges, etc.
- Countless more...

## Description of Circuit

Due to the complexity of our circuit, it is divided into multiple entities. The overall circuit is found in the top-level entity called AngryBirds. AngryBirds contains many components connected together logically (as depicted in the attached block diagram) which collectively create the entire Angry Birds game setup.

The control entity is used to decide the state of the machine. It controls the entire game process, all the way from the game being started and keyboard input being taken to the successful elimination of a pig.

Keyboard input is obtained to decide the initial launch vector of the bird. Once the bird is released, the Progressor entity keeps track of the progress of the bird throughout the game space. It calculates where the bird should be based on velocity and also applies the gravitational effect. It also keeps checks if the bird has hit a pig or has gone off screen and reports appropriately to the state machine and the display unit.

The Color Mapper entity (when connected to the VGA Unit) is used to display the game on the monitor. It is responsible for drawing the birds, the pigs, and the environment.

## Entity Guide

_AngryBirds:_ This is the top level entity that connects everything, from the Slingshot that calculates the launch vector to Progressor that is in charge of the game to the HexDriver which is used to display the launch angle and velocity.

_Control:_ This entity is controls the state machine. It receives signals from all other entities and outputs the appropriate signals to control the state of the machine. Initially we start out in the Calculate state, in which the Slingshot entity is active. Once the spacebar is pressed, the control unit raises the signal for the Progressor entity to start working, which starts the motion of the bird on the screen. Based on the pigs hit, control also decides whether or not the game has been won.

_Slingshot:_ This entity is used to receive user input from the keyboard and output the launch vector for the bird. Based on the launch angle, the appropriate sine and cosine values are output using a set of if-else statements used as a lookup tables. However, sine sine and cosine values are between -1 and +1 and consist of floating point numbers, they are left shifted by 5 (multiplied by 32) to allow for more precise calculation. The launch velocity is multiplied by this cosine factor to obtain the initial velocity in the x-direction, and it is multiplied by the sine factor to obtain the initial velocity in the y-direction.

_Progressor:_ The Progressor entity is used to control the motion of the bird. The bird is initially at rest on top of the slingshot. Once the control signal raises the signal M, the Progressor entity starts moving the bird based on the initial x- and y- velocity components received from Slingshot. This entity uses the same 60Hz clock as the monitor to keep everything in synch.

Each cycle the bird is in motion, we subtract a certain fixed value from the y-velocity (representing the gravitational acceleration g) to simulate the gravitational effect. At the same time, we add the x-velocity to the x component of the position of the bird and y-velocity to the y component of the position. In this way, the projectile motion of the bird is simulated on screen. Also, remember from the Slingshot entity description that we had left shifted everything by 5 to allow for more precision and to get around doing floating point calculations. Therefore before the positions are output on the screen, we must right shift it by 5 to obtain the correct format.

If the bird hits the ground or an environmental object, it bounces off with a reduced percentage of its velocity to simulate inelastic collisions. If the bird hits a pig, the pig is dead. The signal for that pig is raised and sent to the Color\_Mapper and control units to make sure that the pig is taken off the screen.

_Color\_Mapper:_ This entity is used to display the game on the VGA screen. For every pixel on the screen, it outputs the correct RGB value. Based on the location on the screen, it draws a light blue sky and a beach-colored ground. It also draws a stone block and a wooden stand for two of the pigs to sit on. It receives the location of the three pigs from the top level entity and draws the three pigs on the screen. Finally, it also receives the current location of our angry bird and displays it on the screen.

_HexDriver:_ Same as the hex driver provided in previous labs, this is used to display the launch velocity and angle on the FPGA board.

_Scanner_: Upon key press/release, the keyboard sends the correct scan codes (i.e. make codes and break codes for the key) using the ps2data signal serially in synchronization with the ps2clock. The scanner entity receives these bits from the keyboard using the PS/2 input provided on the FPGA and outputs the corresponding scan codes in two shift registers.

This is actually quite simple; as the keyboard sends the bits serially to the scanner entity, they are shifted into the registers. Also the scanner entity ensures that only the correct bits are read in the correct position by only outputting make or break codes when the correct start and stop bits are received in their correct positions.

This entity, along with the next three entities listed here, are very similar to those used in Lab 8, BouncingBall.

_Synch_: As mentioned above, using two clocks in a circuit can cause various problems, which is why we use the ps2clk as a data signal. The synch entity gets the ps2clk from the keyboard and outputs a single bit called fall\_edge which is high whenever we are on the falling edge of the PS2 clock. This signal is synchronized with actual clock from the FPGA. However, the FPGA clock is too fast for the PS2 keyboard and has to be slowed down tremendously.

_clkSlower_: This entity receives an original clock and outputs a much slower clock, as required by the various components used in this assignment. For example, it takes as input the original FPGA clock and outputs a clock with a much lower frequency (100x less) than the FPGA clock for keyboard synchronization. This entity consists of a 9-bit counter which is used to create a much slower clock.

_direction\_detector_: Once the scanner unit outputs the correct scan codes for the key pressed, the direction\_detector entity translates this into the appropriate high and low signals for the appropriate keys; i.e. W, A, S, D, and Space.

## Stats

- Total Logic Elements: 1,173
- Total Registers: 176
- Maximum Operating Frequency: 119.86MHz

## Possible VHDL Improvements

- To reduce the number of logic elements, we could reduce the number of if-else statements by replacing them with case statements which may take fewer muxes.
- We could replace some signals with hard-wired values to reduce the number of registers.
- We use a set of if-else statements for the sine and cosine Lookup Table.
- We could program these into RAM to significantly reduce the number of muxes used, although that would come at the price of longer load times.
- We realized, too late unfortunately, the risk of running such a complicated circuit with so few control signals. Some bugs can be removed by using a few more control signals, and by the proper use of VHDL process statements. We did not know much about the process sensitivity list before project submission, which could have helped us create a better project.
