//  Modules for the valueframe series of aluminium extrusions
//  valueframe.co.uk
//  
//  Author - Damian Axford


// Reference data per section
//  0-width in x
//  1-width in y
//  2-bore radius
//  3-wall thickness
//  4-slot depth
//  5-slot width (opening)
//  6-t width  (widest opening)
//  7-corner radius
//  8-skin thickness
//  9-which sides are solid  =  all=0, 1=1N, ,2=2N90, 3=2N180    (relative to x)
//  10 - distance between slot centres

P5_20x20 = [20, 20, 4.3/2, 1.8, 6.35, 5, 11.5, 1, 1, 0, 20];
P5_20x201N = [20, 20, 4.3/2, 1.8, 6.35, 5, 11.5, 1, 1, 1, 20];
P5_20x202N90 = [20, 20, 4.3/2, 1.8, 6.35, 5, 11.5, 1, 1, 2, 20];
P5_20x202N180 = [20, 20, 4.3/2, 1.8, 6.35, 5, 11.5, 1, 1, 3, 20];
P5_20x40 = [20, 40, 4.3/2, 1.8, 6.35, 5, 11.5, 1, 1, 0, 20];
P5_40x40 = [40, 40, 4.3/2, 1.8, 6.35, 5, 11.5, 1, 1, 0, 20];
P5_20x60 = [20, 60, 4.3/2, 1.8, 6.35, 5, 11.5, 1, 1, 0, 20];
P5_40x60 = [40, 60, 4.3/2, 1.8, 6.35, 5, 11.5, 1, 1, 0, 20];
P5_20x80 = [20, 80, 4.3/2, 1.8, 6.35, 5, 11.5, 1, 1, 0, 20];


// example
//valueFrameProfile(P5_20x20, 100);



module valueFrameSlot(d,slot,t,wall,skinned,skin) {
	polygon(points=[ [skinned?-skin:1,slot/2],
					[skinned?-skin:1,-slot/2],
					[-wall,-slot/2],
					[-wall,-t/2],
					[-wall-skin,-t/2],
					[-d,-slot/2],
					[-d,slot/2],
					[-wall-skin,t/2],
					[-wall,t/2],
					[-wall,slot/2]], 
			paths=[[0,1,2,3,4,5,6,7,8,9]]);
}

module valueFrameHollow(d,slot,t,wall,centres) {
	polygon(points=[ [-wall,-wall/2],
					[-d-wall,-d],
					[-d - (centres-2*d)+wall,-d],
					[-d -(centres-2*d)+wall,d],
					[-d-wall,d],
					[-wall,wall/2]], 
			paths=[[0,1,2,3,4,5]]);
}

module valueFrameProfile(profile, l) {
	$fn=8;

	x=profile[0];
	y=profile[1];
	bore=profile[2];
	wall=profile[3];
	d=profile[4];
	slot=profile[5];
	t=profile[6];
	corner=profile[7];
	skin=profile[8];
	sides=profile[9];
	centres=profile[10];

	xSlots = x / centres;
	xSlotStart = -x/2 + centres/2;
	ySlots = y / centres;
	ySlotStart = -y/2 + centres/2;

	xHollows = xSlots>1?xSlots-1:0;
	yHollows = ySlots>1?ySlots-1:0;

	color("silver") linear_extrude(height=l) {
		
		difference() {		

			hull() {
				// corners
				translate([x/2-corner,y/2-corner,0]) circle(r=corner);
				translate([-x/2+corner,y/2-corner,0]) circle(r=corner);
				translate([-x/2+corner,-y/2+corner,0]) circle(r=corner);
				translate([x/2-corner,-y/2+corner,0]) circle(r=corner);
			}

			// slots
			// y
			for (i=[0:ySlots-1]) {
				translate([0,ySlotStart+i*centres,0]) {
					translate([x/2,0,0]) valueFrameSlot(d,slot,t,wall,sides>0?true:false,skin);
					rotate([0,0,180]) translate([x/2,0,0]) valueFrameSlot(d,slot,t,wall,sides==3?true:false,skin);
				}
			}

			// x
			for (i=[0:xSlots-1]) {	
				translate([xSlotStart+i*centres,0,0]) {
					rotate([0,0,90]) translate([y/2,0,0]) valueFrameSlot(d,slot,t,wall,sides==2?true:false,skin);
					rotate([0,0,270]) translate([y/2,0,0]) valueFrameSlot(d,slot,t,wall,false,skin);
				}
			}

			// bores
			for (i=[0:xSlots-1]) {
				for (j=[0:ySlots-1]) {
					translate([xSlotStart+i*centres,ySlotStart+j*centres,0]) circle(r=bore);
				}
			}

			// hollows
			for (i=[0:xHollows]) 
				for (j=[0:yHollows]) {
			
				
				translate([xSlotStart+centres/2+i*centres,ySlotStart+centres/2 +j*centres,0]) {
					if (j < yHollows) {
						valueFrameHollow(d,slot,t,wall,centres);
						translate([-centres,0,0]) rotate([0,0,180]) valueFrameHollow(d,slot,t,wall,centres);
					}
				
					if (i < xHollows) {
						rotate([0,0,90]) valueFrameHollow(d,slot,t,wall,centres);
						translate([0,-centres,0]) rotate([0,0,270]) valueFrameHollow(d,slot,t,wall,centres);
					}
				}

			}

		}
	}
}


