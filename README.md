# Jump Queen

A 64x64 2D platformer built entirely in MIPS assembly. Players navigate challenging vertical levels with precise jumps and timely powerups. 

(Demo [below](https://github.com/andre-fong/Jump-Queen-Assembly/new/main?filename=README.md#demo) if you'd like to see!)

## Features

* Player movement control (left, right, jump)
* Challenging platform placement and moving platforms
* Falling to the bottom of level 2/3 will bring the player back to the top of level 1/2 respectively (and takes away a heart)
  * Emulates one large vertical level!
* Powerups!
  * **Feather**: Enhance the player's next jump to have less gravity.
  * **Hourglass**: Slows down time (maneuver moving platforms easier!).
  * **Hearts**: Life-up hearts.

## How To Run

1. Download the MARS Assembly simulator from https://courses.missouristate.edu/kenvollmar/mars/download.htm.
2. Clone the repo.
   ```sh
   git clone https://github.com/andre-fong/Jump-Queen-Assembly.git
   ```
3. Open `game.asm` in the MARS simulator.
4. Under "Tools", select the "Keyboard and Display MMIO Simulator" option.
   
   ![image](https://github.com/andre-fong/Jump-Queen-Assembly/assets/99469779/7d125768-0450-4253-af47-36801d21499b)
5. In the new popup, click "Connect to MIPS".

   ![image](https://github.com/andre-fong/Jump-Queen-Assembly/assets/99469779/2da72670-7833-4171-a217-fd36576030cc)
6. Under "Tools" again, select the "Bitmap Display" option.

   ![image](https://github.com/andre-fong/Jump-Queen-Assembly/assets/99469779/7d125768-0450-4253-af47-36801d21499b)
7. Copy the configuration settings shown below, and click "Connect to MIPS".

   ![image](https://github.com/andre-fong/Jump-Queen-Assembly/assets/99469779/24fa2aae-cd64-4ab8-ab88-c1b8e5119287)
8. Under "Run", click "Assemble", then click "Go".

   ![image](https://github.com/andre-fong/Jump-Queen-Assembly/assets/99469779/688969fe-aef1-48bb-b3e8-9575ff6de3ab)
9. The game has been started! For player control, ensure that the keyboard input is being typed into the "Keyboard and Display MMIO Simulator" window.

   ![image](https://github.com/andre-fong/Jump-Queen-Assembly/assets/99469779/134804c2-3aec-489c-ba93-1f075bed6e41)
10. While playing, you can click 'q' to quit, and 'r' to restart from level 1 at any time. Enjoy!

## Demo

https://github.com/andre-fong/Jump-Queen-Assembly/assets/99469779/e61a6ab0-537d-4c9e-a66f-354ee09565f9

<img src="https://github.com/andre-fong/Jump-Queen-Assembly/assets/99469779/b984ba97-052b-4285-bb7e-e9811fb03da7" alt="drawing" width="100"/>
