use_realistic_colors = true;
simplify = false;    // reduces complexity of some parts, e.g. alu extrusions

silicone_color = [1,0.2,0.2,1];
microbore_color = [0.8,0.65,0.4,1];

include <bom.scad>
include <config.scad>
include <colors.scad>
include <aluminiumProfiles.scad>
include <stepper-motors.scad>
include <ball-bearings.scad>
include <screws.scad>
include <washers.scad>
include <nuts.scad>
use <parametric_involute_gear_v5.0.scad>
use <gear_calculator.scad>
use <roundedRect.scad>
use <2DShapes.scad>
use <maths.scad>
use <vector.scad>
use <curvedPipe.scad>
use <microbore.scad>
use <moreShapes.scad>

perim = 0.7;
layers = 0.3;
2perim = 2*perim;
4perim = 4*perim;
eta = 0.001;

frameProfileW = 20;
fpw = frameProfileW;  // short-hand

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
//frameSideCentres = 2 * bottleD - frameProfileW;  // distance between centres of side frames
frameSideCentres = 100 + fpw;

sumpD = bottleD * 2 + 15;
sumpH = 50;
sumpW = frameW - 2*frameProfileW;

frameShelfH1 = 110; 

gearCentres = 40;
cp = fit_spur_gears(11,39,gearCentres);
gearOffset = gearCentres - pitch_diameter(11,cp);
bigGearOD = 2*outer_radius(39,cp) + 2*4perim;

pumpZ = frameShelfH1 + crateH + 30;
pumpH = 100;  // overall height of pump assembly (above pumpZ)

pumpRailCentres = frameSideCentres;
pumpZOffset = 50;
pumpRotorOffset = 22;
pumpRotorArms = 3;
pumpRollerD = 25;
pumpRollerWall = 1;

pumpTubeOR = 10/2;
pumpTubeWall = 1;
pumpTubeIR = pumpTubeOR - pumpTubeWall;
pumpTubeCompW = 15;  //width when fully compressed

pumpTubes = 4;
pumpTubeCasingW = pumpTubeCompW + 4perim;
pumpTubeOffset = pumpTubeCasingW + 1;

pumpTubeRollerW = pumpTubes * (pumpTubeOffset) + 5; 
echo("pumpTubeRollerW",pumpTubeRollerW + 75);

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

washManifoldZOffset = -44;

// dims of t-section profile for crate shelf
crateShelfW = 20;
crateShelfH = 20;
crateShelfT = 1.5 + 0.5;  // 1.5 nominal plus tolerance



function washManifoldAng(washManifoldHandlePos) = washManifoldHandlePos * (16 + 12) - 12; 
function washManifoldZOffset2(washManifoldAng) = washManifoldZOffset +  frameSideCentres/2 * sin(washManifoldAng)   +  16 * cos(washManifoldAng);


// frame height!

frameH = pumpZ + pumpH; 

mRot = 0;	

echo("frameD",frameD);
echo("CrateW", crateW);


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
	color("grey") translate([-sumpW/2+3,-sumpD/2,0]) difference() {
		cube([frameW - 2*frameProfileW-6,sumpD,sumpH]);
		translate([1,1,1]) cube([sumpW-2-6,sumpD-2,sumpH]);
	}
}

module aluExtL(w=10,h=10,l=100,thickness=1.5) {
	color("silver") translate() union() {
		cube([w,thickness,l]);
		cube([thickness,h,l]);
	}
}


module panelButton() {
	// points up z, origin is level with surface of panel
	
	color("silver") cylinder(r1=26/2, r2=24/2, h=3);
	color([0,1.0,0]) cylinder(r=18/2, h=5);
	
	color("black") translate([0,0,-20]) cylinder(r=20/2, h=20);
}


module frameCover() {
	// mock-up of dibond cover sheeting
	
	headW = frameW + 30;
	headD = frameSideCentres + fpw;
	headH = 100;
	
	sideW = (headW - frameW)/2 + fpw;
	sideH = frameH - headH - fpw;
	
	color([0.3,0.3,0.3]) {
	
		/////////////   head
		
		//top
		translate([0,0,frameH + 1.5]) cube([headW, headD, 3],center=true);
		for (i=[-1,1]) {
			// front/back
			translate([0,i*(frameSideCentres/2+fpw/2+1.5),frameH-headH/2]) 
				cube([headW,3,headH],center=true);
		
			// bottom
			translate([0,i*(frameSideCentres/2+fpw/2+1.5 - headD/4),frameH-headH]) 
				cube([headW-2*fpw,headD/2-1,3],center=true);
				
		}
	
		////////// sides
		for (i=[0,1]) mirror([i,0,0]) translate([headW/2,0,0]) {
			
			// outside
			translate([-1.5,0,(frameH-fpw)/2 + fpw]) cube([3, headD, frameH-fpw], center=true);
		
			// front
			difference() {
				translate([-sideW,-headD/2-3,fpw]) cube([sideW,3,sideH]);
				
				translate([-17,-headD/2-5,50]) roundedRectY([15,10,60],3);
			}
			
			// back
			translate([-sideW,headD/2,fpw]) cube([sideW,3,sideH]);
			
			// inside
			difference() {
				translate([-sideW-1.5,0,(sideH+fpw)/2]) cube([3, headD, sideH+fpw], center=true);
				
				// wash manifold slots
				translate([-sideW-5,-8,50]) roundedRectX([15,16,60],3);
			}
		}
	
	}
	
	/////////// buttons
		for (i=[-1,1])
			translate([i*20,-headD/2-3,frameH-25]) rotate([90,0,0]) panelButton();
}


module frame() {

	for (i=[0:1]) {
		// side frames
		rotate([0,0,i*180]) translate([(frameW - 2*frameProfileW)/2+frameProfileW/2,0,0]) {
			// vertical struts
			for (j=[0:1]) rotate([0,0,j*180]) translate([0,frameSideCentres/2,frameProfileW]) {
				rotate([0,0,j*180]) aluProExtrusion(BR_20x20,l=frameH-frameProfileW);
			}

			// feet
			translate([0,frameD/2,frameProfileW/2]) rotate([90,0,0]) rotate([0,0,90]) aluProExtrusion(BR_20x20_1S,l=frameD);

			// crate shelf
			translate([-10-3,-frameD/2,frameShelfH1]) rotate([90,0,180]) aluExtL(w=20,h=20,l=frameD);

			// tops
			translate([0,(frameSideCentres - frameProfileW)/2,frameH - frameProfileW/2]) rotate([90,0,0]) aluProExtrusion(BR_20x20,l=frameSideCentres - frameProfileW);
			
		} 

		// sump supports
		*rotate([0,0,i*180]) translate([0,0,0]) {
			translate([-frameW/2,-sumpD/2 -1.5,frameProfileW]) rotate([90,0,90]) aluExtL(w=20,h=20,l=frameW);
		}
	}

	// sump backstop
	translate([-frameW/2,(frameSideCentres + frameProfileW)/2+3,frameProfileW]) rotate([90,0,90]) aluExtL(w=20,h=20,l=frameW);

	// pump rails
	translate([0,0,pumpZ]) {
		translate([-frameW/2+frameProfileW,(frameSideCentres)/2,pumpZOffset]) rotate([90,0,90]) aluProExtrusion(BR_20x20,l=frameW - 2*frameProfileW);
		translate([-frameW/2+frameProfileW,-(frameSideCentres)/2,pumpZOffset]) rotate([90,0,90]) aluProExtrusion(BR_20x20,l=frameW - 2*frameProfileW);
	}
}

module smallGear(cp=270) {
	hd = 2*outer_radius(11,cp);

	difference() {
		union() {
			gear (circular_pitch=cp, number_of_teeth=11, gear_thickness = 9, 
					rim_thickness = 9, rim_width=3, hub_thickness = 18, hub_diameter=hd, 
					bore_diameter=6, circles=0);
		}

		// need to add nut trap and bolt hole
		translate([0,-hd/4,16])cube([5.5,2.3,9],center = true);
		translate([0,0,14])rotate([0,90,-90])cylinder(r=1.7,h=20);
	}
}



module bigGear(cp=270) {
	circles = 6;
	axw = 10.2;
	hubw = axw + 2*4perim;
	
	gearH = 10;
	h = gearH + 3;
	hubH = h + 4;
	
	difference() {
		union () {
			// hub
			//translate([0,0,0]) cylinder(h=14, r2=hubw/2+3, r1=hubw/2);
			translate([-hubw/2, -hubw/2, -(hubH-h)+1]) roundedRect([hubw, hubw, hubH-1],3, $fn=12);
	
			difference() {
				cylinder(h=h, r=bigGearOD/2);
				translate([0,0,-1]) gear (circular_pitch=cp, number_of_teeth=39, 
				  							gear_thickness = gearH, rim_thickness = gearH, 
				  							rim_width=3, hub_thickness = gearH, hub_diameter=gearH, 
				  							bore_diameter=0, circles=0);
		
				// remove circles, aligned to pumpRotor M8 cap screws
				for(i=[0:circles-1]) rotate([0,0,i*360/circles + 360/circles/2]) {
					translate([0,pumpRotorOffset,-1]) cylinder(h=20,r=screw_head_radius(M8_cap_screw) + perim, $fn=16);
				}
				
			}
		}

		// remove axle
		translate([0,0,0]) cube([axw,axw,100],center=true);	
	}
}

module axle(l=100) {
	w = 10;
	color("silver") translate([-w/2,-w/2]) cube([w,w,l]);
}	

module axleBushing() {
	r = (8 - 0.3)/2;
	h = 7;
	IW = 7.8 - (8.3-7.8);
	OW = IW + 2;
	
	
	color(plastic) difference() {
		union() {
			translate([-IW/2,-IW/2,0]) cube([IW,IW,h+eta]);
			translate([0,0,h]) cylinder(h=h, r=r);
			
			intersection() {
				translate([0,0,h-0.5]) rotate([-90,0,0]) trapezoidPrism(IW,OW,1,(OW-IW)/2,OW,center=true);
				translate([0,0,h-0.5]) rotate([0,-90,0]) rotate([0,0,90]) trapezoidPrism(IW,OW,1,(OW-IW)/2,OW,center=true);
			}
		}
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
					cylinder(h=h+2, r=3.5/2, $fn=12);
	}
}

module NEMA17ScrewClearance(h=5) {
	for(a = [0: 90 : 90 * (4 - 1)])
        rotate([0, 0, a])
    	translate([NEMA17[8]/2, NEMA17[8]/2, -h])
		cylinder(h=h, r=7/2, $fn=16);
}

module motorPlate() {
	// centred on pump axle
	w = 7;
	d = gearCentres + NEMA17[0]/2 + 30/2;
	h = pumpRailCentres-frameProfileW;
	shaftOffset = 37/2 - 11.2;
	
	gO = gearOffset - 1;

	union() {
		difference() {
			bearingPlate();		
			translate([-1,shaftOffset,-gO]) rotate([0,90,0]) cylinder(h=h+2, r=37/2);
		}
	
		difference() {
			translate([0,0,-gO]) rotate([0,90,0]) rotate([0,0,0]) gearMotorMountPlate(h=w);	
			
			// hollow for bearing
			translate([-1,0,0]) rotate([0,90,0]) cylinder(r=22/2, h=h+2);
		}
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
			translate([0,-frameProfileW/2,-h/2]) roundedRectX([w,frameProfileW,h],2.5);

			// feet
			for(i=[0,1]) rotate([i*180,0,0]) translate([0,0,h/2-footH]) {
				translate([-footW,-frameProfileW/2,0]) roundedRectX([footW+1,frameProfileW,footH],2.5);
			}
			
			// t slot and lug
			for(i=[0,1]) mirror([0,0,i]) {
				translate([w,0,-pumpRailCentres/2]) rotate([0,-90,0]) linear_extrude(height=5) aluProTSlot(BR_20x20);
				translate([-footW,0,pumpRailCentres/2-fpw/2-eta]) rotate([90,0,0]) right_triangle(4,3,5.5);
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
			rotate([0,90,0]) roundedRect([h/3.5,frameProfileW/2,2*w],3);
		}
	}

	// screws
	*for(i=[0,1]) rotate([i*180,0,0]) translate([-footScrewOffset,0,h/2-footH+1]) {
		mirror([0,0,1]) screw(M5_cap_screw,12);
	}
}

module pumpRotor() {
	arms = pumpRotorArms;
	armW = 8+4perim;
	armD = 4;
	armL = pumpRotorOffset + 8/2 + 4perim;
	
	axW = 10.2;
	hubW = axW + 2*4perim;
	
	bR = (8 - 0.3)/2;  // bearing IR
	

	//rotate([0,90,0]) 
	difference() {
		union() {
			// hun
			difference() {
				translate([0,0,armD*1.5]) cube([hubW,hubW,armD*3],center=true);
				
				// trim hub
				for (i=[0:arms-1]) rotate([0,0,i*360/arms]) 
					translate([pumpRotorOffset,0,armD+eta])
						cylinder(r=pumpRollerD/2+1, h=50);	
			}

			// outer reinforcement
			hull() for (i=[0:arms-1]) rotate([0,0,i*360/arms]) translate([pumpRotorOffset,0,0]) cylinder(h=armD, r=8/2 + 6*perim);
					
			// bearing mounts - M8
			for (i=[0:arms-1]) rotate([0,0,i*360/arms]) 
				translate([pumpRotorOffset,0,0]) 
				{
					cylinder(h=armD+2, r=bR + 2);
					translate([0,0,armD+2-eta]) cylinder(h=8, r=bR);
				}
		}

		// remove axle
		translate([0,0,0]) cube([axW,axW,100],center=true);
		
		// fixing screw hole
		translate([0,0,armD*2]) rotate([0,-90,0]) cylinder(h=100, r=3.5/2, $fn=12);
		
	}

	// screws and bearings
	*for (i=[0:arms-1]) rotate([0,0,i*360/arms]) translate([pumpRotorOffset,0,0]) {
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

module pumpRollerPrintableTube(l=50) {
	// bearing support caps
	h = ball_bearing_width(BB608) + 8*layers;
	h2 = h+4*layers;
	r1 = pumpRollerD/2;
	r2 = (ball_bearing_diameter(BB608)+0.3)/2;
	r3 = r2 + 2.1*perim;
	r4 = r1 - 2.1*perim;
	
	$fn = 32;

	difference() {
		union() {
			// core
			cylinder(h=l, r=r1);
			
			// bulk out over bearings
			cylinder(h=h, r=r3);
			translate([0,0,l-h]) cylinder(h=h, r=r3);
			
			// chamfer outer edges
			translate([0,0,h-eta]) cylinder(h=4perim, r1=r3, r2=r1);
			translate([0,0,l-h-4perim+eta]) cylinder(h=4perim, r2=r3, r1=r1); 
		}
		
		// hollow for bearings
		translate([0,0,-1]) cylinder(h=h+1, r=r2);
		translate([0,0,l-h]) cylinder(h=h+1, r=r2);

		// hollow the rest
		translate([0,0,-1]) cylinder(h=l+2, r=(r4));
		
		// chamfer internal edges
		translate([0,0,h-eta]) cylinder(h=4perim, r1=r2, r2=r4);
		translate([0,0,l-h-4perim+eta]) cylinder(h=4perim, r2=r2, r1=r4);
		
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
	ir = pumpRotorOffset + pumpRollerD/2 + 2*pumpTubeWall - 1;
	ir2 = pumpRotorOffset + pumpRollerD/2 -0.4;
	
	screwOffset = 7;  //  offset of screw centreline from surface of rail
	
	
	difference() {
		union() {
			// curved casing
			translate([0,0,-w/2]) linear_extrude(height=w) pieSlice(ir + 4perim,0,180);

			// mounting feet
			for(	i=[0,1]) mirror([i,0,0]) {
				difference() {
					union() {
						// wing
						translate([ir * cos(10), frameProfileW/2, -w/2]) cube([(or-ir + fpw)*cos(10),4perim,w],2);
						
						// prop block
						translate([ir,0,-w/2]) cube([or-ir,fpw/2+eta,w]);
						
						// lug
						translate([or + frameProfileW/2-(6/2), frameProfileW/2-3+eta,-w/2]) cube([6,3,w]);
					}
					
					// screw holes
					//translate([or + frameProfileW/2, + frameProfileW/2-10,0]) rotate([-90,0,0]) cylinder(h=20,r=5/2);
				}
				
				// fillet
				translate([0,0,-w/2]) linear_extrude(height=2perim)
					polygon(points=[[(ir+4perim) * cos(60),(ir+4perim) * sin(60)],
									[or+fpw-2,frameProfileW/2+2perim],
									[ir * cos(10) + 2perim, frameProfileW/2+2perim]], 
									paths=[[0,1,2]]);
				
				// vert fillet
				translate([0,0,-w/2]) linear_extrude(height=w)
					polygon(points=[[(ir+4perim) * cos(60),(ir+4perim) * sin(60)],
									[or+fpw-2,frameProfileW/2+2perim],
									[or+fpw-2,frameProfileW/2],
									[(ir+2perim) * cos(60),(ir+2perim) * sin(60)]], 
									paths=[[0,1,2,3]]);					
				
			}
			
			
		}
		
		for(i=[0,1]) mirror([i,0,0]) {
			// remove screw hole through to front casing - M4 screw
			translate([or - screwOffset,-10,0]) rotate([-90,0,0]) cylinder(r=4.5/2, h=100, $fn=12);
		
			// countersink screw head and allow for insertion clearance
			translate([or - screwOffset,11,0]) rotate([-90,0,0]) cylinder(r=8/2, h=100, $fn=12);
		}
	
		// remove tubeway
		translate([0,0,-pumpTubeCompW/2]) cylinder(h=pumpTubeCompW, r=ir);

		// remove bore
		translate([0,0,pumpTubeCompW/2 - 0.5]) cylinder(h=4perim + 1, r1=ir, r2=ir2);
		mirror([0,0,1]) translate([0,0,pumpTubeCompW/2 - 0.5]) cylinder(h=4perim + 1, r1=ir, r2=ir2);
	}

	// screws
	//for(	i=[0,1]) rotate([0,i*180,0]) translate([or + frameProfileW/2, frameProfileW/2+5,0]) rotate([-90,0,0]) screw(M5_cap_screw,8);
}

module pumpTubeCasingFront() {
	w = pumpTubeCasingW;
	or = (pumpRailCentres - frameProfileW)/2;
	ir = pumpRotorOffset + pumpRollerD/2 + 2*pumpTubeWall - 1;
	ir2 = pumpRotorOffset + pumpRollerD/2 + 1;
	d = ir + frameProfileW/2;
	clipH = w/2 + pumpTubeOR/2;
	
	screwOffset = 7;  //  offset of screw centreline from surface of rail
	
	difference() {
		union() {
			for(i=[0,1]) mirror([i,0,0]) {
				
				// prop block
				translate([ir,-11,-w/2]) cube([or-ir,10.5,w]);
				
				// curved casing
				translate([0,0,-w/2]) linear_extrude(height=w) pieSlice(ir + 4perim,-45,-1);
				
				// reverse casing
				translate([(2*ir+4perim)*cos(45),-(2*ir+4perim)*sin(45),-w/2]) linear_extrude(height=clipH) difference() {
					pieSlice(ir + 4*perim,134.5,180);
					circle(r=ir);
				}

				// wing
				translate([ir * cos(10), -frameProfileW/2-4perim, -w/2]) cube([(or-ir + fpw)*cos(10),4perim,w],2);
				
				// lug
				translate([or + frameProfileW/2 - (6/2), -frameProfileW/2-eta,-w/2]) cube([6,3,w]);
				
				
				// fillet
				translate([0,0,-w/2]) linear_extrude(height=w)
					polygon(points=[[(ir+4perim) * cos(58),-(ir+4perim) * sin(58)],
									[or+fpw-2,-(frameProfileW/2+2perim)],
									[ir * cos(10) + 2perim, -(frameProfileW/2+2perim)]], 
									paths=[[0,1,2]]);
				
				// hose clips
				translate([-eta, -(2*ir+4perim)*sin(45),-w/2])
					cube([(2*ir+4perim)*cos(45)-ir, 4perim, clipH]);
			}
			
			// joining piece
				difference() {
					translate([0,0,-w/2]) linear_extrude(height=w) difference() {
						pieSlice(ir + 4perim,225,315);
						circle(ir+eta);
					}
					
					// remove tubeway
					for(i=[0,1]) mirror([i,0,0])
						translate([(2*ir+4perim)*cos(45),-(2*ir+4perim)*sin(45),0])
						torusSlice(ir + 4perim + pumpTubeOR + eta, pumpTubeOR+0.5, 140, 170);
				}
		}
	
	
		// remove tubeway
		translate([0,0,-pumpTubeCompW/2]) cylinder(h=pumpTubeCompW, r=ir);

		// remove bore
		translate([0,0,pumpTubeCompW/2 - 0.5]) cylinder(h=4perim + 1, r1=ir, r2=ir2);
		mirror([0,0,1]) translate([0,0,pumpTubeCompW/2 - 0.5]) cylinder(h=4perim + 1, r1=ir, r2=ir2);
		
		// remove tubeway from clips
		for(i=[0,1]) mirror([i,0,0])
			translate([(2*ir+4perim)*cos(45),-(2*ir+4perim)*sin(45),0])
			torusSlice(ir + 4perim + pumpTubeOR + eta, pumpTubeOR, 175, 185);
			
		for(i=[0,1]) mirror([i,0,0]) {
			// remove screw hole through to front casing - M4 screw
			translate([or - screwOffset,10,0]) rotate([90,0,0]) cylinder(r=4.5/2, h=25, $fn=12);
		
			// nut trap
			
			translate([or - screwOffset,-10,0]) rotate([90,0,0]) rotate([0,0,360/12]) cylinder(r=8.5/2, h=3.5, $fn=6);
			translate([or - screwOffset - (7.5/2),-10 - 4,0]) cube([7.5,4,50]);
		}
	}

	// screws
	//for(	i=[0,1]) rotate([0,i*180,0]) translate([or + frameProfileW/2, -frameProfileW/2-5,0]) rotate([90,0,0]) screw(M5_cap_screw,8);
}

//translate([0,0,frameH]) pumpTubeCasingFront();


module pumpAssembly(pumpRot=0) {

	shaftOffset = 37/2 - 11.2;

	translate([pumpTubeRollerW/2 + 21,0,pumpRailCentres/2]) {
	
		rotate([mRot,0,0]) translate([19,0,-gearOffset]) rotate([0,-90,0]) {
			translate([0,0,19]) rotate([180,0,0]) rotate([0,0,pumpRot *39/11]) smallGear(cp);
			rotate([0,0,mRot]) translate([0,0,-5]) gearMotor();
			
			// motor screws
			for (i=[0:5])
			translate([0,shaftOffset,10]) 
			rotate([0,0,360/6*i])
			translate([31/2,0,-9])
				screw(M3_hex_screw,8);
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
				if (i < 2) pumpTube();
				pumpTubeCasingBack();
				if (i==0) pumpTubeCasingFront();
			}

		}

	}
}



module inletManifold() {
	l = frameW-2*frameProfileW;
	inletOffset = (pumpTubes-1) * inletCentres / 2;
	pumpTubeX = (pumpTubes-1 )* pumpTubeOffset / 2;

	vertL = pumpZ + pumpRailCentres - frameProfileW-100;

	translate([-l/2,0,0]) rotate([0,90,0]) {
		microborePipe(l=l) {
			microboreCap();
			
			// elbow and down pipe
			translate([0,0,-5]) rotate([0,0,180]) microboreElbow() microborePipe2(l=vertL) rotate([0,0,180]) microboreElbow2() microborePipe3(l=10) color(silicone_color) curvedPipe(points=[[0,0,-10],[0,0,80],[0,-frameD/2,100],[-500,-frameD/2,101]], segments=3, radii=[50,50,50],od=13, id=8, $fn=16);
		}
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

module washManifoldHandle(washManifoldAng) {

	translate([0,-frameSideCentres/2,washManifoldZOffset]) rotate([washManifoldAng,0,0]) translate([0,frameSideCentres/2,0])  {

		// handle
		color("silver") translate([-frameW/2,-frameD/2 + 5,0]) rotate([0,90,0]) cylinder(h=frameW, r=10/2);
		
		// handle screws
		for (i=[0:1]) mirror([i,0,0]) {
			translate([frameW/2+1.5,-frameD/2 + 5,0]) rotate([0,90,0]) {
				washer(M5_washer);
				translate(washer_thickness(M5_washer)) screw(M5_cap_screw, 10);
			}
		}


		// side arms
		for (i=[0:1]) mirror([i,0,0]) {
			//translate([frameW/2,-frameD/2,10]) rotate([-90,0,0]) aluExtL(10,20,frameD/2 + frameSideCentres/2);
			color("silver") translate([frameW/2,-frameD/2,10]) rotate([-90,0,0]) difference() {
				cube([10,20,frameD/2 + frameSideCentres/2]);
				translate([1.5,1.5,-1]) cube([7,17,frameD/2 + frameSideCentres/2+10]); 
				
				// handle screws
				translate([2,10,5]) rotate([0,90,0]) cylinder(r=5, h=20);
			}
		}

	}

	// screws
	for (i=[0:1]) mirror([i,0,0]) {
		translate([frameW/2+1.5,-frameSideCentres/2,washManifoldZOffset]) rotate([0,90,0]) {
			washer(M5_washer);
			translate(washer_thickness(M5_washer)) screw(M5_cap_screw, 10);
		}
	}
}

// comes in two parts, rotational symmetry about x axis, through screwed to clamp manifold
module washManifoldSlider() {
	d = frameSideCentres - frameProfileW-1;   // less 1mm to allow easier slide
	w = frameProfileW-4;
	h = 8*perim;
	h2 = 35;
	sliderD = 2perim;
	nutTrapH = screw_head_height(M4_hex_screw)-0.2;
	
	$fn=24;

	difference() {
		union() {
			//cross beam
			translate([-w/2,-d/2,-h/2]) cube([w, d - sliderD - 0.2, h/2]);
		
			// central cylinder
			translate([-w/2,0,0]) rotate([0,90,0]) linear_extrude(height=w) pieSlice(10/2+4perim,-90,90,$fn=24);
		
			// slider
			translate([-w/2,-d/2,-h2/2]) cube([w, sliderD, h2]);
			translate([0,-d/2+1.5+eta - 4perim,0]) trapezoidPrism(6,2,3,-2,h2,center=true);

			// nut trap casing
			translate([0,-d*0.27,-h/2-nutTrapH]) cylinder(h=nutTrapH + 1, r2=w/2, r1=w/2-nutTrapH);
			
			// fillets
			translate([-w/2+perim,-d/2+perim,0]) rotate([0,90,0]) right_triangle(h2/2,h2/2,2perim);
			
		}

		// hollow out central cylinder
		translate([-w/2-1,0,0]) rotate([0,90,0]) cylinder(h=w+2, r=10/2);

		// screw holes
		for (i=[0:1]) mirror([0,i,0]) {
			translate([0,d*0.27,-h/2-1]) cylinder(h=h+2, r=screw_clearance_radius(M4_hex_screw));
		}

		// nut trap
		translate([0,-d*0.27,-h/2-nutTrapH -1]) cylinder(h=nutTrapH+1, r=nut_flat_radius(M4_nut), $fn=6);

		// remove extrusion profile
		//translate([0,-frameSideCentres/2,-100]) aluProExtrusion(BR_20x20,l=200);

		// weight loss
		for (i=[0:1]) mirror([0,i,0]) {
			translate([0,d*0.14,-h/2-1]) cylinder(h=h+2, r=w/4);
			translate([0,d*0.39,-h/2-1]) cylinder(h=h+2, r=w/4);
		}
		
	}

	// screws, washers, nuts
	*translate([0,d/4,h/2]) screw(M4_hex_screw, 15);
	*translate([0,d/4,-h/2]) mirror([0,0,1]) {
		washer(M4_washer);
		translate([0,0,washer_thickness(M4_washer)]) nut(M4_nut);
	}
}



module washManifold(washManifoldHandlePos=0) {
	// -12, to 16

	washManifoldHandle(washManifoldAng(washManifoldHandlePos));


	translate([0,0,washManifoldZOffset2(washManifoldAng(washManifoldHandlePos))]) {
		translate([-frameW/2 , 0, 0]) rotate([0,90,0]) microborePipe(frameW);
	
		// nozzles
		for (i=[0:bottlesWide-1]) translate([i*bottleCentres - (bottlesWide-1)/2*bottleCentres,0,0]) {
			microboreT();
			translate([0,0,12]) microboreNozzle(od=9,nod=7);
		}

		// caps
		for (i=[0:1]) mirror([i,0,0]) {
			translate([frameW/2,0,0]) rotate([0,90,0]) microboreCap();
		}

		// central t
		rotate([90,0,0]) translate([-bottleCentres,0,0]) microboreT();

		// sliders
		for (i=[0:1]) mirror([i,0,0]) {
			translate([frameW/2 - frameProfileW/2,0,0]) {
				washManifoldSlider();
				rotate([180,0,0]) washManifoldSlider();
			}
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

module sumpPumpAssembly(sumpPumpArmPos=1, washManifoldHandlePos=0) {
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
	tubeEX = -bottleCentres;
	tubeEY = 0;
	tubeEZ = frameShelfH1 + washManifoldZOffset2(washManifoldAng(washManifoldHandlePos));

  
	translate([pivotX,pivotY - frameSideCentres/2 - frameProfileW/2 ,pivotZ - sumpPumpD/2 + frameShelfH1-5]) rotate([0,sumpPumpArm,0]) translate([-pivotX,-pivotY,-pivotZ]) {
		translate([0,0,sumpPumpD/2+2]) mirror([0,1,0]) rotate([0,90,0]) aluExtL(w=15,d=15,l=frameW/2);
		translate([-12,sumpPumpD/2,-sumpPumpH/2]) rotate([0,0,0]) sumpPump();

		// pivot screw
		translate([pivotX,pivotY,pivotZ]) rotate([90,0,0]) {
			washer(M5_washer);
			translate(washer_thickness(M5_washer)) screw(M5_cap_screw, 10);
		}
	}

	

	// pump tube
		color(silicone_color) curvedPipe(points=[ 
			[tubeX,tubeY, tubeZ],
			[tubeX + 50*sin(sumpPumpArm) ,tubeY,tubeZ + 40],
			[tubeX - 60,tubeY+13,(tubeZ + tubeEZ)/2 +25],
			[tubeEX,tubeEY-40,tubeEZ],
			[tubeEX, tubeEY, tubeEZ]
		   ],
            segments=4,
			radii=[20,30,15,10,10,30],
		    od=11,
			id=8, $fn=12);
}	


module crateShelfBracket() {
	w = 12 + 2perim;

	union() {
		translate([-fpw/2,0,-5]) linear_extrude(height=crateShelfH-5) aluProTSlot(BR_20x20);
		
		for (i=[-1,1])
			translate([crateShelfT,i*(6),crateShelfH/2]) 
			rotate([-90,0,0]) right_triangle(crateShelfW-crateShelfT-1,crateShelfW+3,2perim,center=true);
			
		translate([crateShelfT,0,crateShelfH/2]) 
			rotate([-90,0,0]) right_triangle(crateShelfW-crateShelfT-1,13,11,center=true);
			
		difference() {
			translate([0,-w/2,-15]) cube([6*perim,w,15]);
			
			translate([-1,0,-9]) rotate([0,90,0]) cylinder(r=4.5/2, h=10, $fn=12);
		}
		
		
		translate([0,-w/2,-eta]) cube([perim,3.5,crateShelfH/2]);
		translate([0,w/2-3.5,-eta]) cube([perim,3.5,crateShelfH/2]);
	}
	
	*color("grey") translate([-1,0,-9]) rotate([0,90,0]) cylinder(r=7/2, h=10, $fn=12);
}


module washManifoldCap() {
	capID = 17;
	capOD = capID + 8*perim;
	
	$fn=24;
	
	difference() {
		union() {
			cylinder(r=10/2, h=fpw-4); 	
			
			translate([0,0,fpw-4-eta])  cylinder(r1=10/2, r2=capOD/2, h=6);
			translate([0,0,fpw-4-eta + 6])  cylinder(r=capOD/2, h=12);
		}
		
		// hollow cap
		translate([0,0,fpw-4-eta + 7])  cylinder(r=capID/2, h=13);
		translate([0,0,fpw-4-eta+2])  cylinder(r1=10/2-4perim, r2=capID/2, h=5.2);
		
		// notch
		translate([-50,-1,fpw-3]) cube([100,2,50]);
		
		
		// section
		*translate([-50,0,-1]) cube([100,100,100]);
	}
}


module washManifoldSlider2() {
	d = frameSideCentres - frameProfileW-1;   // less 1mm to allow easier slide
	w = frameProfileW-4;
	h = 8*perim;
	h2 = 35;
	sliderD = 2perim;
	nutTrapH = screw_head_height(M4_hex_screw)-0.2;
	
	$fn=24;

	difference() {
		union() {
			//cross beam
			translate([-w/2,-d/2,-h/2]) cube([w, d, h]);
		
			// central cylinder
			translate([7,0,0]) rotate([0,90,0]) cylinder(h=14, r=17.5/2 + 4perim);
			
			// chamfered join
			translate([0,0,0]) rotate([0,90,0]) cylinder(h=7+eta, r1=h/2, r2=17.5/2 + 4perim);
		
		
			for (i=[0:1]) mirror([0,i,0]) {
				// slider
				translate([-w/2,-d/2,-h2/2]) cube([w, sliderD, h2]);
				translate([0,-d/2+1.5+eta - 4perim,0]) trapezoidPrism(6,2,3,-2,h2,center=true);
			
				// fillets
				translate([-w/2+perim,-d/2+perim,0]) rotate([0,90,0]) right_triangle(h2/2,h2/2,2perim);			
			}
			
		}

		// hollow out central cylinder
		translate([8,0,0]) rotate([0,90,0]) cylinder(h=50, r=17.5/2);
		
		// slot
		translate([7,-1,-25]) cube([20,2,50]);

		
		// weight loss
		for (i=[0:1]) mirror([0,i,0]) {
			translate([-w/4,d/8,-h-1]) roundedRect([w/2, d/4, 20],3, center=true);
			
		}
		
	}
}


module gearMotorMountPlate(h=5) {
	// centred at origin, facing up
	od = 37;
	l = 56;
	shaftOffset = od/2 - 11.2;
	collarOD = 12;
	w = od +4perim;
	
	difference() {
		translate([0, + shaftOffset,0]) cylinder(h=h, r=w/2);

		// hollow out for collar
		translate([0,0,-1]) cylinder(h=h+2, r=collarOD/2+0.5);

		// screw holes
		for (i=[0:5])
			translate([0,shaftOffset,0]) 
			rotate([0,0,360/6*i])
			translate([31/2,0,-1])
			cylinder(h=h+2, r=3.5/2, $fn=12);
	}
}


module gearMotor() {
	// orientated so that mounting face is in xy plane, at z=0
	// shaft points up z
	// shaft lies on xy=0
	// motor body is offset along y+
	
	od = 37;
	l = 56;
	shaftOffset = od/2 - 11.2;
	collarOD = 12;
	
	
	color("silver") difference() {
		union() {
			// body
			translate([0,shaftOffset,-l]) cylinder(h=l, r=od/2);
			
			// shaft - offset in y
			translate([0,0,0]) {
				// collar
				cylinder(h=5, r=collarOD/2);
				
				//shaft
				cylinder(h=20, r=6/2);
				
			}
			
		}
		
		// screw holes
		for (i=[0:5])
			translate([0,shaftOffset,0]) 
			rotate([0,0,360/6*i])
			translate([31/2,0,-9])
			cylinder(h=10, r=3/2, $fn=12);
			
	}
	
	
}



module bottleRest() {
	w = 12 + 2perim;
	h = 20;
	t1 = layers * 4;
	t2 = 7;

	offset = 40;

	d1 = 45;   // base of bottle
	d2 = 35;   // neck of bottle

difference() {
	union() {
		translate([-fpw/2,0,0]) linear_extrude(height=h/2) aluProTSlot(BR_20x20);

		translate([offset, 0, h/2-t2]) 
		difference() {
			cylinder(r=d1/2, h=t2, $fn=32);

			translate([0,0,-1]) cylinder(r=d2/2, h=t2+2, $fn=32);

			translate([0,0,-1]) cylinder(r=d1/2-2perim, h=t2, $fn=32);
		}
		
		for (i=[-1,1])
			translate([crateShelfT,i*(6),h/2 - t2]) 
			rotate([-90,0,0]) right_triangle(offset-d1/2,h - t2,2perim,center=true);

		translate([0,-w/2,h/2 - t2]) cube([offset-d1/2+2perim,w,t2]);
			
			
		difference() {
			translate([0,-w/2,-h/2]) cube([6*perim,w,h]);
			
			// screw hole
			translate([-1,0,-h/4]) rotate([0,90,0]) cylinder(r=4.5/2, h=10, $fn=12);
		}
		
		
		
	}

	translate([offset - d1/2 - 5,-w/2-1,h/2 - 1]) cube([5,w+2,10]);
}

}


module bottleFeeder() {
	w = 12 + 2perim;
	h = 20;
	t1 = layers * 4;
	t2 = 4;

	offset = 40;

	d1 = 45;   // base of bottle
	d2 = 35;   // neck of bottle

	d3 = 10;  // diameter of silicon tube
	d4 = 5.5;  // dia of sensor tube


	union() {
		translate([-fpw/2,0,0]) linear_extrude(height=h/2) aluProTSlot(BR_20x20);

		difference() {
			union() {
				translate([0,-w/2,h/2 - t2]) cube([offset,w,t2]);
				translate([offset, 0,h/2-t2]) cylinder(r=w/2, h=t2); 

				// bottle retainer
				translate([offset,0,0]) difference() {
					cylinder(r=d2/2 + 2perim, h=10);
		
					translate([0,0,-2]) cylinder(r=d2/2, h=h/2);
		
					translate([-110,-50,-5]) cube([100,100,100]);
				}
			}

			translate([offset, 0,0]) cylinder(r=d3/2, h=50); 
			
			translate([offset - d3/2 - d4/2 + perim, 0,0]) cylinder(r=d4/2, h=50); 

			// weightloss
			translate([6,-(w-6*perim)/2,0]) roundedRect([offset/2,w-6*perim,100], 3);
		}
		
		
		for (i=[-1,1])
			translate([crateShelfT,i*(6),h/2 - t2]) 
			rotate([-90,0,0]) right_triangle(offset-d1/2,h - t2,2perim,center=true);

		
			
			
		difference() {
			translate([0,-w/2,-h/2]) cube([6*perim,w,h]);
			
			// screw hole
			translate([-1,0,-h/4]) rotate([0,90,0]) cylinder(r=4.5/2, h=10, $fn=12);
		}
		
		
		
	}

}

module overflowNozzleCap() {
	d1 = 15.7;
	d2 = 30;
	h = 5;

	$fn = 32;

	difference() {
		union() {
			cylinder(h=h/2 + eta, r=d2/2);
			translate([0,0,h/2]) cylinder(h=h/2, r1=d2/2, r2=d2/2-h);
		}

		translate([0,0,-1]) cylinder(h=h+2, r=d1/2);
		translate([0,0,-1]) cylinder(h=3, r1=d1/2+2, r2=d1/2);
	}
}

module rinseLedge() {

	h = 5;
	d1 = 10.7;
	wall = 2perim;

	difference() {
		union() {
			cylinder(h=h, r=d1/2+wall);
		}
	}

}

module fillSlider() {
	w = frameProfileW-4;
	h = 8*perim;
	h2 = 30;
	sliderD = 2perim;
	
	$fn=24;

	difference() {
		union() {
			// slider
			translate([0,0,-fpw/4]) {
				translate([-fpw/2,0,0]) cube([fpw, sliderD, h2]);
				translate([0,1.5+eta - 4perim,h2/2]) trapezoidPrism(6,2,3,-2,h2,center=true);
			}			 

			// fillet
			translate([7,0,-fpw/4 + 3*perim]) rotate([90,0,90]) right_triangle(10,10,2perim);	
			translate([-w/2,0,-fpw/4]) cube([w,10,4perim]);	
	
			// t Slot
			rotate([90,0,0]) translate([-fpw,0,-fpw/2]) linear_extrude(height=fpw/2) aluProTSlot(BR_20x20);
			
			// joint
			translate([-fpw/2,0,-fpw/4]) cube([4perim,fpw,fpw/2]);

			
		}

		// screw hole
		translate([-15,fpw*3/4,0]) rotate([0,90,0]) cylinder(r=4.5/2, h=10, $fn=12);
		
		// spring slot
		translate([-9/2,5,-10]) cube([9,2,10]);
	}
}


module rinseClamp() {
	d1 = 15.5;

	w = d1 + 8*perim;
	d = 20;

	h1 = 50;
	
	h2  = h1  + d1/2;
	

	difference() {
		union() {
			translate([-w/2,-d/2,0]) cube([w,d,h2]);	
			translate([0,d/2,h1+d1/2]) rotate([90,0,0]) cylinder(r=w/2, h=d);
			
		}

		// pipe hole
		translate([0,50,h1+d1/2]) rotate([90,0,0]) cylinder(r=d1/2, h=100);

		// weight loss
		translate([-(w-12*perim)/2,-d/2-1,8*perim]) cube([w-12*perim,d+2,h2-8*perim]);	

		// screw hole clamp
		translate([-50,0,h1-5]) rotate([0,90,0]) cylinder(r=5.5/2, h=100, $fn=12);

		// screw hole base
		translate([0,0,-1]) cylinder(r=4.5/2, h=10, $fn=12);
	}

}

module bottleBottom() {
	
	h1 = 4;
	h2 = 4;
	d1 = 34;

	difference() {
		union() {
			intersection() {
				union() {
					cylinder(h=h1 + eta, r=d1/2); 
					translate([0,0,h1]) cylinder(h=h2, r1=d1/2, r2=d1/4);
				}

				translate([-fpw/2,-25,-25]) cube([fpw, 50, 50]);
			}

			translate([0,d1/2 + fpw/2 + 5,0]) cylinder(h=h1, r=d1/2 + 4perim);
	
		}

		// bottle neck
		translate([0,d1/2 + fpw/2 + 5,-1]) cylinder(h=20, r=d1/2);

		// screw hole base
		translate([0,0,-1]) cylinder(r=4.5/2, h=10, $fn=12);

		// countersink
		translate([0,0,h1]) cylinder(r=9/2, h=10, $fn=24);
	}
}

module nozzleHolder() {
	
	d = 40;
	d1 = 15.7;
	h1 = 4;
	h2 = 10;
	w1 = 10;
	w2 = d1 + 8*perim;

	$fn = 32;

	difference() {
		union() {
			translate([-w1/2,-d + 10,0]) roundedRect([w1,d,h1],5);
			translate([-w2/2,-d+4perim,0]) roundedRect([w2,w2+10-4perim,h2],5);

			translate([0,-fpw/2,h1]) rotate([0,-90,0]) right_triangle(h2-h1,h2-h1,w1);	
		}

		// nozzle
		translate([0,-fpw,-1]) cylinder(r=d1/2, h=100);

		// notch
		translate([-1,-50,-1]) cube([2,30,100]);

		// screw hole base
		translate([0,0,-1]) cylinder(r=4.5/2, h=10, $fn=12);

		// screw hole across
		translate([-50,-d+7.5,h2/2]) rotate([0,90,0]) cylinder(r=4.5/2, h=100, $fn=12);
	}
}


module machine(pumpRot=0, showCrate=true, showSump=true, showPump=false, sumpPumpArmPos=0, washManifoldHandlePos=0) {
	frame(pumpRot, showPump);

	*translate([0,-40,pumpZ + pumpRailCentres - frameProfileW-40]) inletManifold();

	if (showPump) translate([0,(frameSideCentres)/2,pumpZ+pumpZOffset]) rotate([90,0,0]) pumpAssembly(pumpRot);
	
	if (showSump) translate([0,-(sumpD - frameSideCentres - frameProfileW)/2,0]) sump();

	translate([0,0,frameShelfH1]) washManifold(washManifoldHandlePos=washManifoldHandlePos);

	*sumpPumpAssembly(sumpPumpArmPos = sumpPumpArmPos, washManifoldHandlePos=washManifoldHandlePos);
	
	if (showCrate) translate([0,0,frameShelfH1+1.5]) crateOfBottles();
}


*machine(pumpRot=0, showCrate=false, showSump=true, showPump=false, sumpPumpArmPos=1, washManifoldHandlePos=1);


*frame();
*frameCover();


// printable parts

nozzleHolder();

*bottleBottom();

*rotate([90,0,0]) rinseClamp();

*fillSlider();
*translate([10,35,0]) mirror([0,1,0]) fillSlider();

*rinseLedge();

*overflowNozzleCap();

*rotate([180,0,0]) bottleRest();

*rotate([180,0,0]) bottleFeeder();

*translate([20,25,18]) rotate([180,0,0]) smallGear(cp);

*rotate([0,-90,0])
 washManifoldSlider2();

*washManifoldCap();

*rotate([0,-90,0]) washManifoldSlider();
*rotate([180,0,0]) washManifoldSlider();

*rotate([180,0,0]) crateShelfBracket();

*pumpAssembly(45);

*rotate([180,0,0]) bigGear(cp);
*axleBushing();

*rotate([0,90,0]) bearingPlate();

*pumpRotor();
*pumpRollerPrintableTube(l=50);

*pumpTubeCasingFront();
*pumpTubeCasingBack();

*translate([0,0,7]) rotate([0,90,0]) 
   motorPlate();
 
*aluProTSlotLug(BR_20x20);

// calculate total extrusion requirements
echo("Frame extrusions: ");
echo(frameH - frameProfileW, " x 4");
echo(frameW - 2*frameProfileW, " x 2");
echo(frameSideCentres - frameProfileW, " x 2");



