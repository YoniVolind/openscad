// 100 mm realistic straight train track
// LEGO train ecosystem gauge with LEGO-style interlocking ends,
// realistic rails and individually textured timber sleepers.
// Units: millimeters

$fn = 64;

// ========================
// Core dimensions
// ========================
track_length = 100;          // nominal joint-plane to joint-plane length
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

// Wood texture depth is deliberately shallow for FDM printing.
wood_top_depth = 0.24;
wood_side_depth = 0.20;
wood_grain_min_w = 0.20;
wood_grain_max_w = 0.38;
wood_knot_depth = 0.22;
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
// LEGO-style track end connectors
// Inspired by LEGO 53401: round pin/ring + C receiver,
// mirrored between the two ends.
// ========================
lego_connector_offset = 8.0;        // one stud from track center
lego_pin_outer_d = 5.2;
lego_pin_hole_d = 2.0;
lego_receiver_outer_d = 6.5;
lego_receiver_inner_d = 5.65;       // clearance around mating pin
lego_receiver_mouth = 2.65;
lego_connector_height = sleeper_height;
lego_neck_width = 3.2;
lego_neck_length = 4.2;

// ========================
// Deterministic pseudo-random helpers
// ========================
function fract(x) = x - floor(x);
function rnd(seed, k) = fract(abs(sin(seed*97.13 + k*41.73) * 43758.5453));
function rr(seed, k, lo, hi) = lo + (hi-lo) * rnd(seed, k);

module preview_color(c) {
    if (show_preview_colors) color(c) children();
    else children();
}

// ========================
// Wood texture
// ========================
// A small vertical cutting cylinder used to carve top-face grain.
module top_grain_point(x, y, d) {
    translate([x, y, sleeper_height/2 - wood_top_depth/2])
        cylinder(h = wood_top_depth + 0.16, d = d, center = true, $fn = 14);
}

// One irregular top-face grain groove, spanning nearly the full sleeper length.
module top_grain_line(seed, line_i) {
    points = 8;
    margin = 0.8;
    base_x = rr(seed, 100 + line_i*7, -sleeper_width*0.40, sleeper_width*0.40);
    width = rr(seed, 101 + line_i*7, wood_grain_min_w, wood_grain_max_w);

    for (j = [0 : points-2]) {
        y1 = -sleeper_length/2 + margin + j*((sleeper_length-2*margin)/(points-1));
        y2 = -sleeper_length/2 + margin + (j+1)*((sleeper_length-2*margin)/(points-1));

        x1 = base_x
             + rr(seed, 200 + line_i*31 + j, -0.52, 0.52)
             + 0.16*sin(j*73 + seed*19);
        x2 = base_x
             + rr(seed, 201 + line_i*31 + j, -0.52, 0.52)
             + 0.16*sin((j+1)*73 + seed*19);

        hull() {
            top_grain_point(x1, y1, width);
            top_grain_point(x2, y2, width*rr(seed, 250 + line_i*13 + j, 0.82, 1.18));
        }
    }
}

// Short cracks that start at the outer beam ends and run inward.
module top_end_crack(seed, end_side, crack_i) {
    y0 = end_side*(sleeper_length/2 - 0.25);
    len = rr(seed, 600 + end_side*13 + crack_i*11, 4.5, 11.5);
    x0 = rr(seed, 610 + end_side*17 + crack_i*13, -sleeper_width*0.34, sleeper_width*0.34);
    x1 = x0 + rr(seed, 620 + end_side*19 + crack_i*17, -0.9, 0.9);
    y1 = y0 - end_side*len;
    d = rr(seed, 630 + end_side*23 + crack_i*19, 0.22, 0.40);

    hull() {
        top_grain_point(x0, y0, d);
        top_grain_point(x1, y1, d*0.72);
    }
}

// Knot / growth-ring dents on the top surface.
module top_knot(seed, knot_i) {
    x = rr(seed, 700 + knot_i*17, -sleeper_width*0.28, sleeper_width*0.28);
    y = rr(seed, 710 + knot_i*19, -sleeper_length*0.38, sleeper_length*0.38);
    sx = rr(seed, 720 + knot_i*23, 1.15, 1.85);
    sy = rr(seed, 730 + knot_i*29, 0.55, 1.05);
    r = rr(seed, 740 + knot_i*31, 0.75, 1.25);

    translate([x, y, sleeper_height/2 - wood_knot_depth/2])
        scale([sx, sy, 1])
            difference() {
                cylinder(h = wood_knot_depth + 0.14, r = r, center = true, $fn = 30);
                cylinder(h = wood_knot_depth + 0.24, r = max(0.25, r-0.28), center = true, $fn = 30);
            }
}

// Cutting point for the long vertical side faces x = +/- sleeper_width/2.
module side_grain_point(side, y, z, d) {
    translate([side*(sleeper_width/2 - wood_side_depth/2), y, z])
        rotate([0,90,0])
            cylinder(h = wood_side_depth + 0.15, d = d, center = true, $fn = 12);
}

// Grain on both long side faces, again running almost full length.
module side_grain_line(seed, side, line_i) {
    points = 7;
    margin = 1.0;
    base_z = rr(seed, 800 + (side+1)*100 + line_i*13,
                -sleeper_height*0.30, sleeper_height*0.30);
    width = rr(seed, 810 + (side+1)*100 + line_i*17, 0.18, 0.32);

    for (j = [0 : points-2]) {
        y1 = -sleeper_length/2 + margin + j*((sleeper_length-2*margin)/(points-1));
        y2 = -sleeper_length/2 + margin + (j+1)*((sleeper_length-2*margin)/(points-1));
        z1 = base_z + rr(seed, 820 + line_i*31 + j + (side+1)*200, -0.34, 0.34);
        z2 = base_z + rr(seed, 821 + line_i*31 + j + (side+1)*200, -0.34, 0.34);

        hull() {
            side_grain_point(side, y1, z1, width);
            side_grain_point(side, y2, z2, width*rr(seed, 830 + line_i*7 + j, 0.82, 1.16));
        }
    }
}

// End-grain rings on the very outer ends y = +/- sleeper_length/2.
module end_grain_ring(seed, end_side, ring_i) {
    rx = rr(seed, 900 + ring_i*13 + (end_side+1)*80, 1.05, 2.65);
    rz = rr(seed, 910 + ring_i*17 + (end_side+1)*80, 0.45, 1.12);
    wall = rr(seed, 920 + ring_i*19 + (end_side+1)*80, 0.13, 0.22);
    xoff = rr(seed, 930 + ring_i*23 + (end_side+1)*80, -0.50, 0.50);
    zoff = rr(seed, 940 + ring_i*29 + (end_side+1)*80, -0.18, 0.18);

    translate([xoff, end_side*(sleeper_length/2 - wood_side_depth/2), zoff])
        rotate([90,0,0])
            scale([rx, rz, 1])
                difference() {
                    cylinder(h = wood_side_depth + 0.14, r = 1, center = true, $fn = 32);
                    cylinder(h = wood_side_depth + 0.24,
                             r = max(0.18, 1-wall), center = true, $fn = 32);
                }
}

module textured_sleeper(seed = 1) {
    top_lines = 6 + floor(rnd(seed, 10)*4);    // 6..9, varies per sleeper
    side_lines = 2 + floor(rnd(seed, 11)*3);   // 2..4 per side
    knots = floor(rnd(seed, 12)*3);             // 0..2
    cracks_each_end = 1 + floor(rnd(seed, 13)*2); // 1..2

    difference() {
        cube([sleeper_width, sleeper_length, sleeper_height], center = true);

        // Randomized top grain across the complete sleeper, including sections
        // outside the rails.
        for (i = [0 : top_lines-1])
            top_grain_line(seed, i);

        // Cracks from both outer beam ends.
        for (end_side = [-1,1])
            for (i = [0 : cracks_each_end-1])
                top_end_crack(seed, end_side, i);

        // Random top knots.
        if (knots > 0)
            for (i = [0 : knots-1])
                top_knot(seed, i);

        // Grain down both long vertical side faces.
        for (side = [-1,1])
            for (i = [0 : side_lines-1])
                side_grain_line(seed, side, i);

        // End grain visible at both exposed beam ends.
        for (end_side = [-1,1])
            for (i = [0 : 1])
                end_grain_ring(seed, end_side, i);
    }
}

// ========================
// LEGO-style end connections
// ========================
module lego_round_pin(side, ypos) {
    joint_x = side*track_length/2;

    // Short neck joining the end sleeper to the circular pin.
    translate([joint_x - side*lego_neck_length/2,
               ypos,
               lego_connector_height/2])
        cube([lego_neck_length, lego_neck_width, lego_connector_height], center = true);

    // Annular pin/ring.
    difference() {
        translate([joint_x, ypos, lego_connector_height/2])
            cylinder(h = lego_connector_height,
                     d = lego_pin_outer_d,
                     center = true,
                     $fn = 48);
        translate([joint_x, ypos, lego_connector_height/2])
            cylinder(h = lego_connector_height + 0.3,
                     d = lego_pin_hole_d,
                     center = true,
                     $fn = 36);
    }
}

module lego_c_receiver(side, ypos) {
    joint_x = side*track_length/2;

    difference() {
        union() {
            // Neck into end sleeper.
            translate([joint_x - side*lego_neck_length/2,
                       ypos,
                       lego_connector_height/2])
                cube([lego_neck_length, lego_neck_width, lego_connector_height], center = true);

            // Circular receiver body.
            translate([joint_x, ypos, lego_connector_height/2])
                cylinder(h = lego_connector_height,
                         d = lego_receiver_outer_d,
                         center = true,
                         $fn = 56);
        }

        // Circular socket.
        translate([joint_x, ypos, lego_connector_height/2])
            cylinder(h = lego_connector_height + 0.35,
                     d = lego_receiver_inner_d,
                     center = true,
                     $fn = 48);

        // Mouth opening toward the outside of the track segment, making a C clip.
        translate([joint_x + side*lego_receiver_outer_d*0.42,
                   ypos,
                   lego_connector_height/2])
            cube([lego_receiver_outer_d,
                  lego_receiver_mouth,
                  lego_connector_height + 0.45],
                 center = true);
    }
}

module lego_end_connectors(side) {
    // Mirror the pin/receiver arrangement between ends, as on LEGO track.
    pin_y = side < 0 ? lego_connector_offset : -lego_connector_offset;
    receiver_y = -pin_y;

    lego_round_pin(side, pin_y);
    lego_c_receiver(side, receiver_y);
}

// ========================
// Sleeper placement
// ========================
module sleeper_at(xc, seed) {
    translate([xc, 0, sleeper_height/2])
        textured_sleeper(seed);
}

module all_sleepers() {
    for (i = [0 : sleeper_count-1]) {
        x = -end_sleeper_center
            + i * (2*end_sleeper_center/(sleeper_count-1));
        sleeper_at(x, i+1);
    }

    // Original-style LEGO connection concept at both ends.
    lego_end_connectors(-1);
    lego_end_connectors( 1);
}

// ========================
// Rail hardware
// ========================
module tie_plate(xc, y_center) {
    translate([xc,
               y_center,
               sleeper_height + plate_height/2 - 0.08])
        cube([plate_width_x, plate_length_y, plate_height], center = true);
}

module rail_clip(xc, y_center, side) {
    translate([xc,
               y_center + side*(rail_foot_width/2 + 0.65),
               sleeper_height + plate_height + clip_height/2 - 0.12])
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
            cube([length_mm,
                  rail_web_width,
                  head_bottom_z - (rail_base_z + rail_foot_height) + 0.15]);

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
