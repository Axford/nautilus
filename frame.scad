use_realistic_colors = true;
simplify = false;    // reduces complexity of some parts, e.g. alu extrusions

include <bom.scad>
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
use <curvedPipe.scad>


perim = 0.7;
layers = 0.3;
2perim = 2*perim;
4perim = 4*perim;

frameProfileW = 20;

//bottle 
bottleD = 68.4;
bottleH = 260;

//crate
bottlesWide = 4;
bottlesDeep = 3;
bottleCentres = bottleD +5;
crateW = bottlesWide * bottleCentres + 10;
crateD = bottlesDeep * bottleCentres + 10;
crateH = bottleH + 10;

// external dimensions
frameW = crateW + 5 + 2*frameProfileW;  

frameD = crateD * 5/3;
frameSideCentres = 2 * bottleD - frameProfileW;  // distance between centres of side frames

sumpD = bottleD * 2 + 15;
sumpH = 50;
sumpW = frameW - 2*frameProfileW;

frameShelfH1 = 110; 

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

// sumpPump
sumpPumpW = 70;
sumpPumpH = 49;
sumpPumpD = 45;
sumpPumpImpW = 12;
sumpPumpInD = 13.8;
sumpPumpOutD = 8.7;


// silicone inlet tube, sized to have same cross-section area as the four pump tubes
inletTubeOD = 12;
inletTubeID = 8;
inletTubeWall = 2;

// inlet manifold
inletCentres = 32;   // spacing between inlet nozzles

silicone_color = [1,0.2,0.2,1];
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
		*rotate([0,0,i*180]) translate([0,0,0]) {
			translate([-frameW/2,-sumpD/2 -1.5,frameProfileW]) rotate([90,0,90]) aluExtL(w=20,h=20,l=frameW);
		}
	}

	// sump backstop
	translate([-frameW/2,(frameSideCentres + frameProfileW)/2,frameProfileW]) rotate([90,0,90]) aluExtL(w=20,h=20,l=frameW);

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
	color(silicone_color) union() {
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
	inletOffset = (pumpTubes-1) * inletCentres / 2;
	pumpTubeX = (pumpTubes-1 )* pumpTubeOffset / 2;

	translate([-l/2,0,0]) rotate([0,90,0]) {
		microborePipe(l=l);
		translate([0,0,l-9]) microboreCap();
	}
	

	// pump inlets
	for (i=[0:pumpTubes-1]) {
		translate([-inletOffset + i*inletCentres,0,0]) rotate([0,0,0]) {
			microboreT();
			translate([0,0,10]) microborePipe(l=20);
			translate([0,0,22]) microboreNozzle();
		}
	}

	// pipework
	for (i=[0:pumpTubes-1]) {
		color(silicone_color) curvedPipe(points=[ 
			[i*pumpTubeOffset - pumpTubeX,60,41],
			[i*pumpTubeOffset - pumpTubeX,40,41],
			[-inletOffset + i*inletCentres,1,70],
			[-inletOffset + i*inletCentres,0,36]
		   ],
            segments=3,
			radii=[10,10],
		    od=pumpTubeOR*2,
			id=pumpTubeOR-pumpTubeWall, $fn=12);
	}
}

module washManifold() {
	vOffset = 40; 

	//translate([-frameW/2,0,0]) cube([frameW,10,1]);


	translate([0,0,-vOffset]) {
		translate([-frameW/2 + 30, 0, 0]) rotate([0,90,0]) microborePipe(frameW-30);
	
		for (i=[0:bottlesWide-1]) translate([i*bottleCentres - (bottlesWide-1)/2*bottleCentres,0,0]) {
			microboreT();
			translate([0,0,12]) microboreNozzle(od=9,nod=7);
		}
	}
}

module sumpPump() {
	color([0.2,0.2,0.2]) union() {	
		// motor
		translate([sumpPumpImpW,0,sumpPumpH/2]) rotate([0,90,0]) cylinder(h=sumpPumpW-sumpPumpImpW, r=sumpPumpD/2);
		
		// bracket
		translate([sumpPumpImpW,-sumpPumpD/2,0]) difference() {
			cube([sumpPumpW-sumpPumpImpW, sumpPumpD, 3]);

			// mounting screw holes
			translate([sumpPumpW/2-5,sumpPumpD/2,0])
			for (i=[0:3]) rotate([0,0,i*90]) {
				translate([sumpPumpD/2-3,sumpPumpD/2-3,-1]) cylinder(h=10, r=4/2);
			}
		}
		translate([sumpPumpImpW,-sumpPumpD/2,0]) cube([5, sumpPumpD, sumpPumpH]);
		 

		// impeller
		translate([0,0,sumpPumpH/2]) rotate([0,90,0]) cylinder(h=sumpPumpImpW+1, r=sumpPumpD/2-3);

		// inlet
		translate([-12,0,sumpPumpH/2]) rotate([0,90,0]) difference() {
			cylinder(h=12, r=sumpPumpInD/2);
			translate([0,0,-1]) cylinder(h=14, r=sumpPumpInD/2-1);
		}

		// outlet
		translate([sumpPumpImpW/2,-sumpPumpD/4,sumpPumpH/2]) difference() {
			cylinder(h=sumpPumpH/2+5, r=sumpPumpOutD/2);
			translate([0,0,-1]) cylinder(h=sumpPumpH, r=sumpPumpOutD/2-1);
		}

	}
}

module sumpPumpAssembly(sumpPumpArmPos=1) {
	//sumpPumpArmPos = 0:1  - 0 = up, 1 = down
	sumpPumpArm = sumpPumpArmPos * -19;   //  angle of sump pump arm   0,  -18
	
	pivotX = 	frameW/2 -10;
	pivotY = -2;
	pivotZ = sumpPumpD/2-6;

	// offset to pump tube 
	ptX = pivotX + 6;

	// start of tube
	tubeX = -6 + (ptX - ptX*cos(sumpPumpArm));
	tubeY = pivotY - frameSideCentres/2 - frameProfileW/2 + sumpPumpD/4 + 2;
	tubeZ = pivotZ + frameShelfH1 - sumpPumpD/2 + ptX*sin(sumpPumpArm);

	// end of tube
	tubeEX = -frameW/2+frameProfileW + 20;
	tubeEY = 0;
	tubeEZ = frameShelfH1 -40;

  
	translate([pivotX,pivotY - frameSideCentres/2 - frameProfileW/2 ,pivotZ - sumpPumpD/2 + frameShelfH1-5]) rotate([0,sumpPumpArm,0]) translate([-pivotX,-pivotY,-pivotZ]) {
		translate([0,0,sumpPumpD/2+2]) mirror([0,1,0]) rotate([0,90,0]) aluExtL(w=15,d=15,l=frameW/2);
		translate([-12,sumpPumpD/2,-sumpPumpH/2]) rotate([0,0,0]) sumpPump();

		// pivot screw
		translate([pivotX,pivotY,pivotZ]) rotate([90,0,0]) screw(M5_cap_screw, 10);
	}

	

	// pump tube
		color(silicone_color) curvedPipe(points=[ 
			[tubeX,tubeY, tubeZ],
			[tubeX + 50*sin(sumpPumpArm) ,tubeY,tubeZ + 40],
			[tubeX - 60,tubeY+13,(tubeZ + tubeEZ)/2 +25],
			[tubeEX -40,-20,tubeEZ],
			[tubeEX - 40, tubeEY, tubeEZ],
			[tubeEX, tubeEY, tubeEZ],
			[0,100,50],
			[0,0,0],
			[50,0,0]
		   ],
            segments=5,
			radii=[20,30,10,10,1,30],
		    od=11,
			id=8, $fn=12);
}	


module machine(pumpRot=0, showCrate=true, showSump=true, showPump=false, sumpPumpArmPos=0) {
	frame(pumpRot, showPump);

	translate([0,-40,pumpZ + pumpRailCentres - frameProfileW-40]) inletManifold();

	if (showPump) translate([0,(frameSideCentres)/2,pumpZ]) pumpAssembly(pumpRot);
	
	if (showSump) translate([0,-(sumpD - frameSideCentres - frameProfileW)/2,0]) sump();

	translate([0,0,frameShelfH1]) washManifold();

	sumpPumpAssembly(sumpPumpArmPos = sumpPumpArmPos);
	
	if (showCrate) translate([0,0,frameShelfH1+1.5]) crateOfBottles();
}


machine(pumpRot=0, showCrate=false, showSump=true, showPump=true, sumpPumpArmPos=1);



// calculate total extrusion requirements
echo("Frame extrusions: ");
echo(frameH - frameProfileW, " x 4");
echo(frameW - 2*frameProfileW, " x 2");
echo(frameSideCentres - frameProfileW, " x 2");



