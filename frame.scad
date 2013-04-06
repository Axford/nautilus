use_realistic_colors = true;
simplify = false;    // reduces complexity of some parts, e.g. alu extrusions

include <config.scad>
include <colors.scad>
include <valueframe.scad>
include <stepper-motors.scad>
include <ball-bearings.scad>
include <screws.scad>
include <washers.scad>
include <nuts.scad>
use <parametric_involute_gear_v5.0.scad>
use <gear_calculator.scad>
use <roundedRect.scad>
use <2DShapes.scad>


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

gearCentres = 40;
cp = fit_spur_gears(11,39,gearCentres);
gearOffset = gearCentres - pitch_diameter(11,cp);
bigGearOD = 2*outer_radius(39,cp) + 8;

pumpZ = frameShelfH1 + crateH + 30;
pumpRailCentres = bigGearOD + frameProfileW + 15;
pumpRotorOffset = 22;
pumpRotorArms = 3;
pumpRollerD = 25;
pumpRollerWall = 1;

pumpTubeOR = 8/2;
pumpTubeWall = 2;
pumpTubeIR = pumpTubeOR - pumpTubeWall;
pumpTubeCompW = 2*PI*pumpTubeOR/2 - pumpTubeWall*2;  //width when fully compressed

pumpTubes = 4;
pumpTubeCasingW = pumpTubeCompW + 2*4perim;
pumpTubeOffset = pumpTubeCasingW + 1;

pumpTubeRollerW = pumpTubes * (pumpTubeOffset) + 5; 


// silicone inlet tube, sized to have same cross-section area as the four pump tubes
inletTubeOD = 12;
inletTubeID = 8;
inletTubeWall = 2;

// inlet manifold
inletCentres = 32;   // spacing between inlet nozzles

microbore_color = [0.8,0.65,0.4,1];



frameH = pumpZ + pumpRailCentres + frameProfileW/2; 

mRot = 0;	


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

	translate([0,(frameSideCentres)/2,pumpZ]) {
		translate([-frameW/2+frameProfileW,0,0]) rotate([90,0,90]) valueFrameProfile(P5_20x20,l=frameW - 2*frameProfileW);
		translate([-frameW/2+frameProfileW,0,pumpRailCentres]) rotate([90,0,90]) valueFrameProfile(P5_20x20,l=frameW - 2*frameProfileW);
	}
}

module smallGear(cp=270) {
	hd = 2*outer_radius(11,cp);

	difference() {
		union() {
			gear (circular_pitch=cp, number_of_teeth=11, gear_thickness = 9, rim_thickness = 9, rim_width=3, hub_thickness = 18, hub_diameter=hd, bore_diameter=5, circles=0);
		}

		// need to add nut trap and bolt hole
		translate([0,-hd/4,16])cube([5.5,2.3,9],center = true);
		translate([0,0,14])rotate([0,90,-90])cylinder(r=1.7,h=20);
	}
}



module bigGear(cp=270) {
	circles = 6;

	difference() {
		union () {
			// hub
			translate([0,0,-7]) cylinder(h=14+7, r2=10, r1=5);
	
			difference() {
				cylinder(h=15, r=bigGearOD/2);
				translate([0,0,-1]) gear (circular_pitch=cp, number_of_teeth=39, gear_thickness = 12, rim_thickness = 12, rim_width=3, hub_thickness = 12, hub_diameter=12, bore_diameter=0, circles=0);
		
				// remove circles, aligned to pumpRotor M8 cap screws
				for(i=[0:circles-1]) rotate([0,0,i*360/circles + 360/circles/2]) {
					translate([0,pumpRotorOffset,-1]) cylinder(h=20,r=screw_head_radius(M8_cap_screw) + perim);
				}
				
			}
		}

		// remove axle
		translate([0,0,-1]) axle();	
	}
}

module axle(l=100) {
	w = 5;
	color("silver") translate([-w/2,-w/2]) cube([w,w,l]);
}	

module axleBushing() {
	r = 10/2;
	h = 7.9;
	color(plastic) difference() {
		cylinder(h=h, r=r);
		translate([0,0,1]) b608();
		translate([0,0,-2]) axle();
	}
}


module NEMA17MountPlate(h=5) {
	// centred at origin, facing up
	difference() {
		translate([-NEMA17[0]/2,-NEMA17[0]/2,0]) roundedRect([NEMA17[0],NEMA17[0],h],5,$fn=12);

		// hollow out for smallGear
		translate([0,0,-1]) cylinder(h=h+2, r=12);

		// screw holes
		for(a = [0: 90 : 90 * (4 - 1)])
        		rotate([0, 0, a])
            		translate([NEMA17[8]/2, NEMA17[8]/2, -1])
					cylinder(h=h+2, r=3/2, $fn=8);
	}
}

module motorPlate() {
	// centred on pump axle
	w = 7;
	d = gearCentres + NEMA17[0]/2 + 30/2;
	h = pumpRailCentres-frameProfileW;

	difference() {
		union() {
			translate([2,0,-gearOffset]) rotate([0,90,0]) NEMA17MountPlate(h=w-2);
			bearingPlate();
		}

		// hollow out for bearing
		translate([-1,0,0]) rotate([0,90,0]) cylinder(h=w+2, r=22/2);

		// hollow out for smallGear
		translate([0,0,-gearOffset]) rotate([0,90,0]) translate([0,0,-1]) cylinder(h=h+2, r=12);
		
	}
}


module bearingPlate() {
	// centred on pump axle
	w = 7;
	d = gearCentres + NEMA17[0]/2 + 30/2;
	h = pumpRailCentres-frameProfileW;
	footH = 5;
	footScrewOffset = 2;
	footW = footScrewOffset + 8;

	difference() {
		union() {
			rotate([0,90,0]) cylinder(h=w, r=30/2);
			translate([0,-frameProfileW/2,-h/2]) cube([w,frameProfileW,h]);

			// feet
			for(i=[0,1]) rotate([i*180,0,0]) translate([0,0,h/2-footH]) {
				translate([-footW,-frameProfileW/2,0]) cube([footW+1,frameProfileW,footH]);
			}
		}

		// hollow out for bearing
		translate([-1,0,0]) rotate([0,90,0]) cylinder(h=w+2, r=22/2);

		for(i=[0,1]) rotate([i*180,0,0]) translate([0,0,h/2-footH]) {
			// fixing hole - m5
			translate([-footScrewOffset,0,-1]) rotate([0,0,0]) cylinder(h=footH+2, r=5/2);
					
			// countersink
			translate([-footScrewOffset,0,-4]) rotate([0,0,0]) cylinder(h=footH, r=9/2);
		}

		// weight loss - leave room for foot screws
		for(i=[0,1]) rotate([i*180,0,0]) translate([-1,-frameProfileW/4,h/2-footH]) {
			rotate([0,90,0]) roundedRect([h/3,frameProfileW/2,2*w],3);
		}
	}

	// screws
	for(i=[0,1]) rotate([i*180,0,0]) translate([-footScrewOffset,0,h/2-footH+1]) {
		mirror([0,0,1]) screw(M5_cap_screw,12);
	}
}

module pumpRotor() {
	arms = pumpRotorArms;
	armW = 8+4perim;
	armD = 5;
	armL = pumpRotorOffset + 8/2 + 4perim;

	//rotate([0,90,0]) 
	difference() {
		union() {
			cylinder(h=armD, r=30/2);
			cylinder(h=3*armD,r1=20/2, r2=12/2);

			// outer reinforcement
			hull() for (i=[0:arms-1]) rotate([0,0,i*360/arms]) translate([pumpRotorOffset,0,0]) cylinder(h=armD, r=8/2 + 6*perim);
					
			// arms - redundant
			*for (i=[0:arms-1]) rotate([0,0,i*360/arms]) {
				difference() {
					union() {
						translate([0,-armW/2,0]) roundedRect([armL,armW,armD],3,$fn=12);
						translate([pumpRotorOffset,0,0]) cylinder(h=armD, r=8/2 + 6*perim);
					}

					
				}
			}
		}

		// remove axle
		translate([0,0,-10]) axle();

		// bearing mounts - M8
		for (i=[0:arms-1]) rotate([0,0,i*360/arms]) translate([pumpRotorOffset,0,-1]) cylinder(h=armD+2, r=8/2);
	}

	// screws and bearings
	for (i=[0:arms-1]) rotate([0,0,i*360/arms]) translate([pumpRotorOffset,0,0]) {
		translate([0,0,-washer_thickness(M8_washer)]) mirror([0,0,1]) screw(M8_cap_screw, 25);
		translate([0,0,-washer_thickness(M8_washer)]) washer(M8_washer);
		translate([0,0,armD]) { 
			washer(M8_washer);
			translate([0,0,washer_thickness(M8_washer) + ball_bearing_width(BB608)/2]) {
				ball_bearing(BB608);
				translate([0,0,ball_bearing_width(BB608)/2]) {
					washer(M8_washer);
					translate([0,0,washer_thickness(M8_washer)]) nut(M8_nut);
				}
			}
		}
	}
}

module pumpRollerCap() {
	// bearing support caps
	h = ball_bearing_width(BB608) + 8*layers;

	difference() {
		union() {
			cylinder(h=4*layers, r=pumpRollerD/2);
			cylinder(h=h, r=pumpRollerD/2 - pumpRollerWall);
		}	
		
		translate([0,0,-1]) cylinder(h=h-4*layers+1, r=ball_bearing_diameter(BB608)/2);

		translate([0,0,-1]) cylinder(h=h+2, r=ball_bearing_diameter(BB608)/2 - 2perim);
	}
}

module pumpRoller(l=100) {
	// roller tube and caps
	// origin aligned, pointing along x+
	color("grey") rotate([0,90,0]) difference() {
		cylinder(h=l, r=pumpRollerD/2);
		translate([0,0,-1])  cylinder(h=l+2, r=pumpRollerD/2 - pumpRollerWall);
	}

	// caps
	translate([-4*layers,0,0]) rotate([0,90,0]) pumpRollerCap();
	translate([l+4*layers,0,0]) rotate([0,-90,0]) pumpRollerCap();
}

module pumpRotorAssembly() {
	rollerW = pumpTubeRollerW;

	rotate([0,-90,0]) pumpRotor();

	translate([-rollerW - 16,0,0]) mirror([1,0,0]) rotate([0,-90,0]) pumpRotor();

	// rollers
	for (i=[0:pumpRotorArms-1]) rotate([i*360/pumpRotorArms,0,0]) translate([-rollerW - 8,0,pumpRotorOffset]) 
		pumpRoller(rollerW);
}

module pumpTube(l=50) {
	// centred, aligned on z axis
	// l indicates straight length
	r = pumpRotorOffset + pumpRollerD/2 - (pumpTubeOR - 2*pumpTubeWall);
	or = r + 2*pumpTubeOR;
	color([1,0.2,0.2,0.6]) union() {
		difference() {
			rotate_extrude(convexity = 10)
				translate([r, 0, 0])
				circle(r = pumpTubeOR);
	
			// cut in half
			translate([-or-1,-or-1,-pumpTubeOR-1]) cube([or*2+2,or+1,2*pumpTubeOR+2]);
		}

		// straight extensions
		for (i=[0:1]) rotate([0,i*180,0]) {
			translate([r,0.1,0]) rotate([90,0,0]) cylinder(h=l, r=pumpTubeOR);
		}
	}
}

module pumpTubeCasingBack() {
	w = pumpTubeCasingW;
	or = (pumpRailCentres - frameProfileW)/2;
	ir = pumpRotorOffset + pumpRollerD/2 + 2*pumpTubeWall;
	ir2 = pumpRotorOffset + pumpRollerD/2 + 1;
	difference() {
		union() {
			// curved casing
			translate([0,0,-w/2]) linear_extrude(height=w) pieSlice(or,0,180);

			// mounting feet
			for(	i=[0,1]) rotate([0,i*180,0]) {
				difference() {
					translate([or - 5, + frameProfileW/2,-w/2]) cube([frameProfileW+2,5,w]);
					translate([or + frameProfileW/2, + frameProfileW/2-1,0]) rotate([-90,0,0]) cylinder(h=7,r=5/2);
				}
			}
		}
	
		// remove tubeway
		translate([0,0,-pumpTubeCompW/2]) cylinder(h=pumpTubeCompW, r=ir);

		// remove bore
		translate([0,0,pumpTubeCompW/2 - 0.5]) cylinder(h=4perim + 1, r1=ir, r2=ir2);
		mirror([0,0,1]) translate([0,0,pumpTubeCompW/2 - 0.5]) cylinder(h=4perim + 1, r1=ir, r2=ir2);
	}

	// screws
	for(	i=[0,1]) rotate([0,i*180,0]) translate([or + frameProfileW/2, frameProfileW/2+5,0]) rotate([-90,0,0]) screw(M5_cap_screw,8);
}

module pumpTubeCasingFront() {
	w = pumpTubeCasingW;
	or = (pumpRailCentres - frameProfileW)/2;
	ir = pumpRotorOffset + pumpRollerD/2 + 2*pumpTubeWall;
	ir2 = pumpRotorOffset + pumpRollerD/2 + 1;
	d = ir + frameProfileW/2;
	difference() {
		union() {
			for(	i=[0,1]) rotate([0,i*180,0]) {
				// casing
				translate([ir,-d + frameProfileW/2,-w/2]) cube([or-ir,d,w]);

				// mounting feet
				difference() {
					translate([or - 5, - frameProfileW/2-5,-w/2]) cube([frameProfileW+2,5,w]);
					translate([or + frameProfileW/2, - frameProfileW/2-6,0]) rotate([-90,0,0]) cylinder(h=7,r=5/2);
				}
			
				// hose clips
				difference() {
					translate([or - pumpTubeOR/2 - 4 - (or-ir), -ir,-w/2]) cube([pumpTubeOR + 2 + 2,5,w]);
					translate([or - pumpTubeOR/2 - 2 - (or-ir), -ir-1,0]) rotate([-90,0,0]) cylinder(h=7,r=pumpTubeOR);
				}
			}
		}
	
		
	}

	// screws
	for(	i=[0,1]) rotate([0,i*180,0]) translate([or + frameProfileW/2, -frameProfileW/2-5,0]) rotate([90,0,0]) screw(M5_cap_screw,8);
}

//translate([0,0,frameH]) pumpTubeCasingFront();


module pumpAssembly(pumpRot=0) {

	translate([pumpTubeRollerW/2 + 21,0,pumpRailCentres/2]) {
	
		rotate([mRot,0,0]) translate([19,0,-gearOffset]) rotate([0,-90,0]) {
			translate([0,0,19]) rotate([180,0,0]) rotate([0,0,pumpRot *39/11]) smallGear(cp);
			rotate([0,0,mRot]) translate([0,0,-5]) NEMA(NEMA17);
			
			// motor screws
			for(a = [0: 90 : 90 * (4 - 1)])
        			rotate([0, 0, a])
            		translate([NEMA17[8]/2, NEMA17[8]/2, 0])
				screw(M4_hex_screw,8);
		}
	
		translate([17,0,0]) {
			motorPlate();
			translate([BB608[2]/2,0,0]) rotate([0,90,0]) ball_bearing(BB608);
			translate([-1,0,0]) rotate([0,90,0]) axleBushing();
		}
		translate([-pumpTubeRollerW-50,0,0]) {
			translate([7,0,0]) mirror([1,0,0]) bearingPlate();
			translate([BB608[2]/2,0,0]) rotate([0,90,0]) ball_bearing(BB608);
			translate([0,0,0]) rotate([0,90,0]) axleBushing();
		}

		rotate([pumpRot,0,0]) {

			translate([8,0,0]) rotate([0,-90,0]) bigGear(cp);
	
			translate([24,0,0]) rotate([0,-90,0]) axle(l=pumpTubeRollerW + 75);
	
			translate([-13,0,0]) pumpRotorAssembly();

		}

		// pump tubes
		for (i=[0:pumpTubes-1]) {
		
			translate([-31 - i*pumpTubeOffset,0,0]) rotate([0,90,0]) {
				pumpTube();
				pumpTubeCasingBack();
				pumpTubeCasingFront();
			}

		}

	}
}

module microborePipe(l=100, od=10) {
	color(microbore_color) difference() {
		cylinder(h=l, r=od/2);
		translate([0,0,-1]) cylinder(h=l+2, r=od/2-1);
	}
}

module microboreCap(od=10) {
	color(microbore_color) difference() {
		cylinder(h=od, r=od/2+1);
		translate([0,0,-1]) cylinder(h=od, r=od/2);
	}
}

module microboreT(od=10) {
	// T points up z axis
	color(microbore_color) union() {
		microborePipe(l=20, od=od+2);
		translate([-15,0,0]) rotate([0,90,0]) microborePipe(l=30, od=od+2);
	}
}

module microboreNozzle(l=25, od=10, nod=4) {
	// nod = nozzle outer diameter
	color(microbore_color) difference() {
		union() {
			cylinder(h=od, r=od/2+1);
			translate([0,0,od]) cylinder(h=(l-od)/2, r1=od/2+1, r2=nod/2);
			cylinder(h=l, r=nod/2);
		}
		translate([0,0,-1]) cylinder(h=l+2, r=nod/2-0.2);
	}
}



//translate([0,0,frameH]) microboreT();

module inletManifold() {
	l = frameW;
	inletOffset = pumpTubes * inletCentres / 2;

	translate([-l/2,0,0]) rotate([0,90,0]) {
		microborePipe(l=l);
		translate([0,0,l-9]) microboreCap();
	}
	

	// pump inlets
	for (i=[0:pumpTubes-1]) {
		translate([-inletOffset +15 + i*inletCentres,0,0]) rotate([-45,0,0]) {
			microboreT();
			translate([0,0,10]) microborePipe(l=20);
			translate([0,0,22]) microboreNozzle();
		}
	}
}


module machine(pumpRot=0, showCrate=true, showSump=true, showPump=false) {
	frame(pumpRot, showPump);

	translate([0,-40,pumpZ + pumpRailCentres - frameProfileW-40]) inletManifold();

	if (showPump) translate([0,(frameSideCentres)/2,pumpZ]) pumpAssembly(pumpRot);
	
	if (showSump) translate([0,0,frameProfileW+1.5]) sump();
	
	if (showCrate) translate([0,0,frameShelfH1+1.5]) crateOfBottles();
}


machine(pumpRot=0, showCrate=false, showSump=false, showPump=true);



// calculate total extrusion requirements
echo("Frame extrusions: ");
echo(frameH - frameProfileW, " x 4");
echo(frameW - 2*frameProfileW, " x 2");
echo(frameSideCentres - frameProfileW, " x 2");



