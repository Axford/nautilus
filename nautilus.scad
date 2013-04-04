
plastic = "yellow";


module bottleCap() {
	neckOD=26;
	wall = 1;
	h = 5;
	difference() {
		translate([0,0,-h+wall]) cylinder(h=h, r1=neckOD/2+2*wall, r2=neckOD/2+wall);
		translate([0,0,-h]) cylinder(h=h, r1=neckOD/2+2*wall, r2=neckOD/2+wall);
	}
}

module bottle() {
	// 330ml
	dia = 58;
	h = 225;
	
	//500 ml
	dia = 68.4;
	h = 259.4;

	neckOD = 26;
	$fn=32;

	h1 = h*0.52;
	h2 = h - 20;
	r2 = neckOD/2;
	h3 = h - 15;
	r3 = neckOD/2;
	h4 = h-10;
	r4 = neckOD/2 + 2;
	
	

	wall = 3;

	union() {
		color([1,0.8,0.5,0.9]) {
			cylinder(r=dia/2, h=h1);
			translate([0,0,h1]) cylinder(h=h2-h1, r1=dia/2, r2=r2);
			translate([0,0,h2]) cylinder(h=h3-h2, r1=r2, r2=r3);
			translate([0,0,h3]) cylinder(h=h4-h3, r1=r3, r2=r4);
			translate([0,0,h4]) cylinder(h=h-h4, r1=r4, r2=neckOD/2);
		}

		translate([0,0,h]) bottleCap();
	}

}


module crateOfBottles() {
	offset = 68.4 + 5;
	for (x=[0:3]) {
		for (y=[0:2]) {
			translate([x*offset, y*offset, 0]) bottle();
		}
	}
}

//crateOfBottles();


module b608(h=7) {
	color("silver") difference() {
		cylinder(r=22.1/2, h=h);
		translate([0,0,-1]) cylinder(h=h+2, r=7.9/2);
	}
}

module axle(l=100) {
	w = 5;
	color("grey") translate([-w/2,-w/2,0]) cube([w,w,l]);
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

//axle();
//b608();
//axleBushing();
