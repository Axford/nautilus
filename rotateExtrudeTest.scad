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


//re(100, 20, 0 ,45);



module reCylPart(r1, r2,r3,r4, ang) {

	h = 2*max(r2,r3);
	rAvg = (r2 + r3)/2;	

	ri = r1 * cos(ang/2);

	l1 = ((r1 + rAvg)*cos(ang/2) - (r1-rAvg)*cos(ang/2))/2;


	l2 = 2 * (r1 + h/2) * sin(ang/2);


	difference() {
		translate([ri ,0,0]) union() {
			scale([l1/r2,1,1])
				rotate([90,0,0])
				cylinder(h=l2, r1=r3, r2=r2, center=true);
		}

		for (i=[0,1])
			mirror([0,i,0])
			rotate([0,0,ang/2 +eta ])
			translate([0,0,-h/2 - 1]) 
			cube([r1+h+1, h * cos(90-ang/2), h +2]);
		
	}
}




module re(r1, r2, r3, parts, start_angle, end_angle) {
	ang = (end_angle - start_angle)/parts;

	rDiff = r3 - r2;

	union()
	for (i=[0:parts-1]) 
	{
		color([i/parts+0.2,i/parts,i/parts]) rotate([0,0,start_angle + i*ang]) reCylPart(r1,r2 + i/parts*rDiff,r2 + (i+1)/parts*rDiff,5,ang);
	}
}

re(50,20,2,30,0,360, $fn=32);
