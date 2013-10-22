
use <moreShapes.scad>

perim = 0.7;
2perim = 2*perim;
4perim = 4*perim;

eta = 0.001;


// global vars


	r1 = 8/2;
	r2 = 8/2 + 2perim;
	r3 = 4/2;
	
	r4 = r1 - 2perim;
	
	tipR = 2/2;
	
	// relative to z=0
	h1 = 8;
	h2 = 8+2perim;
	h3 = 16;


	$fn=24;

module nozzle() {

	

	difference() {
		union() { 
			cylinder(h=h1, r=r1);
			
			// lip
			translate([0,0,h1-eta]) cylinder(h=h2-h1+eta, r1=r1, r2=r2);
			
			// taper
			translate([0,0,h2-eta]) cylinder(h=h3-h2, r1=r2, r2=r3);
		}
		
		// bore
		translate([0,0,-eta]) cylinder(h=h3+2*eta, r1=r4, r2=tipR);
		
		// chamfer inlet
		translate([0,0,-eta]) cylinder(h=4perim, r1=r1-perim, r2=r4-0.4);
		
		
		// section
		*translate([0,0,-1]) cube([100,100,100]);
	}	
}

module sprayNozzle() {
	difference() {
		union() {
			nozzle();
			
			translate([0,0,h3-eta]) cylinder(h=2perim, r=r3);
			
		}
		
		// notch spray tip
		translate([0,0,h3]) rotate([-90,0,0]) trapezoidPrism(2*tipR,tipR,4perim+eta,-tipR/2,10, center=true);
		
		// section
		*translate([0,0,-1]) cube([100,100,100]);
	}
}

module sprayNozzle2() {
	difference() {
		union() {
			nozzle();
			
			
		}
		
		// extra nozzle holes
		for (i=[0:2])
			rotate([0,0,i*360/3])
			translate([0,0,h1-1]) rotate([0,30,0]) scale([0.6,1.2,1]) cylinder(h=h3-h2+1, r1=1.7*tipR, r2=tipR);
			
		// widen internal bore
		translate([0,0,-eta]) cylinder(h=h2+2*eta, r1=r4, r2=r3);
		translate([0,0,h2]) cylinder(h=(h3-h2)+2*eta, r1=r3, r2=tipR);
		
		
		// section
		*translate([-50,0,-1]) cube([100,100,100]);
	}
}

//translate([20,0,0]) nozzle();
//translate([-20,0,0]) sprayNozzle();

//sprayNozzle2();


module manifoldNozzle() {

	mOD = 15;
	mID = 13;
	
	
	r1 = 8/2;
	r2 = 8/2 + 2perim;
	r3 = 4/2;
	
	r4 = r1 - 2perim;
	
	tipR = 2/2;
	
	// relative to z=0
	h1 = 20;
	h2 = 20+2perim;
	h3 = 30;
	
	

	union() {
		difference() {
			union() { 
				cylinder(h=h1, r=r1);
			
				// lip
				translate([0,0,h1-eta]) cylinder(h=h2-h1+eta, r1=r1, r2=r2);
			
				// taper
				translate([0,0,h2-eta]) cylinder(h=h3-h2, r1=r2, r2=r3);
				
				// flange
				intersection() {
					cylinder(h=mOD/2+2perim, r=r1 + 4perim);
					translate([-50,0,0]) rotate([0,90,0]) cylinder(h=100, r=mOD/2+2perim);
					translate([0,0,50 + mID/2-2perim]) cube([mID, mID, 100],center=true);
				}
			}	
		
			// bore
			translate([0,0,-eta]) cylinder(h=h3+2*eta, r1=r4, r2=tipR);
		
			// remove manifold
			translate([-50,0,0]) rotate([0,90,0]) cylinder(h=100, r=mOD/2);
		}
		
		// add interior tube
		translate([0,0,mID/2-2perim]) difference() {
			cylinder(h=4*perim, r=r1);
			translate([0,0,-eta]) cylinder(h=4*perim+2*eta, r1=r4, r2=r3);
		}
	}

	// show manifold
	color([1.0,1.0,1.0,0.3]) translate([-50,0,0]) rotate([0,90,0]) difference() {
			cylinder(h=100, r=mOD/2);
			translate([0,0,-1]) cylinder(h=102, r=mID/2);
		}

}



manifoldNozzle();

