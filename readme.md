# About
This repository hosts basic exercises for learning vulkan raytracing. These exercises were established as part of the lecture "Algorithmen für Realtime Rendering" held by Prof. Dr. Dreier, Master of Science "Game Engineering and Visual Computing" at the university of applied sciences Kempten.

The code was taken from [Sascha Willems' Vulkan Examples](https://github.com/SaschaWillems/Vulkan) (available MIT License), and modified by me (also via MIT License).

# Folder Structure and File Descriptions
```
root/
 | - vulkan_rt_übung.docx           File explaining the exercises (german)
 | - vulkan_rt_übung_tipps.txt      Some tips for an easier time (german)
 | - vulkanrt/
      | - base/                     Base library (effectively a C++ Vulkan API wrapper) made by Sascha Willems, with minor edits
      | - data/                     Folder containing runtime data for programs, such as models, textures and precompiled shaders
      | - external/                 Folder for external code
      | - vulkanrt-reference/       Directory containing the reference project. Slightly modified copy of Sascha Willems' raytracingreflections example
      | - vulkanrt-exercise1/       Directory containing the base project for solving exercise 1
      | - vulkanrt-exercise2/       Directory containing the base project for solving exercise 2
      | - vulkanrt-solution1/       Directory containing the solution for exercise 1
      | - vulkanrt-solution2/       Directory containing the solution for exercise 2
 ```