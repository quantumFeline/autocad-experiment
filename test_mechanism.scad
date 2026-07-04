// test_mechanism.scad
// ===================================================================
// Verification harness for thumb_v3.scad. Not a printable part.
//
// Run with the main part selector silenced, e.g.:
//   openscad -o out.stl -D 'part="none"' -D 'test="interference"' \
//            -D test_flex=60 test_mechanism.scad
//
// Modes:
//   interference - boolean intersection of the proximal and the
//                  distal flexed by test_flex degrees. An empty
//                  result (OpenSCAD reports "Current top level
//                  object is empty") means no collision. Expected:
//                  non-empty at test_flex < 0 (the extension stop
//                  engaging is a collision by construction), empty
//                  from 0 up to the flexion limit.
//   cutaway      - assembly at test_flex with the palm-front half
//                  removed: shows walls, cavity, tendon channel,
//                  entry hole, barrel pocket, and distal tunnels
//                  in section.
//   cutaway_x    - assembly cut at the hinge centre plane normal to
//                  the pin: shows pin bore, disk counterbores, and
//                  elastic button holes in section.
// ===================================================================

include <thumb_v3.scad>

test = "cutaway";
test_flex = 0;

module assembly_at_flex() {
    proximal_body();
    hinge_frame() rotate([test_flex, 0, 0]) distal_body();
}

if (test == "interference")
    intersection() {
        proximal_body();
        hinge_frame() rotate([test_flex, 0, 0]) distal_body();
    }

if (test == "cutaway")
    difference() {
        assembly_at_flex();
        translate([0, -60, 0]) cube([120, 120, 160], center = true);
    }

if (test == "cutaway_x")
    difference() {
        assembly_at_flex();
        translate([hinge_x + 60, 0, 0]) cube([120, 120, 160], center = true);
    }
