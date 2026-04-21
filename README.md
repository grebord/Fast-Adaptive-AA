# Fast-Adaptive-AA

This in an antialiasing shader for Reshade, based on Timothy Lottes' PC FXAA v3.  

Overhauled edge detection is its main feature: The original algorithm has been replaced with a new one that preserves visual quality better, while catching more noticeable edges.  

Major refactoring went into the shader code, subpixel AA has been removed to prevent blur and the edge processing is now much more readable and maintainable without sacrificing performance.  

It is faster than even low-quality SMAA, and visual quality is much better than original FXAA, on par with -and sometimes better than!- SMAA.  

Try it out!  

## License

This project is licensed under the MIT License (see [LICENSE](LICENSE)).   
Portions are based on FXAA 3.11 by Timothy Lottes / NVIDIA.  
See the top of the shader source file for original copyright/disclaimer.
