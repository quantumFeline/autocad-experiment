// thumb_v3.scad
// ===================================================================
// Realistic-proportioned, cybernetic-look thumb prosthesis
// per design/spec.md and design/clean_sketch.png
// ===================================================================
// Coordinate system:
//   Z  up, along the prosthesis axis; z=0 at the base opening
//   +X inner side (towards the other fingers)
//   -X outer side (towards the wrist)
//   +Y palm-back (dorsal side of the hand), -Y palm-front
//
// The proximal phalange is a single hollow truncated pyramid: a
// rounded ~30 mm footprint tapering straight to the 13 mm hinge.
// The stump (triangular with its skin web) sits in the hollow,
// lined with foam.
//
// The hinge is modelled in a local frame (hinge_frame): the pin axis
// is local X, tilted by hinge_tilt in the frontal plane and rolled
// about the thumb axis by hinge_spin. At the default spin of 90 the
// thumb is fully pronated: the pin runs along the palm normal, the
// disks face palm-front/palm-back, flexion curls the tip across the
// palm towards the fingers (mirroring the stump's adduction), and
// the nail faces away from the fingers.
//
// Mechanism (Knick's-style differential tendon):
//   - tendon (fishing line): anchored to the fabric wrap on the
//     wrist side, enters through the outer wall hole above the
//     stump, crosses the hollow interior, exits through the channel
//     below the hinge on the fingers side, rides in the barrel
//     groove, enters the distal tunnel, knots in the anchor pocket.
//     When the stump adducts, the path from the wrist-side anchor
//     lengthens and pulls the distal into flexion.
//   - elastic cord: loops through the two button holes in the
//     wrist-side wall below the hinge, spans the hinge on the wrist
//     side, enters the distal tunnel, knots in its anchor pocket;
//     returns the distal to extension when the stump relaxes
//
// ASSEMBLY:
//   1. print proximal + distal (white PLA), nail + 2 disk rings +
//      2 disk plugs (black/white PLA), 2 sewing plates (TPU)
//   2. slide the distal barrel between the fork cheeks, push a
//      2.5 mm pin through, trim flush with the counterbores
//   3. glue disk rings, then plugs, into the counterbores
//   4. thread tendon and elastic as above
//   5. glue the nail into its pocket
//   6. screw or filament-rivet the sewing plates onto the base pads
// ===================================================================

/* [Part Selection] */
part = "preview"; // [preview, proximal, distal, nail, disk_ring, disk_plug, plate_inner, plate_outer, print_all]
// hinge flexion angle shown in the preview, degrees
preview_flex = 0; // [0:90]
// draw coordinate axes in the preview:
// red = +X (towards fingers), green = +Y (back of hand), blue = +Z (up the thumb)
show_axes = false;

/* [Base] */
// footprint width across the palm plane (X); the hollow leaves
// room for the ~15 mm triangular stump profile plus foam lining
base_w = 30;
// palm-normal depth at the outer (wrist) side
base_depth_outer = 25;
// palm-normal depth at the inner (fingers) side
base_depth_inner = 15;
// obliqueness of the bottom opening rim, degrees: the palm-back
// edge reaches lower than the palm-front one, which makes the
// proximal edges ~35 vs ~30 mm in the front view and keeps the
// palm-front lip from digging in when the stump flexes
rim_tilt = 12;

/* [Shell] */
wall = 2.0;

/* [Hinge placement] */
// the hinge axis is horizontal and the distal runs straight up the
// thumb axis; all the asymmetry lives in the base (rim_tilt) and in
// the gentle sideways drift of the pyramid (hinge_x)
hinge_x = 2;
hinge_z = 32.5;
// roll of the hinge/distal group about the thumb axis, degrees.
//   0 = pin along the fingers-wrist direction: disks face the fingers
//       and the wrist, the tip curls out of the palm plane (palmar)
//  90 = pin along the palm normal: disks face palm-front/palm-back,
//       the tip curls across the palm towards the fingers, mirroring
//       the stump's adduction; nail faces away from the fingers
hinge_spin = 90;

/* [Hinge] */
// knuckle (barrel) outer diameter
knuckle_d = 11;
// width of the hinge region along the pin axis
hinge_w = 13;
// fork cheek thickness
cheek_t = 2.5;
// clearance between barrel and cheeks, per side
hinge_gap = 0.35;
// pin hole diameter (2.5 mm pin + clearance)
pin_hole_d = 2.8;

/* [Hinge disks] */
// decorative disk diameter (black ring + white plug)
disk_d = 8;
// black rim width of the ring
disk_rim = 1.8;
// counterbore depth in the cheek face
disk_recess = 1.4;
// ring / plug thickness
disk_t = 1.2;

/* [Distal phalange] */
distal_len = 25;
// nail length and width
nail_len = 8;
nail_w = 6.5;

/* [Tendon and elastic] */
tunnel_r = 1.2;
// tendon entry hole height on the outer (wrist-side) wall;
// keep above the stump so the line crosses an empty interior
tendon_entry_z = 18;

/* [Sewing plates] */
// the plates sit on the inner (fingers-side) and outer (wrist-side)
// faces of the pyramid; widths follow the base wedge depths there
plate_w_outer = 22;
plate_w_inner = 13;
plate_h = 13;
plate_t = 1.8;
// fabric slit sizes (slit length per plate, common height)
slit_w_outer = 12;
slit_w_inner = 7;
slit_h = 2.8;
// screw hole diameter: in plate (loose) and in base (self-tapping M2)
plate_hole_d = 2.3;
base_hole_d = 1.9;

/* [Hidden] */
// facet override for fast CLI draft renders (0 = automatic)
fn_draft = 0;
$fn = fn_draft > 0 ? fn_draft : ($preview ? 48 : 96);
eps = 0.01;
clr = 0.15;                             // glued-insert clearance
barrel_w = hinge_w - 2*(cheek_t + hinge_gap);
slot_w = barrel_w + 2*hinge_gap;
pocket_d = knuckle_d + 0.7;             // barrel swing pocket
// depth of the base at a given x (linear wedge outer -> inner)
function base_depth_at(x) =
    base_depth_outer + (x + base_w/2) / base_w
                     * (base_depth_inner - base_depth_outer);
// centre height of the sewing plate band on the side faces
plate_z = 10;

// ===================== PART SELECTION =====================

if (part == "preview")      preview_assembly();
if (part == "proximal")     proximal_body();
if (part == "distal")       distal_print();
if (part == "nail")         nail_solid(0);
if (part == "disk_ring")    disk_ring();
if (part == "disk_plug")    disk_plug();
if (part == "plate_inner")  sewing_plate(plate_w_inner, slit_w_inner);
if (part == "plate_outer")  sewing_plate(plate_w_outer, slit_w_outer);
if (part == "print_all")    print_plate();

// ===================== HELPERS =====================

// thin ellipsoid disk used as a loft cross-section for hull chains
module slice(w, d, x=0, y=0, z=0) {
    translate([x, y, z]) resize([w, d, 1.2]) sphere(1);
}

// hull consecutive pairs of child slices -> smooth loft
module loft() {
    for (i = [0 : $children - 2])
        hull() { children(i); children(i+1); }
}

// hinge centre, unrolled; used for the pyramid top slice so it does
// not twist with hinge_spin
module tilt_frame() {
    translate([hinge_x, 0, hinge_z]) children();
}

// places children at the hinge centre, rolled by hinge_spin;
// local X = pin axis, local Z = distal direction at 0 deg flexion
module hinge_frame() {
    tilt_frame() rotate([0, 0, hinge_spin]) children();
}

// cylinder along the local pin axis (X)
module pin_cyl(d, h) {
    rotate([0, 90, 0]) cylinder(d = d, h = h, center = true);
}

// ===================== OUTER FORM =====================

// rounded trapezoid footprint of the pyramid: wedge-shaped in Y
// (deeper at the wrist side)
module footprint_2d(grow = 0) {
    r = 4;
    hull() for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*(base_w/2 - r),
                   sy*(base_depth_at(sx*base_w/2)/2 - r)])
            circle(r = r + grow);
}

module footprint_slab(grow = 0) {
    linear_extrude(1.2) footprint_2d(grow);
}

// soft edge roll just above the footprint
module corner_ring(grow = 0) {
    r = 4.5;
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*(base_w/2 - r - 0.3),
                   sy*(base_depth_at(sx*base_w/2)/2 - r - 0.3), 5])
            sphere(r + grow);
}

// the whole proximal outer form: one truncated pyramid from the
// footprint to the hinge. grow < 0 shrinks it for the hollow;
// top_off lowers the top slice (used to keep the hollow clear of
// the hinge mechanism).
module pyramid(grow = 0, top_off = 0) {
    g2 = 2*grow;
    loft() {
        footprint_slab(grow);
        hull() corner_ring(grow);
        slice(21.5 + g2, 18 + g2,   1,   0, 12);
        slice(17.5 + g2, 16.3 + g2, 1.5, 0, 19);
        slice(14.8 + g2, 15 + g2,   2,   0, 25);
        tilt_frame()
            slice(13 + g2, 13.5 + g2, 0, 0,
                  -(knuckle_d/2 + 0.5 + top_off));
    }
}

// distal phalange outer form in the hinge frame (local Z up at 0 deg).
// Soft palmar bow and a fuller pad, per a real thumb silhouette.
module distal_form(grow = 0) {
    g2 = 2*grow;
    union() {
        loft() {
            slice(11 + g2,   10.5 + g2, 0,  0,   4);
            slice(12.5 + g2, 12 + g2,   0, -0.4, 9.5);
            slice(12 + g2,   11 + g2,   0, -0.7, 15);
            slice(10.5 + g2, 9.5 + g2,  0, -0.8, distal_len - 6);
        }
        // rounded tip
        translate([0, -0.8, distal_len - 5.2])
            resize([10 + g2, 9 + g2, 10 + g2]) sphere(1);
    }
}

// ===================== PROXIMAL =====================

module proximal_body() {
    difference() {
        union() {
            pyramid();
            // knuckle hub around the pin axis
            hinge_frame() pin_cyl(knuckle_d, hinge_w);
        }
        cavity();
        fork_slot();
        hinge_frame() {
            // pin bore through both cheeks
            pin_cyl(pin_hole_d, hinge_w + 2);
            // disk counterbores on the outside cheek faces
            for (s = [-1, 1])
                translate([s*(hinge_w/2 - disk_recess/2 + eps/2), 0, 0])
                    pin_cyl(disk_d + 2*clr, disk_recess + eps);
            // round the cheek tops off along the knuckle circle
            difference() {
                translate([-hinge_w/2 - 1, -(knuckle_d/2 + 5), 0.5])
                    cube([hinge_w + 2, knuckle_d + 10, knuckle_d]);
                pin_cyl(knuckle_d - eps, hinge_w + 4);
            }
            // tendon channel: from the hollow interior up through the
            // flexion-side lip, surfacing inside the barrel pocket
            hull() {
                translate([0, -2.5, -11.5]) sphere(tunnel_r);
                translate([0, -4.8, -2.4]) sphere(tunnel_r);
            }
            // elastic anchor: two button holes through the extension-
            // side wall below the knuckle; the cord loops through
            for (s = [-1, 1])
                translate([s*2.2, 4, -12])
                    rotate([-90, 0, 0]) cylinder(d = 2, h = 6);
        }
        // tendon entry hole through the outer (wrist-side) wall,
        // above the stump
        translate([-base_w/2 + 2, 0, tendon_entry_z])
            rotate([0, 90, 0]) cylinder(d = 2.4, h = 10);
        plate_pockets();
        // oblique bottom rim: hinged on the palm-back bottom edge,
        // rising towards the palm-front
        translate([0, base_depth_outer/2, 0]) rotate([-rim_tilt, 0, 0])
            translate([0, 0, -25]) cube([90, 90, 50], center = true);
    }
}

// hollow interior: open cup from below, tapering with the pyramid
// and stopping short of the hinge mechanism
module cavity() {
    union() {
        pyramid(-wall, 3.5);
        // open the bottom
        translate([0, 0, -4]) linear_extrude(4 + 2*eps)
            footprint_2d(-wall);
    }
}

// clears the space between the fork cheeks: a slab above the slot
// floor plus a cylindrical pocket the barrel swings in
module fork_slot() {
    hinge_frame() {
        translate([-slot_w/2, -knuckle_d/2 - 4, -1.5])
            cube([slot_w, knuckle_d + 8, knuckle_d + 6]);
        pin_cyl(pocket_d, slot_w);
    }
}

// local frame on the inner (s=1, fingers side) or outer (s=-1,
// wrist side) face of the pyramid: origin on the face at y=0,
// z=plate_z; local +Z = outward normal, local X along the plate
// width (world Y). The frame leans with the pyramid side.
module side_face_frame(s) {
    lean = s > 0 ? 13 : 25;    // face slope off vertical, degrees
    xc   = s > 0 ? 13.3 : -12.2;
    translate([xc, 0, plate_z])
        rotate([0, s*(90 - lean), 0])
            // orient the plate upright and align it with the
            // oblique bottom rim
            rotate([0, 0, s*(90 - rim_tilt)])
                children();
}

function plate_w_of(s)  = s > 0 ? plate_w_inner : plate_w_outer;
function slit_w_of(s)   = s > 0 ? slit_w_inner : slit_w_outer;

// flat pockets with screw holes for the TPU sewing plates
module plate_pockets() {
    for (s = [-1, 1]) side_face_frame(s) {
        w = plate_w_of(s);
        // flat pocket, 0.8 deep, also shaves the face bulges flush
        translate([0, 0, -0.8]) linear_extrude(8)
            offset(3) square([w - 6 + 0.6, plate_h - 6 + 0.6],
                             center = true);
        // screw pilot holes (self-tapping M2), lower band
        for (h = [-1, 1])
            translate([h*(w/2 - 3.5), -plate_h/2 + 3, -6])
                cylinder(d = base_hole_d, h = 7);
    }
}

// ===================== DISTAL =====================

module distal_body() {
    difference() {
        union() {
            distal_form();
            // barrel with a central tendon groove (pulley)
            difference() {
                pin_cyl(knuckle_d, barrel_w);
                rotate([0, 90, 0]) rotate_extrude()
                    translate([knuckle_d/2, 0]) circle(r = tunnel_r);
            }
            // root fan: barrel to phalange, kept inside the slot width
            hull() {
                pin_cyl(knuckle_d, barrel_w);
                slice(11, 10.5, 0, 0, 4);
            }
            // extension stop heel: dorsal tab that rests on the slot
            // floor at 0 deg and lifts away in flexion
            translate([-barrel_w/2, 2.5, -1.2])
                cube([barrel_w, knuckle_d/2 - 0.5, 3]);
        }
        // pin bore
        pin_cyl(pin_hole_d, hinge_w + 2);
        // palmar tendon tunnel: root entry to anchor pocket
        hull() {
            translate([0, -knuckle_d/2 - 0.3, 1.5]) sphere(tunnel_r);
            translate([0, -4.6, 9]) sphere(tunnel_r);
        }
        // palmar anchor pocket (knot recess)
        translate([0, -4.9, 9]) sphere(2.2);
        // dorsal elastic tunnel and anchor pocket
        hull() {
            translate([0, knuckle_d/2 + 0.3, 1.5]) sphere(tunnel_r);
            translate([0, 4.4, 8]) sphere(tunnel_r);
        }
        translate([0, 4.7, 8]) sphere(2.2);
        // nail pocket
        nail_solid(clr);
        // lightening cavity, clear of tunnels and hinge
        intersection() {
            distal_form(-3);
            translate([0, 0, 7]) cube([20, 20, 12], center = true);
        }
    }
}

// distal in print orientation (barrel down is preview default here;
// print tip-up with a brim, or on its side, whichever slices cleaner)
module distal_print() { distal_body(); }

// ===================== BLACK / WHITE INLAYS =====================

// decorative nail: almond dome, half-buried in the dorsal surface of
// the distal phalange; also used (grown) to cut the pocket
module nail_solid(grow) {
    cz = distal_len - 9;          // nail centre along the phalange
    translate([0, 4.1, cz])
        resize([nail_w + 2*grow, 3 + 2*grow, nail_len + 2*grow])
            sphere(1);
}

module disk_ring() {
    difference() {
        cylinder(d = disk_d, h = disk_t);
        translate([0, 0, -eps]) cylinder(d = disk_d - 2*disk_rim, h = disk_t + 2*eps);
    }
}

module disk_plug() {
    cylinder(d = disk_d - 2*disk_rim - 2*clr, h = disk_t);
}

// ===================== SEWING PLATES (TPU) =====================

// w = plate width, sw = slit length; slit in the upper half, screw
// holes in the lower half (matching the base pad pilot holes)
module sewing_plate(w, sw) {
    difference() {
        linear_extrude(plate_t)
            offset(3) square([w - 6, plate_h - 6], center = true);
        // fabric slit
        translate([0, plate_h/2 - 3 - slit_h/2, -eps])
            linear_extrude(plate_t + 2*eps)
                offset(slit_h/2) square([sw - slit_h, eps], center = true);
        // screw holes
        for (h = [-1, 1])
            translate([h*(w/2 - 3.5), -plate_h/2 + 3, -eps])
                cylinder(d = plate_hole_d, h = plate_t + 2*eps);
    }
}

// ===================== PREVIEW / PLATES =====================

module axis_gizmo() {
    translate([0, 0, -10]) {
        color("red")   rotate([0, 90, 0])  cylinder(r = 0.8, h = 22);
        color("green") rotate([-90, 0, 0]) cylinder(r = 0.8, h = 22);
        color("blue")  cylinder(r = 0.8, h = 12);
    }
}

module preview_assembly() {
    if (show_axes) axis_gizmo();
    color("white") proximal_body();
    hinge_frame() rotate([preview_flex, 0, 0]) {
        color("white") distal_body();
        color("black") nail_solid(0);
    }
    // disk rings and plugs in place
    hinge_frame() for (s = [-1, 1])
        translate([s*(hinge_w/2 - disk_recess), 0, 0])
        rotate([0, s*90, 0]) {
            color("black") disk_ring();
            color("white") disk_plug();
        }
    // sewing plates seated in their pockets
    for (s = [-1, 1])
        color([0.2, 0.2, 0.25])
            side_face_frame(s) translate([0, 0, -0.8])
                sewing_plate(plate_w_of(s), slit_w_of(s));
}

// all printable parts laid out flat
module print_plate() {
    translate([-25, 0, 0]) proximal_body();
    translate([15, 0, knuckle_d/2]) rotate([0, 90, 0])
        rotate([0, -90, 0]) distal_body();
    translate([35, 15, 0]) disk_ring();
    translate([45, 15, 0]) disk_ring();
    translate([35, 25, 0]) disk_plug();
    translate([45, 25, 0]) disk_plug();
    translate([40, -15, 0]) rotate([0, -90, 90]) nail_solid(0);
    translate([70, 12, 0]) sewing_plate(plate_w_inner, slit_w_inner);
    translate([70, -12, 0]) sewing_plate(plate_w_outer, slit_w_outer);
}
