// Automatic Transmission Model

use <../MCAD/involute_gears.scad>
use <../pins.scad>
use <../WriteScad/Write.scad>

tol=0.25;// tolerance for sliding
stol=0.1;// less tolerance for shaft
T=20;// thickness of gears
e=1;// extra space between gear faces
D=140;// outer diameter of anulus
ta=10;// thickness of rim of anulus
pd=8;// pin diameter
ph=15;// pin length
sd=14;// shaft diameter
re=3;// extra radius for shaft bushing
te=5;// thickness of end plates
psi=40;// angle of end plates
p=2*(T+e+tol)+te+3*e+2*tol;// shaft position of driver
rs=2+stol;// radius of snap sphere
lb=12;// length of brake
Trod=10;// thickness of crank
Lrod=50;// length of crank

na=60;// number of teeth on anulus
ns=24;// number of teeth on sun gears
np1=14;// number of teeth on planet 1
np2=na-ns-np1;// number of teeth on planet 2
ni=10;// number of teeth on idler

pitch=na/(D-2*ta);// diametral pitch of gear teeth
twistpitch=1;// number of teeth to twist across (can be non-integer)
phi=acos(((ns+ni)*(ns+ni)+(na-np1)*(na-np1)-(np1+ni)*(np1+ni))/(2*(ns+ni)*(na-np1)));
echo(str("Planet 2 teeth = ",np2));
echo(str("phi = ",phi));
echo(str("First Gear = ",na/np1,":1"));
echo(str("Second Gear = ",na/ns,":1"));
echo(str("Third Gear = ",na/(na - ns),":1"));
echo(str("Fourth Gear = ",na/(na - np1),":1"));
echo(str("Fifth Gear = ",1,":1"));
echo(str("Sixth Gear = ",1 - (np1*ns)/((na - np1)*(na - ns)),":1"));
echo(str("Reverse = ",(na*(np1 - na + ns))/(np1*ns),":1"));

//rotate([90,0,0])translate([0,0,-2*T])assembly();
//anulus();
//sun();
//carrier();
//planet1();
//planet2();
//idler();
//shaft();
//brace();
//front();
back();
//crank();
//handle();
//pin1();
//pin2();
//pin3();

module assembly(){
anulus();
sun();
translate([0,0,3*(T+e)+2*tol])rotate([180,0,180/ns])sun();
translate([0,0,2*(T+e)+tol])rotate([180,0,0])carrier();
for(i=[0:2])rotate([0,0,120*i]){
	translate([(na-np1)/pitch/2,0,0])planet1();
	rotate([0,0,-phi])translate([(ns+ni)/pitch/2,0,0])rotate([0,0,180/ni])idler();
	translate([(na-np1)/pitch/2,0,3*(T+e)+2*tol])rotate([180,0,0])planet2();
}
translate(-[0,0,1+te+3*e+2*tol+1*(T+e+tol)])shaft();
translate([Lrod/2,0,te+3*e+2*tol+4.5*(T+e+tol)])crank();
translate([Lrod,0,te+3*e+2*tol+4.5*(T+e+tol)+Trod])handle();
translate(-[0,0,te+3*e+tol])back();
translate([0,0,3*(T+e+tol)+te+3*e+tol])rotate([0,180,0])front();
for(i=[0,1])translate([0,0,3/2*(T+e+tol)])rotate([0,i*180,0])
	rotate([0,0,-psi])translate(-[sd/2+re,D/2+12,0])rotate([0,90,0])brace();
}

module front()
end(L1="4",L2="6");

module back()
end(L1="1",L2="3");

module end(L1="0",L2="0"){
difference(){
	union(){
		cylinder(r=sd/2+re,h=te+3*e);
		for(i=[-1,1])rotate([0,0,-90+i*psi]){
			translate(-[0,sd/2+re,0])cube([D/2/cos(psi),2*(sd/2+re),te]);
			translate([D/2/cos(psi),0,0])cylinder(r=sd/2+re,h=te);
		}
		translate(-[D*tan(psi)/2,sd/2+re+D/2,0])cube([D*tan(psi),2*(sd/2+re),te]);
	}
	translate([0,0,-1])hex(tol=tol,h=T);
	rotate([0,0,psi])translate(-[te/2-sd/2-re,D/2+12,-2])
		rotate([0,-90,0])cube([2*te,20-te+2*tol,te+2*tol],center=true);
	mirror([1,0,0])rotate([0,0,psi])translate(-[te/2-sd/2-re,D/2+12,-2])
		rotate([0,-90,0])cube([2*te,20-te+2*tol,te+2*tol],center=true);
	rotate([0,0,psi])translate([0,-22+te/2,te/2])brake(tol=tol);
	rotate([0,0,psi])translate([0,-22+te/2,te/2])
		rotate([0,90,0])translate([0,0,-te/2-4*tol])difference(){
			cylinder(r=lb-te/2+4*tol,h=te+8*tol);
			translate([0,te/2-25,0])cube(50,center=true);
		}
	rotate([0,180,psi-90])translate([-38,0,0])
		write(L1,h=T/3,t=2,center=true,font="../WriteScad/orbitron.dxf");
	rotate([0,180,psi-90])translate([-28,0,0])
		write(L2,h=T/3,t=2,center=true,font="../WriteScad/orbitron.dxf");
}
rotate([0,0,psi])translate([0,-22+te/2,te/2])brake(tol=0);
}

module brake(tol=0,s=1)
rotate([0,90,0])translate([0,0,-te/2-tol])
render()union(){
	difference(){
		if(s==1){
			cylinder(r=lb-te/2+tol,h=te+2*tol);
		} else {
			translate([te/2,-te/2,0])scale([s,1,1])cylinder(r=lb+tol,h=te+2*tol);
		}
		translate([20+te/2+tol,0,0])cube(40,center=true);
		translate([0,-20-te/2-tol,0])cube(40,center=true);
		if(tol==0)translate([0,-te,0])cube([te,te,10]);
	}
	cylinder(r=te/2+tol,h=te+2*tol,$fn=12);
	translate([0,0,te+2*tol])cylinder(r1=te/2+tol,r2=0,h=te/2+tol,$fn=12);
	mirror([0,0,1])cylinder(r1=te/2+tol,r2=0,h=te/2+tol,$fn=12);
}

module brace(){
difference(){
	union(){
		translate([0,0,te/2])cube([3*(T+e+tol)+2*(te+3*e+2*tol)+6,20,te],center=true);
		translate([-te-1,0,0])cube([2*te+2,10+te/2,te+2]);
	}
	for(i=[-1,1])for(j=[-1,1])translate([i*(3/2*(T+e+tol)+te/2+3*e+tol),j*10,0])
		cube([te+0.2,te,3*te],center=true);
	translate([0,10,te/2])rotate([180,0,0])brake(tol=tol);
	translate([0,10,te/2])brake(tol=tol);
	translate([10,0,0])rotate([0,180,0])
		write("2",h=T/3,t=2,center=true,font="../WriteScad/orbitron.dxf");
	translate([-10,0,0])rotate([0,180,0])
		write("R",h=T/3,t=2,center=true,font="../WriteScad/orbitron.dxf");
}
translate([0,10,te/2])brake(tol=0,s=0.6);
}

module shaft()
difference(){
	union(){
		cylinder(r=sd/2+stol,h=5.5*(T+e+tol)+1+2*(te+3*e+2*tol),$fn=30);
		cylinder(r=sd/2+2,h=1);// end cap
		translate([0,0,p+T/4+1])hex(tol=stol,h=T/2+e);
		translate([0,0,p+T/4+T/2+e+1])hex(tol=stol,h=T/2,f=0.5);
		translate([0,0,p+T/4+1])mirror([0,0,1])hex(tol=stol,h=T/2,f=0.5);
		translate([sd/sqrt(3)-rs,0,p+(T+e)/2+1])sphere(r=rs,$fn=24);// snap
		translate([-sd/sqrt(3)+rs,0,p+(T+e)/2+1])sphere(r=rs,$fn=24);// snap
	}
	translate([0,0,5.5*(T+e+tol)+1+2*(te+3*e+2*tol)])rotate([180,0,0])pinhole(r=pd/2,h=Trod,fixed=true);
	difference(){
		union(){
			shaftletter(L="2",p=0);
			rotate([0,0,90])shaftletter(L="4",p=0);
			shaftletter(L="5",p=1);
			shaftletter(L="3",p=2);
			rotate([0,0,90])shaftletter(L="6",p=2);
			shaftletter(L="5",p=3);
			shaftletter(L="1",p=4);
			rotate([0,0,90])shaftletter(L="R",p=4);
		}
		cylinder(r=sd/2+stol-0.3,h=5.5*(T+e+tol)+1+2*(te+3*e+2*tol),$fn=30);
	}
}

module shaftletter(L="0",p=0)
for(i=[0,1])translate([0,0,(5.25-0.5*p)*(T+e+tol)+1+2*(te+3*e+2*tol)])rotate([180,0,i*180])
	writecylinder(text=L,radius=sd/2+stol,h=T/3,t=2,font="../WriteScad/orbitron.dxf");

module crank()
translate([0,0,Trod/2])difference(){
	union(){
		cube([Lrod,Trod,Trod],center=true);
		translate([Lrod/2,0,0])cylinder(r=sd/2,h=Trod,center=true);
		translate([-Lrod/2,0,0])cylinder(r=sd/2,h=Trod,center=true);
	}
	translate([-Lrod/2,0,-Trod/2])pinhole(r=pd/2,h=Trod,fixed=true);
	rotate([180,0,0])translate([Lrod/2,0,-Trod/2])pinhole(r=pd/2,h=Trod,fixed=true);
}

module handle()
difference(){
	cylinder(r=sd/2,h=30);
	pinhole(r=pd/2,h=Trod,tight=false);
}

module anulus()
difference(){
	cylinder(r=D/2,h=2*T,$fn=na);
	translate([0,0,-0.01])HBgear(n=na,tol=-tol);
	difference(){
		translate([0,0,D/2+1+T-0.02])cube(D+2,center=true);
		translate([D/2,0,T-3])rotate([45,0,0])cube(10,center=true);
	}
	for(i=[0:3])translate([0,0,T/2])rotate([180,0,i*360/4])
		writecylinder(text="Output",radius=D/2,h=T/2,t=0.6,space=1.1,
			font="../WriteScad/orbitron.dxf");
}

module sun()
difference(){
	union(){
		HBgear(n=ns,tol=tol);
		cylinder(r=sd/2+3,h=T+e);
	}
	translate([0,0,-T])hex(tol=tol,h=3*T);
	snaps();
	translate([0,0,-0.01])difference(){// brake
		cylinder(r=20,h=5);
		cylinder(r1=10,r2=15,h=5);
		translate([0,-2,0])cube([30,4,10]);
	}
}

module carrier()
difference(){
	union(){
		for(i=[0:2])rotate([0,0,120*i]){
			difference(){
				union(){
					rotate([0,0,12]){
						translate([0,-20,0])cube([42,40,T+e]);
						translate([42,0,0])cylinder(r=20,h=T+e);
						translate([56,0,(T+e)/2])rotate([90,0,0])cylinder(r=T/2,h=3,center=true);
					}
					translate([(na-np1)/pitch/2,0,0])cylinder(r=pd/2+2,h=T+2*e);
					rotate([0,0,phi])translate([(ns+ni)/pitch/2,0,0])cylinder(r=pd/2+2,h=T+2*e);
				}
				translate([(na-np1)/pitch/2,0,0])pinhole(r=pd/2,h=2*T,tight=false);
				rotate([0,0,phi])translate([(ns+ni)/pitch/2,0,T+2*e])rotate([180,0,0])
					pinhole(r=pd/2,h=T+2*e,fixed=true);
			}
		}
	}
	translate([0,0,-T])hex(tol=tol,h=3*T);
	snaps();
}

module planet1()
difference(){
	HBgear(n=np1,tol=tol);
	translate([0,0,T])rotate([180,0,0])pinhole(r=pd/2,h=T,fixed=true);
}

module planet2()
difference(){
	union(){
		mirror([0,1,0])HBgear(n=np2,tol=tol);
		cylinder(r=pd/2+2,h=T+e);
	}
	translate([0,0,T+e])rotate([180,0,0])pinhole(r=pd/2,h=T+e,fixed=true);
}

module idler()
difference(){
	mirror([0,1,0])HBgear(n=ni,tol=tol);
	translate([0,0,T])rotate([180,0,0])pinhole(r=pd/2,h=T,tight=false);
}

module pin1()
longpin(l=3*(T+e)+2*tol);

module pin2()
longpin(l=2*(T+e)+tol);

module pin3()
pinpeg(r=pd/2,h=2*Trod);

module longpin(l=50)
union(){
	translate([0,l/2-ph,0])pin_horizontal(r=pd/2,h=ph);
	pinshaft(r=pd/2,h=l-2*ph+0.2,side=true);
	rotate([0,0,180])translate([0,l/2-ph,0])pin_horizontal(r=pd/2,h=ph);
}

module hex(tol=0,h=10,f=1)
cylinder(r1=(sd/2+tol)/cos(30),r2=f*(sd/2+tol)/cos(30),h=h,$fn=6);

module snaps()
for(i=[0:5])rotate([0,0,60*i]){
	translate([sd/sqrt(3)-rs,0,0])sphere(r=rs+tol,$fn=24);
	translate([sd/sqrt(3)-rs,0,(T+e)/2])sphere(r=rs+tol,$fn=24);
	translate([sd/sqrt(3)-rs,0,T+e])sphere(r=rs+tol,$fn=24);
}

module HBgear(n=20,tol=.25)// herringbone gear
translate([0,0,T/2])
union(){
	gear(number_of_teeth=n,
		diametral_pitch=pitch,
		gear_thickness=T/2,
		rim_thickness=T/2,
		hub_thickness=T/2,
		bore_diameter=0,
		backlash=2*tol,
		clearance=2*tol,
		pressure_angle=20,
		twist=360*twistpitch/n,
		slices=10);
	mirror([0,0,1])
	gear(number_of_teeth=n,
		diametral_pitch=pitch,
		gear_thickness=T/2,
		rim_thickness=T/2,
		hub_thickness=T/2,
		bore_diameter=0,
		backlash=2*tol,
		clearance=2*tol,
		pressure_angle=20,
		twist=360*twistpitch/n,
		slices=10);
}
