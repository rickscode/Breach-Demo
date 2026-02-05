# BREACH - UE5 Tactical Stealth Action

## Project Overview
A story-driven stealth action game inspired by Metal Gear Solid's deep narrative and infiltration gameplay, combined with the visual realism of "Bodycam" and a gritty Cyberpunk aesthetic. Single-player campaign focused. Built as a learning project to master the Claude Code + Cloud VM workflow.

## Story Context (See BREACH_STORY_BIBLE.md for full details)

**Logline:** A disavowed operative infiltrates the fortress of the private military contractor that trained them, to expose a global AI-driven assassination program before it goes live.

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

## Visual Direction (The "Cyber-Tanker" Look)

### Environment — THE SPIRE (AXIOM HQ)
- Dystopian megacorp compound disguised as tech campus
- Clean corporate facades hiding brutal infrastructure beneath
- Mix of sterile office spaces and industrial underbelly
- Server farms, research labs, detention levels, executive suites

### Surface Detail
- Polished floors in public areas, wet concrete in maintenance tunnels
- Holographic corporate propaganda displays
- Steam vents and heavy machinery in lower levels
- Exposed wiring and conduits in restricted areas
- Rain-slicked exteriors, neon reflections

### Lighting
- High-contrast shadows (crucial for stealth gameplay)
- Cold blue corporate lighting vs. warm orange emergency systems
- Neon accent strips (cyan AXIOM branding, magenta hazard warnings)
- Searchlights and patrol flashlights
- Volumetric fog/steam in industrial areas
- Lumen GI for realistic bounce

### Camera Feel (Bodycam DNA)
- Low FOV (~70 degrees) for claustrophobic tension
- Film grain post-process
- Chromatic aberration
- Slight camera sway when moving

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
│       │   ├── BreachCharacter.cpp/.h      # Player character
│       │   └── EnemyBase.cpp/.h            # Base enemy class
│       ├── AI/
│       │   ├── EnemyAIController.cpp/.h    # AI state machine
│       │   ├── PatrolRoute.cpp/.h          # Patrol waypoints
│       │   └── DetectionComponent.cpp/.h   # Vision/hearing
│       ├── Stealth/
│       │   ├── CoverSystem.cpp/.h          # Wall cover mechanics
│       │   ├── NoiseSystem.cpp/.h          # Sound propagation
│       │   ├── HidingSpot.cpp/.h           # Lockers, hiding places
│       │   └── TakedownSystem.cpp/.h       # CQC mechanics
│       ├── Weapons/
│       │   ├── WeaponBase.cpp/.h
│       │   └── Pistol.cpp/.h
│       ├── Narrative/
│       │   ├── DialogueSystem.cpp/.h       # Conversations
│       │   ├── CodecSystem.cpp/.h          # Radio calls
│       │   └── ObjectiveManager.cpp/.h     # Mission tracking
│       ├── Components/
│       │   ├── HealthComponent.cpp/.h
│       │   └── InventoryComponent.cpp/.h
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

### Phase 1: Movement & Stealth Basics
- [ ] Third-person character controller (MGSV-style camera)
- [ ] Walk, sprint, crouch, prone
- [ ] Cover system (snap to walls)
- [ ] Peek around corners
- [ ] Footstep noise system (surface-based)

### Phase 2: Detection & AI
- [ ] Enemy AI state machine (Patrol → Alert → Search → Combat)
- [ ] Vision cone detection
- [ ] Sound-based detection
- [ ] Alert/Caution phases
- [ ] Guard patrol routes

### Phase 3: Stealth Actions
- [ ] CQC takedowns (lethal/non-lethal)
- [ ] Body drag and hide
- [ ] Distractions (throw objects, knock on walls)
- [ ] Hiding spots (lockers, under objects, cardboard box?)
- [ ] Lockpicking/hacking mini-games

### Phase 4: Combat (Last Resort)
- [ ] Weapon base class
- [ ] Suppressed pistol
- [ ] Tranquilizer option
- [ ] Health/damage system
- [ ] Combat triggers full alert

### Phase 5: Narrative Systems
- [ ] Dialogue system
- [ ] Codec/radio calls
- [ ] Collectible intel/documents
- [ ] Cutscene triggers
- [ ] Mission objectives UI

### Phase 6: Feel (The "Cyber-Tanker" Look)
- [ ] Low FOV (~70) for tension
- [ ] Film grain post-process
- [ ] Chromatic aberration
- [ ] Wet surface materials (puddle reflections)
- [ ] Neon emissive materials
- [ ] Volumetric fog/steam
- [ ] Dynamic lighting (flickering, searchlights)

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
- Corporate/office surfaces (polished concrete, glass, metal panels)
- Industrial surfaces (grating, pipes, machinery)
- Tech props (servers, monitors, control panels)
- Wet/weathered surface decals
- Debris and grime for contrast areas

### Custom Materials Needed
- Corporate floor (polished, reflective)
- Wet concrete (maintenance areas)
- Neon emissive strips (cyan AXIOM brand, magenta hazards)
- Holographic display material
- Steam/fog particle material

### Reference Games
- Metal Gear Solid 2 — stealth gameplay, codec system, narrative depth
- Metal Gear Solid V — modern stealth mechanics, AI systems
- Deus Ex: Human Revolution — megacorp aesthetic, stealth + narrative
- Hitman (World of Assassination) — AI systems, detection mechanics
- Splinter Cell: Chaos Theory — light/shadow stealth
- Cyberpunk 2077 — neon + corporate dystopia
- Control — brutalist corporate architecture
- Bodycam — camera feel and visual grain

## Commands for Claude

When asked to create game systems, always:
1. Create the .h file first with full documentation
2. Create the .cpp implementation
3. Explain what Blueprint connections are needed
4. Note any Content/ work required on Vagon
5. Consider the industrial/cyberpunk setting when naming and designing systems
6. Prioritize stealth mechanics over combat — combat is a fail state
7. Design AI systems with clear state transitions (Patrol → Alert → Search → Combat)
8. Keep narrative systems modular for easy expansion

## Current Sprint
Phase 1 - Third-person movement, crouch/prone, and basic cover system
