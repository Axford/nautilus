use <moreShapes.scad>

eta = 0.01;

module rePart(r1, r2, h, ang) {

	r3 = r1 * cos(ang/2);

	l1 = (r1 + r2/2)*cos(ang/2) - (r1-r2/2)*cos(ang/2);
	l2 = 2 * (r1 + r2/2) * sin(ang/2);


	difference() {
		translate([r3 ,0,0])
			scale([l1/r2,1,1])
			rotate([90,0,0])
			linear_extrude(height = l2,center=true)
			child(0);

		for (i=[0,1])
			mirror([0,i,0])
			rotate([0,0,ang/2 + eta])
			translate([0,0,-h/2 - 1]) 
			cube([r1+r2+1, r2 * cos(90-ang/2), h +2]);
		
	}
}




module re(r1, parts, start_angle, end_angle) {
	ang = (end_angle - start_angle)/parts;

	union()
	for (i=[0:parts-1]) 
	{
		color([i/parts,i/parts,i/parts]) rotate([0,0,start_angle + i*ang]) rePart(r1,20,20,ang) difference() {
			square([20,20], center=true);
			circle(8);
		}
	}
}


re(100, 20, 0 ,45);
