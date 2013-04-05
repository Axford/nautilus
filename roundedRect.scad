
module roundedRect(size, radius) {
x = size[0];
y = size[1];
z = size[2];

linear_extrude(height=z)
hull() {
translate([radius, radius, 0])
circle(r=radius);

translate([x - radius, radius, 0])
circle(r=radius);

translate([x - radius, y - radius, 0])
circle(r=radius);

translate([radius, y - radius, 0])
circle(r=radius);
}
}