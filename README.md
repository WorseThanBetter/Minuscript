# Minuscript
Spelling-based cryptic puzzle game, created for CS 193.

MVP:
The goal is to create a simple 3D game using the Godot engine that focuses on exploration and spelling. The MVP will include the puzzles, the scripts connecting them, and a small demo level with little to no visuals.

Future:
After MVP and looking towards 2.0, I want to create more puzzles, work on level design, and get some simple visuals in the game to push it past the white box stage.

Tech Stack
- I'll primarily be using Godot's GDScript coding language, inspired by Python.
- I plan to use JSON for data storage.
- No external data pulling is currently planned.

CHUNKED BUILD PLAN
- Set up the git repo and empty Godot project.
- Get a basic player in with a camera and controls.
- Let the player input a word that sends out a global signal.
- Create a modular puzzle structure that lets puzzles individually respond to the global signal, and decide what to do.
- JSON data storage to save progress in-between runs.
- Create basic level design with puzzle ideas included.
- Refine the level with basic visual polish.
