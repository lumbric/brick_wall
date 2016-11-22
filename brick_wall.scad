// everything in cm


// dimensions of brick
WIDTH = 10;
HEIGHT = 6;
DEPTH = 8;

DOOR_HEIGHT = 202.5;
DOOR_WIDTH = 90.;
DOOR_FRAME = 30.;

// total dimensions of wall
TOTAL_HEIGHT = 203;
TOTAL_WIDTH = 99;

GAP = 1;
GAP_DEPTH = 5.; // approx. 0.75 * DEPTH;
GAP_DEPTH = 0.75 * DEPTH;

ROWS = ceil(TOTAL_HEIGHT / (HEIGHT + GAP));
COLS = ceil(TOTAL_WIDTH/ (WIDTH + GAP));

// how to deal with breathing shifts (eg. print to allow easier measuring)
Z_SHIFT_MODE = "shift";   // on of stdout, label, shift

MAX_BREATH_DEPTH = 0.9 * GAP_DEPTH * (COLS-1)/2.;

time = $t;  // a value between 0 and 1, represents breathing state


echo(str("total number of rows =", ROWS));
echo(str("total number of cols=", COLS));


door();
wall();
print_to_stdout();



// distance to center
function dist(x, y) = sqrt(x*x + y*y);
        // +0.5 compensates for x-shift of even rows

        //pow(((col - COLS/2 + 0.5) * (WIDTH + GAP)), 2) +
        //pow(((row - ROWS/2)* (HEIGHT+ GAP)), 2)


base = 7;
max_dist = min((COLS - 2) * (GAP + WIDTH) / 2., (ROWS - 2) * (GAP + HEIGHT)/ 2.);

// wow this is not z... just thought this must be z... actually it is y...
// Z is used for depth!
//
// this is something like a 2D Gaussian curve
function z(x, y) =
    dist(x, y) > max_dist ?
    0 :
    time * MAX_BREATH_DEPTH * (pow(base, -pow(dist(x, y)/max_dist, 2) - 1./base));


module print_to_stdout() {
    // this is probably only helpful if post processed and converted to CSV or so
    if (Z_SHIFT_MODE == "stdout") {
        echo(str("time=", time));
        for (i = [0:ROWS-1])
            echo(str("row=", i, ": ", str([for (j = [0:COLS-1]) (z(i, j))])));
    }
}


module brick(x, y) {
    z_shift = z(x, y);
    translate([x, Z_SHIFT_MODE == "shift" ? z_shift : 0., y]) {
        translate([-WIDTH/2., 0., 0.]) {
            color("red")
                 cube([WIDTH, DEPTH, HEIGHT]);
            gap_gemisou();
        }


        if (Z_SHIFT_MODE == "label" && z_shift > 0.)
            zlabel(z_shift);
    }
}


module zlabel(label) {
    translate([0., 0., HEIGHT/2.])
    rotate([90., 0., 0.])
         text(str(round(label * 100) / 100.),
                 size=0.3 * HEIGHT, halign="center", valign="center");
}


module gap_gemisou() {
    // name hint: "gemi sou! (greek) = fill yourself!"
    translate([WIDTH, DEPTH - GAP_DEPTH, 0.])
        cube([GAP, GAP_DEPTH, HEIGHT + GAP]);
    translate([0., DEPTH - GAP_DEPTH, HEIGHT])
        cube([WIDTH, GAP_DEPTH, GAP]);
}


module wall(){
    translate([0., 0., 0.])
        for (i = [0:ROWS-1]) {
            for (j = [0:COLS-1]) {
                brick(
                        x=(j + 0.5 * (i % 2)) * (WIDTH + GAP) -  (COLS-1) * (WIDTH + GAP)/2.,
                        y=(HEIGHT + GAP) * (i - (ROWS-1)/2.)
                );
            }
        }
}


module door() {
    translate([-DOOR_WIDTH/2 - DOOR_FRAME, -DOOR_FRAME, -(HEIGHT + GAP) * (ROWS-1)/2.])
        color("black")
        difference() {
            cube([DOOR_WIDTH + 2*DOOR_FRAME, DOOR_FRAME, DOOR_HEIGHT + DOOR_FRAME]);
            translate([DOOR_FRAME, -DOOR_FRAME, -DOOR_HEIGHT])
            cube([DOOR_WIDTH, 3 * DOOR_FRAME, 2*DOOR_HEIGHT]);
        }
}
