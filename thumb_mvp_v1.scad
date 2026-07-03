// thumb_mvp_v1.scad
// ===================================================================
// Rigid Thumb Extension Prosthetic - MVP
// ===================================================================
// A tapered thimble cap fits over the thumb stump. A rigid arm
// extends from the cap with a downward bend and rounded grip tip.
// A palm plate extends from the cradle toward the wrist for mounting
// inside a fingerless cycling glove.
//
// COORDINATE SYSTEM (as worn):
//   Z = along arm axis, from stump opening toward grip tip
//   X = width (left-right across the arm)
//   Y = dorsal(+) to palmar(-). Palm plate is on -Y side.
//
// MEASUREMENTS NEEDED (all in mm):
//   cradle_w/d  : stump cross-section at widest + ~2mm clearance
//   cradle_depth: how much stump to cup (leave some free for ROM)
//   cradle_taper: ratio of top to base width (0.7-0.9)
//   arm lengths : adjust so tip reaches normal thumb tip position
//   bend_angle  : 20-25 cup, 30-35 general, 40+ pen
//
// PRINTING:
//   Cradle + arm: PLA, 0.2mm layers, 3 perimeters, 20% infill
//   Palm plate: consider printing thin (2mm) or in TPU for flex
//   Post-print: sand cradle interior and skin-contact edges smooth
// ===================================================================

/* [Stump Cradle] */
// Width at cradle opening (wider axis of stump + clearance)
cradle_w = 18;
// Depth at cradle opening (narrower axis + clearance)
cradle_d = 14;
// Cup height
cradle_depth = 10;
// Taper ratio: top dimensions as fraction of base (< 1 = narrows)
cradle_taper = 0.8;
// Wall thickness
wall = 2.5;
// Comfort slot width on dorsal side
slot_w = 3;

/* [Extension Arm] */
// Straight section before bend
arm_pre = 22;
// Arm width
arm_w = 14;
// Arm thickness
arm_h = 6;
// Downward bend angle (degrees toward palm/objects)
bend_angle = 30;
// Section after bend
arm_post = 16;

/* [Grip Tip] */
// Grip pad length
tip_len = 10;

/* [Palm Plate] */
// Length extending toward wrist from cradle base
plate_len = 25;
// Width of palm plate
plate_w = 22;
// Thickness (keep thin for comfort under glove, or print in TPU)
plate_t = 2;

/* [Mounting] */
// Sewing hole diameter
hole_d = 2;

/* [Hidden] */
$fn = 48;
tran = 10;

main();

module main() {
    difference() {
        union() {
            cradle_outer();
            arm_assembly();
            palm_plate();
        }
        cradle_hollow();
        comfort_slot();
        stitch_holes();
    }
}

// Rounded rectangle extrusion helper
module rr(w, d, h, r = 2) {
    linear_extrude(height = h)
    offset(r = r) offset(delta = -r)
    square([w, d], center = true);
}

// Arm cross-section
module arm_cs(h) {
    linear_extrude(height = h)
    offset(r = 1) offset(delta = -1)
    square([arm_w, arm_h], center = true);
}

// Outer cradle shell: tapered (blunt pyramid), closed top
module cradle_outer() {
    ow = cradle_w + wall * 2;
    od = cradle_d + wall * 2;
    tw = cradle_w * cradle_taper + wall * 2;
    td = cradle_d * cradle_taper + wall * 2;

    // Tapered body + cap
    hull() {
        rr(ow, od, 0.1);
        translate([0, 0, cradle_depth + wall])
        rr(tw, td, 0.1);
    }
    // Chamfer at opening for comfort
    hull() {
        rr(ow + 1.6, od + 1.6, 0.1, 2.5);
        translate([0, 0, 0.8])
        rr(ow, od, 0.1);
    }
}

// Interior cavity (tapered to match outer shell)
module cradle_hollow() {
    tw = cradle_w * cradle_taper;
    td = cradle_d * cradle_taper;

    translate([0, 0, -0.1])
    hull() {
        rr(cradle_w, cradle_d, 0.1, 1.5);
        translate([0, 0, cradle_depth + 0.1])
        rr(tw, td, 0.1, 1.5);
    }
}

// Transition from cradle top to arm, pre-bend arm, bend, post-bend, tip
module arm_assembly() {
    z1 = cradle_depth + wall;
    z2 = z1 + tran;
    z3 = z2 + arm_pre;

    tw = cradle_w * cradle_taper + wall * 2;
    td = cradle_d * cradle_taper + wall * 2;

    // Transition: pyramid top -> rectangular arm
    hull() {
        translate([0, 0, z1 - 0.1])
        rr(tw, td, 0.1);
        translate([0, 0, z2])
        arm_cs(0.1);
    }

    // Pre-bend arm
    translate([0, 0, z2])
    arm_cs(arm_pre);

    // Bend filler: fills the gap at the bend joint
    translate([0, 0, z3])
    hull() {
        arm_cs(0.1);
        rotate([-bend_angle, 0, 0])
        arm_cs(0.1);
    }

    // Post-bend arm
    translate([0, 0, z3])
    rotate([-bend_angle, 0, 0]) {
        arm_cs(arm_post);

        // Grip tip: rounded, slightly wider on palmar side
        translate([0, 0, arm_post])
        hull() {
            arm_cs(0.1);
            translate([0, -1, tip_len])
            resize([arm_w * 0.7, arm_h + 3, tip_len * 0.6])
            sphere(d = arm_w);
        }
    }
}

// Flat plate on palmar side, extending from cradle base toward wrist
module palm_plate() {
    y_base = -(cradle_d / 2 + wall);
    overlap = cradle_depth * 0.3;

    // Plate body
    translate([-plate_w / 2, y_base - plate_t, -plate_len])
    cube([plate_w, plate_t, plate_len + overlap]);

    // Fillet connecting plate to cradle (smooth the junction)
    hull() {
        translate([-plate_w / 2, y_base - plate_t, 0])
        cube([plate_w, plate_t, 0.1]);
        translate([-(cradle_w / 2 + wall), y_base - 0.1, 0])
        cube([cradle_w + wall * 2, 0.1, cradle_depth * 0.2]);
    }
}

// Comfort slot on dorsal (+Y) side for flex and insertion
module comfort_slot() {
    max_y = cradle_d / 2 + wall + 1;
    translate([-slot_w / 2, 0, -0.1])
    cube([slot_w, max_y, cradle_depth + 0.2]);
}

// Sewing holes through the palm plate
module stitch_holes() {
    y_base = -(cradle_d / 2 + wall);

    // Through palm plate (two rows)
    for (i = [0:3]) {
        z = -plate_len + plate_len * (i + 0.5) / 4;
        for (x_off = [-plate_w / 2 + 3, plate_w / 2 - 3]) {
            translate([x_off, y_base - plate_t - 0.1, z])
            rotate([-90, 0, 0])
            cylinder(h = plate_t + 0.2, d = hole_d, $fn = 12);
        }
    }
}
