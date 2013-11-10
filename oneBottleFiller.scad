

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

caseOD = 70;
caseBR = 16;
caseTR = 5;
caseOH = 34;
caseWall = 4;

pipeZ = 5;

module pipework() {
	color(c_steel) translate([0,0,-15+pipeZ]) microboreElbow() { 
		microborePipe(40); // inlet
		microborePipe(40);   // outlet
	}

	color(c_silicone) translate([caseOD/2+5,0,pipeZ]) rotate([0,90,0]) cylinder(r=6,h=100);

	// sense tube
	color(c_steel) translate([-8,0,-25]) tube(4/2,3/2,50);

	// outlet gasket
	color(c_wire) translate([0,0,-caseOH/2+1]) tube(12/2,10/2,4);
	
	// sense gasket
	color(c_wire) translate([-8,0,-caseOH/2+1]) tube(5/2,4/2,4);
}

module wires() {
	color(c_wire) translate([caseOD/2-5,10,pipeZ]) rotate([0,90,0]) cylinder(r=4/2,h=100);
	
	color(c_wire) translate([caseOD/2-5,-10,pipeZ]) rotate([0,90,0]) cylinder(r=4/2,h=100);
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
	color(c_wire)
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
	color(c_plas) 
		translate([0,0,-caseOH/2-5]) 
		rotate([0,5,0])
		linear_extrude(height=4)
		union() {
			for (i=[-1,1]) 
				rotate([0,0, 180+i*45]) translate([12.5,0,0]) circle(r=(caseOD/2-caseBR-6)/2);
			translate([12.5,0,0]) circle(r=(caseOD/2-caseBR-6)/2);

			difference() {
				circle(r=caseOD/2-caseBR-6);
				rotate([0,0,180]) sector2D(r=caseOD/2-caseBR,a=90);
				circle(r=6);
			}
		}
	
}

case();
pipework();
wires();
switch();