//  Modules for the Bosch Rexroth series of aluminium profiles
//  
//  Author - Damian Axford
//  Public Domain

use <moreShapes.scad>

eta = 0.01;


// Bore Types
BR_20x20_Bore = [5.5, 1.5, 7];

function aluProBore_r(boreType) = boreType[0]/2;
function aluProBore_outsetW(boreType) = boreType[1];
function aluProBore_outsetR(boreType) = boreType[2]/2;

// Core Types
BR_20x20_Core = [9,2,0.75];

function aluProCore_w(coreType) = coreType[0];
function aluProCore_keyW(coreType) = coreType[1];
function aluProCore_keyD(coreType) = coreType[2];

//Corner Types
BR_20x20_Corner = [20, 7, 1.5, 0.5, 4];

// Side Types  - for closed slots
BR_20x20_Side = [20, 1.5];

// Side Styles
BR_0 = [0,0,0,0];
BR_1S = [0,1,1,1];
BR_2S = [0,1,0,1];
BR_3S = [0,1,0,0];
BR_2SA = [1,1,0,0];

// Profiles - combination of elements

BR_20x20 = [BR_20x20_Bore, BR_20x20_Core, BR_20x20_Corner, BR_20x20_Side, BR_0, 1, 1];
BR_20x20_1S = [BR_20x20_Bore, BR_20x20_Core, BR_20x20_Corner, BR_20x20_Side, BR_1S, 1, 1];
BR_20x20_2S = [BR_20x20_Bore, BR_20x20_Core, BR_20x20_Corner, BR_20x20_Side, BR_2S, 1, 1];
BR_20x20_3S = [BR_20x20_Bore, BR_20x20_Core, BR_20x20_Corner, BR_20x20_Side, BR_3S, 1, 1];
BR_20x20_2SA = [BR_20x20_Bore, BR_20x20_Core, BR_20x20_Corner, BR_20x20_Side, BR_2SA, 1, 1];

BR_20x40 = [BR_20x20_Bore, BR_20x20_Core, BR_20x20_Corner, BR_20x20_Side, BR_0, 1, 2];

BR_20x60 = [BR_20x20_Bore, BR_20x20_Core, BR_20x20_Corner, BR_20x20_Side, BR_0, 1, 3];

BR_20x80 = [BR_20x20_Bore, BR_20x20_Core, BR_20x20_Corner, BR_20x20_Side, BR_0, 1, 4];


module aluProBore(boreType, $fn=16) {
	union() {
		circle(r=aluProBore_r(boreType));
	
		intersection() {
			circle(r=aluProBore_outsetR(boreType));
			for (i=[0:3]) 
				rotate([0,0,i*90 + 45]) 	
				square([aluProBore_outsetR(boreType)*2,aluProBore_outsetW(boreType)], center=true);
		}
	}
}


module aluProCore(coreType) {
	w = aluProCore_w(coreType);
	keyW = aluProCore_keyW(coreType);
	keyD = aluProCore_keyD(coreType);

	difference() {
		square([w,w],center=true);

		// remove keys
		for (i=[0:3]) 
			rotate([0,0,i*90])
			translate([w/2,0,0])
			polygon([[eta,keyW/2], 
                      [-keyD,0], 
                      [eta,-keyW/2]]); 
	}
}


module aluProCorner(cornerType, $fn=8) {
	// xy corner
	w1 = cornerType[0];
	w2 = cornerType[1];
	t = cornerType[2];
	cham = cornerType[3];
	w3 = cornerType[4];	

	union() {	
		// radial arm
		rotate([0,0,45]) translate([0,-t/2,0]) square([w1/2+t,t]);

		// outer radius
		translate([w1/2-t,w1/2-t,0]) circle(r=t);

		// corner block
		translate([w1/2-w3,w1/2-w3]) square([w3-t+eta,w3-t+eta]);

		// returns
		for (i=[0,1]) mirror([i,i,0]) {
			translate([w1/2-w2,w1/2-t,0]) square([w2-t,t-cham]);
			translate([w1/2-w2+cham,w1/2-cham-eta,0]) square([w2-t-cham,cham+eta]);
		}
	}
}

module aluProSide(sideType) {
	// x side
	w = sideType[0];
	t = sideType[1];
	translate([w/2-t-eta,-w/4,0]) square([t+eta,w/2]);	
}

module aluProHollow(cornerType) {
	// x hollow
	w1 = cornerType[0];
	t = cornerType[2];
	w3 = cornerType[4];	

	translate([w1/2,0]) square([2*w3 - 2*t, w1 - 2*t],center=true);
}


module aluProBasicSection(profileType) {
	difference() {
		union() {
			aluProCore(profileType[1]);
			
			for (i=[0:3]) rotate([0,0,i*90]) {
				aluProCorner(profileType[2]);

				if (profileType[4][i] == 1)
					aluProSide(profileType[3]);
			}
		}
		aluProBore(profileType[0]);
	}
}

module aluProSection(profileType) {
	x = profileType[5];
	y = profileType[6];
	w = profileType[3][0];
	sx = -(x-1)*w/2;
	sy = -(y-1)*w/2;

	difference() {
		union() {
			for (i=[0:x-1])
				for (j=[0:y-1])
					translate([sx + w * i, sy + w * j,0]) aluProBasicSection(profileType);
			
			// fill-in sides
			if (y > 1)
				for (i=[0:y-2])
					for (j=[0,1]) 
						mirror([j,0,0])
							translate([sx + (x-1) * w/2, sy + i*w + w/2,0])
								aluProSide(profileType[3]);
		}

		// remove hollows
		if (y > 1)
			for (i=[0:y-2])
				for (j=[0,1]) 
					mirror([j,0,0])
						translate([sx + (x-1) * w/2, sy + i*w,0])
							rotate([0,0,90]) aluProHollow(profileType[2]);
	}
		
}

module aluProExtrusion(profileType, l=100, center=false) {
	translate([0,0,center?-l/2:0]) 
		linear_extrude(height=l)
		aluProSection(profileType, center);
}

arrangeShapesOnGrid(showLocalAxes=true) {
	aluProExtrusion(BR_20x20, l=80, center=true);
	aluProExtrusion(BR_20x20_1S, l=50);
	aluProExtrusion(BR_20x20_2S, l=50);
	aluProExtrusion(BR_20x20_3S, l=70);
	aluProExtrusion(BR_20x20_2SA, l=70);

	aluProExtrusion(BR_20x40, l=70, center=false);
	aluProExtrusion(BR_20x60, center=true);
	rotate([0,0,35]) aluProExtrusion(BR_20x80, center=false);
}

