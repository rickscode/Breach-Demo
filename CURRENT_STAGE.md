# Current Stage Handoff (Audio / Footsteps)

## Why this file exists
Sound is still not working after merge. This note is for the next model/engineer to pick up quickly without re-discovering context.

## Branch / change context
- Latest merged work focused on `scenes/characters/ash.tscn`.
- `FootstepAudio3D` now has explicit values:
  - `bus = &"Master"`
  - `volume_db = 8.0`
  - `attenuation_model = 0`
  - `unit_size = 4.0`
  - `max_db = 2.0`
  - `max_distance = 30.0`

File: `scenes/characters/ash.tscn`

## Important code path
File: `scripts/characters/ash_controller.gd`

### Footstep tone generation flow
1. `_ready()` calls `_setup_footstep_audio()`.
2. `_setup_footstep_audio()` creates an `AudioStreamGenerator` if needed, then `footstep_audio.play()`, then caches generator playback in `_footstep_playback`.
3. `_physics_process()` calls `update_stealth_noise(delta)`.
4. `update_stealth_noise(delta)` computes movement/noise and then calls `_play_footstep_tone(noise_strength)`.

## High-probability blocker (critical)
`update_stealth_noise(delta)` returns early if `_noise_system == null`.

That means `_play_footstep_tone(...)` is **never reached** when no `NoiseSystem` is resolved, even if movement is happening and `FootstepAudio3D` is configured correctly.

So the current behavior can be: **no noise system -> no footstep sound at all**.

## Recommended next fix
In `scripts/characters/ash_controller.gd`, decouple footstep tone playback from the noise-system dependency:

- Keep `_noise_system` checks for stealth emission only.
- Still allow `_play_footstep_tone(...)` when moving, even if `_noise_system` is missing.
- Suggested refactor target: `update_stealth_noise(delta)` around the early return path.

## Quick diagnostic checklist for next model
1. Verify `_footstep_playback` is not null after `_setup_footstep_audio()`.
2. Confirm `_play_footstep_tone(...)` is called while moving.
3. Confirm `NoiseSystem` node/path resolution behavior in `_resolve_noise_system()`.
4. Ensure a listener exists (usually active camera) and bus routing reaches `Master`.
5. Validate generated frame writes are accepted (buffer not starved/blocked).

## Scope already done
- Scene-side AudioStreamPlayer3D defaults are explicit.
- Merge-conflict numeric mismatch in `ash.tscn` was aligned.
- Remaining issue appears runtime-logic related, not just scene property defaults.
