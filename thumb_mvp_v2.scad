// thumb_mvp_v2.scad
// ===================================================================
// Thumb Extension with Tendon-Driven Flexing Hinge
// ===================================================================
// The v1 fixed bend is replaced by a pin hinge. A tendon routed along
// the palmar side converts the stump's adduction into flexion at the
// hinge. Elastic on the dorsal side provides return force.
//
// The hinge sits where the static bend was in v1. The distal segment
// is the post-bend arm + tip from v1, now free to pivot.
//
// ASSEMBLY:
//   1. Print part 1 (proximal) and part 2 (distal) separately
//   2. Slot the distal barrel between the proximal fork prongs
//   3. Push a 2mm pin (nail/wire) through the aligned holes
//   4. Thread tendon (fishing line): from glove anchor, through arm
//      palmar tunnel, around hinge, through distal palmar tunnel
//   5. Thread elastic cord through dorsal tunnels, tie off at both
//      anchor points
// ===================================================================

/* [Part Selection] */
part = 0; // [0:Preview, 1:Proximal body, 2:Distal segment]
preview_flex = 35; // [0:90]

/* [Stump Cradle] */
cradle_w = 18;
cradle_d = 14;
cradle_depth = 10;
cradle_taper = 0.55;
wall = 2.5;
slot_w = 3;

/* [Proximal Arm] */
arm_pre = 22;
arm_w = 14;
arm_h = 12;

/* [Hinge] */
hinge_d = 9;
pin_d = 2.3;
fork_t = 2.5;
hinge_gap = 0.35;

/* [Distal Segment] */
arm_post = 18;
tip_len = 8;

/* [Tendon and Elastic] */
tunnel_r = 1.1;

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
arm_bend_w = arm_w * 0.95;
arm_bend_h = arm_h * 0.95;
barrel_w = arm_bend_w - 2 * (fork_t + hinge_gap);
fork_len = hinge_d / 2 + 2;

// ===================== PART SELECTION =====================

if (part == 0) preview_assembled();
if (part == 1) proximal_body();
if (part == 2) print_distal();

// ===================== SHARED MODULES =====================

module ell(w, h, ht) {
    linear_extrude(height = ht)
    scale([1, h / w])
    circle(d = w);
}

module rr(w, d, ht) {
    r = min(w, d) * 0.38;
    linear_extrude(height = ht)
    offset(r = r) offset(delta = -r)
    square([w, d], center = true);
}

// ===================== PROXIMAL BODY (part 1) =====================
// Cradle + straight arm + hinge fork at the bend point

module proximal_body() {
    difference() {
        union() {
            cradle_outer();
            proximal_arm();
            palm_plate();
        }
        cradle_hollow();
        comfort_slot();
        stitch_holes();
        proximal_tendon_tunnel();
        proximal_elastic_tunnel();
    }
}

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
    hull() {
        rr(ow + 1.2, od + 1.2, 0.1);
        translate([0, 0, 1])
        rr(ow, od, 0.1);
    }
}

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

// Straight arm from cradle top to hinge fork (no fixed bend)
module proximal_arm() {
    z1 = cradle_depth + wall;
    z2 = z1 + tran;
    z3 = z2 + arm_pre;

    tw = cradle_w * cradle_taper + wall * 2;
    td = cradle_d * cradle_taper + wall * 2;

    // Transition from cradle to arm
    hull() {
        translate([0, 0, z1 - 0.1])
        rr(tw, td, 0.1);
        translate([0, 0, z2])
        ell(arm_w, arm_h, 0.1);
    }

    // Straight arm (slight taper toward hinge)
    hull() {
        translate([0, 0, z2])
        ell(arm_w, arm_h, 0.1);
        translate([0, 0, z3])
        ell(arm_bend_w, arm_bend_h, 0.1);
    }

    // Hinge fork at the bend point
    translate([0, 0, z3])
    hinge_fork();
}

// Fork (clevis) at arm end: two prongs with pin hole
module hinge_fork() {
    difference() {
        union() {
            for (side = [-1, 1]) {
                x = side * (barrel_w / 2 + hinge_gap + fork_t / 2);
                hull() {
                    translate([x, 0, 0])
                    scale([1, arm_bend_h / fork_t])
                    cylinder(d = fork_t, h = 0.1, $fn = 20);

                    translate([x, 0, fork_len])
                    rotate([0, 90, 0])
                    cylinder(d = hinge_d, h = fork_t, center = true, $fn = 32);
                }
            }
            // Dorsal bridge between prongs
            hull() {
                for (side = [-1, 1]) {
                    x = side * (barrel_w / 2 + hinge_gap + fork_t / 2);
                    translate([x, arm_bend_h * 0.25, fork_len * 0.4])
                    sphere(r = fork_t * 0.45, $fn = 16);
                }
            }
        }
        // Pin hole
        translate([0, 0, fork_len])
        rotate([0, 90, 0])
        cylinder(d = pin_d, h = arm_w + 2, center = true, $fn = 20);

        // Barrel rotation clearance
        translate([0, 0, fork_len])
        rotate([0, 90, 0])
        cylinder(d = hinge_d + hinge_gap * 2, h = barrel_w + hinge_gap * 2,
                 center = true, $fn = 32);

        // Open palmar side for distal segment to swing through
        translate([0, -(hinge_d / 2 + 2), fork_len])
        cube([barrel_w + hinge_gap * 2, hinge_d, hinge_d + 4], center = true);
    }
}

// Tendon tunnel through proximal arm (palmar side, -Y)
module proximal_tendon_tunnel() {
    z2 = cradle_depth + wall + tran;
    z3 = z2 + arm_pre;
    y_off = arm_h / 2 - tunnel_r - 0.8;

    // Tunnel from arm start to hinge
    hull() {
        translate([0, -y_off, z2 + 2])
        sphere(r = tunnel_r);
        translate([0, -(arm_bend_h / 2 - tunnel_r - 0.5), z3 + fork_len])
        sphere(r = tunnel_r);
    }
    // Entry hole (tendon comes from glove anchor, enters arm here)
    translate([0, -(arm_h / 2 + 0.5), z2 + 2])
    sphere(r = tunnel_r * 2);
    // Exit at hinge
    translate([0, -(arm_bend_h / 2 - tunnel_r + 0.5), z3 + fork_len])
    sphere(r = tunnel_r * 1.5);
}

// Elastic tunnel through proximal arm (dorsal side, +Y)
module proximal_elastic_tunnel() {
    z3 = cradle_depth + wall + tran + arm_pre;
    // Anchor hole on dorsal side near hinge
    hull() {
        translate([0, arm_bend_h / 2 - tunnel_r, z3 + fork_len - 3])
        sphere(r = tunnel_r);
        translate([0, arm_bend_h / 2 + 1, z3 + fork_len - 3])
        sphere(r = tunnel_r);
    }
}

// ===================== DISTAL SEGMENT (part 2) =====================
// Barrel + post-bend arm + dome tip (the old post-bend section, now pivoting)

module distal_segment() {
    arm_end_w = arm_bend_w * 0.85;
    arm_end_h = arm_bend_h * 0.9;
    tip_w = arm_end_w * 0.5;
    tip_h = arm_end_h * 0.6;

    difference() {
        union() {
            // Barrel (sits between fork prongs)
            rotate([0, 90, 0])
            cylinder(d = hinge_d - 0.2, h = barrel_w - 0.2,
                     center = true, $fn = 32);

            // Arm body: from barrel upward to tip
            hull() {
                translate([0, 0, hinge_d / 2 - 0.5])
                ell(barrel_w, hinge_d * 0.85, 0.1);

                translate([0, 0, hinge_d / 2 + arm_post * 0.3])
                ell(arm_end_w, arm_end_h, 0.1);
            }
            hull() {
                translate([0, 0, hinge_d / 2 + arm_post * 0.3])
                ell(arm_end_w, arm_end_h, 0.1);

                translate([0, 0, hinge_d / 2 + arm_post])
                ell(arm_end_w * 0.9, arm_end_h * 0.95, 0.1);
            }

            // Dome tip
            translate([0, 0, hinge_d / 2 + arm_post])
            hull() {
                ell(arm_end_w * 0.9, arm_end_h * 0.95, 0.1);
                translate([0, 0, tip_len])
                resize([tip_w, tip_h, tip_h])
                sphere(d = 1, $fn = 32);
            }
        }

        // Pin hole
        rotate([0, 90, 0])
        cylinder(d = pin_d, h = barrel_w + 2, center = true, $fn = 20);

        // Extension stop: flat face toward arm (prevents hyperextension)
        translate([0, 0, -(hinge_d / 2 + 0.5)])
        cube([barrel_w + 1, hinge_d + 2, hinge_d], center = true);

        // Tendon tunnel (palmar side, -Y)
        hull() {
            translate([0, -(hinge_d / 2 - tunnel_r - 0.3), 0])
            sphere(r = tunnel_r);
            translate([0, -(arm_end_h * 0.3),
                       hinge_d / 2 + arm_post + tip_len - tunnel_r])
            sphere(r = tunnel_r);
        }
        // Enlarged tendon entry at barrel
        translate([0, -(hinge_d / 2 - tunnel_r + 0.8), 0])
        sphere(r = tunnel_r * 1.8);

        // Elastic tunnel (dorsal side, +Y)
        hull() {
            translate([0, hinge_d / 2 - tunnel_r - 0.3, 0])
            sphere(r = tunnel_r);
            translate([0, arm_end_h * 0.2,
                       hinge_d / 2 + arm_post * 0.5])
            sphere(r = tunnel_r);
        }
        // Enlarged elastic entry
        translate([0, hinge_d / 2 - tunnel_r + 0.8, 0])
        sphere(r = tunnel_r * 1.5);
    }
}

// Orient for printing: tip down, barrel up
module print_distal() {
    rotate([180, 0, 0])
    distal_segment();
}

// ===================== PALM PLATE =====================

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

// ===================== CRADLE DETAILS =====================

module comfort_slot() {
    max_y = cradle_d / 2 + wall + 1;
    translate([-slot_w / 2, 0, -0.1])
    cube([slot_w, max_y, cradle_depth + 0.2]);
}

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

// ===================== PREVIEW =====================

module preview_assembled() {
    z3 = cradle_depth + wall + tran + arm_pre;

    color("SteelBlue") proximal_body();

    // Distal segment pivots at the hinge, flexing toward palm (-Y)
    translate([0, 0, z3 + fork_len])
    rotate([-preview_flex, 0, 0])
    color("Coral") distal_segment();
}
