
use <vector.scad>
use <maths.scad>

fudge = 0.01;

// result is u-v
function subv(u,v) = [u[0]-v[0], u[1]-v[1], u[2]-v[2]];


module torusSlice(r1, r2, start_angle, end_angle, convexity=10) {
	rx = r1 + r2;
    ry = rx;
    trx = rx* sqrt(2) + 1;
    try = ry* sqrt(2) + 1;
    a0 = (4 * start_angle + 0 * end_angle) / 4;
    a1 = (3 * start_angle + 1 * end_angle) / 4;
    a2 = (2 * start_angle + 2 * end_angle) / 4;
    a3 = (1 * start_angle + 3 * end_angle) / 4;
    a4 = (0 * start_angle + 4 * end_angle) / 4;
    if(end_angle > start_angle)
        intersection() {
			rotate_extrude(convexity=convexity) translate([r1,0,0]) circle(r2);

			translate([0,0,-r2-1])
			linear_extrude(height=2*r2+2)
        		polygon([
		            [0,0],
		            [trx * cos(a0), try * sin(a0)],
		            [trx * cos(a1), try * sin(a1)],
		            [trx * cos(a2), try * sin(a2)],
		            [trx * cos(a3), try * sin(a3)],
		            [trx * cos(a4), try * sin(a4)],
		            [0,0]
		       ]);
    }
}


module pipeSegment(start,end,od,id,beginning=true) {
	dir = subv(end,start);
	l = mod(dir); 
	
	translate(start) orientate(dir) translate([0,0,beginning?0:l/2]) cylinder(h=l/2 + fudge,r=od/2);	
}

module drawVec(v1, start=[0,0,0]) {
	hull() {
		sphere();
		translate(v1) sphere();
	}
}

function vec3_from_vec4(v) = [v[0], v[1], v[2]];
function vec4_from_vec3(v) = [v[0], v[1], v[2], 1];

module pipeOrientate(v1,v2)
{
	// calc orientate for v1
	v1axis = cross([0,0,1], v1);
	v1ang = anglev([0,0,1], v1);
	
	v1axisLen = mod(v1axis);
	
	// apply reverse rotation to v2
	// calculate rotation of v2 around z axis
	
	// v2 as vec4	
	vec2 = vec4_from_vec3(v2);
	
	// make quat to reverse the final rotation
	qRev = quat(v1axis, v1ang);
	qRevMat = quat_to_mat4(qRev);

	//echo("ang ", v1ang);
	
	// rotate v2 by qRev
	vec2Rev = v1axisLen>0 ? vec4_mult_mat4(vec2, qRevMat) : vec2;

	// look and x,y components of vec2Rev and calc rot about z
	theta = atan2(vec2Rev[1], vec2Rev[0]);
	//echo("theta = ",theta);
	
	// complete the two rotations
    rotate(a=v1ang, v=v1axis)
	  rotate(a=theta<0 || theta>0?theta:0, v=[0,0,1])
         child(0);
}

module pipeCurve(start,mid,end,r, od,id,isLastSegment=false) {
	dir1 = subv(mid,start);
	dir2 = subv(end,mid);
	l1 = mod(dir1);
	l2 = mod(dir2);
	ang = anglev(dir1,dir2);
	vref = [0,0,1];

	dir1u = unitv(dir1);
	dir2u = unitv(dir2);

	inset = r * tan(ang/2);
	
	
	rAxis = cross(dir1,dir2);

	rStart = start + (l1-inset)*dir1u;
	rZAng = anglev(dir1,[1,0,0]) - 90;
	
	
	// start
	translate(start) orientate(dir1) translate([0,0,l1/2]) cylinder(h=l1/2-inset,r=od/2);

	//end
	translate(mid) orientate(dir2) translate([0,0,inset]) cylinder(h=l2/2-inset,r=od/2);
	
	
	// curved section
	// nb: torus slice always starts at x axis and goes counter clockwise around z
	translate(rStart) 
	pipeOrientate(dir1,dir2)
	rotate([0,0,180])  // rotate to lie along x
	rotate([90,0,0]) // flip up
	translate([-r,0,0]) torusSlice(r, od/2, 0, ang);
}


module curvedPipe(points, segments, radii, od, id) {
	union() {
		for (point = [0:segments-2]) 
			pipeCurve(points[point],points[point+1],points[point+2],radii[point],od,id);
	
		//start
		pipeSegment(points[0],points[1],od,id,beginning=true);
	
		//end
		pipeSegment(points[segments-1],points[segments],od,id,beginning=false);
	}
}



//test piece
*curvedPipe([ [50,0,0],
			[100,0,0],
			[100,100,0],
			[50,100,100],
			[50,100,150],
			[0,100,50],
			[0,0,0],
			[50,0,0]
		   ],
            7,
			[30,30,30,6,50,30],
		    10,
			8);

