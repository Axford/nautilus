
include <valueframe.scad>
include <stepper-motors.scad>
use <parametric_involute_gear_v5.0.scad>

perim = 0.7;
layers = 0.3;
2perim = 2*perim;
4perim = 4*perim;

frameProfileW = 20;

//bottle 
bottleD = 68.4;
bottleH = 260;

//crate
crateW = 4 * bottleD + 5* 5;
crateD = 3 * bottleD + 4*5;
crateH = bottleH + 10;

// external dimensions
frameW = crateW + 5 + 2*frameProfileW;  

frameD = crateD * 5/3;
frameSideCentres = 2 * bottleD - frameProfileW;  // distance between centres of side frames

sumpD = bottleD * 2;
sumpH = 50;
sumpW = frameW - 2*frameProfileW;

frameShelfH1 = 100;

pumpZ = frameShelfH1 + crateH + 30;
pumpRailCentres = 85;

frameH = pumpZ + pumpRailCentres + frameProfileW/2;  


module beerBottle() {
	color([0.8,0.5,0.3,0.8]) cylinder(h=bottleH, r1=bottleD/2, r2=26/2);
}

module crate() {
	x = crateW;
	y = crateD;
	h = crateH;

	color("green") translate([-x/2,-y/2,0]) difference() {
		cube([x,y,h]);
		translate([5,5,5]) cube([x-10,y-10,h]);
	}
}

module crateOfBottles() {
	crate();

	for (x=[0:3]) {
		for (y=[0:2]) {
			translate([-110.1 + 73.4*x,-73.4 + 73.4*y,5]) beerBottle();
		}
	}
	
}


module sump() {
	color("grey") translate([-sumpW/2,-sumpD/2,0]) difference() {
		cube([frameW - 2*frameProfileW,sumpD,sumpH]);
		translate([1,1,1]) cube([sumpW-2,sumpD-2,sumpH]);
	}
}

module aluExtL(w=10,h=10,l=100,thickness=1.5) {
	color("silver") translate() union() {
		cube([w,thickness,l]);
		cube([thickness,h,l]);
	}
}




module frame() {

	for (i=[0:1]) {
		// side frames
		rotate([0,0,i*180]) translate([(frameW - 2*frameProfileW)/2+frameProfileW/2,0,0]) {
			// vertical struts
			for (j=[0:1]) rotate([0,0,j*180]) translate([0,frameSideCentres/2,frameProfileW]) {
				rotate([0,0,j*180]) valueFrameProfile(P5_20x201N,l=frameH-frameProfileW);
			}

			// feet
			translate([0,frameD/2,frameProfileW/2]) rotate([90,0,0]) valueFrameProfile(P5_20x202N180,l=frameD);

			// crate shelf
			translate([-10,-frameD/2,frameShelfH1]) rotate([90,0,180]) aluExtL(w=20,h=20,l=frameD);

			// tops
			translate([0,(frameSideCentres - frameProfileW)/2,frameH - frameProfileW/2]) rotate([90,0,0]) valueFrameProfile(P5_20x202N180,l=frameSideCentres - frameProfileW);
			
		} 

		// sump supports
		rotate([0,0,i*180]) translate([0,0,0]) {
			translate([-frameW/2,-sumpD/2 -1.5,frameProfileW]) rotate([90,0,90]) aluExtL(w=20,h=20,l=frameW);
		}
	}

	translate([0,(frameSideCentres)/2,pumpZ]) pumpAssembly();

}

module smallGear() {
	union() {
		translate([0,0,9]) gear (circular_pitch=180*1.5, number_of_teeth=11, gear_thickness = 5, rim_thickness = 10, rim_width=3, hub_thickness = 10, hub_diameter=10, bore_diameter=5, circles=0);
		cylinder(h=10, r=10);

		// need to add nut trap and bolt hole
	}
}

gearCentres = (11+39)/1.5 + 4;

module bigGear() {
	gear (circular_pitch=180*1.5, number_of_teeth=39, gear_thickness = 5, rim_thickness = 9, rim_width=3, hub_thickness = 15, hub_diameter=20, bore_diameter=2, circles=8);
}

module axle(l=100) {
	w = 5;
	color("silver") translate([-w/2,-w/2]) cube([w,w,l]);
}	

module motorPlate() {
	// centred on pump axle
	w = 7;
	d = gearCentres + NEMA17[0]/2 + 30/2;
	h = pumpRailCentres-frameProfileW;

	difference() {
		union() {
			translate([w,-30/2,-NEMA17[0]/2]) rotate([0,-90,0]) roundedRect([NEMA17[0],d,w],5,$fn=12);
			translate([0,-frameProfileW/2,-h/2]) cube([w,frameProfileW,h]);
		}

		// hollow out for smallGear
		translate([-1,gearCentres,0]) rotate([0,90,0]) cylinder(h=w+2, r=12);

		// hollow out for bearing
		translate([-1,0,0]) rotate([0,90,0]) cylinder(h=w+2, r=22/2);
	}
}


module bearingPlate() {
	// centred on pump axle
	w = 7;
	d = gearCentres + NEMA17[0]/2 + 30/2;
	h = pumpRailCentres-frameProfileW;

	difference() {
		union() {
			rotate([0,90,0]) cylinder(h=w, r=30/2);
			translate([0,-frameProfileW/2,-h/2]) cube([w,frameProfileW,h]);
		}

		// hollow out for bearing
		translate([-1,0,0]) rotate([0,90,0]) cylinder(h=w+2, r=22/2);
	}
}

module pumpAssembly() {
	
	translate([50,0,pumpRailCentres/2]) {
	
		translate([19,gearCentres,0]) rotate([0,-90,0]) {
			rotate([0,0,0]) smallGear();
			translate([0,0,-3]) color("grey") NEMA(NEMA17);
		}
	
		rotate([0,90,0]) bigGear();

		translate([25,0,0]) rotate([0,-90,0]) axle(l=200);

		translate([15,0,0]) motorPlate();
		translate([-150,0,0]) bearingPlate();

	}

	translate([-frameW/2+frameProfileW,0,0]) rotate([90,0,90]) valueFrameProfile(P5_20x20,l=frameW - 2*frameProfileW);
	translate([-frameW/2+frameProfileW,0,pumpRailCentres]) rotate([90,0,90]) valueFrameProfile(P5_20x20,l=frameW - 2*frameProfileW);
}


frame();

translate([0,0,frameProfileW+1.5]) sump();

translate([0,0,frameShelfH1+1.5]) crateOfBottles();




module roundedRect(size, radius) {
x = size[0];
y = size[1];
z = size[2];

linear_extrude(height=z)
hull() {
translate([radius, radius, 0])
circle(r=radius);

translate([x - radius, radius, 0])
circle(r=radius);

translate([x - radius, y - radius, 0])
circle(r=radius);

translate([radius, y - radius, 0])
circle(r=radius);
}
}

