# This is a simple shader to simulate a retro screen for your PSX games on Unity URP.
> ⚠️ This shader has been tested ONLY on the Unity URP 2022.3 LTS version. Please keep this in mind.
>
>>  Also note that this shader is **ONLY** for Unity URP, it will **NOT** work on HDRP rendering.
## Description
This is a “true” CRT simulation with every scanline being divided into multiple sets of red, green, and blue squares. Also, the shader has support for effects such as:
* Scanlines
* Changing the screen resolution
* Roll effect
* Noise
* Color settings
* Warp
* Vignette
## Installation and usage
1. Create an `Assets/Shaders` folder and move all the downloaded files there.
2. Create a material and assign a `Custom/Vhs Effect` shader to it.
3. Customize it to your liking.
4. Go to your Render Pipeline Settings -> Add Renderer Feature -> Vhs Effect Feature.
5. Enjoy it!
## Images
###### Only CRT simulation
![image](https://github.com/user-attachments/assets/0fa0056d-3299-428b-988c-515f47fd2600)
###### Roll effect
![image](https://github.com/user-attachments/assets/b1183945-f904-4bd1-8345-0b33197c6e83)
