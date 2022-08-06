
// ==============================================
/*
            Gut Culture Device Model            
    
    Author: Shlomi Green, Tel Aviv (IL)
    For the use of Yissachar Lab (BIU)

    last update: August 2022
*/

// ==============================================



// --------- EDIT SECTION ---------
  
// - Change parameters as desired      
// - All measures are in mm
// - Arrays format: [width(x), depth(y), height(z)]


// Basic Measurments 

base = [53, 95, 2];
ramp = [33, 75, 2];
well = [25, 7, 7];

number_of_wells = 6;

medium_needle_diameter = 1.27; //outer diameter
organ_needle_diameter = 0.718; //outer diameter

// Plot Options
mirror_holes = true; 
// whether  to mirror holes to both sides of the frame. if false, only one side will be ploted

mode = 0;
/*
    Posible modes
    0 - Normal: both wells and frame with holes side by side
    1 - Wells only
    2 - Frame with holes only
    3 - Lid : both bottom part and top part (frame) without holes side by side for lid
    4 - Lid bottom part only
    5 - Lid's frame only (same as option 2 but without holes)
*/


// ADVANCED PARAMETERS

safety_pad = 0.3;

medium_needle_padding = [0,1,-1] ;
medium_needle_angle = 0 ;
medium_needle_length = 50;

organ_needle_padding = [-5,well[1]/2,-1] ;
organ_needle_angle = 5 ;
organ_needle_length = 50;













// ------ [DON'T EDIT BELOW THIS] ------
$fn = 50;

overlap = 0.01;

base_loc= [-base[0]/2,0,0];

ramp_loc = base_loc + 
            [(base[0] - ramp[0])/2,
            (base[1] - ramp[1])/2, 
            base[2]];
            
well_initial_loc = ramp_loc + 
                    [(ramp[0] - well[0])/2,
                      0,
                      ramp[2]];
                      
well_spacer = (ramp[1] - well[1] * number_of_wells)/(number_of_wells+1);
assert(well_spacer >= 0, "not enough space for requested number of wells");

frame_dim = [base[0], base[1], ramp[2]+well[2] - overlap];
frame_loc = [base_loc[0], base_loc[1], base_loc[2] + base[2]];

// Setup
module Base(){
    translate(base_loc){
        cube(base);
    }
}


module Ramp(){
    translate(ramp_loc){
      cube(ramp);
    }
}


module Wells(){
    for (i=[1:number_of_wells]){
        translate(well_initial_loc + [0,well_spacer * i + (i-1)*well[1], 0]){
                        cube(well);
        }
    }
}

module Lid(){
    dims =  [well[0], (well[1] + well_spacer) * number_of_wells - well_spacer, well[2]];
    translate(well_initial_loc + [0, well_spacer, 0])
    cube(dims);
}

module Frame(needle_holes=true){
        difference(){
            translate(frame_loc)
                cube(frame_dim);
                            
            translate(frame_loc + [(base[0] - ramp[0])/2 - safety_pad, 
                      (base[1] - ramp[1])/2 - safety_pad, 
                           0 - overlap])
                cube([ramp[0] + safety_pad*2,
                      ramp[1] + safety_pad*2,
                      ramp[2]+well[2] + overlap]);
                               
             slit(frame_loc, frame_dim, 1,1);
             if (needle_holes){
                // Medium needles
                Needles(medium_needle_diameter + safety_pad, medium_needle_padding, medium_needle_angle, medium_needle_length);
                if (mirror_holes)
                 mirror([1,0,0])
                    Needles(medium_needle_diameter + safety_pad, [0,1,-1]);
                // Organ needles
                Needles(organ_needle_diameter + safety_pad, organ_needle_padding, organ_needle_angle, organ_needle_length);
                if (mirror_holes)
                    mirror([1,0,0])
                    Needles(organ_needle_diameter + safety_pad, organ_needle_padding, organ_needle_angle, organ_needle_length);
             }
    }
}


module Needles(diameter, padding=[0,0,0], angle=0, length=50){
   for (i=[1:number_of_wells]){
        translate(well_initial_loc + [well[0], 
                              well_spacer * i + (i-1)*well[1], 
                              well[2] - diameter/2] + padding)
        rotate([0,90 + angle,0])
        cylinder(h=length, d=diameter, center=false);
    }
} 

module slit(loc, dim, t,h){

    
    
    slit_center = loc + [dim[0]/2, dim[1]/2, -overlap];
    outer_dim = [dim[0],dim[1]] + [overlap, overlap];
    translate(slit_center){
        linear_extrude(h, center=t){
                difference(){
                    square(outer_dim, center=true);
                    square(outer_dim - [t,t], center=true);
                }
        } 
    }   
}




// Build


if (mode == 0 || mode ==1 || mode == 3 ||  mode == 4){
     Base();
     Ramp();   
    }

if (mode == 0){
    Wells();
    rotate([0,180,0])
    translate([base[0] + 3,0,-base[2]-well[2]-ramp[2]])
    Frame();
    }

if (mode == 1)
    Wells();

if (mode == 2)
    rotate([0,180,0])
    translate([0,0,-base[2]-well[2]-ramp[2]])
    Frame();

if (mode == 3){
    Lid();
    rotate([0,180,0])
    translate([base[0] + 3,0,-base[2]-well[2]-ramp[2]])
    Frame(false);
    }

if (mode == 4)
    Lid();

if (mode == 5)
    rotate([0,180,0])
    translate([0,0,-base[2]-well[2]-ramp[2]])
    Frame(false);

