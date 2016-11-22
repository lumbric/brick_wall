// everything in cm

//
WIDTH = 10;
HEIGHT = 7;
DEPTH = 6;

DOOR_HEIGHT = 242.;
DOOR_WIDTH = 152.;
DOOR_FRAME = 30.;

TOTAL_HEIGHT = 249.4;
TOTAL_WIDTH = 167.0;

GAP = 1;
GAP_DEPTH = 5.; // approx. 0.75 * DEPTH;
GAP_DEPTH = 0.75 * DEPTH;

ROWS = ceil(TOTAL_HEIGHT / (HEIGHT + GAP));
COLS = ceil(TOTAL_WIDTH/ (WIDTH + GAP));

// how to deal with breathing shifts (eg. print to allow easier measuring)
Z_SHIFT_MODE = "label";   // on of stdout, label, shift

MAX_BREATH_DEPTH = 0.9 * GAP_DEPTH * (COLS-1)/2.;

time = $t;  // a value between 0 and 1, represents breathing state



door();
wall();
//brick();

// old function with circle function
//function z(row, col) = max_z +
//    max(-max_z, -10. *
//            sqrt(pow((col - COLS/2.), 2) +
//                pow((row - ROWS/2.), 2)));
//


// distance to center
function dist(row, col) =
    sqrt(
        // +0.5 compensates for x-shift of even rows
        pow(((col - COLS/2 + 0.5) * (WIDTH + GAP)), 2) +
        pow(((row - ROWS/2)* (HEIGHT+ GAP)), 2)
    );

base = 7;
max_dist = min((COLS - 1) * (GAP + WIDTH) / 2., ROWS * (GAP + HEIGHT)/ 2.);

// wow this is not z... just thought this must be z... actually it is y...
// Z is used for depth!
function z(row, col) =
    dist(row, col) > max_dist ?
    0 :
    time * MAX_BREATH_DEPTH * (pow(base, -pow(dist(row, col)/max_dist, 2) - 1./base));


if (Z_SHIFT_MODE == "stdout") {
    echo(str("time=", time));
    echo(str("rows=", ROWS));
    echo(str("cols=", COLS));
    for (i = [0:ROWS-1])
        echo(str("row=", i, ": ", str([for (j = [0:COLS-1]) (z(i, j))])));
}


module brick() {
    translate([-WIDTH/2., 0., 0.]) {
        color("red")
             cube([WIDTH, DEPTH, HEIGHT]);
        gap_gemisou();
    }

    //zlabel(0.234234);
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
    translate([-(COLS+0.5) * (GAP + WIDTH)/2., 0., 0.])
        for (i = [0:ROWS-1]) {
            for (j = [0:COLS-1]) {
                translate([
                        j * (WIDTH + GAP) + 0.5 * WIDTH * (i % 2),
                        z(i, j),
                        i * (HEIGHT + GAP)])
                    brick(z(i, j));
            }
        }
}


module door() {
    translate([-DOOR_WIDTH/2 - DOOR_FRAME, -DOOR_FRAME, 0.])
        color("black")
        difference() {
            cube([DOOR_WIDTH + 2*DOOR_FRAME, DOOR_FRAME, DOOR_HEIGHT + DOOR_FRAME]);
            translate([DOOR_FRAME, -DOOR_FRAME, -DOOR_HEIGHT])
            cube([DOOR_WIDTH, 3 * DOOR_FRAME, 2*DOOR_HEIGHT]);
        }
}
