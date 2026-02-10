# Blender-to-Godot Asset Pipeline

## Export Settings

1. **File > Export > glTF 2.0 (.glb/.gltf)**
2. Choose **glTF Binary (.glb)** -- single file, no loose textures
3. Under **Include**, check only what you need (usually Meshes + Armatures + Animations)
4. Under **Transform**, leave Y Up (Godot handles conversion)

## Before Exporting

- **Apply all transforms**: `Ctrl+A > All Transforms` on every object
- **Scale**: Blender default (1 unit = 1 meter) matches Godot -- no conversion needed
- **Origin**: Set object origin to the feet/base of the character, not center of mass
- **Face orientation**: Check normals are correct (Viewport Overlays > Face Orientation -- all blue = good)

## Naming Convention

| Asset | Filename |
|-------|----------|
| Player model | `ash_model.glb` |
| Enemy soldier | `enemy_soldier.glb` |
| Wall segment | `wall_segment.glb` |
| Door | `door_model.glb` |
| Props | `prop_[name].glb` |

## Folder Structure

Drop all .glb files into:
```
assets/models/
├── ash_model.glb
├── enemy_soldier.glb
├── wall_segment.glb
└── ...
```

Godot auto-imports on next editor focus. No manual import step needed.

## Rigging & Animation (Mixamo Workflow)

1. Model your character in Blender (or use a base mesh)
2. Upload .fbx to [Mixamo](https://www.mixamo.com/) for auto-rigging
3. Download animations individually as .fbx (Without Skin for anims, With Skin for the rigged model)
4. Import into Blender, then export as .glb with animations embedded
5. In Godot, the AnimationPlayer will auto-populate with the embedded clips

## How to Swap a Primitive for a Real Model

Example -- replacing Ash's capsule:

1. Export your model as `ash_model.glb` into `assets/models/`
2. Open `ash.tscn` in Godot editor
3. Delete the CapsuleMesh MeshInstance3D under the `Model` node
4. Drag `ash_model.glb` as a child of the `Model` node
5. Adjust position/scale if needed so it fits within the CollisionShape3D
6. Done -- collision, movement, camera all keep working

Same pattern for enemies: open `enemy.tscn`, swap contents under `Model`.

## Tips

- Keep polygon counts PS2-era friendly: 3k-8k tris for characters, 500-2k for props
- Use a single texture atlas per character when possible
- Test with `F5` (run project) frequently -- catch scale/orientation issues early
- The CollisionShape3D is independent of the visual model. Adjust it if the new model is significantly different in size.
