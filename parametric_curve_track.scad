// PARAMETRIC STRAIGHT / CURVED REALISTIC LEGO-GAUGE TRACK
// ----------------------------------------------------------
// Same design language as main.scad:
// - same 8 x 56 x 3.2 mm timber sleepers
// - same extracted LEGO-compatible connector profile
// - same randomized wood texture
// - LEGO train rail gauge: 40 mm center-to-center, 37.5 mm running gauge
//
// CURVE PARAMETERS:
// track_radius = 0     -> straight track; straight_length is used.
// track_radius > 0     -> curved track.
// track_angle          -> curve angle in DEGREES.
// track_radius is the CENTERLINE radius midway between both rails.
//
// Example:
// track_radius = 400;
// track_angle  = 15;
// centerline arc length = 400 * 15 * PI / 180 = 104.72 mm
//
// Units: millimeters

$fn = 64;

// =============================
// USER PARAMETERS
// =============================
track_radius = 400;        // 0 = straight; >0 = curve centerline radius in mm
track_angle = 15;          // degrees; used only when track_radius > 0
straight_length = 100;     // mm; used only when track_radius == 0

// =============================
// LEGO-GAUGE / MODEL PARAMETERS
// =============================
rail_center_gauge = 40;
running_gauge = 37.5;

sleeper_width = 8;         // along the track
sleeper_length = 56;       // across the track
sleeper_height = 3.2;

// Taken from the approved 100 mm model:
// (100 - 8) / (8 - 1) = 13.142857 mm.
target_sleeper_spacing = 13.1428571429;

// rail top = 9.6 mm above ground
rail_base_z = 3.40;
rail_total_height = 9.6 - rail_base_z;
rail_foot_width = 5.8;
rail_foot_height = 0.9;
rail_web_width = 1.45;
rail_head_bottom_width = 3.7;
rail_head_top_width = rail_center_gauge - running_gauge;
rail_head_height = 1.95;

// mounting details
plate_x = 5.6;
plate_y = 8.2;
plate_h = 0.42;
clip_d = 1.2;
clip_h = 0.78;

// wood texture
wood_top_depth = 0.22;
wood_side_depth = 0.18;
wood_grain_min_w = 0.20;
wood_grain_max_w = 0.38;
show_preview_colors = true;

// =============================
// DERIVED PARAMETERS
// =============================
curve_mode = track_radius > 0;
path_length = curve_mode
    ? track_radius * abs(track_angle) * PI / 180
    : straight_length;

// Pick the nearest whole sleeper count while keeping the first and last
// sleeper integrated with the connector ends.
sleeper_count = max(
    2,
    round((path_length - sleeper_width) / target_sleeper_spacing) + 1
);

actual_sleeper_spacing = sleeper_count > 1
    ? (path_length - sleeper_width) / (sleeper_count - 1)
    : 0;

assert(track_radius >= 0, "track_radius must be 0 or positive.");
assert(!curve_mode || track_angle > 0, "For a curve, track_angle must be > 0 degrees.");
assert(!curve_mode || track_radius > rail_center_gauge/2 + rail_foot_width,
       "Radius is too small for the inner rail.");
assert(path_length >= sleeper_width,
       "Track is too short for the end sleepers/connectors.");

// =============================
// CONNECTOR PROFILE
// =============================
// Dimensionally extracted from the compatible uploaded STL used for main.scad.
// Local coordinates:
// x = 0 is the mating plane
// x > 0 points inward into the track
// y is across the track
lego_end_profile = [
    [8.0000, 31.6000],
    [7.9966, -31.6522],
    [7.9548, -31.7847],
    [7.8702, -31.8949],
    [7.7531, -31.9696],
    [7.6174, -31.9996],
    [0.3478, -31.9966],
    [0.2153, -31.9548],
    [0.1051, -31.8702],
    [0.0304, -31.7531],
    [0.0004, -31.6174],
    [0.0000, -22.8000],
    [-0.0241, -22.6632],
    [-0.0723, -22.5706],
    [-0.1429, -22.4936],
    [-0.2310, -22.4375],
    [-0.3394, -22.4046],
    [-2.2611, -22.3987],
    [-2.5623, -22.3523],
    [-2.7917, -22.2688],
    [-2.9522, -22.1807],
    [-3.0999, -22.0725],
    [-3.2322, -21.9458],
    [-3.3807, -21.7522],
    [-3.4688, -21.5917],
    [-3.5352, -21.4210],
    [-3.5880, -21.1827],
    [-3.6000, -21.0000],
    [-3.6000, -18.8000],
    [-3.5880, -18.6173],
    [-3.5352, -18.3790],
    [-3.4688, -18.2083],
    [-3.3807, -18.0478],
    [-3.2322, -17.8542],
    [-3.0911, -17.7203],
    [-2.9000, -17.5876],
    [-2.7249, -17.5022],
    [-2.5144, -17.4358],
    [-2.2118, -17.4001],
    [-0.3462, -17.3964],
    [-0.2276, -17.3609],
    [-0.1286, -17.2938],
    [-0.0490, -17.1919],
    [-0.0080, -17.0795],
    [0.0000, -12.3728],
    [-0.0152, -12.1991],
    [-0.0937, -11.9502],
    [-0.2340, -11.7300],
    [-1.2243, -10.7343],
    [-1.3060, -10.6324],
    [-1.3675, -10.5049],
    [-1.3980, -10.3596],
    [-1.3915, -10.1896],
    [-1.3478, -10.0452],
    [-1.2432, -9.8890],
    [-1.1528, -9.8428],
    [-1.0649, -9.8292],
    [-0.9753, -9.8424],
    [-0.6807, -9.9655],
    [-0.4205, -10.0370],
    [-0.1532, -10.0743],
    [0.2063, -10.0697],
    [0.3845, -10.0442],
    [0.6459, -9.9772],
    [0.8965, -9.8769],
    [1.0554, -9.7924],
    [1.2785, -9.6407],
    [1.4802, -9.4613],
    [1.6569, -9.2574],
    [1.8058, -9.0323],
    [1.9242, -8.7898],
    [2.0103, -8.5341],
    [2.0489, -8.3583],
    [2.0781, -8.0900],
    [2.0722, -7.8202],
    [2.0315, -7.5534],
    [1.9566, -7.2942],
    [1.8487, -7.0468],
    [1.7098, -6.8155],
    [1.5420, -6.6041],
    [1.3483, -6.4162],
    [1.1319, -6.2550],
    [0.8965, -6.1231],
    [0.6459, -6.0228],
    [0.3845, -5.9558],
    [0.1166, -5.9233],
    [-0.1532, -5.9257],
    [-0.4205, -5.9630],
    [-0.6807, -6.0345],
    [-0.9768, -6.1580],
    [-1.1222, -6.1650],
    [-1.2329, -6.1184],
    [-1.2991, -6.0430],
    [-1.3739, -5.8850],
    [-1.3995, -5.7353],
    [-1.3796, -5.5347],
    [-1.2915, -5.3458],
    [-0.2369, -4.2735],
    [-0.0890, -4.0394],
    [-0.0136, -3.7918],
    [0.0000, -3.6272],
    [0.0000, 3.3444],
    [0.0306, 3.5899],
    [0.1205, 3.8203],
    [0.2369, 3.9907],
    [1.3657, 5.1243],
    [1.4747, 5.2601],
    [1.5391, 5.3838],
    [1.5878, 5.5510],
    [1.6000, 5.7929],
    [1.5806, 5.9442],
    [1.5237, 6.0857],
    [1.4330, 6.2083],
    [1.3581, 6.2599],
    [1.2583, 6.2884],
    [1.1215, 6.2708],
    [0.8349, 6.1223],
    [0.4993, 6.0066],
    [0.2372, 5.9587],
    [-0.0288, 5.9452],
    [-0.3821, 5.9808],
    [-0.6401, 6.0472],
    [-0.8873, 6.1464],
    [-1.1197, 6.2768],
    [-1.3332, 6.4361],
    [-1.5243, 6.6217],
    [-1.6898, 6.8305],
    [-1.8658, 7.1388],
    [-1.9862, 7.4728],
    [-2.0377, 7.7342],
    [-2.0531, 8.0888],
    [-2.0243, 8.3537],
    [-1.9616, 8.6126],
    [-1.8658, 8.8612],
    [-1.7845, 9.0192],
    [-1.6376, 9.2414],
    [-1.4633, 9.4429],
    [-1.2643, 9.6200],
    [-1.1197, 9.7232],
    [-0.8873, 9.8536],
    [-0.6401, 9.9528],
    [-0.3821, 10.0192],
    [-0.1177, 10.0516],
    [0.1488, 10.0496],
    [0.4127, 10.0131],
    [0.5850, 9.9700],
    [0.8349, 9.8777],
    [1.1175, 9.7308],
    [1.2511, 9.7110],
    [1.3463, 9.7347],
    [1.4330, 9.7917],
    [1.5237, 9.9143],
    [1.5806, 10.0558],
    [1.5995, 10.1816],
    [1.5891, 10.4417],
    [1.5453, 10.6009],
    [1.4697, 10.7476],
    [1.3657, 10.8757],
    [0.2369, 12.0093],
    [0.1016, 12.2164],
    [0.0213, 12.4504],
    [0.0000, 12.6556],
    [0.0000, 16.8000],
    [0.0136, 16.9035],
    [0.0536, 17.0000],
    [0.1084, 17.0738],
    [0.1851, 17.1374],
    [0.3499, 17.1968],
    [2.3552, 17.2067],
    [2.6659, 17.2613],
    [2.9607, 17.3686],
    [3.1671, 17.4819],
    [3.3570, 17.6211],
    [3.5271, 17.7839],
    [3.6745, 17.9676],
    [3.7966, 18.1689],
    [3.8914, 18.3844],
    [3.9573, 18.6104],
    [3.9940, 18.8532],
    [4.0000, 20.8000],
    [3.9727, 21.1126],
    [3.8914, 21.4156],
    [3.7966, 21.6311],
    [3.6745, 21.8324],
    [3.4728, 22.0728],
    [3.2958, 22.2280],
    [3.1000, 22.3588],
    [2.8156, 22.4914],
    [2.5896, 22.5573],
    [2.4349, 22.5846],
    [2.2000, 22.6000],
    [0.3489, 22.6033],
    [0.2303, 22.6378],
    [0.1441, 22.6926],
    [0.0624, 22.7854],
    [0.0191, 22.8779],
    [0.0000, 23.0000],
    [0.0000, 31.6000],
    [0.0281, 31.7472],
    [0.1051, 31.8702],
    [0.2469, 31.9696],
    [0.4000, 32.0000],
    [7.6000, 32.0000],
    [7.7472, 31.9719],
    [7.8702, 31.8949],
    [7.9625, 31.7690]
];

// =============================
// HELPERS
// =============================
function fract(x) = x-floor(x);
function rnd(seed,k) = fract(abs(sin(seed*97.13+k*41.73)*43758.5453));
function rr(seed,k,a,b) = a+(b-a)*rnd(seed,k);

module preview_color(c) {
    if(show_preview_colors) color(c) children();
    else children();
}

// Position/orient children on the centerline.
// Local +X always points FORWARD along the track.
// Local +Y points across the track.
module at_path(s) {
    if(!curve_mode) {
        translate([-path_length/2 + s, 0, 0])
            children();
    } else {
        theta = s / track_radius * 180 / PI;
        translate([
            track_radius*cos(theta),
            track_radius*sin(theta),
            0
        ])
            rotate([0,0,theta+90])
                children();
    }
}

// =============================
// RANDOM TIMBER TEXTURE
// =============================
module top_point(x,y,d,h) {
    translate([x,y,h/2-wood_top_depth/2])
        cylinder(h=wood_top_depth+0.14,d=d,center=true,$fn=12);
}

module top_grain(seed,i,bw,bl,bh) {
    n=8;
    bx=rr(seed,100+i*11,-bw*0.40,bw*0.40);
    d=rr(seed,101+i*13,wood_grain_min_w,wood_grain_max_w);

    for(j=[0:n-2]) {
        y1=-bl/2+0.7+j*((bl-1.4)/(n-1));
        y2=-bl/2+0.7+(j+1)*((bl-1.4)/(n-1));
        x1=bx+rr(seed,200+i*31+j,-0.55,0.55);
        x2=bx+rr(seed,201+i*31+j,-0.55,0.55);

        hull() {
            top_point(x1,y1,d,bh);
            top_point(x2,y2,d*rr(seed,250+i*17+j,0.82,1.18),bh);
        }
    }
}

module end_crack(seed,side,i,bw,bl,bh) {
    y0=side*(bl/2-0.10);
    y1=y0-side*rr(seed,300+side*19+i*17,4.5,11.5);
    x0=rr(seed,310+side*23+i*13,-bw*0.34,bw*0.34);
    x1=x0+rr(seed,320+side*29+i*11,-0.9,0.9);
    d=rr(seed,330+side*31+i*7,0.22,0.40);

    hull() {
        top_point(x0,y0,d,bh);
        top_point(x1,y1,d*0.70,bh);
    }
}

module knot(seed,i,bw,bl,bh) {
    x=rr(seed,400+i*17,-bw*0.28,bw*0.28);
    y=rr(seed,410+i*19,-bl*0.40,bl*0.40);

    translate([x,y,bh/2-0.11])
        scale([
            rr(seed,420+i,1.1,1.8),
            rr(seed,430+i,0.55,1.0),
            1
        ])
            difference() {
                cylinder(h=0.28,r=1.0,center=true,$fn=24);
                cylinder(h=0.36,r=0.62,center=true,$fn=24);
            }
}

module side_point(side,y,z,d,bw) {
    translate([side*(bw/2-wood_side_depth/2),y,z])
        rotate([0,90,0])
            cylinder(h=wood_side_depth+0.14,d=d,center=true,$fn=10);
}

module side_grain(seed,side,i,bw,bl,bh) {
    n=7;
    bz=rr(seed,500+(side+1)*100+i*13,-bh*0.30,bh*0.30);
    d=rr(seed,510+(side+1)*100+i*17,0.18,0.31);

    for(j=[0:n-2]) {
        y1=-bl/2+0.8+j*((bl-1.6)/(n-1));
        y2=-bl/2+0.8+(j+1)*((bl-1.6)/(n-1));
        z1=bz+rr(seed,520+(side+1)*200+i*29+j,-0.30,0.30);
        z2=bz+rr(seed,521+(side+1)*200+i*29+j,-0.30,0.30);

        hull() {
            side_point(side,y1,z1,d,bw);
            side_point(side,y2,z2,d*0.9,bw);
        }
    }
}

module end_ring(seed,side,i,bl) {
    rx=rr(seed,600+(side+1)*50+i*11,1.0,2.5);
    rz=rr(seed,610+(side+1)*50+i*13,0.45,1.05);

    translate([
        rr(seed,620+i,-0.45,0.45),
        side*(bl/2-wood_side_depth/2),
        rr(seed,630+i,-0.15,0.15)
    ])
        rotate([90,0,0])
            scale([rx,rz,1])
                difference() {
                    cylinder(h=wood_side_depth+0.14,r=1,center=true,$fn=28);
                    cylinder(h=wood_side_depth+0.22,r=0.78,center=true,$fn=28);
                }
}

module wood_cutters(seed,bw,bl,bh,include_side=true) {
    lines=7+floor(rnd(seed,1)*5);
    cracks=1+floor(rnd(seed,2)*3);
    knots=floor(rnd(seed,3)*3);

    for(i=[0:lines-1])
        top_grain(seed,i,bw,bl,bh);

    for(side=[-1,1])
        for(i=[0:cracks-1])
            end_crack(seed,side,i,bw,bl,bh);

    if(knots>0)
        for(i=[0:knots-1])
            knot(seed,i,bw,bl,bh);

    if(include_side)
        for(side=[-1,1])
            for(i=[0:2])
                side_grain(seed,side,i,bw,bl,bh);

    for(side=[-1,1])
        for(i=[0:2])
            end_ring(seed,side,i,bl);
}

module timber_sleeper(seed) {
    difference() {
        cube([sleeper_width,sleeper_length,sleeper_height],center=true);
        wood_cutters(seed,sleeper_width,sleeper_length,sleeper_height,true);
    }
}

// =============================
// CONNECTOR END SLEEPER
// =============================
// Same connector as main.scad.
// Only the plain outer beam is clipped to 56 mm;
// mating geometry is untouched.
module source_end_local(seed) {
    difference() {
        linear_extrude(height=sleeper_height)
            intersection() {
                polygon(points=lego_end_profile);
                translate([-4.1,-sleeper_length/2])
                    square([12.3,sleeper_length]);
            }

        // Texture only the timber body x=0..8.
        // Do not modify the mating connector surfaces at x<0.
        intersection() {
            translate([4,0,sleeper_height/2])
                wood_cutters(seed,8,sleeper_length,sleeper_height,false);

            translate([4,0,sleeper_height/2])
                cube([8.01,sleeper_length+0.02,sleeper_height+0.04],center=true);
        }
    }
}

module end_sleepers() {
    // Start: local +X points inward/forward.
    at_path(0)
        source_end_local(101);

    // End: rotate connector 180 degrees so local +X points back inward.
    at_path(path_length)
        rotate([0,0,180])
            source_end_local(208);
}

// =============================
// INTERNAL SLEEPERS
// =============================
module internal_sleepers() {
    if(sleeper_count > 2) {
        for(i=[1:sleeper_count-2]) {
            s = sleeper_width/2 + i*actual_sleeper_spacing;
            at_path(s)
                translate([0,0,sleeper_height/2])
                    timber_sleeper(300+i*47);
        }
    }
}

// =============================
// RAIL PROFILE
// =============================
module rail_profile_2d() {
    head_bottom_z = rail_total_height - rail_head_height;

    union() {
        // foot
        translate([-rail_foot_width/2,0])
            square([rail_foot_width,rail_foot_height]);

        // web
        translate([-rail_web_width/2,rail_foot_height-0.05])
            square([
                rail_web_width,
                head_bottom_z-(rail_foot_height-0.05)+0.15
            ]);

        // tapered head
        hull() {
            translate([-rail_head_bottom_width/2,head_bottom_z])
                square([rail_head_bottom_width,0.42]);

            translate([-rail_head_top_width/2,rail_total_height-0.58])
                square([rail_head_top_width,0.58]);
        }
    }
}

module straight_rail(yc) {
    head_z=rail_base_z+rail_total_height-rail_head_height;

    union() {
        translate([-path_length/2,yc-rail_foot_width/2,rail_base_z])
            cube([path_length,rail_foot_width,rail_foot_height]);

        translate([
            -path_length/2,
            yc-rail_web_width/2,
            rail_base_z+rail_foot_height-0.05
        ])
            cube([
                path_length,
                rail_web_width,
                head_z-(rail_base_z+rail_foot_height)+0.15
            ]);

        hull() {
            translate([
                -path_length/2,
                yc-rail_head_bottom_width/2,
                head_z
            ])
                cube([path_length,rail_head_bottom_width,0.42]);

            translate([
                -path_length/2,
                yc-rail_head_top_width/2,
                rail_base_z+rail_total_height-0.58
            ])
                cube([path_length,rail_head_top_width,0.58]);
        }
    }
}

module curved_rail(radius) {
    rotate_extrude(angle=track_angle,convexity=12,$fn=max(64,ceil(track_angle*4)))
        translate([radius,rail_base_z])
            rail_profile_2d();
}

module rails() {
    if(!curve_mode) {
        straight_rail(-rail_center_gauge/2);
        straight_rail( rail_center_gauge/2);
    } else {
        // radius is defined at the centerline midway between both rails.
        curved_rail(track_radius-rail_center_gauge/2);
        curved_rail(track_radius+rail_center_gauge/2);
    }
}

// =============================
// RAIL MOUNTING HARDWARE
// =============================
module tie_plate_local(y) {
    translate([0,y,sleeper_height+plate_h/2-0.05])
        cube([plate_x,plate_y,plate_h],center=true);
}

module rail_clip_local(y,side) {
    translate([
        0,
        y+side*(rail_foot_width/2+0.60),
        sleeper_height+plate_h+clip_h/2-0.10
    ])
        cylinder(h=clip_h,d=clip_d,center=true,$fn=20);
}

module hardware() {
    if(sleeper_count > 2) {
        for(i=[1:sleeper_count-2]) {
            s = sleeper_width/2 + i*actual_sleeper_spacing;

            at_path(s)
                for(y=[-rail_center_gauge/2,rail_center_gauge/2]) {
                    tie_plate_local(y);
                    rail_clip_local(y,-1);
                    rail_clip_local(y, 1);
                }
        }
    }
}

// =============================
// FINAL MODEL
// =============================
module parametric_track() {
    union() {
        preview_color([0.36,0.22,0.11]) {
            end_sleepers();
            internal_sleepers();
        }

        preview_color([0.24,0.25,0.26])
            hardware();

        preview_color([0.55,0.57,0.59])
            rails();
    }
}

parametric_track();

// Console information
echo("track_radius =",track_radius);
echo("track_angle =",track_angle);
echo("path_length_mm =",path_length);
echo("sleeper_count =",sleeper_count);
echo("actual_sleeper_spacing_mm =",actual_sleeper_spacing);
