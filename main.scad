// 100 mm LEGO-style straight train track
// Parametric OpenSCAD model for FDM printing
// Units: millimeters
//
// Geometry targets used here:
// - LEGO/L-gauge rail centerline spacing: 40.0 mm
// - Running gauge between inner rail-head faces: 37.5 mm
// - Overall LEGO track width: 8 studs = 64 mm
// - LEGO stud pitch: 8 mm
// - Track top height: 9.6 mm (3 plates)
//
// NOTE: 100 mm is a custom length (standard LEGO straight track is 128 mm).
// Connector clearance is intentionally parameterized because FDM printers vary.

$fn = 64;

// ========================
// Main parameters
// ========================
track_length = 100;          // nominal joint-plane to joint-plane length
track_width = 64;            // 8 LEGO studs
rail_center_gauge = 40;      // rail centerline spacing
running_gauge = 37.5;        // inner rail-head face to face
track_top_height = 9.6;

// Sleepers / ties
sleeper_height = 3.2;        // one LEGO plate
sleeper_width = 8.0;         // dimension along track
end_sleeper_depth = 8.0;
internal_sleeper_count = 3;

// LEGO-style studs
stud_pitch = 8.0;
stud_diameter = 4.8;
stud_height = 1.8;
stud_fn = 48;

// Rail profile
rail_foot_width = 7.0;
rail_foot_height = 1.4;
rail_web_width = 2.2;
rail_head_top_width = rail_center_gauge - running_gauge; // 2.5 mm
rail_head_bottom_width = 4.0;
rail_head_height = 2.1;
rail_web_top = track_top_height - rail_head_height + 0.25;

// End connector: LEGO-style complementary half-round interlock
connector_offset = 8.0;      // connector centers are +/- one stud from center
male_outer_d = 5.0;
male_inner_d = 2.0;
female_d = 5.45;             // increase if your printer fits too tightly
connector_height = sleeper_height;

// Cosmetic / utility details
screw_hole_d = 3.2;
countersink_d = 6.0;
countersink_depth = 0.9;
preview_colors = true;
show_debug = false;

// ========================
// Helpers
// ========================
module preview_color(c) {
    if (preview_colors) color(c) children();
    else children();
}

module stud(x, y) {
    translate([x, y, sleeper_height - 0.05])
        cylinder(h = stud_height + 0.05, d = stud_diameter, $fn = stud_fn);
}

module screw_hole(x) {
    // through-hole + shallow countersink from the top
    translate([x, 0, -0.2])
        cylinder(h = sleeper_height + 0.4, d = screw_hole_d, $fn = 40);
    translate([x, 0, sleeper_height - countersink_depth])
        cylinder(h = countersink_depth + 0.2,
                 d1 = screw_hole_d,
                 d2 = countersink_d,
                 $fn = 40);
}

// A printable I-ish rail profile built from fused primitives.
// The 2.5 mm top head width gives 37.5 mm between inner faces
// when the rail centers are 40 mm apart.
module rail(length_mm, y_center) {
    union() {
        // foot: slightly sunk into sleepers for a strong manifold union
        translate([-length_mm/2, y_center - rail_foot_width/2, sleeper_height - 0.45])
            cube([length_mm, rail_foot_width, rail_foot_height]);

        // web
        translate([-length_mm/2, y_center - rail_web_width/2, sleeper_height + 0.45])
            cube([length_mm, rail_web_width, rail_web_top - (sleeper_height + 0.45)]);

        // tapered rail head
        hull() {
            translate([-length_mm/2,
                       y_center - rail_head_bottom_width/2,
                       track_top_height - rail_head_height])
                cube([length_mm, rail_head_bottom_width, 0.45]);

            translate([-length_mm/2,
                       y_center - rail_head_top_width/2,
                       track_top_height - 0.55])
                cube([length_mm, rail_head_top_width, 0.55]);
        }
    }
}

module sleeper_base(x_center, width_x = sleeper_width) {
    translate([x_center - width_x/2, -track_width/2, 0])
        cube([width_x, track_width, sleeper_height]);
}

module sleeper_studs(x_center) {
    // Six studs across: two outside the rails and four between them.
    // Positions follow LEGO's 8 mm pitch.
    for (y = [-28, -12, -4, 4, 12, 28])
        stud(x_center, y);
}

module internal_sleeper(x_center, add_hole = true) {
    difference() {
        sleeper_base(x_center);
        if (add_hole) screw_hole(x_center);
    }
    sleeper_studs(x_center);
}

// side = -1 -> left end, +1 -> right end
// End tie occupies only the inward side of the nominal joint plane.
// The male half-round ring projects across the joint plane into the
// matching female half-round notch of the neighboring track.
module end_sleeper(side) {
    joint_x = side * track_length/2;
    center_x = joint_x - side * end_sleeper_depth/2;

    male_y = side < 0 ? connector_offset : -connector_offset;
    female_y = -male_y;

    difference() {
        union() {
            sleeper_base(center_x, end_sleeper_depth);

            // male annular lobe centered on the joint plane
            translate([joint_x, male_y, 0])
                cylinder(h = connector_height, d = male_outer_d, $fn = 56);
        }

        // center hole in male lobe
        translate([joint_x, male_y, -0.2])
            cylinder(h = connector_height + 0.4, d = male_inner_d, $fn = 40);

        // complementary female half-round notch at the edge
        translate([joint_x, female_y, -0.2])
            cylinder(h = connector_height + 0.4, d = female_d, $fn = 56);
    }

    // Studs are one half-stud (4 mm) inward from the joint plane,
    // matching the end-stud placement of the LEGO track geometry.
    sleeper_studs(center_x);
}

module track_sleepers() {
    // End sleepers
    end_sleeper(-1);
    end_sleeper(1);

    // Three intermediate sleepers distributed evenly between end sleepers.
    // For a 100 mm piece: -25, 0, +25 mm.
    usable_span = track_length - 2 * end_sleeper_depth;
    for (i = [1 : internal_sleeper_count]) {
        x = -track_length/2 + end_sleeper_depth
            + i * usable_span/(internal_sleeper_count + 1);
        internal_sleeper(x, true);
    }
}

module straight_track() {
    union() {
        preview_color([0.34, 0.27, 0.20])
            track_sleepers();

        preview_color([0.48, 0.50, 0.53]) {
            rail(track_length, -rail_center_gauge/2);
            rail(track_length,  rail_center_gauge/2);
        }
    }
}

// ========================
// Build model
// ========================
straight_track();

if (show_debug) {
    // Visual-only gauge marker
    color([1,0,0,0.35])
        translate([-track_length/2, -running_gauge/2, track_top_height + 0.2])
            cube([track_length, running_gauge, 0.25]);
}
