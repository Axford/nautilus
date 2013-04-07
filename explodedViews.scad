// Borrowed from nophead / Mendel90 utils.scad


//
// Exploded view helper
//
module explode(v, offset = [0,0,0]) {
    if(exploded) {
        translate(v)
            child();
        render() hull() {
            sphere(0.2);
            translate(v + offset)
                sphere(0.2);
        }
    }
    else
        child();
}


//
// Same again as cant appear twice in the tree
//
module explode2(v, offset = [0,0,0]) {
    if(exploded) {
        translate(v)
            child();
        render() hull() {
            sphere(0.2);
            translate(v + offset)
                sphere(0.2);
        }
    }
    else
        child();
}


