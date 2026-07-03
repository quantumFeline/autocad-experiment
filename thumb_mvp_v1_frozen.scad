// thumb_mvp_v1.scad
// ===================================================================
// Rigid Thumb Extension Prosthetic - MVP
// ===================================================================
// Organic, finger-like shape. Tapered cradle over the stump, smooth
// elliptical arm with bend, rounded grip tip. Palm plate for mounting.
//
// MEASUREMENTS NEEDED (all in mm):
//   cradle_w/d  : stump cross-section at widest + ~2mm clearance
//   cradle_depth: how much stump to cup
//   cradle_taper: top/bottom ratio (0.7-0.9)
//   arm lengths : total should match normal thumb length
//   bend_angle  : 20-25 cup, 30-35 general, 40+ pen
// ===================================================================

/* [Stump Cradle] */
cradle_w = 18;
cradle_d = 14;
cradle_depth = 10;
cradle_taper = 0.55;
wall = 2.5;
slot_w = 3;

/* [Extension Arm] */
arm_pre = 22;
arm_w = 14;
arm_h = 12;
bend_angle = 30;
arm_post = 16;

/* [Grip Tip] */
tip_len = 8;

/* [Palm Plate] */
plate_len = 18;
plate_w = 20;
plate_t = 2;
plate_r = 5;

/* [Mounting] */
hole_d = 2;

/* [Hidden] */
$fn = 64;
tran = 12;

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

// Elliptical cross-section (organic arm profile)
module ell(w, h, ht) {
    linear_extrude(height = ht)
    scale([1, h / w])
    circle(d = w);
}

// Rounded rectangle cross-section
module rr(w, d, ht) {
    r = min(w, d) * 0.38;
    linear_extrude(height = ht)
    offset(r = r) offset(delta = -r)
    square([w, d], center = true);
}

// Tapered cradle outer shell
module cradle_outer() {
    ow = cradle_w + wall * 2;
    od = cradle_d + wall * 2;
    tw = cradle_w * cradle_taper + wall * 2;
    td = cradle_d * cradle_taper + wall * 2;

    hull() {
        rr(ow, od, 0.1);
        translate([0, 0, cradle_depth + wall])
        rr(tw, td, 0.1);
    }
    // Lip chamfer at opening
    hull() {
        rr(ow + 1.2, od + 1.2, 0.1);
        translate([0, 0, 1])
        rr(ow, od, 0.1);
    }
}

// Interior cavity
module cradle_hollow() {
    tw = cradle_w * cradle_taper;
    td = cradle_d * cradle_taper;
    translate([0, 0, -0.1])
    hull() {
        rr(cradle_w, cradle_d, 0.1);
        translate([0, 0, cradle_depth + 0.1])
        rr(tw, td, 0.1);
    }
}

// Full arm: transition, pre-bend, bend filler, post-bend, tip
module arm_assembly() {
    z1 = cradle_depth + wall;
    z2 = z1 + tran;
    z3 = z2 + arm_pre;

    tw = cradle_w * cradle_taper + wall * 2;
    td = cradle_d * cradle_taper + wall * 2;

    // Transition from cradle top to elliptical arm
    hull() {
        translate([0, 0, z1 - 0.1])
        rr(tw, td, 0.1);
        translate([0, 0, z2])
        ell(arm_w, arm_h, 0.1);
    }

    // Pre-bend arm (slight taper toward the bend)
    hull() {
        translate([0, 0, z2])
        ell(arm_w, arm_h, 0.1);
        translate([0, 0, z3])
        ell(arm_w * 0.95, arm_h * 0.95, 0.1);
    }

    // Bend filler (smooth outer curve)
    translate([0, 0, z3])
    hull() {
        ell(arm_w * 0.95, arm_h * 0.95, 0.1);
        rotate([-bend_angle, 0, 0])
        ell(arm_w * 0.95, arm_h * 0.95, 0.1);
    }

    // Post-bend arm (tapers further toward tip)
    translate([0, 0, z3])
    rotate([-bend_angle, 0, 0]) {
        hull() {
            ell(arm_w * 0.95, arm_h * 0.95, 0.1);
            translate([0, 0, arm_post])
            ell(arm_w * 0.8, arm_h * 0.9, 0.1);
        }

        // Grip tip: smooth dome cap
        translate([0, 0, arm_post])
        hull() {
            ell(arm_w * 0.8, arm_h * 0.9, 0.1);
            translate([0, 0, tip_len])
            resize([arm_w * 0.5, arm_h * 0.6, arm_h * 0.6])
            sphere(d = 1, $fn = 32);
        }
    }
}

// Palm plate: thick rounded mounting pad, flush against palm side of cradle
module palm_plate() {
    y_base = -(cradle_d / 2 + wall);
    overlap = cradle_depth * 0.2;
    sr = plate_t / 2;
    top_w = plate_w;
    bot_w = plate_w * 0.5;

    translate([0, y_base - sr, 0])
    hull() {
        for (x = [-(top_w / 2 - sr), top_w / 2 - sr])
            translate([x, 0, overlap])
            sphere(r = sr);

        for (x = [-(bot_w / 2 - sr), bot_w / 2 - sr])
            translate([x, 0, -plate_len])
            sphere(r = sr);
    }
}

// Comfort slot on dorsal (+Y) side
module comfort_slot() {
    max_y = cradle_d / 2 + wall + 1;
    translate([-slot_w / 2, 0, -0.1])
    cube([slot_w, max_y, cradle_depth + 0.2]);
}

// Stitch holes through the palm plate
module stitch_holes() {
    y_base = -(cradle_d / 2 + wall);
    sr = plate_t / 2;
    top_w = plate_w;
    bot_w = plate_w * 0.5;
    overlap = cradle_depth * 0.4;
    total = plate_len + overlap;

    for (i = [0:2]) {
        frac = (i + 0.5) / 3;
        z = overlap - total * frac;
        pw = bot_w + (top_w - bot_w) * (1 - frac);
        for (x_off = [-(pw / 2 - 3), pw / 2 - 3]) {
            translate([x_off, y_base - sr - sr - 0.1, z])
            rotate([-90, 0, 0])
            cylinder(h = plate_t + 0.2, d = hole_d, $fn = 12);
        }
    }
}
