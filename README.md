# cg_project_godot4

### Team

- Andrei Potrebin
- Natalja Frantikova
- Kaspar Metsa

### What Did We Do?
- We created a first-person survival horror game set on a ship at night, where the player must defend against a kraken's tentacles emerging from the dark ocean.

#### Core Gameplay
- Explore a detailed wooden ship with multiple rooms, including a captain's cabin, storage areas, and deck
- Collect items such as binoculars (for scouting), bottles (throwable weapons), and an axe (melee weapon)
- Defend the ship against tentacles that emerge from the water and attempt to grab hold of the vessel
- Manage stamina - sprinting drains energy, which can be restored by sleeping in the cabin bed
- Survive - if too many tentacles grab the ship simultaneously, the player loses

### How Did We Do It?
- Godot 4 for the Game engine - handles rendering, physics, scripting, and game logic.
- Blender for 3D modeling - all assets(except the radio) were created in Blender and exported as .glb files.
- GDScript- Programming language for game mechanics and systems.
- GLSL for ocean shader.

### All 3D models were hand-crafted in Blender(except radio):

- Ship - Detailed wooden vessel with proper collision geometry (40+ collision shapes)
- Furniture - Bed, table, chairs, helm/steering wheel, crates, lockers
- Items - Binoculars, bottles, axe, lanterns
- Tentacles - Rigged and skinned for IK-based animation
- Textures - 2K resolution albedo, normal, roughness, and metallic maps

### Shaders
#### Screen Distortion Shader
- A post-processing effect that adds visual feedback:
```
// Wavy distortion with noise
float wave = sin(uv.y * frequency + TIME * speed) * strength;
vec3 noise_color = vec3(rand(uv + TIME));
```

#### Ocean Shader
- written in GLSL
- Features:
  - Wave Simulation
  - Moonlight Reflection with Blinn-Phong reflection model

### Atmosphere
- Dark sky
- Volumetric fog
- Large moon with emissive material
- Lantern lighting throughout the ship interior
 
### Game Systems
- Tentacles
  - 11 spawn points positioned around the ship
  - 18 grab points distributed across the ship
  - State machine: INACTIVE → EMERGE → REACH → HOLD → RETURN
  - Wave spawning: 1-2 tentacles emerge every 1-3 seconds
  - Lose condition: 7+ grab points held for 5 seconds
 
### Download & Play

**[Download Windows Build (.exe)](https://drive.google.com/drive/folders/1JSrIa1oyvGYWlGrNvNBCfTI2XZFjGSZB)**

### Controls
| Key | Action |
|-----|--------|
| WASD | Move |
| Mouse | Look around |
| Shift | Sprint (uses stamina) |
| E | Interact |
| Left Click | Use item (throw/swing) |
| Right Click | Zoom (binoculars) |

### Launch Guide (via Godot)

#### Prerequisites

Make sure you have Godot 4 installed.

**Option A:** Visit [Godot Game Engine's official download page](https://godotengine.org/download/windows/) and download the latest Godot 4.x version for your operating system.

**Option B:** Go to Steam and search for *Godot Engine*. Add it to your library and install it.

In order to run the game in Godot:

1. Clone the repository
`git clone https://github.com/potrebin/cg_project_godot4.git`
2. Open Godot 4
   - See prerequisites if you don't have Godot 4 installed
3. Click *Import*
4. Select the *cg-project-2025* folder in the clones repo and open it
5. When the project fully loads, click the *Run Project* button (small triangle on the top bar)

### Launch Guide (Windows executable)

1. Access this [Google Drive link](https://drive.google.com/drive/folders/11ZzY9g2W_P0qKzqwXunJ6knNs5-Nfbcd?usp=sharing)
2. Download the folder
3. Once downloaded, run the `.exe` game file
