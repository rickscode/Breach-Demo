# BREACH - Godot 4 Tactical Stealth Action

## Project Overview
A story-driven stealth action game inspired by Metal Gear Solid's deep narrative and infiltration gameplay. PS2-era visual fidelity (MGS2/MGS3 style) with modern lighting and post-processing. Single-player campaign focused.

**BREACH 1** is the Godot 4 proof-of-concept. If successful, BREACH 2 moves to Unreal Engine 5 with photorealistic visuals.

## Story Context (See BREACH_STORY_BIBLE.md for full details)

**Logline:** A disavowed operative infiltrates the fortress of the private military contractor that trained them, to expose a global AI-driven assassination program before it goes live.

**Tagline:** *"They burned me. I'm what's left."*

**Player Character:** ASH — former AXIOM operative, betrayed after discovering their targets were innocent

**Enemy:** AXIOM SOLUTIONS — PMC running BLACK LIST, an AI that generates global kill orders

**Primary Antagonist:** SHEPHERD — ASH's former mentor, true believer in AXIOM's mission

**Codec Team:**
- ORACLE — Handler, mysterious, knows too much
- WRENCH — Tech/weapons, sarcastic, reliable
- DOC — Medical, warm, moral compass
- GHOST — Intel analyst, nervous, possibly compromised

**Theme:** "Who decides who deserves to live?"

**Demo Level:** THE RELAY — Small AXIOM facility, tutorial mission, ends with ASH finding their own name on the kill list

**Combat Tone:** Stylized, high-impact “wow” action with cinematic gore beats (John Wick-style precision and intensity).

## Tech Stack
- **Engine**: Godot 4.3+ (GDScript)
- **Dev Machine**: Mac M2 (runs locally, no cloud needed)
- **Version Control**: Git + GitHub
- **3D Modeling**: Blender (free)
- **Audio**: Audacity (free)
- **Production**: OBS (Capture) & DaVinci Resolve (Editing)

## Visual Direction (PS2-Era Fidelity)

### Target Aesthetic
MGS2/MGS3 on PS2 — not retro for retro's sake, but clean stylized 3D that prioritizes readability and atmosphere over polygon count.

### Environment — THE SPIRE (AXIOM HQ)
- Dystopian megacorp compound
- Clean corporate facades hiding brutal infrastructure
- Server farms, research labs, detention levels
- Industrial underbelly with pipes and machinery

### What Sells The Look
- **Dramatic lighting**: Strong single sources, deep shadows
- **Fog/atmosphere**: Hides draw distance, adds mood
- **Animation quality**: Smooth, weighty movement
- **Sound design**: Audio does half the immersion work
- **Post-processing**: Film grain, color grading, vignette
- **Readability**: Clean silhouettes

### Lighting Palette
- Cold blue corporate lighting
- Warm orange emergency systems
- Neon accents (cyan AXIOM branding, magenta hazards)
- Darkness as a gameplay element

## Architecture

### The Pipeline (All Local)
```
Mac (Claude Code + Godot Editor)
            ↓
    Write GDScript
    Build scenes
    Test immediately
    Iterate fast
            ↓
       Git Push → GitHub
```

No cloud. No waiting. No monthly fees.

## Project Structure
```
Breach/
├── project.godot
├── scenes/
│   ├── characters/
│   │   ├── ash.tscn
│   │   └── enemy.tscn
│   ├── levels/
│   │   ├── the_relay.tscn
│   │   └── test_arena.tscn
│   ├── ui/
│   │   ├── hud.tscn
│   │   ├── codec.tscn
│   │   └── game_over.tscn
│   └── objects/
│       ├── door.tscn
│       └── hiding_spot.tscn
├── scripts/
│   ├── characters/
│   │   ├── ash_controller.gd
│   │   └── enemy_ai.gd
│   ├── stealth/
│   │   ├── detection_system.gd
│   │   ├── noise_system.gd
│   │   └── cover_system.gd
│   ├── combat/
│   │   ├── weapon_base.gd
│   │   └── health_component.gd
│   └── narrative/
│       ├── codec_system.gd
│       └── objective_manager.gd
├── assets/
│   ├── models/
│   ├── textures/
│   └── audio/
└── resources/
```

## GDScript Conventions

### Naming
- **Classes**: PascalCase (AshController, EnemyBase)
- **Files**: snake_case (ash_controller.gd)
- **Functions**: snake_case (apply_damage)
- **Variables**: snake_case (max_health)
- **Constants**: SCREAMING_SNAKE (MAX_SPEED)
- **Signals**: past tense (health_changed, enemy_spotted)

### Script Template
```gdscript
class_name AshController
extends CharacterBody3D

## Player character controller for ASH

signal health_changed(new_health: float)
signal detected_by_enemy(enemy: Node3D)

@export var move_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var crouch_speed: float = 2.5
@export var max_health: float = 100.0

var current_health: float
var is_crouching: bool = false
var is_sprinting: bool = false

@onready var camera: Camera3D = $Camera3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
    current_health = max_health

func _physics_process(delta: float) -> void:
    handle_movement(delta)

func handle_movement(delta: float) -> void:
    pass

func apply_damage(amount: float) -> void:
    current_health -= amount
    health_changed.emit(current_health)
    if current_health <= 0:
        die()

func die() -> void:
    # Trigger game over — "ASH! ASH! ASHHHHH!"
    pass
```

## Core Systems to Build

### Phase 1: Movement & Camera
- [ ] Third-person character controller
- [ ] Camera follow (MGS-style)
- [ ] Walk, sprint, crouch
- [ ] Basic animations

### Phase 2: Stealth Basics
- [ ] Vision cone detection
- [ ] Detection states (Unaware → Suspicious → Alert)
- [ ] Noise system
- [ ] Hiding spots

### Phase 3: AI
- [ ] Patrol routes
- [ ] State machine
- [ ] Alert propagation
- [ ] Search behavior

### Phase 4: Stealth Actions
- [ ] CQC takedowns
- [ ] Body drag
- [ ] Distraction throws

### Phase 5: Combat (Fail State)
- [ ] Pistol weapon
- [ ] Health/damage
- [ ] Enemy combat AI

### Phase 6: Narrative
- [ ] Codec UI
- [ ] Dialogue system
- [ ] Objectives

### Phase 7: Polish
- [ ] Post-processing
- [ ] Sound design
- [ ] Game over screen

## Git Workflow

Commit format:
```
[System] Brief description
```

Examples:
- `[Player] Add crouch and sprint`
- `[AI] Implement patrol routes`
- `[Stealth] Vision cone detection`

## Current Sprint
Phase 1 - Third-person movement and camera
