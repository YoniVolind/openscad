// Stylized table-tennis player bust based on the supplied reference photo.
// Intended for 3D printing; simplified from a single frontal image.
// Units: millimeters

$fn = 72;

// ========================
// Main scale
// ========================
model_height = 72;
base_radius = 21;
base_height = 3.5;

// Body
torso_width = 42;
torso_depth = 18;
torso_height = 30;

// Head
head_width = 22;
head_depth = 18;
head_height = 27;

// Neck
neck_radius = 6.2;
neck_height = 7;

// Facial proportions
ear_radius = 2.3;
nose_length = 2.9;
nose_width = 3.0;
brow_depth = 0.7;

// Hair
hair_thickness = 1.8;

// Jersey
shirt_shell = 1.0;
collar_depth = 1.5;

// Preview colors
use_preview_colors = true;

module pc(c) {
    if (use_preview_colors) color(c) children();
    else children();
}

// ========================
// Base
// ========================
module base() {
    cylinder(h=base_height, r1=base_radius, r2=base_radius-1.2);
}

// ========================
// Torso
// ========================
module torso_core() {
    // Broad shoulders tapering toward the lower torso.
    hull() {
        translate([0,0,base_height + 7])
            scale([0.72,0.72,1])
                sphere(d=24);

        translate([0,0,base_height + torso_height-3])
            scale([1.55,0.72,0.75])
                sphere(d=20);
    }
}

module shoulder(side=1) {
    translate([side*20,0,base_height + torso_height-7])
        rotate([0,side*12,0])
            scale([1.2,0.78,1.65])
                sphere(d=12);
}

module arm_stub(side=1) {
    translate([side*22,0,base_height + 18])
        rotate([0,side*8,0])
            scale([0.85,0.72,1.45])
                sphere(d=11);
}

// shallow center chest plane
module chest_panel() {
    translate([0,-7.4,base_height+20])
        scale([1.35,0.32,1.25])
            sphere(d=22);
}

// ========================
// Neck and head
// ========================
module neck() {
    translate([0,0,base_height + torso_height - 1])
        cylinder(h=neck_height, r=neck_radius);
}

module head_core() {
    z0 = base_height + torso_height + neck_height + 10;

    // Face / skull
    translate([0,0,z0])
        scale([head_width/20, head_depth/20, head_height/20])
            sphere(d=20);

    // Slight jaw squaring
    translate([0,-0.5,z0-7.5])
        scale([0.88,0.82,0.55])
            sphere(d=17);
}

module ears() {
    z = base_height + torso_height + neck_height + 11;
    for(side=[-1,1])
        translate([side*(head_width/2-0.4),0,z])
            scale([0.72,0.45,1.15])
                sphere(r=ear_radius);
}

module nose() {
    z = base_height + torso_height + neck_height + 11.2;

    hull() {
        translate([0,-head_depth/2+0.5,z+1.0])
            sphere(r=1.15);

        translate([0,-head_depth/2-nose_length+0.8,z-0.8])
            scale([nose_width/2.3,1,0.8])
                sphere(r=1.15);
    }
}

module brow(side=1) {
    z = base_height + torso_height + neck_height + 15.3;

    translate([side*3.6,-head_depth/2+0.1,z])
        rotate([0,0,side*5])
            scale([1.7,0.45,0.35])
                sphere(d=4.1);
}

module cheek(side=1) {
    z = base_height + torso_height + neck_height + 8.9;
    translate([side*4.2,-head_depth/2+0.8,z])
        scale([1.35,0.55,0.8])
            sphere(d=5.4);
}

module mouth_cut() {
    z = base_height + torso_height + neck_height + 5.7;

    translate([0,-head_depth/2-0.05,z])
        rotate([90,0,0])
            scale([1.35,0.45,1])
                cylinder(h=1.2, r=2.0, center=true);
}

module eye_cut(side=1) {
    z = base_height + torso_height + neck_height + 14.0;
    translate([side*3.6,-head_depth/2-0.25,z])
        rotate([90,0,0])
            scale([1.25,0.45,1])
                cylinder(h=1.1,r=1.0,center=true);
}

// ========================
// Hair
// ========================
module hair_mass() {
    z = base_height + torso_height + neck_height + 19.8;

    difference() {
        translate([0,0,z])
            scale([1.02,0.98,0.72])
                sphere(d=22.2);

        // remove lower portion so it sits like a cap
        translate([0,0,z-8.0])
            cube([30,30,12],center=true);

        // open face/front
        translate([0,-10.6,z-2.0])
            cube([24,8,15],center=true);
    }
}

module fringe_piece(x,z,rot=0) {
    translate([x,-8.1,z])
        rotate([0,rot,0])
            scale([0.75,0.48,1.5])
                sphere(d=3.8);
}

module fringe() {
    z0 = base_height + torso_height + neck_height + 19.8;
    fringe_piece(-5.4,z0-3.0,-8);
    fringe_piece(-2.8,z0-4.0,-4);
    fringe_piece(-0.4,z0-4.5, 0);
    fringe_piece( 2.0,z0-4.0, 5);
    fringe_piece( 4.4,z0-3.2,10);
}

// ========================
// Shirt shell/details
// ========================
module jersey_shell() {
    difference() {
        union() {
            torso_core();
            shoulder(-1);
            shoulder(1);
            arm_stub(-1);
            arm_stub(1);
        }

        // V-neck opening
        translate([0,-8.0,base_height+torso_height-2])
            rotate([90,0,0])
                linear_extrude(height=4)
                    polygon(points=[[-5,3],[5,3],[0,-5]]);
    }
}

module chest_nameplate() {
    // Raised simplified sponsor block corresponding to the large white/red panel
    translate([0,-10.3,base_height+13])
        rotate([90,0,0])
            linear_extrude(height=0.9)
                offset(r=0.6)
                    square([20,7],center=true);
}

module chest_text() {
    translate([0,-10.85,base_height+13])
        rotate([90,0,0])
            linear_extrude(height=0.55)
                text("MAXI",
                     size=5.0,
                     font="Arial:style=Bold",
                     halign="center",
                     valign="center");
}

module small_brand_text() {
    translate([-8,-9.8,base_height+24])
        rotate([90,0,0])
            linear_extrude(height=0.5)
                text("DONIC",
                     size=2.7,
                     font="Arial:style=Bold",
                     halign="center",
                     valign="center");
}

// ========================
// Face assembly
// ========================
module face_and_head() {
    difference() {
        union() {
            head_core();
            ears();
            nose();
            brow(-1);
            brow(1);
            cheek(-1);
            cheek(1);
        }

        eye_cut(-1);
        eye_cut(1);
        mouth_cut();
    }
}

// ========================
// Final model
// ========================
union() {
    pc([0.18,0.18,0.18])
        base();

    pc([0.05,0.20,0.42]) {
        jersey_shell();
        chest_panel();
    }

    pc([0.82,0.67,0.55]) {
        neck();
        face_and_head();
    }

    pc([0.12,0.07,0.04]) {
        hair_mass();
        fringe();
    }

    pc([0.95,0.95,0.95])
        chest_nameplate();

    pc([0.75,0.05,0.05])
        chest_text();

    pc([0.95,0.95,0.95])
        small_brand_text();
}
