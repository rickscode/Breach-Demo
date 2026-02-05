# BREACH - Complete Project Overview

## Executive Summary

**BREACH** is a story-driven tactical stealth action game combining Metal Gear Solid's deep narrative and infiltration gameplay with the hyper-realistic camera aesthetic of "Bodycam" and gritty Cyberpunk neon-noir visuals. Single-player campaign focused. This is a learning project to master a specific AI-assisted game development workflow, with potential to become YouTube content for the AccordingToRick channel.

**Developer:** Rick Hartley (OMR)
**Timeline:** Learning project, no fixed deadline
**Budget:** ~$50/month for cloud compute
**Goal:** Build a playable stealth demo while mastering the Claude Code + Cloud VM pipeline, with potential to expand into a full campaign

---

## Story Summary

**See BREACH_STORY_BIBLE.md for complete narrative documentation.**

### Logline
A disavowed operative infiltrates the fortress of the private military contractor that trained them, to expose a global AI-driven assassination program before it goes live — while confronting the mentor who made them a weapon.

### The World
Near future. Governments are weak. Megacorps fill the gaps. **AXIOM SOLUTIONS** is a private military contractor that handles the dirty work democracies can't admit to.

### The Conspiracy — BLACK LIST
AXIOM has developed an AI system that identifies "threats to stability" (journalists, activists, whistleblowers) and coordinates their quiet elimination worldwide. Governments don't order the kills — they just subscribe. Plausible deniability.

### The Player — ASH
Former AXIOM operative. Twelve years of service. Three months ago, discovered their "terrorist targets" were innocent journalists. AXIOM tried to silence them. They escaped. Now they're coming back to burn it all down.

### The Enemy — SHEPHERD
ASH's former mentor. Runs AXIOM security. True believer in BLACK LIST. He's not evil — he's convinced he's saving the world through "precise elimination of chaos agents."

**His philosophy:** *"Every life I take saves a thousand. That's not murder. That's math."*

### The Codec Team
| Codename | Role | Personality |
|----------|------|-------------|
| **ORACLE** | Mission handler | Calm, precise, suspiciously well-informed |
| **WRENCH** | Tech support | Sarcastic, complains, always delivers |
| **DOC** | Medical | Warm, maternal, moral compass |
| **GHOST** | Intel analyst | Nervous, guilt-ridden, possibly compromised |

### The Theme
*"Who decides who deserves to live?"*

### Demo Level — THE RELAY
A small AXIOM data relay station. ASH infiltrates to extract BLACK LIST data. Tutorial mission that ends with a twist: ASH's own name is on the kill list. AXIOM knows they're coming.

---

## The Core Problem We're Solving

Rick has:
- A Mac M2 with 8GB RAM (cannot run Unreal Engine 5)
- Claude Code for AI-assisted C++ development
- No prior Unreal Engine experience

The solution:
- Use Mac locally for all C++ code generation via Claude Code
- Use Vagon (cloud Windows VM with GPU) for Unreal Engine editor work
- Connect them via Git/GitHub

---

## Technical Architecture

### The Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│                        DEVELOPMENT PIPELINE                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   MAC (Local)                         VAGON (Cloud)              │
│   ───────────                         ─────────────              │
│   • Claude Code AI                    • Windows VM               │
│   • C++ source files                  • Unreal Engine 5.5        │
│   • Game logic                        • Compilation              │
│   • Git operations                    • Visual editor work       │
│                                       • Playtesting              │
│                                       • Materials/Lighting       │
│                                                                  │
│            ┌──────────────────────┐                              │
│   MAC ───► │   GitHub Repository  │ ◄─── VAGON                   │
│    push    │   (Git + Git LFS)    │      pull                    │
│            └──────────────────────┘                              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Technology Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| Game Engine | Unreal Engine 5.5 | Game development, rendering |
| Programming | C++ | Core game logic |
| Visual Scripting | Blueprints | Connecting systems, prototyping |
| Local IDE | Claude Code (Mac) | AI-assisted C++ generation |
| Cloud Workstation | Vagon | Running UE5 Editor |
| Version Control | Git + Git LFS | Code sync between Mac and Vagon |
| Repository | GitHub | Remote storage |
| Capture | OBS | Recording gameplay footage |
| Editing | DaVinci Resolve | Video production |

### Hardware Constraints

**Mac M2 (8GB RAM):**
- CANNOT run Unreal Engine 5
- Used ONLY for text-based work (code, config files)
- Claude Code operates here

**Vagon Cloud VM:**
- 125GB storage ($5/month)
- Hourly compute billing (~$0.99-1.74/hr)
- RTX-class GPU for UE5
- Pre-installed Unreal Engine

---

## Game Design Document

### Concept

**Title:** BREACH
**Genre:** Tactical Stealth Action (MGS-like)
**Visual Style:** "Cyber-Tanker" — Bodycam realism + MGS2 industrial + Cyberpunk neon
**Perspective:** Third-person (MGS-style camera)
**Scope:** Single-player campaign, starting with one infiltration mission as demo

### Design Philosophy

**Stealth First:** Combat is a fail state, not the goal. The player should feel tension from avoiding detection, not from firefights.

**Narrative Depth:** Story matters. Characters have motivations. The world has lore. Codec calls and collectible intel flesh out the universe.

**Player Agency:** Multiple approaches to objectives — ghost (no traces), non-lethal, or lethal. Each has consequences.

### Visual Direction (The "Cyber-Tanker" Look)

**Environment:**
- Industrial maritime/facility setting
- Steel walls, corrugated metal, pipes, valves
- Tight corridors, catwalks, cargo holds, engine rooms
- Cyberpunk neon accents in a gritty industrial space

**Surface Detail:**
- Wet metal floors with puddle reflections
- Steam vents and heavy hydraulic machinery
- Rust, grime, oil stains
- Exposed wiring and conduits

**Lighting:**
- High-contrast shadows (crucial for stealth gameplay)
- Flickering emergency lights (orange/blue contrast)
- Neon hazard strips and warning signs
- Searchlights and patrol flashlights
- Volumetric fog/steam catching light
- Lumen GI for realistic bounce

**Camera Feel (Bodycam DNA):**
- Low FOV (~70 degrees) for claustrophobic tension
- Film grain post-process
- Chromatic aberration
- Slight camera sway when moving

**Reference Games:**
- Metal Gear Solid 2 (Tanker) — stealth gameplay, industrial setting, narrative
- Metal Gear Solid V — modern stealth mechanics, AI systems
- Deus Ex: Human Revolution — stealth + narrative + cyberpunk
- Hitman (World of Assassination) — AI systems, detection mechanics
- Splinter Cell: Chaos Theory — light/shadow stealth
- Cyberpunk 2077 — neon + grime aesthetic
- Bodycam — camera feel and visual grain

### Core Mechanics

**Phase 1 - Movement & Stealth Basics:**
- Third-person character controller (MGS-style camera)
- Walk / Sprint / Crouch / Prone
- Cover system (snap to walls, peek corners)
- Footstep noise system (surface-based: metal clanks, water splashes)

**Phase 2 - Detection & AI:**
- Enemy AI state machine (Patrol → Alert → Search → Combat)
- Vision cone detection (affected by lighting)
- Sound-based detection (footsteps, gunshots, distractions)
- Alert/Caution phases with timers
- Guard patrol routes and behaviors

**Phase 3 - Stealth Actions:**
- CQC takedowns (lethal/non-lethal choice)
- Body drag and hide in containers
- Distractions (throw objects, knock on surfaces)
- Hiding spots (lockers, under objects, shadows)
- Lockpicking/hacking for alternate routes

**Phase 4 - Combat (Last Resort):**
- Suppressed pistol (limited ammo)
- Tranquilizer option (non-lethal)
- Combat triggers full facility alert
- Health system with limited healing

**Phase 5 - Narrative Systems:**
- Dialogue system for NPC interactions
- Codec/radio calls (mission support, lore dumps, character development)
- Collectible intel (documents, recordings)
- Cutscene triggers at key moments
- Mission objectives with optional sub-objectives

**Phase 6 - Polish (The Feel):**
- Post-processing stack
- Dynamic music (tension levels based on alert state)
- Environmental storytelling
- UI design (minimal, diegetic where possible)

### AI Design

**Enemy States:**
```
PATROL (Green) → SUSPICIOUS (Yellow) → ALERT (Orange) → COMBAT (Red)
     ↑                                                        ↓
     └────────────── SEARCH (returns to patrol) ←────────────┘
```

**Detection Factors:**
- Line of sight (blocked by cover, affected by darkness)
- Sound radius (walking vs running vs prone)
- Bodies discovered
- Alarms triggered
- Cameras/sensors

### Level Design Philosophy

**Demo Setting — THE RELAY:**
- Small AXIOM data relay station
- Industrial outskirts, satellite dishes, server rooms
- Rainy night, orange sodium lights, chain-link fences
- 30-45 minute level introducing all core mechanics

**Full Game Setting — THE SPIRE:**
AXIOM headquarters disguised as a tech campus. Multiple distinct zones:

| Level | Setting | Stealth Focus |
|-------|---------|---------------|
| THE PERIMETER | Corporate campus exterior | Guard patrols, cameras, dogs |
| THE ATRIUM | Main building lobby | Civilian presence, social stealth |
| THE LABS | R&D, cyber-augmentation | Horror undertones, scientists |
| THE DETENTION LEVEL | Holding cells, interrogation | Rescue objectives, moral choices |
| THE SERVER FARM | Massive data center | Environmental hazards, MIRROR boss |
| THE BARRACKS | Operative quarters | Former colleagues, AEGIS boss |
| THE EXECUTIVE LEVEL | Luxury meets fortress | WHISPER boss |
| THE CORE | BLACK LIST control center | SHEPHERD confrontation |

**Stealth Considerations:**
- Patrol routes with gaps for sneaking
- Cover objects placed intentionally
- Hiding spots distributed throughout
- Light sources that can be disabled
- Sound surfaces (metal grating vs carpet vs water)
- Multiple paths to objectives (main route, vents, alternate doors)

---

## Project Structure

```
BREACH/
├── .git/
├── .gitattributes          # Git LFS configuration
├── .gitignore              # Excludes Content/, Binaries/, etc.
├── CLAUDE.md               # AI context file for Claude Code
├── SETUP.md                # Development environment setup guide
├── Source/
│   └── Breach/
│       ├── Breach.Build.cs
│       ├── Breach.h
│       ├── Breach.cpp
│       ├── Characters/
│       │   ├── BreachCharacter.h/.cpp     # Player character
│       │   └── EnemyBase.h/.cpp           # Base enemy class
│       ├── AI/
│       │   ├── EnemyAIController.h/.cpp   # AI state machine
│       │   ├── PatrolRoute.h/.cpp         # Patrol waypoints
│       │   └── DetectionComponent.h/.cpp  # Vision/hearing
│       ├── Stealth/
│       │   ├── CoverSystem.h/.cpp         # Wall cover mechanics
│       │   ├── NoiseSystem.h/.cpp         # Sound propagation
│       │   ├── HidingSpot.h/.cpp          # Lockers, hiding places
│       │   └── TakedownSystem.h/.cpp      # CQC mechanics
│       ├── Weapons/
│       │   ├── WeaponBase.h/.cpp
│       │   └── Pistol.h/.cpp
│       ├── Narrative/
│       │   ├── DialogueSystem.h/.cpp      # Conversations
│       │   ├── CodecSystem.h/.cpp         # Radio calls (MGS-style)
│       │   └── ObjectiveManager.h/.cpp    # Mission tracking
│       └── Components/
│           ├── HealthComponent.h/.cpp
│           └── InventoryComponent.h/.cpp
├── Config/                 # Engine and input configuration
│   ├── DefaultEngine.ini
│   ├── DefaultGame.ini
│   └── DefaultInput.ini
├── Content/                # NOT IN GIT - managed on Vagon only
├── Binaries/               # NOT IN GIT - compiled output
├── Intermediate/           # NOT IN GIT - build cache
└── Breach.uproject         # UE5 project file
```

### What Goes Where

**In Git (synced between Mac and Vagon):**
- All Source/ C++ files
- Config/ files
- CLAUDE.md, SETUP.md
- .gitignore, .gitattributes
- Breach.uproject

**NOT in Git (Vagon only):**
- Content/ (assets, materials, levels) - too large
- Binaries/ (compiled code)
- Intermediate/ (build cache)
- DerivedDataCache/ (shader cache)
- Saved/ (logs, autosaves)

---

## Workflow Documentation

### Daily Development Cycle

**Step 1: Mac (Claude Code) - Write Code**
```bash
cd ~/Projects/breach
claude

# Example prompts to Claude Code:
# "Create the BreachCharacter class with sprint and crouch mechanics"
# "Add a stamina system to the character"
# "Create the FlashlightComponent with toggle functionality"
```

**Step 2: Mac - Commit and Push**
```bash
git add -A
git commit -m "[Character] Add sprint mechanic with stamina"
git push origin main
```

**Step 3: Vagon - Pull and Compile**
```cmd
cd D:\Projects\Breach
git pull origin main

# Open UE5 Editor
# Use Live Coding (Ctrl+Alt+F11) for hot reload
# Or full recompile if needed
```

**Step 4: Vagon - Test and Iterate**
- Playtest the changes
- Tweak Blueprint connections
- Adjust materials, lighting
- Do level design work

**Step 5: Repeat**

### Git Commit Message Format

```
[System] Brief description

- Detail 1
- Detail 2
```

**Examples:**
- `[Init] Project setup for BREACH`
- `[Character] Add sprint mechanic with stamina`
- `[Weapon] Implement base weapon class`
- `[Combat] Add hitscan damage system`
- `[Config] Update input bindings for crouch`

---

## Unreal Engine C++ Conventions

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Actor classes | A prefix | `ABreachCharacter` |
| Component classes | U prefix | `UHealthComponent` |
| Interfaces | I prefix | `IInteractable` |
| Functions | PascalCase | `GetCurrentHealth()` |
| UPROPERTY variables | PascalCase | `MaxHealth` |
| Local variables | camelCase | `currentAmmo` |
| Booleans | b prefix | `bIsAlive`, `bCanFire` |

### Essential UE5 Macros

**Class Declaration:**
```cpp
UCLASS()
class BREACH_API ABreachCharacter : public ACharacter
{
    GENERATED_BODY()
    // ...
};
```

**Properties (expose to editor/Blueprints):**
```cpp
UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Stats")
float MaxHealth = 100.0f;

UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "State")
bool bIsAlive = true;
```

**Functions (expose to Blueprints):**
```cpp
UFUNCTION(BlueprintCallable, Category = "Combat")
void ApplyDamage(float DamageAmount);

UFUNCTION(BlueprintImplementableEvent, Category = "Events")
void OnDeath();
```

---

## Learning Roadmap

### Week 1-2: Foundation
- [ ] Complete Mac setup (Git, Git LFS, Claude Code)
- [ ] Complete Vagon setup (UE5 installed, project created)
- [ ] Verify Git sync works between Mac and Vagon
- [ ] Create basic third-person character with movement
- [ ] Learn UE5 Editor basics (navigation, viewport, content browser)

### Week 3-4: Movement Polish
- [ ] Implement crouch and prone
- [ ] Build cover system (snap to walls)
- [ ] Add peek around corners
- [ ] Implement footstep noise system
- [ ] Learn UE5 animation basics

### Week 5-6: AI Foundation
- [ ] Create enemy base class
- [ ] Build AI state machine (Patrol/Alert/Search/Combat)
- [ ] Implement vision cone detection
- [ ] Add patrol routes
- [ ] Basic level blockout for testing

### Week 7-8: Stealth Systems
- [ ] Sound-based detection
- [ ] CQC takedowns (lethal/non-lethal)
- [ ] Body drag mechanics
- [ ] Hiding spots (lockers, shadows)
- [ ] Distraction system (throw objects)

### Week 9-10: Combat & Items
- [ ] Weapon base class
- [ ] Suppressed pistol
- [ ] Tranquilizer option
- [ ] Health component
- [ ] Basic inventory

### Week 11-12: Narrative Foundation
- [ ] Dialogue system basics
- [ ] Codec/radio call system
- [ ] Objective manager
- [ ] Collectible intel system

### Week 13+: Polish & Demo Level
- [ ] Post-processing stack (Cyber-Tanker look)
- [ ] Lighting pass (shadows crucial for stealth)
- [ ] Wet metal materials, neon emissives
- [ ] Full demo level with story beats
- [ ] Audio integration
- [ ] UI/HUD design

---

## Asset Direction

### Megascans/Quixel Categories to Use
- Industrial surfaces (metal panels, grating, pipes)
- Machinery and mechanical parts
- Wet/weathered surface decals
- Debris and grime

### Custom Materials to Create (Vagon)
- Wet metal (high roughness variation, puddle blend)
- Neon emissive strips (cyan, magenta, orange)
- Rust/corrosion blend material
- Steam/fog particle material

---

## Content Creation Angle

**Channel:** AccordingToRick (tech/maker content)

**Potential Videos:**
1. "I'm Building an MGS-Style Game with AI (No Engine Experience)"
2. "Claude Code + Cloud VM: My Game Dev Workflow"
3. "Building Stealth AI from Scratch in UE5"
4. "Recreating the MGS2 Tanker Atmosphere in Unreal"
5. "How I Designed a Detection System with AI Help"
6. "The Cyber-Tanker Aesthetic: Bodycam + Cyberpunk + MGS"
7. "Writing Game Narrative with AI Assistance"

**The Hook:** Learning in public, AI-assisted development, budget game dev ($50/month setup), deep dive into stealth game design

---

## Key Constraints and Decisions

1. **No local UE5** - Mac cannot run it, all editor work on Vagon
2. **Content not in Git** - Too large, managed only on Vagon
3. **C++ focus** - Blueprints for wiring only, logic in code
4. **Scope is small** - One level, basic mechanics, learning project
5. **Budget conscious** - Minimize Vagon hours by doing code locally
6. **Git LFS required** - For any binary files that do get committed
7. **Visual style is specific** - Cyber-Tanker aesthetic guides all art decisions

---

## Quick Reference Commands

**Mac:**
```bash
cd ~/Projects/breach          # Navigate to project
claude                        # Start Claude Code
git add -A                    # Stage all changes
git commit -m "message"       # Commit
git push origin main          # Push to GitHub
```

**Vagon (Windows):**
```cmd
cd D:\Projects\Breach         # Navigate to project
git pull origin main          # Pull latest code
# Ctrl+Alt+F11 in UE5        # Live Coding (hot reload)
```

**Storage cleanup (Vagon):**
```cmd
rd /s /q DerivedDataCache     # Delete shader cache
rd /s /q Intermediate         # Delete build cache
rd /s /q Saved\Logs           # Delete logs
```

---

## Glossary

| Term | Definition |
|------|------------|
| **Claude Code** | Anthropic's AI coding assistant CLI |
| **Vagon** | Cloud PC service for running Windows/GPU apps |
| **Git LFS** | Git Large File Storage - handles binary files |
| **UE5** | Unreal Engine 5 |
| **Blueprints** | UE5's visual scripting system |
| **Lumen** | UE5's global illumination system |
| **Megascans/Quixel** | Library of photogrammetry assets (free with UE5) |
| **Hot Reload / Live Coding** | Recompile C++ without closing editor |
| **UPROPERTY** | Macro to expose C++ variables to editor |
| **UFUNCTION** | Macro to expose C++ functions to Blueprints |
| **Cyber-Tanker** | Project's visual style (Bodycam + MGS + Cyberpunk) |
| **CQC** | Close Quarters Combat - melee takedowns |
| **AI State Machine** | System managing enemy behavior states |
| **Vision Cone** | Enemy's field of view for detection |
| **Codec** | MGS-style radio communication system |
| **Ghost Run** | Completing level without being detected |
| **ASH** | Player character codename — "They burned me. I'm what's left." |
| **AXIOM** | Enemy megacorp / PMC |
| **BLACK LIST** | AI assassination program (the MacGuffin) |
| **SHEPHERD** | Primary antagonist, ASH's mentor |
| **THE SPIRE** | AXIOM headquarters, main game setting |
| **THE RELAY** | Demo level, data relay station |

---

*Document Version: 3.0 — Story Integration*
*Last Updated: January 29, 2026*
*Project: BREACH*
