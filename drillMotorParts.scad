use <moreShapes.scad>


perim = 0.7;
layers = 0.3;

eta = 0.001;

module torqueLock() {
	pgOD = 37.9;
	pgID = 31;
	nibs = 8;
	nibW = 2.6;
	nibH = 1.2;
	ringH = 2;
	pinD = 4.5;
	pinOD = 37.7;  /// touches outer edge of pins
	pinH = 3;
	
	nibAng = 360 * nibW / (2* PI * pinOD/2);
	
	ringID = pinOD - 2*pinD;
	
	difference() {
		union() {
			tube(or=pgOD/2, ir=ringID/2, h=ringH, center = false, $fn=64);
		
			// pins
			for (i=[0:nibs]) rotate([0,0,i*360/nibs]) {
				translate([pinOD/2 - pinD/2,0,0]) cylinder(r=4/2, h=ringH + pinH, $fn=16);
			}			
		}
		
		// nibs
		for (i=[0:nibs]) rotate([0,0,i*360/nibs + 180/nibs]) {
				translate([0,0,-eta]) sector(r=pgOD/2 + 1, a=nibAng, h=nibH+eta, center=false);
			}
	}

}


torqueLock();