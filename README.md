# Fast-Adaptive-AA

This in an antialiasing shader for Reshade, based on Timothy Lottes' PC FXAA v3.

Edge detection has been replaced with a new algorithm that preserves visual quality better, while catching more noticeable edges.
Major refactoring went into the shader code, subpixel AA has been removed to prevent blur and the edge processing is now much more readable without sacrificing performance.

It is much faster than even low-quality SMAA, and visual quality is much better than original FXAA, on par with -and sometimes better than!- SMAA.

Try it out!
