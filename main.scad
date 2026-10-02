// 100 mm realistic straight train track
// LEGO train ecosystem gauge/footprint, but visually styled like real railway track.
// No ballast/base bed. Individual wooden sleepers with hidden underside connectors.
// Units: millimeters

$fn = 64;

// ========================
// Core dimensions
// ========================
track_length = 100;          // joint plane to joint plane
rail_center_gauge = 40;      // LEGO train rail center spacing
running_gauge = 37.5;        // inner rail-head face spacing

// ========================
// Sleepers / timber ties
// ========================
sleeper_count = 8;
sleeper_length = 56;         // across the track
sleeper_width = 8;           // along the track
sleeper_height = 3.2;
end_sleeper_center = track_length/2 - sleeper_width/2;

wood_grain_depth = 0.22;
wood_grain_width = 0.28;
wood_knot_depth = 0.20;
show_preview_colors = true;

// ========================
// Rail profile
// ========================
rail_foot_width = 5.8;
rail_foot_height = 0.9;
rail_web_width = 1.45;
rail_head_bottom_width = 3.7;
rail_head_top_width = rail_center_gauge - running_gauge;  // 2.5 mm
rail_head_height = 1.9;
rail_total_height = 5.4;

// Rail mounting details
plate_width_x = 5.6;
plate_length_y = 8.2;
plate_height = 0.55;
clip_diameter = 1.25;
clip_height = 0.85;

// ========================
// Hidden segment connectors
// Right side = two male tongues
// Left side  = two female sockets
// They sit in the lower half of the end sleepers,
// so they are not visible from above.
// ========================
connector_y = 11.5;
connector_length = 6.0;
connector_width = 4.4;
connector_height = 1.55;
connector_clearance = 0.25;
connector_chamfer = 0.6;

// ========================
// Helpers
// ========================
module preview_color(c) {
    if (show_preview_colors) color(c) children();
    else children();
}

// Curved shallow groove for printable wood grain.
module grain_groove(seed, base_x) {
    pts = 6;
    for (i = [0 : pts-2]) {
        y1 = -sleeper_length*0.40 + i * (sleeper_length*0.80/(pts-1));
        y2 = -sleeper_length*0.40 + (i+1) * (sleeper_length*0.80/(pts-1));

        x1 = base_x + 0.28*sin(seed*37 + i*61);
        x2 = base_x + 0.28*sin(seed*37 + (i+1)*61);

        hull() {
            translate([x1, y1, sleeper_height - wood_grain_depth/2])
                cylinder(h = wood_grain_depth + 0.12,
                         d = wood_grain_width,
                         center = true,
                         $fn = 16);

            translate([x2, y2, sleeper_height - wood_grain_depth/2])
                cylinder(h = wood_grain_depth + 0.12,
                         d = wood_grain_width,
                         center = true,
                         $fn = 16);
        }
    }
}

module wood_knots(seed) {
    // A subtle knot on alternating sleepers.
    if (seed % 2 == 0) {
        translate([
            1.2*sin(seed*43),
            11*sin(seed*29),
            sleeper_height - wood_knot_depth/2
        ])
            scale([1.45, 0.72, 1])
                cylinder(h = wood_knot_depth + 0.12,
                         d = 1.7,
                         center = true,
                         $fn = 28);

        translate([
            1.2*sin(seed*43),
            11*sin(seed*29),
            sleeper_height - wood_knot_depth/2
        ])
            scale([2.1, 1.05, 1])
                difference() {
                    cylinder(h = wood_knot_depth + 0.10,
                             d = 2.0,
                             center = true,
                             $fn = 28);
                    cylinder(h = wood_knot_depth + 0.20,
                             d = 1.35,
                             center = true,
                             $fn = 28);
                }
    }
}

// Local sleeper at origin, with top wood texture engraved.
module textured_sleeper(seed = 1) {
    difference() {
        cube([sleeper_width, sleeper_length, sleeper_height], center = true);

        // Grain lines run lengthwise, like real timber.
        for (gx = [-2.6, -1.25, 0.15, 1.55, 2.75])
            grain_groove(seed + round((gx+3)*10), gx);

        wood_knots(seed);
    }
}

// Tapered male tongue for easier insertion.
module connector_tongue(ypos) {
    hull() {
        translate([track_length/2 - 0.3, ypos, connector_height/2])
            cube([0.6, connector_width, connector_height], center = true);

        translate([track_length/2 + connector_length - connector_chamfer,
                   ypos,
                   connector_height/2])
            cube([connector_chamfer,
                  connector_width - 0.55,
                  connector_height - 0.10],
                 center = true);
    }
}

// Female socket cut into lower part of left end sleeper.
module connector_socket(ypos) {
    slot_w = connector_width + connector_clearance*2;
    slot_h = connector_height + connector_clearance;

    hull() {
        translate([-track_length/2 - 0.2, ypos, slot_h/2])
            cube([0.8, slot_w + 0.35, slot_h + 0.15], center = true);

        translate([-track_length/2 + connector_length,
                   ypos,
                   slot_h/2])
            cube([0.8, slot_w, slot_h], center = true);
    }
}

module sleeper_at(xc, seed, is_left_end = false, is_right_end = false) {
    translate([xc, 0, sleeper_height/2])
        difference() {
            textured_sleeper(seed);

            // Female connectors are cut only into the underside of the left end sleeper.
            if (is_left_end) {
                translate([-xc, 0, -sleeper_height/2]) {
                    connector_socket(-connector_y);
                    connector_socket( connector_y);
                }
            }
        }

    // Male tongues project from the underside of the right end sleeper.
    if (is_right_end) {
        connector_tongue(-connector_y);
        connector_tongue( connector_y);
    }
}

module all_sleepers() {
    // End sleepers define the 100 mm joint planes.
    sleeper_at(-end_sleeper_center, 1, true, false);
    sleeper_at( end_sleeper_center, sleeper_count, false, true);

    // Internal sleepers evenly spaced.
    for (i = [1 : sleeper_count-2]) {
        x = -end_sleeper_center
            + i * (2*end_sleeper_center/(sleeper_count-1));
        sleeper_at(x, i+1, false, false);
    }
}

module tie_plate(xc, y_center) {
    translate([
        xc,
        y_center,
        sleeper_height + plate_height/2 - 0.08
    ])
        cube([plate_width_x, plate_length_y, plate_height], center = true);
}

module rail_clip(xc, y_center, side) {
    translate([
        xc,
        y_center + side*(rail_foot_width/2 + 0.65),
        sleeper_height + plate_height + clip_height/2 - 0.12
    ])
        cylinder(h = clip_height,
                 d = clip_diameter,
                 center = true,
                 $fn = 22);
}

module rail(length_mm, y_center) {
    rail_base_z = sleeper_height + plate_height - 0.18;
    head_bottom_z = rail_base_z + rail_total_height - rail_head_height;

    union() {
        // Wide rail foot
        translate([-length_mm/2,
                   y_center - rail_foot_width/2,
                   rail_base_z])
            cube([length_mm, rail_foot_width, rail_foot_height]);

        // Narrow web
        translate([-length_mm/2,
                   y_center - rail_web_width/2,
                   rail_base_z + rail_foot_height - 0.05])
            cube([
                length_mm,
                rail_web_width,
                head_bottom_z - (rail_base_z + rail_foot_height) + 0.15
            ]);

        // Tapered rail head
        hull() {
            translate([-length_mm/2,
                       y_center - rail_head_bottom_width/2,
                       head_bottom_z])
                cube([length_mm, rail_head_bottom_width, 0.42]);

            translate([-length_mm/2,
                       y_center - rail_head_top_width/2,
                       rail_base_z + rail_total_height - 0.58])
                cube([length_mm, rail_head_top_width, 0.58]);
        }
    }
}

module mounting_hardware() {
    // Add a tie plate and two clips at every sleeper/rail crossing.
    for (i = [0 : sleeper_count-1]) {
        x = -end_sleeper_center
            + i * (2*end_sleeper_center/(sleeper_count-1));

        for (rail_y = [-rail_center_gauge/2, rail_center_gauge/2]) {
            tie_plate(x, rail_y);
            rail_clip(x, rail_y, -1);
            rail_clip(x, rail_y,  1);
        }
    }
}

module realistic_track() {
    union() {
        preview_color([0.36, 0.22, 0.11])
            all_sleepers();

        preview_color([0.24, 0.25, 0.26])
            mounting_hardware();

        preview_color([0.55, 0.57, 0.59]) {
            rail(track_length, -rail_center_gauge/2);
            rail(track_length,  rail_center_gauge/2);
        }
    }
}

realistic_track();
