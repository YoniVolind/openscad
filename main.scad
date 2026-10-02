// 100 mm realistic straight train track
// LEGO train ecosystem gauge with exact 53401-compatible end geometry,
// realistic rails, and textured timber sleepers.
// Units: millimeters
//
// The end connector mesh in lego_53401_end.stl is extracted from the
// official LDraw representation of LEGO train track part 53401.
// LDraw geometry is licensed under CC BY; source attribution:
// Ronald Vallenduuk [Duq], LDraw part 53401 / subpart 53401s02.

$fn = 64;

// ========================
// Core dimensions
// ========================
track_length = 100;          // joint-plane to joint-plane length
rail_center_gauge = 40;      // LEGO train rail center spacing
running_gauge = 37.5;        // inner rail-head face spacing

// ========================
// Timber sleepers
// ========================
sleeper_count = 8;           // includes the 2 exact LEGO-style end sleepers
internal_sleeper_length = 56;
sleeper_width = 8;
sleeper_height = 3.2;
end_body_length = 64;        // exact 53401 end sleeper is 8 studs wide

show_preview_colors = true;

// Wood texture: deliberately shallow enough for FDM.
wood_top_depth = 0.24;
wood_side_depth = 0.20;
wood_grain_min_w = 0.20;
wood_grain_max_w = 0.38;
wood_knot_depth = 0.22;

// ========================
// Rail profile
// ========================
// Top of rail is intentionally 9.6 mm above ground,
// matching the overall height of LEGO 53401 track.
rail_foot_width = 5.8;
rail_foot_height = 0.9;
rail_web_width = 1.45;
rail_head_bottom_width = 3.7;
rail_head_top_width = rail_center_gauge - running_gauge;  // 2.5 mm
rail_head_height = 1.95;
rail_base_z = 3.40;
rail_total_height = 9.6 - rail_base_z;

// Rail mounting hardware
plate_width_x = 5.6;
plate_length_y = 8.2;
plate_height = 0.42;
clip_diameter = 1.20;
clip_height = 0.78;

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
// Wood texture cutters
// Local timber beam is centered at origin:
// X = along track, Y = across track, Z = vertical.
// ========================
module top_grain_point(x, y, d, h) {
    translate([x, y, h/2 - wood_top_depth/2])
        cylinder(h = wood_top_depth + 0.16, d = d, center = true, $fn = 14);
}

module top_grain_line(seed, line_i, beam_w, beam_len, beam_h) {
    points = 8;
    margin = 0.6;
    base_x = rr(seed, 100 + line_i*7, -beam_w*0.40, beam_w*0.40);
    width = rr(seed, 101 + line_i*7, wood_grain_min_w, wood_grain_max_w);

    for (j = [0 : points-2]) {
        y1 = -beam_len/2 + margin + j*((beam_len-2*margin)/(points-1));
        y2 = -beam_len/2 + margin + (j+1)*((beam_len-2*margin)/(points-1));

        x1 = base_x
             + rr(seed, 200 + line_i*31 + j, -0.55, 0.55)
             + 0.16*sin(j*73 + seed*19);
        x2 = base_x
             + rr(seed, 201 + line_i*31 + j, -0.55, 0.55)
             + 0.16*sin((j+1)*73 + seed*19);

        hull() {
            top_grain_point(x1, y1, width, beam_h);
            top_grain_point(x2, y2,
                            width*rr(seed, 250 + line_i*13 + j, 0.80, 1.20),
                            beam_h);
        }
    }
}

module top_end_crack(seed, end_side, crack_i, beam_w, beam_len, beam_h) {
    y0 = end_side*(beam_len/2 - 0.12);
    len = rr(seed, 600 + end_side*13 + crack_i*11, 4.5, 12.0);
    x0 = rr(seed, 610 + end_side*17 + crack_i*13, -beam_w*0.35, beam_w*0.35);
    x1 = x0 + rr(seed, 620 + end_side*19 + crack_i*17, -0.95, 0.95);
    y1 = y0 - end_side*len;
    d = rr(seed, 630 + end_side*23 + crack_i*19, 0.22, 0.42);

    hull() {
        top_grain_point(x0, y0, d, beam_h);
        top_grain_point(x1, y1, d*0.70, beam_h);
    }
}

module top_knot(seed, knot_i, beam_w, beam_len, beam_h) {
    x = rr(seed, 700 + knot_i*17, -beam_w*0.29, beam_w*0.29);
    y = rr(seed, 710 + knot_i*19, -beam_len*0.42, beam_len*0.42);
    sx = rr(seed, 720 + knot_i*23, 1.15, 1.85);
    sy = rr(seed, 730 + knot_i*29, 0.55, 1.05);
    r = rr(seed, 740 + knot_i*31, 0.75, 1.25);

    translate([x, y, beam_h/2 - wood_knot_depth/2])
        scale([sx, sy, 1])
            difference() {
                cylinder(h = wood_knot_depth + 0.14, r = r, center = true, $fn = 30);
                cylinder(h = wood_knot_depth + 0.24,
                         r = max(0.25, r-0.28), center = true, $fn = 30);
            }
}

// Grain cut into the two long side faces X = +/- beam_w/2.
module side_grain_point(side, y, z, d, beam_w) {
    translate([side*(beam_w/2 - wood_side_depth/2), y, z])
        rotate([0,90,0])
            cylinder(h = wood_side_depth + 0.15, d = d, center = true, $fn = 12);
}

module side_grain_line(seed, side, line_i, beam_w, beam_len, beam_h) {
    points = 7;
    margin = 0.8;
    base_z = rr(seed, 800 + (side+1)*100 + line_i*13,
                -beam_h*0.30, beam_h*0.30);
    width = rr(seed, 810 + (side+1)*100 + line_i*17, 0.18, 0.32);

    for (j = [0 : points-2]) {
        y1 = -beam_len/2 + margin + j*((beam_len-2*margin)/(points-1));
        y2 = -beam_len/2 + margin + (j+1)*((beam_len-2*margin)/(points-1));
        z1 = base_z + rr(seed, 820 + line_i*31 + j + (side+1)*200, -0.34, 0.34);
        z2 = base_z + rr(seed, 821 + line_i*31 + j + (side+1)*200, -0.34, 0.34);

        hull() {
            side_grain_point(side, y1, z1, width, beam_w);
            side_grain_point(side, y2, z2,
                             width*rr(seed, 830 + line_i*7 + j, 0.82, 1.16),
                             beam_w);
        }
    }
}

// Growth rings cut into the exposed outer ends Y = +/- beam_len/2.
module end_grain_ring(seed, end_side, ring_i, beam_len) {
    rx = rr(seed, 900 + ring_i*13 + (end_side+1)*80, 1.05, 2.65);
    rz = rr(seed, 910 + ring_i*17 + (end_side+1)*80, 0.45, 1.12);
    wall = rr(seed, 920 + ring_i*19 + (end_side+1)*80, 0.13, 0.22);
    xoff = rr(seed, 930 + ring_i*23 + (end_side+1)*80, -0.50, 0.50);
    zoff = rr(seed, 940 + ring_i*29 + (end_side+1)*80, -0.18, 0.18);

    translate([xoff, end_side*(beam_len/2 - wood_side_depth/2), zoff])
        rotate([90,0,0])
            scale([rx, rz, 1])
                difference() {
                    cylinder(h = wood_side_depth + 0.14, r = 1, center = true, $fn = 32);
                    cylinder(h = wood_side_depth + 0.24,
                             r = max(0.18, 1-wall), center = true, $fn = 32);
                }
}

module beam_texture_cutters(seed, beam_w, beam_len, beam_h) {
    top_lines = 7 + floor(rnd(seed, 10)*5);       // 7..11
    side_lines = 3 + floor(rnd(seed, 11)*3);      // 3..5 per side
    knots = floor(rnd(seed, 12)*3);                // 0..2
    cracks_each_end = 1 + floor(rnd(seed, 13)*3); // 1..3

    for (i = [0 : top_lines-1])
        top_grain_line(seed, i, beam_w, beam_len, beam_h);

    for (end_side = [-1,1])
        for (i = [0 : cracks_each_end-1])
            top_end_crack(seed, end_side, i, beam_w, beam_len, beam_h);

    if (knots > 0)
        for (i = [0 : knots-1])
            top_knot(seed, i, beam_w, beam_len, beam_h);

    for (side = [-1,1])
        for (i = [0 : side_lines-1])
            side_grain_line(seed, side, i, beam_w, beam_len, beam_h);

    for (end_side = [-1,1])
        for (i = [0 : 2])
            end_grain_ring(seed, end_side, i, beam_len);
}

module textured_internal_sleeper(seed) {
    difference() {
        cube([sleeper_width, internal_sleeper_length, sleeper_height], center = true);
        beam_texture_cutters(seed,
                             sleeper_width,
                             internal_sleeper_length,
                             sleeper_height);
    }
}

// ========================
// Exact LEGO 53401 end geometry
// ========================
// lego_53401_end.stl local coordinates:
// joint plane X=0
// end sleeper body X=0..8
// width Y=-32..32
// ground Z=0
// original track fingers reach Z=9.6

module exact_left_end_local(seed) {
    difference() {
        import("lego_53401_end.stl", convexity = 20);

        // Apply timber texture ONLY to the 8 x 64 x 3.2 mm sleeper body.
        // This leaves the actual LEGO connector/finger geometry untouched,
        // preserving compatibility.
        intersection() {
            translate([4, 0, sleeper_height/2])
                beam_texture_cutters(seed,
                                     sleeper_width,
                                     end_body_length,
                                     sleeper_height);

            translate([4, 0, sleeper_height/2])
                cube([8.02, end_body_length+0.02, sleeper_height+0.04], center = true);
        }
    }
}

module exact_end_at(side, seed) {
    if (side < 0) {
        translate([-track_length/2, 0, 0])
            exact_left_end_local(seed);
    } else {
        // Official 53401 uses the same end geometry mirrored in both
        // longitudinal and lateral directions at the opposite end.
        translate([track_length/2, 0, 0])
            scale([-1,-1,1])
                exact_left_end_local(seed);
    }
}

// ========================
// Sleeper placement
// ========================
module all_sleepers() {
    exact_end_at(-1, 101);
    exact_end_at( 1, 208);

    // Internal sleepers between the exact LEGO end sleepers.
    internal_count = sleeper_count - 2;
    for (i = [1 : internal_count]) {
        x = -track_length/2 + 8
            + i * ((track_length - 16)/(internal_count + 1));

        translate([x, 0, sleeper_height/2])
            textured_internal_sleeper(300 + i*47);
    }
}

// ========================
// Rail hardware
// ========================
module tie_plate(xc, y_center) {
    translate([xc, y_center, sleeper_height + plate_height/2 - 0.05])
        cube([plate_width_x, plate_length_y, plate_height], center = true);
}

module rail_clip(xc, y_center, side) {
    translate([xc,
               y_center + side*(rail_foot_width/2 + 0.60),
               sleeper_height + plate_height + clip_height/2 - 0.10])
        cylinder(h = clip_height,
                 d = clip_diameter,
                 center = true,
                 $fn = 22);
}

module rail(length_mm, y_center) {
    head_bottom_z = rail_base_z + rail_total_height - rail_head_height;

    union() {
        // Rail foot
        translate([-length_mm/2,
                   y_center - rail_foot_width/2,
                   rail_base_z])
            cube([length_mm, rail_foot_width, rail_foot_height]);

        // Rail web
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
    // Do not put decorative clips on the exact end sleepers because their
    // LEGO rail-finger geometry already occupies the rail ends.
    internal_count = sleeper_count - 2;
    for (i = [1 : internal_count]) {
        x = -track_length/2 + 8
            + i * ((track_length - 16)/(internal_count + 1));

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
