// OpenSCAD integration test
// Repository: YoniVolind/openscad
// Units: millimeters

// ===== Parameters =====
length = 40;
width = 30;
height = 10;
hole_diameter = 5;

// Rendering quality
$fn = 64;

// ===== Model =====
difference() {
    cube([length, width, height], center = true);

    cylinder(
        h = height + 2,
        d = hole_diameter,
        center = true
    );
}
