// Mini pillow with raised Star of David
// Approximate footprint: 20 x 10 mm
// Units: millimeters

$fn = 64;

// ========================
// Main dimensions
// ========================
pillow_length = 20;
pillow_width  = 10;
pillow_height = 5.0;

corner_radius = 2.0;

// Star dimensions
star_outer_radius = 3.0;
star_line_width   = 0.65;
star_height       = 0.55;

// ========================
// Rounded 2D rectangle
// ========================
module rounded_rect_2d(w, h, r) {
    offset(r = r)
        square([w - 2*r, h - 2*r], center = true);
}

// Very thin rounded plate used for lofting the pillow
module rounded_slice(z, w, h, r, thickness = 0.12) {
    translate([0, 0, z])
        linear_extrude(height = thickness, center = true)
            rounded_rect_2d(w, h, r);
}

// ========================
// Pillow body
// ========================
// The slices get wider toward the middle and narrower
// near the top/bottom to create a soft stuffed-pillow shape.
module pillow_body() {
    hull() {
        rounded_slice(
            -pillow_height/2 + 0.30,
            pillow_length - 2.2,
            pillow_width  - 1.8,
            corner_radius - 0.45
        );

        rounded_slice(
            -pillow_height/2 + 1.15,
            pillow_length - 0.7,
            pillow_width  - 0.5,
            corner_radius - 0.10
        );

        rounded_slice(
            0,
            pillow_length,
            pillow_width,
            corner_radius
        );

        rounded_slice(
            pillow_height/2 - 1.15,
            pillow_length - 0.7,
            pillow_width  - 0.5,
            corner_radius - 0.10
        );

        rounded_slice(
            pillow_height/2 - 0.30,
            pillow_length - 2.2,
            pillow_width  - 1.8,
            corner_radius - 0.45
        );
    }
}

// ========================
// Star of David
// ========================
function triangle_points(r, rotation = 0) = [
    for (a = [90 + rotation, 210 + rotation, 330 + rotation])
        [r*cos(a), r*sin(a)]
];

module triangle_outline(r, line_w) {
    difference() {
        polygon(points = triangle_points(r));
        offset(delta = -line_w)
            polygon(points = triangle_points(r));
    }
}

module star_of_david_2d(r, line_w) {
    union() {
        triangle_outline(r, line_w);

        rotate(180)
            triangle_outline(r, line_w);
    }
}

module star_of_david() {
    translate([
        0,
        0,
        pillow_height/2 - 0.18
    ])
        linear_extrude(height = star_height)
            star_of_david_2d(star_outer_radius, star_line_width);
}

// ========================
// Final model
// ========================
union() {
    color([0.82, 0.82, 0.82])
        pillow_body();

    color([0.15, 0.25, 0.65])
        star_of_david();
}
