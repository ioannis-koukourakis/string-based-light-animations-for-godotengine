# String-based light animations for GodotEngine

A simple light class for the Godot engine inspired by the string-based light animation system originally found in Quake and Half Life games.

Video Preview: https://youtu.be/GOXrcUhZN_c

Created on Godot version 3.4.2 but should work on earlier versions too. 

Installation:
- Setup your lamp scene according to QuakeLamp*.tscn example scenes. Lights and models should be added as child nodes.
- Attach QuakeLamp.gd on your parent lamp node. 
- Drag and drop in your main scene, select the desired animation type and enjoy your new animated light.

Features:
 - Includes 11 original Quake animation tables.
 - Supports custom user animations.
 - Animations can be previewed in the Godot editor.
 - Supports optional fade between the string animation values to break the stepping effect where needed.
 - The light animation affects the emission of the lamp material/s.
