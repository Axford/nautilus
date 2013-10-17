use <moreShapes.scad>
use <curvedPipe.scad>

eta = 0.001;




outlet_tube_wall = 2;
outlet_tube_od = 14;
outlet_tube_id = outlet_tube_od - outlet_tube_wall;

outlet_protrusion = 25;  // protrusion from case, includes extension tube
outlet_extension = 10;  // length of extension

outlet_extension_od = outlet_tube_id;
outlet_extension_id = outlet_extension_od - 2;  // 2mm wall

outletSpacing = 70;
outletAdjust = 30;
outletSpacingMax = outletSpacing + outletAdjust;

inletPos = 50;  // vertical height of inlet centreline

caseWall = 2; 

caseClearance = 5;  // 5 mm interior clearance

outlet_offset = caseWall+caseClearance+outlet_tube_od/2;

caseWidth = outletSpacingMax + outlet_tube_id + 2*(caseClearance + caseWall);
caseHeight = inletPos + outlet_offset + 10;
caseDepth = outlet_tube_id + 2*(caseClearance + caseWall);



// colours
c_silicone = [0.6,0.6,0.6,0.4];
c_hdpe = [1,0.6,0.6,1];
c_alu = [0.8,0.8,0.8,1];
c_pcb = [0,0.5,0.1,1.0];


module inlet() {
	// centred on x, pointing along -x
	h = 100;
	color(c_silicone)
		rotate([0,-90,0])
		translate([0, 0,0]) 
		tube(outlet_tube_od/2, outlet_tube_id/2, h, false);
}


module outlet() {
	// centred on z
	h = outlet_protrusion + 5;

	// extension
	color(c_hdpe)
		translate([0, 0,-outlet_protrusion]) 
		tube(outlet_extension_od/2, outlet_extension_id/2, h, false);

	// tube
	color(c_silicone)
		translate([0, 0,-outlet_protrusion+outlet_extension]) 
		tube(outlet_tube_od/2, outlet_tube_id/2, h, false);
}


module case() {
	*cube([caseWidth,caseDepth,caseHeight]);

	//open case
	color(c_alu)
	difference() {
		roundedRectY([caseWidth,caseDepth,caseHeight],caseClearance);
	
		translate([caseWall,-caseWall,caseWall]) 
			roundedRectY([caseWidth-2*caseWall,caseDepth,caseHeight-2*caseWall],caseClearance);
		
		// holes for outlets
		translate([outlet_offset,outlet_offset,-1]) 
			cylinder(r=outlet_tube_od/2+1, h=caseWall+2);

		translate([caseWall+caseClearance -1 + outletSpacing,caseWall+caseClearance-1,-1]) 
			roundedRect([outletAdjust+2, outlet_tube_od+2, caseWall+2],outlet_tube_od/2);
	}

	// divider
	color(c_alu) translate([outlet_offset+40,0,0]) cube([caseWall,caseDepth,caseHeight]);
}


module manifold() {
	
	// tee
	color(c_hdpe)
		translate([outlet_offset,outlet_offset,inletPos - outlet_extension_od*1.5]) {
			translate([-outlet_extension_od*1.5,0,outlet_extension_od*1.5]) rotate([0,90,0]) tube(outlet_extension_od/2, outlet_extension_id/2, outlet_extension_od*3, false);
			tube(outlet_extension_od/2, outlet_extension_id/2, outlet_extension_od*1.5, false);
		}

	// joining bits of tube
	
	color(c_silicone)
		translate([outlet_offset,outlet_offset,10])
		tube(outlet_tube_od/2, outlet_tube_id/2, inletPos - outlet_tube_od/2  -10, false);

	color(c_silicone)
		curvedPipe([ [outlet_offset + outletSpacing,outlet_offset,10],
					[outlet_offset + outletSpacing,outlet_offset,20],
					[outlet_offset + outletSpacing+outletAdjust/2,outlet_offset,caseHeight+5],
					[outlet_offset+45,outlet_offset,inletPos],
					[outlet_offset+outlet_tube_od/2,outlet_offset,inletPos]
			   	  ],
	            	  4,
				  [20,15,15],
			      outlet_tube_od,
				  outlet_tube_id);

	// outlets
	translate([outlet_offset ,outlet_offset,0]) {
		outlet();
		translate([outletSpacing,0,0]) outlet();
	}

	// inlet
	translate([caseWall+caseClearance,outlet_offset,inletPos]) inlet();
}


module circuitry() {
	translate([outlet_offset+15,caseDepth-caseWall,caseWall+caseClearance]) {
		
		// pressure sensor
		color(c_pcb)
		translate([0,-10,0]) cube([16.5,3,16.5]);

		// main board
		color(c_pcb) translate([0,-5,0]) cube([20,5,30]);
	}
}

case();
manifold();
circuitry();

echo(caseWidth);
echo(caseHeight);
echo(caseDepth);
