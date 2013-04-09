
use <vector.scad>
use <maths.scad>
use <moreShapes.scad>

fudge = 0.01;

// result is u-v
function subv(u,v) = [u[0]-v[0], u[1]-v[1], u[2]-v[2]];



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
	
	v1axis = v1[0]==0 && v1[1] == 0 ? [0,1,0] : cross([0,0,1], v1);
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

module pipeCurve(points,point,radii, od,id,isLastSegment=false) {
	pre = points[point-1];
	start = points[point];
	mid = points[point+1];
	end = points[point+2];

	post = points[point+3];
	preR = radii[point-1];
	r = radii[point];	
	postR = radii[point+1];

	dir1 = subv(mid,start);
	dir2 = subv(end,mid);
	l1 = mod(dir1);
	l2 = mod(dir2);
	ang = anglev(dir1,dir2);

	preDir = pre? subv(start,pre) : dir1;
	preAng = pre? anglev(preDir, dir1) : 0;
	preInset = pre? preR * tan(preAng/2) : 0;
	
	postDir = post? subv(post,end) : dir2;
	postAng = post? anglev(dir2, postDir) : 0;
	postInset = post? postR * tan(postAng/2) : 0;
	

	dir1u = unitv(dir1);
	inset = r * tan(ang/2);
	rStart = start + (l1-inset)*dir1u;
	
	// start
	translate(start) orientate(dir1) translate([0,0,preInset]) cylinder(h=l1-preInset-inset,r=od/2);

	//end
	translate(mid) orientate(dir2) translate([0,0,inset]) cylinder(h=l2-postInset-inset,r=od/2);
	
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
			pipeCurve(points,point,radii,od,id);
	}
}



//test pieces
*curvedPipe([ [0,0,0],
			[100,0,0],
			[100,100,0],
			[50,100,100],
			[50,100,150],
			[0,100,50],
			[0,0,0],
			[50,0,50]
		   ],
            7,
			[70,30,30,6,50,30],
		    10,
			8);


curvedPipe([ [0,0,0],
			[100,0,0],
			[100,100,0],
			[100,100,100],
			[0,100,100],
			[0,100,0],
			[0,0,0],
			[50,0,50]
		   ],
            7,
			[70,30,30,6,50,30],
		    10,
			8);

