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
// The proximal phalange is a single hollow truncated pyramid over a
// rounded trapezoid footprint: parallel 15/25 mm sides at the
// palm-front/palm-back, two ~30 mm slanted sides facing the fingers
// and the wrist (these carry the sewing plates). It tapers straight
// to the 13 mm hinge; the stump sits in the hollow, lined with foam.
//
// The hinge is modelled in a local frame (hinge_frame): the pin axis
// is local X, rolled about the thumb axis by hinge_spin. At the
// default spin of 90 the thumb is fully pronated: the pin runs along
// the palm normal, the disks face palm-front/palm-back, flexion
// curls the tip across the palm towards the fingers (mirroring the
// stump's adduction), and the nail faces away from the fingers.
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
part = "preview"; // [preview, proximal, distal, nail, disk_ring, disk_plug, plate, print_all]
// hinge flexion angle shown in the preview, degrees
preview_flex = 0; // [0:78]
// draw coordinate axes in the preview:
// red = +X (towards fingers), green = +Y (back of hand), blue = +Z (up the thumb)
show_axes = false;

/* [Base] */
// palm-normal depth of the footprint; the two ~30 mm slanted sides
// face the fingers and the wrist and carry the sewing plates
base_d = 30;
// footprint width across the palm at the palm-back side
base_w_back = 25;
// footprint width across the palm at the palm-front side
base_w_front = 15;
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
// knuckle outer diameter (the visible hinge cylinder)
knuckle_d = 11;
// barrel diameter, smaller than the knuckle so its swing pocket
// stays inside the hub and leaves a natural extension stop floor
barrel_d = 9;
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
// nail length and width (slender ellipse, sitting high on the tip)
nail_len = 8.5;
nail_w = 5;

/* [Tendon and elastic] */
tunnel_r = 1.2;
// tendon entry hole height on the outer (wrist-side) wall;
// keep above the stump so the line crosses an empty interior
tendon_entry_z = 18;

/* [Sewing plates] */
// the plates sit on the two long (~30 mm) faces of the pyramid,
// facing the fingers and the wrist, slitted halves below the rim
plate_w = 27;
plate_h = 13;
plate_t = 1.8;
// fabric slit size
slit_w = 19;
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
pocket_d = barrel_d + 0.7;              // barrel swing pocket
// proximal cross-section just under the knuckle (slightly larger
// than the hinge so the cheeks sit flush with the shaft)
top_w = 13.2;
top_d = 13.5;
// proximal loft sections (more = smoother silhouette; 9 leaves
// visible banding on the swept faces)
prox_n = 15;
// height below which the proximal keeps its full footprint
skirt_h = 4;
// centre height of the sewing plate band: screw band on the face,
// slitted half hanging below the base rim
plate_z = 2.8;

function lerp(a, b, t) = a + (b - a)*t;
// smoothstep: zero slope at both ends, so the skirt shoulder and
// the landing under the knuckle blend without creases
function ease(t) = let (u = max(0, min(1, t))) u*u*(3 - 2*u);

// ===================== PART SELECTION =====================

if (part == "preview")      preview_assembly();
if (part == "proximal")     proximal_body();
if (part == "distal")       distal_body();
if (part == "nail")         rotate([90, 0, 0]) nail_shape(0);
if (part == "disk_ring")    disk_ring();
if (part == "disk_plug")    disk_plug();
if (part == "plate")        sewing_plate();
if (part == "print_all")    print_all();

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

// places children at the hinge centre, rolled by hinge_spin;
// local X = pin axis, local Z = distal direction at 0 deg flexion
module hinge_frame() {
    translate([hinge_x, 0, hinge_z]) rotate([0, 0, hinge_spin]) children();
}

// cylinder along the local pin axis (X)
module pin_cyl(d, h) {
    rotate([0, 90, 0]) cylinder(d = d, h = h, center = true);
}

// ===================== OUTER FORM =====================

// the proximal cross-section at height z: a rounded trapezoid
// (parallel 15/25 mm sides at palm-front/palm-back, ~30 mm slanted
// sides at the fingers and wrist sides) that morphs into a near-
// circle under the knuckle. grow < 0 shrinks it for the hollow.
module prox_section_2d(z, h, grow = 0) {
    t  = ease((z - skirt_h) / (h - skirt_h));
    wf = lerp(base_w_front, top_w, t) + 2*grow;  // palm-front width
    wb = lerp(base_w_back,  top_w, t) + 2*grow;  // palm-back width
    d  = lerp(base_d,       top_d, t) + 2*grow;  // palm-normal depth
    r  = min(lerp(4, 6, t) + grow,
             min(wf, wb, d)/2 - 0.5);           // corner rounding
    translate([lerp(0, hinge_x, t), 0])
        offset(r) polygon([
            [-(wf/2 - r), -(d/2 - r)],
            [  wf/2 - r,  -(d/2 - r)],
            [  wb/2 - r,   d/2 - r ],
            [-(wb/2 - r),  d/2 - r ]]);
}

// the whole proximal outer form: one smooth sweep of the section
// profile from the footprint to just below the knuckle. top_off
// lowers the top (used to keep the hollow clear of the mechanism).
module pyramid(grow = 0, top_off = 0) {
    // the top section reaches 0.5 into the knuckle hub so the sweep
    // and the hub fuse into one solid
    h = hinge_z - (knuckle_d/2 - 0.5 + top_off);
    for (i = [0 : prox_n - 2]) hull() {
        translate([0, 0,  h*i/(prox_n - 1)])
            linear_extrude(0.2) prox_section_2d(h*i/(prox_n - 1), h, grow);
        translate([0, 0,  h*(i + 1)/(prox_n - 1)])
            linear_extrude(0.2) prox_section_2d(h*(i + 1)/(prox_n - 1), h, grow);
    }
}

// distal phalange outer form in the hinge frame (local Z up at 0 deg).
// Soft palmar bow and a fuller pad, per a real thumb silhouette.
// The root stays barrel-width until it clears the fork cheek radius
// (knuckle_d/2), then fans out, so it never rubs the cheeks at any
// flexion angle.
module distal_form(grow = 0) {
    g2 = 2*grow;
    loft() {
        slice(barrel_w + g2, 9.5 + g2, 0, 0,   5.8);
        // early flare cupping down towards the knuckle
        slice(11.5 + g2, 11 + g2,   0, -0.15, 8);
        slice(12.3 + g2, 12 + g2,   0, -0.3, 9.5);
        slice(12 + g2,   11 + g2,   0, -0.7, 15);
        slice(10.5 + g2, 9.5 + g2,  0, -0.8, distal_len - 6);
        // rounded tip, part of the hull chain so no seam forms
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
            // tangent blend from the pyramid top into the hub, so
            // the shaft meets the knuckle without a sharp ledge; a
            // rounded slab (not a cube) so no corner fins form
            hinge_frame() hull() {
                pin_cyl(8, hinge_w - 2);
                slice(13.2, 13, 0, 0, -5);
            }
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
            // side wall below the knuckle, into the hollow, so the
            // cord can be threaded in one hole and out the other
            for (s = [-1, 1])
                translate([s*2.2, 2, -12])
                    rotate([-90, 0, 0]) cylinder(d = 2, h = 9.5);
            // shallow guide groove on the extension-side outer wall,
            // keeping the elastic on track between the buttons and
            // the hinge; the end notches the hub's lower edge
            hull() {
                translate([0, 6.5, -12]) sphere(1.1);
                translate([0, 5.4, -2])  sphere(1.1);
            }
        }
        // tendon entry hole through the wrist-side wall, above the
        // stump
        translate([-11, 0, tendon_entry_z])
            rotate([0, 90, 0]) cylinder(d = 2.4, h = 10);
        plate_pockets();
        // oblique bottom rim: hinged on the palm-back bottom edge,
        // rising towards the palm-front
        translate([0, base_d/2, 0]) rotate([-rim_tilt, 0, 0])
            translate([0, 0, -25]) cube([90, 90, 50], center = true);
    }
}

// hollow interior: open cup from below, tapering with the pyramid
// and stopping short of the hinge mechanism
module cavity() {
    pyramid(-wall, 3.5);
    // open the bottom (the profile height argument is irrelevant
    // at z=0, where the section is always the full footprint)
    translate([0, 0, -4]) linear_extrude(4 + 2*eps)
        prox_section_2d(0, hinge_z, -wall);
}

// clears the space between the fork cheeks: a slab above the slot
// floor plus a cylindrical pocket the barrel swings in
module fork_slot() {
    hinge_frame() {
        translate([-slot_w/2, -knuckle_d/2 - 4, -1.5])
            cube([slot_w, knuckle_d + 8, knuckle_d + 6]);
        // flexion-side relief: the same slab rotated palmar-down,
        // letting the distal root sweep below the floor level
        // through full flexion without hitting the hub blend.
        // Angle, drop, and overhang are tuned against the
        // interference sweep in test_mechanism.scad; re-run it
        // after changing any hinge geometry
        rotate([35, 0, 0])
            translate([-slot_w/2 - 1.3, -knuckle_d/2 - 4, -2.1])
                cube([slot_w + 2.6, knuckle_d + 8, knuckle_d + 6]);
        pin_cyl(pocket_d, slot_w);
    }
}

// local frame on the fingers-side (s=1) or wrist-side (s=-1) long
// face of the pyramid: origin on the face at y=0, z=plate_z;
// local +Z = outward normal, local X along the plate width (which
// runs palm-front to palm-back). The frame follows the plan-view
// convergence of the faces, the pyramid taper, and the oblique rim.
module side_face_frame(s) {
    plan = atan((base_w_back - base_w_front) / 2 / base_d);
    // the offset and lean angles are fitted by eye to the swept
    // profile; re-check the pocket seating in renders if the
    // pyramid slices change
    lean = s > 0 ? 6 : 14;     // face slope off vertical, degrees
    translate([s*10.2, 0, plate_z])
        rotate([0, 0, -s*plan])
        rotate([0, s*(90 - lean), 0])
            // orient the plate upright and align it with the
            // oblique bottom rim
            rotate([0, 0, s*(90 - rim_tilt)])
                children();
}

// flat pockets with screw holes for the TPU sewing plates
module plate_pockets() {
    for (s = [-1, 1]) side_face_frame(s) {
        // flat pocket, 0.8 deep, also shaves the face bulges flush
        translate([0, 0, -0.8]) linear_extrude(8)
            offset(3) square([plate_w - 6 + 0.6, plate_h - 6 + 0.6],
                             center = true);
        // screw pilot holes (self-tapping M2), upper band
        for (h = [-1, 1])
            translate([h*(plate_w/2 - 3.5), plate_h/2 - 3, -6])
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
                pin_cyl(barrel_d, barrel_w);
                rotate([0, 90, 0]) rotate_extrude()
                    translate([barrel_d/2, 0]) circle(r = tunnel_r);
            }
            // root neck: barrel-width column joining the phalange,
            // kept inside the slot at every flexion angle
            hull() {
                pin_cyl(barrel_d, barrel_w);
                slice(barrel_w, 9.5, 0, 0, 5.8);
            }
            // extension stop heel: a rounded tab hidden within the
            // knuckle circle; rests on the hub's internal stop floor
            // at 0 deg and lifts away in flexion
            intersection() {
                pin_cyl(knuckle_d - 0.2, barrel_w);
                translate([-barrel_w/2, 2.2, -1.2])
                    cube([barrel_w, 3.5, 4]);
            }
        }
        // pin bore
        pin_cyl(pin_hole_d, hinge_w + 2);
        // flexion-side tendon tunnel: root entry to anchor pocket
        hull() {
            translate([0, -4.9, 2]) sphere(tunnel_r);
            translate([0, -4.8, 9.5]) sphere(tunnel_r);
        }
        // tendon anchor pocket (knot recess)
        translate([0, -5.3, 10]) sphere(2.1);
        // extension-side elastic tunnel and anchor pocket
        hull() {
            translate([0, 4.6, 3]) sphere(tunnel_r);
            translate([0, 4.2, 8.5]) sphere(tunnel_r);
        }
        translate([0, 5.2, 9]) sphere(2.1);
        // nail pocket
        nail_place() nail_shape(clr);
        // lightening cavity, clear of tunnels and hinge
        intersection() {
            distal_form(-3);
            translate([0, 0, 7]) cube([20, 20, 12], center = true);
        }
    }
}

// ===================== BLACK / WHITE INLAYS =====================

// decorative nail: almond dome, half-buried in the nail-side
// surface of the distal phalange; also used (grown) to cut the
// pocket. Shape is origin-centred; nail_place() puts it on the
// distal in the hinge frame.
module nail_shape(grow) {
    resize([nail_w + 2*grow, 2.6 + 2*grow, nail_len + 2*grow])
        sphere(1);
}

module nail_place() {
    translate([0, 3.9, distal_len - 7]) children();
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

// the screw band (upper half) mounts on the pyramid face; the
// slitted lower half hangs below the base rim so the wrap pulls
// the base down onto the stump.
module sewing_plate() {
    difference() {
        linear_extrude(plate_t)
            offset(3) square([plate_w - 6, plate_h - 6], center = true);
        // fabric slit, below the rim
        translate([0, -plate_h/2 + 4, -eps])
            linear_extrude(plate_t + 2*eps)
                offset(slit_h/2) square([slit_w - slit_h, eps], center = true);
        // screw holes, on-face band
        for (h = [-1, 1])
            translate([h*(plate_w/2 - 3.5), plate_h/2 - 3, -eps])
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
        color("black") nail_place() nail_shape(0);
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
                sewing_plate();
}

// all printable parts laid out in print orientation, resting on z=0
module print_all() {
    // proximal tilted so the oblique bottom rim sits flat on the bed
    translate([-25, 0, -(base_d/2)*sin(rim_tilt)])
        rotate([rim_tilt, 0, 0]) proximal_body();
    // distal upright, standing on the barrel (needs a brim)
    translate([15, 0, barrel_d/2]) distal_body();
    for (i = [0, 1]) {
        translate([35 + i*10, 15, 0]) disk_ring();
        translate([35 + i*10, 25, 0]) disk_plug();
    }
    // nail dome up; the underside is curved, so print on a raft
    translate([40, -15, 1.3]) rotate([90, 0, 0]) nail_shape(0);
    for (i = [-1, 1]) translate([70, i*12, 0]) sewing_plate();
}
