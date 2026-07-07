# Thumb prosthesis (thumb_v3)

The active design is `thumb_v3.scad` on branch `fable/thumb-v3`.
`thumb_mvp_*.scad` are abandoned early drafts; the reference designs
(Knick's finger, E-Nable thumb) live in their own directories.

**Before touching the geometry, read `thumb_v3_notes.md`.** It holds
the orientation conventions (which were mis-derived several times
before being settled with Vero - do not re-interpret the sketch from
scratch), the design decisions with their rejected alternatives, the
verified mechanism envelope, print orientations, and the open items.

## Workflow

- Git: work on a `<model>/thumb-v3`-style branch; commit after each
  verified iteration with a detailed message (the history is the
  design changelog). Never merge or rebase without asking Vero.
- Verify visually by rendering PNGs (`make views`, or the camera
  cheat sheet in the notes) and reading them back; `show_axes=true`
  draws the axis gizmo (red=+X towards fingers, green=+Y palm-back,
  blue=Z up the thumb).
- After ANY change near the hinge, re-run the interference sweep
  (`make sweep FLEX=<deg>`) across the envelope in the notes; after
  shape changes, `make check` for watertightness and bed contact.
- `renders/` and `stl/` are regenerable and gitignored.
- Use `-D fn_draft=24` for fast draft renders; full quality is slow.

## Tuning map (what to touch for common tweaks)

Safe, cosmetic or fit-only:

- Stump fit: `base_w_front`, `base_w_back`, `base_d`, `wall` (the
  cavity follows the outer shape automatically), `rim_tilt`.
- Lengths: `hinge_z` (proximal height), `distal_len`.
- Cosmetics: `nail_*`, `disk_d` (deliberately undecided, default 8),
  `prox_n` (loft smoothness).
- Sewing plates: `plate_*`, `slit_w`; their placement frame
  (`side_face_frame`) is eyeballed against the base faces - re-render
  after changing base dimensions.

Mechanism-coupled - re-run the sweep after touching:

- `barrel_d` vs `knuckle_d` (their difference creates the extension
  stop inside the hub), `hinge_gap`, `cheek_t`, `hinge_w`.
- Anything in `fork_slot()` or the distal neck profile in
  `distal_form()`: those numbers were tuned empirically against the
  interference sweep, not derived.
