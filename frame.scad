
frameW = 20;
frameWall = 1;

module frameTube(l=100) {
	w = frameW;

	translate([-w/2,-w/2,0]) difference() {
		cube([w,w,l]);
		translate([frameWall, frameWall, -1]) cube([w-2*frameWall, w-2*frameWall, l+2]);
	}
}


module frame() {

	frameTube(l=100);

}


frame();