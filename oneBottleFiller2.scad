

use <vector.scad>
use <maths.scad>
use <moreShapes.scad>
use <curvedPipe.scad>
use <microbore.scad>

c_alu = [0.8,0.8,0.8,1];
c_steel = [0.9,0.9,0.9,1];
c_silicone = [1,0.8,0.8,0.5];
c_wire = [0.2,0.2,0.2,1];
c_led = [0,1,0,1];
c_plas = [1,1,1,1];
c_rubber = [0.2,0.2,0.2,1];
c_pcb = [0,0.8,0,1];

perim = 0.7;
2perim = 2*0.7;
4perim = 4*perim;

layer=0.3;

caseOD = 70;
caseOR=caseOD/2;
caseBR = 16;
caseTR = 8;
caseOH = 34;
caseBH = 25;
caseTH = 11;
caseWall = 4;
innerWall = 3*perim;

outletOD = 10;
outletOR = outletOD/2;

outletHoleOR = outletOR + 1;

senseOffset = 8;
senseOD = 5;
senseOR = senseOD/2;
senseHoleOR = senseOR +1;

wireOD = 5.5;
wireOR = wireOD/2;
wireHoleOR = wireOR + 1;

wireOffset = 9.5;

fixingOD = 4;  // M4
fixingOR = fixingOD/2;
fixingOffset = caseOR-10;  // radial offset
fixPostOR = fixingOR + innerWall;

footOD = 12;
footOR=footOD/2;
footH = 9;
footP = 3;  // amount of protrusion

pipeZ = 0;

magOD = 7.5;
magOR = magOD/2;
magH = 1.5;


eta = 0.001;

module pipework() {
	color(c_steel) translate([0,0,-15+pipeZ]) microboreElbow() { 
		microborePipe(40); // inlet
		microborePipe(80);   // outlet
	}

	color(c_silicone) translate([caseOD/2+5,0,pipeZ]) rotate([0,90,0]) cylinder(r=6,h=100);

	// sense tube
	color(c_steel) translate([-senseOffset,0,-25]) tube(senseOR,3/2,50,$fn=16);

	// outlet gasket
	color(c_wire) translate([0,0,-caseBH-1]) tube(outletHoleOR,10/2,caseWall+2,center=false);
	
	// sense gasket
	color(c_wire) translate([-senseOffset,0,-caseBH-1]) tube(senseHoleOR,4/2,caseWall+2,center=false);
}

module wires() {
	color(c_wire) translate([20,wireOffset,pipeZ]) rotate([0,90,0]) cylinder(r=wireOR,h=100);
	
	color(c_wire) translate([20,-wireOffset,pipeZ]) rotate([0,90,0]) cylinder(r=wireOR,h=100);
}

module case() {
	color(c_alu) {
		rotate_extrude($fn=64)
			hull() {
				translate([caseOD/2-caseTR,caseOH/2-caseTR,0]) 
					circle(r = caseTR, $fn=32);
				translate([caseOD/2-caseBR,-caseOH/2+caseBR,0]) 
					circle(r = caseBR, $fn=64);
				square([1,caseOH],center=true);
				
			}
	}

	// gasket
	*color(c_wire)
		translate([0,0,caseOH/2])
		rotate_extrude($fn=64)
		translate([caseOD/2-caseTR-2,0,0]) 
		square([2,3],center=true);


	// screws
	for (i=[0:2]) {
		color(c_steel)
		rotate([0,0,i*360/3 + 90]) 
		translate([0,20,caseOH/2])
		cylinder(r=5/2,h=0.2);
	}
}

module switch() {
	r = magOR + 4perim;
	h = magH/2 + 1;

	$fn=32;

	color(c_plas) 
	difference() {
		linear_extrude(height=h)
		union() {
			for (i=[-1,1]) 
				rotate([0,0, 180+i*45]) translate([12.5,0,0]) circle(r=r);
			
			translate([12.5,0,0]) circle(r=r);

			difference() {
				circle(r=caseOD/2-caseBR-6);
				rotate([0,0,180]) sector2D(r=caseOD/2-caseBR,a=90);
				circle(r=(12.5-r));
			}
		}

		// mag holes
		for (i=[-1,1]) 
			rotate([0,0, 180+i*45]) 
				translate([12.5,0,1]) 
				cylinder(r=magOR, h=magH+1);

		translate([12.5,0,1]) cylinder(r=magOR, h=magH+1);

	}
	
}


module bottomCase() {
	color(c_alu) 
	union() {
		// outer casing
		difference() {
			rotate_extrude($fn=64) 
			difference() {
				union() {
					translate([caseOD/2-caseBR,-caseBH+caseBR,0]) 
						circle(r = caseBR, $fn=64);
					translate([0,-caseBH,0]) square([caseOD/2-caseBR+eta,caseWall]);
					translate([caseOD/2-caseWall,-caseBH+caseBR-eta,0]) square([caseWall,caseBH-caseBR]);
				}
			
				// hollow it out
				translate([caseOD/2-caseBR-1,-caseBH+caseBR,0]) 
					circle(r = caseBR-caseWall, $fn=64);
				translate([0,-caseBH+caseWall,0]) square([caseOD/2-caseBR-2,100]);
				
				translate([0,-outletHoleOR,0]) square([caseOD/2-caseWall,100]);
								
				// pcb ledge
				translate([0,-outletHoleOR-4,0]) square([caseOD/2-caseWall-1,100]);

				translate([0,0,0]) square([100,100]);
	
				// hollow for outlet
				translate([0,-caseBH-1,0]) square([outletHoleOR,100]);
				
			}
	
			// sense hole
			translate([-senseOffset,0,-caseBH-1]) cylinder(r=senseHoleOR,h=100);
	
			// inlet
			translate([10,0,0]) rotate([0,90,0]) cylinder(r=outletHoleOR,h=100, $fn=16);
	
	
			// wires
			translate([10,wireOffset,0]) rotate([0,90,0]) cylinder(r=wireHoleOR,h=100, $fn=16);
			translate([10,-wireOffset,0]) rotate([0,90,0]) cylinder(r=wireHoleOR,h=100, $fn=16);
			
	
			//translate([-50,-100,-50]) cube([100,100,100]);
		}

		// fixing posts
		intersection() {
			union() {
				for (i=[0:2]) {
					rotate([0,0,i*360/3 + 90]) 
					translate([0,fixingOffset,-caseBH+caseWall-eta])
					difference() {
						union() {
							cylinder(r1=fixingOR+caseWall,r2=fixPostOR,h=caseBH-caseWall+eta);
							translate([-fixPostOR,0,0]) cube([fixPostOR*2,10,caseBH-caseWall-2],center=false);
						}
						translate([0,0,caseBH-caseWall-4]) cylinder(r1=0,r2=fixingOR,h=5,$fn=12);
					}
				}
			}

			// casing limits
			rotate_extrude($fn=64) 
				union() {
					translate([caseOD/2-caseBR,-caseBH+caseBR,0]) 
						circle(r = caseBR-1, $fn=64);
					translate([0,-caseBH,0]) square([caseOD/2-caseBR+eta,caseWall]);
					translate([caseOD/2-caseWall,-caseBH+caseBR-eta,0]) square([caseWall,caseBH-caseBR]);
				}
		}
		
		
	}
}


module topCase() {
	color(c_alu) 
	difference() {
		union() {
			// outer casing
			difference() {
				union() {
					rotate_extrude($fn=64) 
					difference() {
						union() {
							translate([caseOD/2-caseTR,caseTH-caseTR,0]) 
								circle(r = caseTR, $fn=64);
							translate([0,caseTH-caseWall,0]) square([caseOD/2-caseTR+eta,caseWall]);
							translate([caseOD/2-caseWall,0,0]) square([caseWall,caseTH-caseTR]);
						}
					
						// hollow it out
						translate([caseOD/2-caseTR-2perim,caseTH-caseTR,0]) circle(r = caseTR-caseWall, $fn=64);
						translate([0,-1,0]) square([caseOD/2-caseTR,caseTH-caseWall+1]);
						translate([0,-1,0]) square([caseOD/2-caseWall-2perim,caseTH-caseTR+1]);
		
						// allows for 1mm gasket
						translate([0,-100+1,0]) square([100,100]);
						
					}

					// locating rim
					translate([0,0,-1]) tube(caseOR-caseWall,caseOR-caseWall-2perim,3,center=false,$fn=64);
				}
		
				// inlet
				translate([10,0,0]) rotate([0,90,0]) cylinder(r=outletHoleOR,h=100, $fn=16);
		
		
				// wires
				translate([10,wireOffset,0]) rotate([0,90,0]) cylinder(r=wireHoleOR,h=100, $fn=16);
				translate([10,-wireOffset,0]) rotate([0,90,0]) cylinder(r=wireHoleOR,h=100, $fn=16);
				
			}
	
			// fixing posts
			intersection() {
				union() {
					for (i=[0:2]) {
						rotate([0,0,i*360/3 + 90]) 
						translate([0,fixingOffset,1])
						difference() {
							union() {
								cylinder(r2=footOR+caseWall,r1=footOR+innerWall,h=caseBH-caseWall+eta);
								translate([-footOR,0,0]) cube([footOR*2,10,caseBH-caseWall-2],center=false);
							}
							translate([0,0,-1]) cylinder(r=fixingOR,h=100,$fn=12);
						}
					}

					// stabilising plate
					difference() {
						translate([0,-50,caseTH+1]) rotate([-90,0,0]) trapezoidPrism(caseWall,caseWall+6,caseTH,3,100,center=false);

						// hollow for inlet
						rotate([0,90,0]) cylinder(r=outletOR+2,h=100,$fn=16);

						// hollow for wires
						translate([0,wireOffset,0]) rotate([0,90,0]) cylinder(r=wireOR,h=100, $fn=16);
						translate([0,-wireOffset,0]) rotate([0,90,0]) cylinder(r=wireOR,h=100, $fn=16);
					}
				}
	
				// casing limits
				rotate_extrude($fn=64) 
					union() {
						translate([caseOD/2-caseTR,caseTH-caseTR,0]) 
							circle(r = caseTR-1, $fn=64);
						translate([0,0,0]) square([caseOD/2-caseTR+eta,caseTH]);
						translate([caseOD/2-caseWall,0,0]) square([caseWall,caseTH-caseTR]);
						
					}
			}
			
			
		}

		// hollow out for feet
		for (i=[0:2]) {
			rotate([0,0,i*360/3 + 90]) {
				translate([0,fixingOffset,caseTH - footH + footP]) cylinder(r1=footOR,r2=footOR+2,h=caseBH-caseWall+eta);
				translate([0,fixingOffset,caseTH - 2 ]) cylinder(r1=footOR,r2=footOR+3,h=2.1);

				//translate([0,fixingOffset,caseTH - 1.5 ]) cylinder(r1=footOR,r2=footOR+5,h=1.6);
			}
		}

		// slice in half for debug
		//translate([-50,-100,-50]) cube([100,100,100]);

	}
}


module feet() {
	color(c_rubber) for (i=[0:2]) {
			rotate([0,0,i*360/3 + 90]) {
				translate([0,fixingOffset,caseTH - footH + footP]) cylinder(r1=footOR,r2=footOR-1,h=footH);
			}
		}
}

module pcb() {
	color(c_pcb) {

		// main board
		translate([0,0,-10])
		linear_extrude(height=1.6) 
		difference() {
			circle(caseOR-caseWall-1);

			// remove fixings
			for (i=[0:2]) {
				rotate([0,0,i*360/3 + 90]) 
				translate([0,fixingOffset,-caseBH+caseWall-eta]) {
					circle(fixingOR+caseWall-0.5);
					translate([-(fixingOR+caseWall-0.5),0,0]) square([(fixingOR+caseWall-0.5)*2,10],center=false);
				}
			}

			// remove outlet
			circle(outletHoleOR+1);
	
			// trim in half
			translate([-100,-50,0]) square([100,100]);
		}
		
		// pressure sensor
		

	}
}


module rocketFeet() {
	rOD = 14;
	rOR = rOD/2;
	r = caseOR + 12 + rOR;
	h = caseTH + 4;
	bh = caseBH + 10;
	
	echo(r);

	for (i=[0:2]) {
			rotate([0,0,i*360/3 + 60]) {
				intersection() {
					translate([]) scale([1,rOR/r,bh/r]) sphere(r=r);
					translate([0,-rOR,-bh]) cube([r,rOD,bh],center=false);
				}

				color(c_alu) intersection() {
					translate([]) scale([1,rOR/r,caseTH/r]) sphere(r=r);
					translate([0,-rOR,0]) cube([r,rOD,bh],center=false);
				}

				translate([r-rOR,0,0]) scale([rOR/h,rOR/h,1]) sphere(r=h);
			}
		}
	
}


module triangleHull() {
	rOD = 14;
	rOR = rOD/2;
	r = caseOR + 20 + rOR;
	h = caseTH + 4;

	hull()
	for (i=[0:2]) {
			rotate([0,0,i*360/3 ]) {
				translate([r-rOR,0,-5]) scale([rOR/h,rOR/h,1]) sphere(r=h);
			}
		}
}

module rocketBody() {
	rOD = 14;
	rOR = rOD/2;
	r = caseOR + 20 + rOR;
	h = caseTH + 4;
	bh = caseBH + 10;

	or = caseBH;

	intersection() {
		scale([1,1,1.05*bh/or]) sphere(r=or,$fn=64);
		translate([-r,-r,-bh]) cube([2*r,2*r,bh],center=false);
	}

	translate([0,0,-bh]) cylinder(r=outletHoleOR+2,h=10,$fn=16);
	translate([-senseOffset,0,-bh]) cylinder(r=senseOR+2,h=10,$fn=16);

	color(c_alu)  rotate_extrude($fn=64) 
			union() {
					translate([or-caseTR,caseTH-caseTR,0]) 
								circle(r = caseTR, $fn=64);
							translate([0,caseTH-caseWall,0]) square([or-caseTR+eta,caseWall]);
							translate([or-caseWall,0,0]) square([caseWall,caseTH-caseTR]);
				}
}


if (true) {
	*render(convexity = 2) 
		bottomCase();
	*render(convexity = 2)
		topCase();

	rocketFeet();
	rocketBody();
	
	// cool triangle
	//triangleHull();

	//feet();
	
	pipework();
	wires();
	//translate([0,0,-caseBH-5]) rotate([0,5,0]) switch();
	
	//pcb();
}

// printables
//render(convexity = 2) bottomCase();

//rotate([180,0,0]) topCase();

//switch();

