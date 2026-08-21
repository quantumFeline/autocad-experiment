# thumb_v3 design notes

Working notes for `thumb_v3.scad`, the sketch-faithful thumb prosthesis
(branch `fable/thumb-v3`). This file captures decisions and context that
are not obvious from the code or the spec; the commit history on this
branch is the detailed changelog.

## Orientation conventions (hard-won, do not re-derive)

Model frame: Z up the thumb axis (z=0 at the base opening), +X towards
the other fingers, +Y towards the back of the hand. The preview's axis
gizmo shows red=+X, green=+Y, blue=Z.

Mapping to `design/clean_sketch.png`:

- **SIDE VIEW** = camera along the palm normal (Y). Shows the hinge
  disk face-on, both sewing plates edge-on hanging below the rim, and
  the nail edge-on. "15 mm far side / 25 mm near side" are the two
  bottom edges of the base seen along the viewing axis.
- **INNER PALM (front) VIEW** = camera along X from the palm centre.
  Shows the hinge as a band, and the fingers-side sewing plate as the
  wide ~30 mm strip with the long slit.

Render cheat sheet (add `-D show_axes=true` for the gizmo):

    side view :  openscad --camera=0,0,28,90,0,0,240  --projection=ortho -D 'part="preview"'
    front view:  openscad --camera=0,0,28,90,0,90,240 --projection=ortho -D 'part="preview"'
    use -D fn_draft=24 for fast draft renders

## Key design decisions

- **Fully pronated hinge** (`hinge_spin=90`): pin along the palm
  normal, disks face palm-front/palm-back, flexion curls the tip
  across the palm towards the fingers, mirroring the stump's MCP
  adduction (recipient has no functional CMC; motion is in the palm
  plane). Grip pattern: lateral/key pinch against the middle finger.
  This is anatomically correct thumb-IP flexion for a pronated thumb;
  it only looks "sideways" on the isolated model.
- **Base trapezoid**: parallel 15 mm (palm-front) / 25 mm (palm-back)
  sides; the two ~30 mm slanted faces towards fingers/wrist carry the
  sewing plates. All asymmetry lives in the base: oblique bottom rim
  (`rim_tilt`, palm-back edge ~5 mm longer = the 30/35 mm front-view
  edges) plus sideways drift (`hinge_x`); the distal and hinge sit
  straight on the thumb axis (a tilted distal was rejected).
- **Barrel smaller than knuckle** (`barrel_d 9` vs `knuckle_d 11`):
  keeps the swing pocket inside the hub, so the extension stop floor
  exists naturally inside the knuckle and nothing protrudes. Earlier
  external stop collars looked like scaffolding and were removed.
- **Colour scheme** is realised as separate glued parts (any
  single-extruder printer): black nail inlay, black disk rings, white
  centre plugs. `disk_d` is deliberately parametric (spec says 5 mm,
  sketch reads ~10 mm; default 8, decide after a test print).
- **Sewing plates** (TPU): slitted halves hang below the rim per the
  sketch, so wrap tension pulls the base down onto the stump. Screw
  band pockets + M2 pilot holes in the base. Rejected alternative,
  revisit if the inner plate irritates the thumb-index web: slits cut
  directly into the pyramid wall (single piece, but rigid fabric edges
  and no compliance).
- **Mechanism** (Knick's-style differential tendon): tendon anchors to
  the wrap on the wrist side, enters the wrist-side wall above the
  stump, crosses the hollow, exits below the hinge on the fingers
  side, rides the barrel groove, knots in the distal pocket. Elastic
  return loops through two button holes in the wrist-side wall and
  runs in an outer guide groove over the hinge.

## Verified mechanism numbers (test_mechanism.scad)

Interference sweep (boolean intersection of proximal and flexed
distal; "empty" result = clear):

    openscad -o out.stl -D 'part="none"' -D 'test="interference"' \
             -D test_flex=<deg> -D fn_draft=24 test_mechanism.scad

- extension stop engages at ~-2.5 deg (collision at -4 is the stop
  working, by construction)
- free travel: -1 .. 78 deg; hard flexion limit ~80 deg
- key pinch needs roughly 30-50 deg, so margin is ample
- `cutaway` / `cutaway_x` test modes show walls (~2 mm), tendon path,
  and pocket clearances in section

The relief-cut numbers in `fork_slot()` and the hairline clearances
were tuned against this sweep; re-run it after any hinge geometry
change. Debugging trick: export the intersection STL and read its
vertex coordinates to locate a graze exactly.

## STL export and printing

`stl/` is gitignored (regenerable). `make stl` exports everything at
full quality; `make check` runs `scripts/check_manifold.py` on the
results (watertightness, degenerate faces, per-shell bed contact).
Single parts: `openscad -o stl/<part>.stl -D 'part="<part>"'
thumb_v3.scad`.

All parts verified manifold at $fn=96 (watertight single shells, all
edges paired, no degenerate faces). `part="print_all"` is the print
layout: every part rests on z=0 in its print orientation. Per-part
exports stay in the model frame for assembly and inspection.

Orientation notes:

- **Proximal** rim-down; `print_all` pre-tilts it by `rim_tilt` so
  the oblique rim sits flat (full rim ring contacts the bed). Fork
  cheeks print vertical; the swing-pocket bore ceiling bridges
  ~9.7 mm, fine for FDM; sag on the cavity ceiling is internal and
  harmless.
- **Distal** upright on the barrel, tip up; small footprint, use a
  brim. The neck-to-flare overhang is gradual.
- **Nail** dome up on a raft (the underside is curved to match the
  nail pocket).
- **Disk rings, plugs, plates** flat. Plates in TPU; everything else
  PETG or PLA.

Materials/colours: bodies + plugs white, nail + rings black, plates
any (hidden under the wrap).

## External review triage (2026-07-07)

Five findings from an outside review, with verdicts:

1. **Tendon crosses the hollow interior** - AGREE, mitigate at
   assembly. The tendon does run loose across the cavity between the
   wrist-side entry (z=18) and the channel mouth below the hinge; it
   can snag on the stump or foam. Recommended fix: glue a short PTFE
   or Bowden tube between the two holes at assembly time (enlarge the
   entry to ~4 mm for a 2 mm-ID liner if adopted). A printed closed
   channel was considered and rejected: it would need support inside
   the cavity, exactly where supports cannot be removed.
2. **Faceting at prox_n=9** - AGREE, fixed. Default raised to 15;
   side-by-side renders confirmed the banding on the swept faces
   drops markedly. Full-quality proximal export cost rises to ~2 min.
3. **Distal neck constriction** - DISAGREE as a defect. The neck must
   stay at barrel width until it clears the swinging fork cheeks; the
   z=8 flare start was tuned against the interference sweep (earlier,
   lower flares grazed at flex 65-81). It is the clearance envelope
   of a fork-and-barrel hinge, same look as Knick's fingers. Only a
   cheek redesign (thinner cheeks or smaller knuckle) would shrink
   it, and that trades away pin bearing area.
4. **"1.1 mm wall at the pin bore"** - REJECT, geometry misread. The
   pin bore runs along the pin axis, perpendicular to the slot faces,
   so the material around it is the radial ring of the knuckle disk:
   (11 - 2.8)/2 = 4.1 mm, about 1.5x the bore diameter. The reviewer
   computed cheek_t - bore radius, which would apply only to a bore
   drilled parallel to the cheek face.
5. **Nail reads as a blister** - AGREE, not yet done. A flatter
   roof-tile section (large-radius cylinder along the nail length
   intersected with the dome) would read better than the symmetric
   ellipsoid. Contained change: only `nail_shape(grow)` needs editing
   (the pocket derives from the same module, so it follows); verify
   by render and re-export nail + distal.

## Open items before a test print

1. **Calliper measurements of the stump** (width/depth at base,
   length, where the bulk sits palm-front vs palm-back). PLAN.md
   estimated 15-18 mm width; the cavity is ~11 mm wide at the
   palm-front half, ~21 mm at the palm-back, so the trapezoid
   parameters may need adjusting.
2. **25 mm side placement**: currently palm-back (`base_w_back`),
   matching the sketch's front view; anatomical argument exists for
   palm-front (thenar bulk). One-line swap if wrong.
3. **Tendon entry height** (`tendon_entry_z=18`) assumes the stump
   tip stays below ~18 mm; confirm after measuring.
4. Wrap sewing: pad the inner plate area near the stretching
   thumb-index skin web (hem or thin foam strip).
5. **Tendon liner** (review item 1): PTFE/Bowden tube across the
   cavity at assembly; widen the entry hole if adopted.
6. **Nail reshape** (review item 5): roof-tile section instead of the
   ellipsoid dome.
7. Cosmetics accepted for now: visible slot lines and the 0.3 mm stop
   gap at the joint (inherent to a printed pin hinge), faint loft
   facets at draft $fn.

## Reference

- Anatomy and measurement notes: PLAN.md (gitignored, in repo root).
- Baseline designs: Knick's finger v3.5.5 (hinge/tendon architecture),
  E-Nable/Sandra thumb (proportions; STEP file partly empty).
- Licences: baselines are CC-BY-NC-SA (see README/LICENSE files).
