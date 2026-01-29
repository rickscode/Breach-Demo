# BREACH - UE5 Tactical Realism FPS

## Project Overview
A short tactical realism first-person shooter demo inspired by the visual style of "Bodycam," the industrial atmosphere of Metal Gear Solid 2 (Tanker), and a gritty Cyberpunk aesthetic. Built as a learning project to master the Claude Code + Cloud VM workflow.

## Visual Direction (The "Cyber-Tanker" Look)

### Environment
- Industrial maritime/facility (steel walls, corrugated metal, pipes, valves)
- Tight corridors, catwalks, cargo holds, engine rooms
- Mix of "Bodycam" grit and "Cyberpunk" neon/grime

### Surface Detail
- Wet metal floors with puddle reflections
- Steam vents and heavy hydraulic machinery
- Rust, grime, oil stains on surfaces
- Exposed wiring and conduits

### Lighting
- High-contrast shadows with flickering emergency lights
- Orange/blue color temperature contrast
- Neon hazard strips and warning signs
- Volumetric fog/steam catching light
- Lumen GI for realistic bounce light

### Camera Feel (Bodycam DNA)
- Low FOV (~70 degrees)
- Heavy motion blur
- Film grain post-process
- Chromatic aberration
- Realistic camera inertia and shake
- Slight lens distortion

## Tech Stack
- **Engine**: Unreal Engine 5.5 (C++ and Blueprints)
- **Local Dev**: Mac M2 (Claude Code for C++ development)
- **Cloud Dev**: Vagon (UE5 Editor, compilation, testing)
- **Version Control**: Git + Git LFS
- **Production**: OBS (Capture) & DaVinci Resolve (Editing)

## Architecture

### The Pipeline
```
Mac (Claude Code) → Git Push → Vagon (UE5 Editor)
     ↓                              ↓
  C++ Logic                   Compile + Test
  Header Files                Blueprint Wiring
  Game Systems                Materials/Lighting
                              Level Design
```

### What Gets Written Locally (Claude Code)
- All C++ source files (.cpp, .h)
- Game logic, player mechanics, weapon systems
- AI behavior trees (C++ side)
- Configuration files (.ini)

### What Gets Done on Vagon (Manual)
- Blueprint visual scripting
- Material creation (wet metal, industrial shaders, neon emissives)
- Lighting and post-processing (Lumen/LUT)
- Level design and asset placement
- Playtesting and debugging

## Project Structure
```
Breach/
├── Source/
│   └── Breach/
│       ├── Characters/
│       │   ├── BreachCharacter.cpp/.h
│       │   └── EnemyCharacter.cpp/.h
│       ├── Weapons/
│       │   ├── WeaponBase.cpp/.h
│       │   └── Pistol.cpp/.h
│       ├── Components/
│       │   ├── HealthComponent.cpp/.h
│       │   └── FlashlightComponent.cpp/.h
│       └── Breach.Build.cs
├── Content/                    # MANAGED ON VAGON ONLY (Excluded from Git)
├── Config/                     # Input and Game settings
└── Breach.uproject
```

## Coding Conventions

### Naming
- **Classes**: PascalCase with prefix (ABreachCharacter, UHealthComponent)
- **Functions**: PascalCase (GetCurrentHealth, ApplyDamage)
- **Variables**: PascalCase for UPROPERTY, camelCase for local
- **Booleans**: b prefix (bIsAlive, bCanFire)

### UE5 Macros - Always Use
```cpp
UCLASS()           // Before class declaration
UPROPERTY()        // Expose to editor/Blueprints
UFUNCTION()        // Expose functions to Blueprints
```

### Common UPROPERTY Specifiers
```cpp
UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Stats")
UPROPERTY(VisibleAnywhere, BlueprintReadOnly)
UPROPERTY(EditDefaultsOnly)  // Only in Blueprint defaults
```

### Common UFUNCTION Specifiers
```cpp
UFUNCTION(BlueprintCallable, Category = "Combat")
UFUNCTION(BlueprintImplementableEvent)  // Implement in BP
UFUNCTION(BlueprintNativeEvent)         // C++ default, BP override
```

## Core Systems to Build

### Phase 1: Movement
- [ ] Basic FPS character controller
- [ ] Walk, sprint, crouch
- [ ] Head bob and camera shake
- [ ] Footstep sounds integration point (metal clanks, water splashes)

### Phase 2: Interaction
- [ ] Flashlight toggle
- [ ] Door interaction (bulkhead doors, sliding industrial doors)
- [ ] Valve/switch interaction
- [ ] Basic pickup system

### Phase 3: Combat
- [ ] Weapon base class
- [ ] Pistol implementation
- [ ] Hitscan shooting
- [ ] Damage system
- [ ] Health component

### Phase 4: Feel (The "Cyber-Tanker" Look)
- [ ] Low FOV (~70)
- [ ] Heavy motion blur
- [ ] Film grain post-process
- [ ] Chromatic aberration
- [ ] Realistic camera inertia
- [ ] Wet surface materials (puddle reflections)
- [ ] Neon emissive materials
- [ ] Volumetric fog/steam
- [ ] Flickering light Blueprints

## Git Workflow

### Before Pushing (Mac)
```bash
git add -A
git commit -m "descriptive message"
git push origin main
```

### On Vagon (After Pull)
```bash
cd D:\Projects\Breach
git pull origin main
# Open UE5, Hot Reload or full compile
```

### Commit Message Format
```
[System] Brief description

- Detail 1
- Detail 2
```

Examples:
- `[Character] Add sprint mechanic with stamina`
- `[Weapon] Implement base weapon class`
- `[Config] Update input mappings`

## Important Notes

1. **Never commit Content/ folder** - Too large, managed on Vagon
2. **Always compile on Vagon** - Mac can't run UE5
3. **Use Live Coding** - Ctrl+Alt+F11 in UE5 for fast iteration
4. **Derived Data** - Delete DerivedDataCache/ if space gets tight on Vagon

## Asset Direction (For Vagon Work)

### Recommended Megascans/Quixel Categories
- Industrial surfaces (metal panels, grating, pipes)
- Machinery and mechanical parts
- Wet/weathered surface decals
- Debris and grime

### Custom Materials Needed
- Wet metal (high roughness variation, puddle blend)
- Neon emissive strips (cyan, magenta, orange)
- Rust/corrosion blend material
- Steam/fog particle material

### Reference Games
- Metal Gear Solid 2 (Tanker chapter)
- Cyberpunk 2077 (industrial areas)
- Bodycam (camera feel and grain)
- Alien: Isolation (industrial sci-fi atmosphere)

## Commands for Claude

When asked to create game systems, always:
1. Create the .h file first with full documentation
2. Create the .cpp implementation
3. Explain what Blueprint connections are needed
4. Note any Content/ work required on Vagon
5. Consider the industrial/cyberpunk setting when naming and designing systems

## Current Sprint
Phase 1 - Basic movement and character setup
