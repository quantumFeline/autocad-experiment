// thumb_mvp_v1.scad
// ===================================================================
// Rigid Thumb Extension Prosthetic - MVP
// ===================================================================
// A thimble cap fits over the thumb stump tip. A rigid arm extends
// from the cap with a downward bend, ending in a rounded grip pad.
// Mount in a fingerless cycling glove: the cradle sits inside the
// glove's thumb pocket, sewn through the wing tabs and wall holes.
//
// COORDINATE SYSTEM (as worn):
//   Z = along arm axis, from stump opening toward grip tip
//   X = width (left-right across the arm)
//   Y = dorsal(+) to palmar(-)
//
// MEASUREMENTS NEEDED (all in mm):
//   cradle_id   : stump circumference / pi, then add 2mm clearance
//   cradle_depth: how much of the stump to cup (leave some free for ROM)
//   arm_pre + arm_post + tip_len: total extension beyond cradle,
//       adjust so prosthetic tip reaches normal thumb tip position
//   bend_angle  : 20-25 wide grip (cup), 30-35 general, 40+ pen grip
//
// PRINTING:
//   Material: PLA (consider lining cradle interior with soft foam)
//   Layer height: 0.2mm, 3 perimeters, 20% infill
//   Post-print: sand cradle interior and all skin-contact edges smooth
// ===================================================================

/* [Stump Cradle] */
cradle_id = 15;
cradle_depth = 10;
wall = 2.5;
slot_w = 3;

/* [Extension Arm] */
arm_pre = 22;
arm_w = 14;
arm_h = 6;
bend_angle = 30;
arm_post = 16;

/* [Grip Tip] */
tip_len = 10;

/* [Cradle Mounting] */
wing_w = 8;
wing_t = 1.5;
hole_d = 2;

/* [Hidden] */
$fn = 48;
tran = 10;

main();

module main() {
    or = cradle_id / 2 + wall;

    difference() {
        union() {
            // Cradle: closed-end thimble
            cylinder(h = cradle_depth + wall, r = or);
            cylinder(h = 0.8, r1 = or + 0.8, r2 = or);

            // Transition: circle to rounded rectangle
            hull() {
                translate([0, 0, cradle_depth + wall - 0.1])
                cylinder(h = 0.1, r = or);
                translate([0, 0, cradle_depth + wall + tran])
                arm_cs(0.1);
            }

            // Pre-bend arm
            translate([0, 0, cradle_depth + wall + tran])
            arm_cs(arm_pre);

            // Post-bend arm + grip tip
            translate([0, 0, cradle_depth + wall + tran + arm_pre])
            rotate([-bend_angle, 0, 0]) {
                arm_cs(arm_post);
                translate([0, 0, arm_post])
                hull() {
                    arm_cs(0.1);
                    translate([0, -1, tip_len])
                    resize([arm_w * 0.7, arm_h + 3, tip_len * 0.6])
                    sphere(d = arm_w);
                }
            }

            // Wing tabs on cradle sides
            cradle_wings();
        }

        // Hollow out cradle interior
        translate([0, 0, -0.1])
        cylinder(h = cradle_depth + 0.2, r = cradle_id / 2);

        // Comfort slot on dorsal (+Y) side
        translate([-slot_w / 2, 0, -0.1])
        cube([slot_w, or + 1, cradle_depth + 0.2]);

        // Sewing holes through cradle wall
        cradle_wall_holes();
    }
}

module arm_cs(h) {
    linear_extrude(height = h)
    offset(r = 1) offset(delta = -1)
    square([arm_w, arm_h], center = true);
}

module cradle_wings() {
    or = cradle_id / 2 + wall;
    wing_h = cradle_depth * 0.7;
    z_off = cradle_depth * 0.15;

    for (side = [-1, 1]) {
        x_start = (side > 0) ? or : -or - wing_w;
        translate([x_start, -wing_t / 2, z_off])
        difference() {
            cube([wing_w, wing_t, wing_h]);
            for (i = [0:1])
                translate([wing_w / 2, -0.1, wing_h * (i + 0.5) / 2])
                rotate([-90, 0, 0])
                cylinder(h = wing_t + 0.2, d = hole_d, $fn = 12);
        }
    }
}

module cradle_wall_holes() {
    or = cradle_id / 2 + wall;
    for (i = [0:1]) {
        z = cradle_depth * (i + 0.5) / 2;
        // Through-holes on left and right (along X axis)
        translate([0, 0, z])
        rotate([0, 90, 0])
        cylinder(h = or * 3, d = hole_d, center = true, $fn = 12);
        // Through-hole on palmar side (along Y axis)
        translate([0, 0, z])
        rotate([90, 0, 0])
        cylinder(h = or * 3, d = hole_d, center = true, $fn = 12);
    }
}
