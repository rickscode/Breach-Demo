# BREACH - Godot 4 Setup Guide

## Day One Checklist

### 1. Install Godot 4
```bash
# Option A: Download from official site
# https://godotengine.org/download/macos/

# Option B: Homebrew
brew install --cask godot
```

Download the **Standard** version (not .NET/Mono) since we're using GDScript.

### 2. Install Git LFS
```bash
# Check if installed
git lfs version

# If not installed
brew install git-lfs
git lfs install
```

### 3. Install Blender (for 3D modeling)
```bash
brew install --cask blender

# Or download from: https://www.blender.org/download/
```

### 4. Clone or Initialize the Repository
```bash
# If starting fresh
mkdir Breach
cd Breach
git init
git lfs install

# Copy the files from this setup into the folder
```

### 5. Create the Godot Project

1. Open Godot 4
2. Click "New Project"
3. Browse to your Breach folder
4. Project Name: `Breach`
5. Renderer: **Forward+** (best for 3D)
6. Click "Create & Edit"

### 6. Create Folder Structure
In Godot's FileSystem panel, right-click to create:
```
res://
├── scenes/
│   ├── characters/
│   ├── levels/
│   ├── ui/
│   └── objects/
├── scripts/
│   ├── characters/
│   ├── stealth/
│   ├── combat/
│   └── narrative/
├── assets/
│   ├── models/
│   ├── textures/
│   └── audio/
└── resources/
```

### 7. First Commit
```bash
git add -A
git commit -m "[Setup] Initialize Godot 4 project structure"
git branch -M main
git remote add origin git@github.com:YOUR_USERNAME/Breach.git
git push -u origin main
```

---

## Project Settings to Configure

### Rendering (for PS2 aesthetic)
1. Project → Project Settings → Rendering → Textures
   - Default Texture Filter: **Nearest** (for crisp textures, optional)

2. Project → Project Settings → Rendering → Anti Aliasing
   - Quality: MSAA 2x or 4x

3. Environment settings (in your WorldEnvironment node):
   - Add film grain via shader
   - Add vignette
   - Adjust tonemap for moodier look

### Input Map
Project → Project Settings → Input Map

Add these actions:
| Action | Key |
|--------|-----|
| move_forward | W |
| move_back | S |
| move_left | A |
| move_right | D |
| sprint | Shift |
| crouch | C / Ctrl |
| interact | E |
| attack | Left Mouse |
| aim | Right Mouse |
| codec | Tab |
| pause | Escape |

---

## Your First Scene: Test Arena

1. Create new scene: 3D Scene (Node3D root)
2. Add: **DirectionalLight3D** (sun/main light)
3. Add: **WorldEnvironment** (for post-processing)
4. Add: **CSGBox3D** scaled to (20, 1, 20) — this is your floor
5. Add more **CSGBox3D** nodes for walls
6. Save as `res://scenes/levels/test_arena.tscn`

This gives you a playpen to test ASH's movement before building THE RELAY.

---

## Your First Script: ASH Movement

1. Create new scene: **CharacterBody3D** (root)
2. Add child: **CollisionShape3D** with CapsuleShape3D
3. Add child: **MeshInstance3D** with CapsuleMesh (temporary visual)
4. Add child: **Camera3D** (position it behind/above)
5. Attach script to root → Save as `res://scripts/characters/ash_controller.gd`
6. Save scene as `res://scenes/characters/ash.tscn`

Basic movement script:
```gdscript
extends CharacterBody3D

@export var move_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var crouch_speed: float = 2.5

var current_speed: float

func _physics_process(delta: float) -> void:
    var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    
    # Sprint or crouch
    if Input.is_action_pressed("sprint"):
        current_speed = sprint_speed
    elif Input.is_action_pressed("crouch"):
        current_speed = crouch_speed
    else:
        current_speed = move_speed
    
    if direction:
        velocity.x = direction.x * current_speed
        velocity.z = direction.z * current_speed
    else:
        velocity.x = move_toward(velocity.x, 0, current_speed)
        velocity.z = move_toward(velocity.z, 0, current_speed)
    
    # Gravity
    if not is_on_floor():
        velocity.y -= 9.8 * delta
    
    move_and_slide()
```

---

## Free Assets to Get Started

### Characters
- **Mixamo** (https://www.mixamo.com/) — free rigged characters and animations
  - Download in FBX or GLB format
  - Great for placeholder ASH and enemies

### Models
- **Kenney.nl** (https://kenney.nl/assets) — free low-poly assets
- **OpenGameArt** (https://opengameart.org/) — various 3D models
- **Quaternius** (https://quaternius.com/) — free low-poly packs

### Textures
- **ambientCG** (https://ambientcg.com/) — free PBR textures
- **Poly Haven** (https://polyhaven.com/) — free HDRIs, textures, models

### Audio
- **Freesound** (https://freesound.org/) — sound effects
- **OpenGameArt** — music and sfx

---

## Daily Workflow

1. Open Godot project
2. Open terminal, run `claude` for code help
3. Build/test in Godot
4. When something works:
   ```bash
   git add -A
   git commit -m "[System] What you built"
   git push
   ```
5. Repeat

---

## Troubleshooting

### "Godot won't open on Mac"
System Preferences → Security → Allow Godot

### "Git LFS files not downloading"
```bash
git lfs pull
```

### "CharacterBody3D not moving"
- Check your Input Map has the actions defined
- Make sure collision shape is not disabled
- Check if floor has collision (StaticBody3D or CSGBox3D with Use Collision)

---

*You're ready to build BREACH. Let's go.*
