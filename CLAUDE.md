# BREACH - UE5 Tactical Realism FPS

## Project Overview
A short tactical realism first-person shooter demo inspired by the visual style of "Bodycam". Built as a learning project to master the Claude Code + Cloud VM workflow.

## Tech Stack
- **Engine**: Unreal Engine 5.5 (C++ and Blueprints)
- **Local Dev**: Mac M2 (Claude Code for C++ development)
- **Cloud Dev**: Vagon (UE5 Editor, compilation, testing)
- **Version Control**: Git + Git LFS

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
- Configuration files

### What Gets Done on Vagon (Manual)
- Blueprint visual scripting
- Material creation and editing
- Lighting and post-processing
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
├── Content/                    # Managed on Vagon only
├── Config/
└── Breach.uproject
```

## Coding Conventions

### Naming
- Classes: PascalCase with prefix (ABreachCharacter, UHealthComponent)
- Functions: PascalCase (GetCurrentHealth, ApplyDamage)
- Variables: PascalCase for UPROPERTY, camelCase for local
- Booleans: bIsAlive, bCanFire (b prefix)

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
- [ ] Footstep sounds integration point

### Phase 2: Interaction
- [ ] Flashlight toggle
- [ ] Door interaction
- [ ] Basic pickup system

### Phase 3: Combat
- [ ] Weapon base class
- [ ] Pistol implementation
- [ ] Hitscan shooting
- [ ] Damage system
- [ ] Health component

### Phase 4: Feel (The "Bodycam" Look)
- [ ] Low FOV (~70)
- [ ] Heavy motion blur
- [ ] Film grain post-process
- [ ] Chromatic aberration
- [ ] Realistic camera inertia

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
4. **Derived Data** - Delete DerivedDataCache/ if space gets tight

## Commands for Claude

When asked to create game systems, always:
1. Create the .h file first with full documentation
2. Create the .cpp implementation
3. Explain what Blueprint connections are needed
4. Note any Content/ work required on Vagon

## Current Sprint
Phase 1 - Basic movement and character setup
