// Realistic-looking straight toy train track
// Sized for the LEGO train ecosystem geometry, but visually styled like real track.
// Units: millimeters

$fn = 72;

// ========================
// Core geometry
// ========================
track_length = 100;          // requested custom length
rail_center_gauge = 40;      // LEGO train rail center spacing
running_gauge = 37.5;        // inner rail-head face spacing
track_width = 64;            // matches the footprint width of LEGO track ecosystem

// ========================
// Visual styling
// ========================
ballast_bottom_width = 64;
ballast_top_width = 50;
ballast_height = 3.6;
ballast_end_bevel = 2.0;

sleeper_count = 7;
sleeper_length_y = 53;
sleeper_width_x = 7.2;
sleeper_height = 2.2;
sleeper_embed = 0.8;         // how much sleeper sinks into ballast

rail_foot_width = 5.6;
rail_foot_height = 0.9;
rail_web_width = 1.4;
rail_head_bottom_width = 3.6;
rail_head_top_width = rail_center_gauge - running_gauge; // 2.5 mm
rail_head_height = 1.8;
rail_total_height = 5.1;

end_margin = 8.5;            // keeps first/last sleepers inset like real track
show_preview_colors = true;

// ========================
// Helpers
// ========================
module preview_color(c) {
    if (show_preview_colors) color(c) children();
    else children();
}

module ballast_profile() {
    polygon(points = [
        [-ballast_bottom_width/2, 0],
        [ ballast_bottom_width/2, 0],
        [ ballast_top_width/2,    ballast_height],
        [-ballast_top_width/2,    ballast_height]
    ]);
}

module ballast_bed() {
    // Slightly chamfered ends for a more finished look.
    intersection() {
        rotate([90,0,90])
            linear_extrude(height = track_length, center = true)
                ballast_profile();

        hull() {
            translate([-(track_length/2) + ballast_end_bevel/2, 0, ballast_height/2])
                cube([ballast_end_bevel, ballast_bottom_width, ballast_height], center = true);
            translate([(track_length/2) - ballast_end_bevel/2, 0, ballast_height/2])
                cube([ballast_end_bevel, ballast_bottom_width, ballast_height], center = true);
        }
    }
}

module sleeper(xc) {
    translate([xc, 0, ballast_height - sleeper_embed + sleeper_height/2])
        cube([sleeper_width_x, sleeper_length_y, sleeper_height], center = true);
}

module rail(length_mm, y_center) {
    head_bottom_z = ballast_height - sleeper_embed + sleeper_height + (rail_total_height - rail_head_height);
    foot_z = ballast_height - sleeper_embed + sleeper_height;
    web_z0 = foot_z + rail_foot_height;
    web_z1 = head_bottom_z;

    union() {
        // Foot
        translate([-length_mm/2, y_center - rail_foot_width/2, foot_z])
            cube([length_mm, rail_foot_width, rail_foot_height]);

        // Web
        translate([-length_mm/2, y_center - rail_web_width/2, web_z0])
            cube([length_mm, rail_web_width, web_z1 - web_z0]);

        // Tapered head
        hull() {
            translate([-length_mm/2, y_center - rail_head_bottom_width/2, head_bottom_z])
                cube([length_mm, rail_head_bottom_width, 0.35]);
            translate([-length_mm/2, y_center - rail_head_top_width/2, foot_z + rail_total_height - 0.55])
                cube([length_mm, rail_head_top_width, 0.55]);
        }
    }
}

module rail_joiner_hint(side, y_center) {
    // Small fishplate-like side plates for realism.
    x = side * (track_length/2 - 2.1);
    z0 = ballast_height - sleeper_embed + sleeper_height + 1.0;
    for (sign = [-1, 1]) {
        translate([x, y_center + sign * (rail_head_bottom_width/2 + 0.25), z0])
            cube([4.2, 0.7, 1.7], center = true);
    }
}

module all_sleepers() {
    for (i = [0 : sleeper_count - 1]) {
        x = -track_length/2 + end_margin + i * ((track_length - 2*end_margin) / (sleeper_count - 1));
        sleeper(x);
    }
}

module realistic_track() {
    union() {
        preview_color([0.48, 0.47, 0.45])
            ballast_bed();

        preview_color([0.33, 0.22, 0.14])
            all_sleepers();

        preview_color([0.56, 0.58, 0.60]) {
            rail(track_length, -rail_center_gauge/2);
            rail(track_length,  rail_center_gauge/2);

            rail_joiner_hint(-1, -rail_center_gauge/2);
            rail_joiner_hint(-1,  rail_center_gauge/2);
            rail_joiner_hint( 1, -rail_center_gauge/2);
            rail_joiner_hint( 1,  rail_center_gauge/2);
        }
    }
}

realistic_track();
