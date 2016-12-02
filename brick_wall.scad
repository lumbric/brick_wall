// everything in cm
// note that variable names x/y are used for columns/rows of bricks and z is
// used for breathing direction, but this is not the axis of OpenSCAD

// dimensions of brick
WIDTH = 10;
HEIGHT = 6;
DEPTH = 8;

ENABLE_DOOR = false;

DOOR_HEIGHT = 202.5;
DOOR_WIDTH = 90.;
DOOR_FRAME = 30.;

// total dimensions of wall
TOTAL_HEIGHT = 203;
TOTAL_WIDTH = 99;

GAP = 1;
GAP_DEPTH = DEPTH - GAP;

ROWS = ceil(TOTAL_HEIGHT / (HEIGHT + GAP));
COLS = ceil(TOTAL_WIDTH/ (WIDTH + GAP));

// how to deal with breathing shifts (eg. print to allow easier measuring)
Z_SHIFT_MODE = "all";   // one of stdout, label, shift, all

// "relative" means relative to lower left brick
Z_LABEL = "relative_right";  // one of absolute, relative

// this calculation is just and approximation and correct by the factor
MAX_BREATH_DEPTH = 1. * GAP_DEPTH * (COLS-2)/2.;

// this makes the hill more steep if the value is higher
BREATHING_BASE = 25;

// how many walls do we want including the flat one?
NUMBER_OF_WALLS = 4;


// ---------------------------------------------------------------------------

// time is a value between 0 and 1, represents breathing state
// Set via  0 <= wall_number <= NUMBER_OF_WALLS - 1 using -D as command line parameter
// or if not set can be used for interactive animation in OpenSCAD
wall_number = -1;
time = (wall_number != -1) ?
    wall_number / (NUMBER_OF_WALLS - 1) :
    $t;

door_shift = -(HEIGHT + GAP) * (ROWS-1)/2. - GAP;

echo(str("total number of rows =", ROWS));
echo(str("total number of cols=", COLS));


if (ENABLE_DOOR)
    door();
wall();
//brick();   // just for testing
print_to_stdout();
title();




// distance to center
function dist(x, y) = sqrt(x*x + y*y);
        // +0.5 compensates for x-shift of even rows

        //pow(((col - COLS/2 + 0.5) * (WIDTH + GAP)), 2) +
        //pow(((row - ROWS/2)* (HEIGHT+ GAP)), 2)


max_x_dist = (COLS - 2) * (GAP + WIDTH) / 2.;
max_y_dist = (ROWS - 3) * (GAP + HEIGHT)/ 2.;

// wow this is not z... just thought this must be z... actually it is y...
// Z is used for depth!
//
// this is something like a 2D Gaussian curve
function z(x, y) =
    dist(x/max_x_dist, y/max_y_dist) > 1 ?
    0 :
    time * MAX_BREATH_DEPTH * (pow(BREATHING_BASE, -pow(dist(x/max_x_dist, y/max_y_dist), 2)
                - 1./BREATHING_BASE));


module print_to_stdout() {
    // this is probably only helpful if post processed and converted to CSV or so
    if (Z_SHIFT_MODE == "stdout" || Z_SHIFT_MODE == "all") {
        echo(str("time=", time));
        for (i = [0:ROWS-1])
            echo(str("row=", i, ": ", str([for (j = [0:COLS-1]) (z(i, j))])));
    }
}

module title() {
    msg = (wall_number != -1) ? str(Z_LABEL, ", wall nr=", wall_number) : str(Z_LABEL);
    translate([0., -DOOR_FRAME, DOOR_HEIGHT + door_shift + DOOR_FRAME/2.])
        rotate([90., 0., 0.])
            text(str(msg),
                    halign="center", valign="center");
}

module brick(x, y) {
    z_shift = z(x, y);
    translate([x, Z_SHIFT_MODE == "shift" || Z_SHIFT_MODE == "all" ? z_shift : 0., y]) {
        translate([-WIDTH/2., 0., 0.]) {
            color("white")
                 cube([WIDTH, DEPTH, HEIGHT]);
            gap_gemisou();
        }

        if (Z_SHIFT_MODE == "label" || Z_SHIFT_MODE == "all") {
            labeltxt =
            Z_LABEL == "absolute" ?
                z_shift :
                (Z_LABEL == "relative" ?
                    z_shift - z(x - (WIDTH + GAP)/2., y - HEIGHT - GAP) :
                    // Z_LABEL == "relative_right"
                    z_shift - z(x + (WIDTH + GAP), y));

            if (labeltxt != 0)
                zlabel(labeltxt);
        }
    }
}


module zlabel(label) {
    color("black")
        translate([0., 0., HEIGHT/2.])
        rotate([90., 0., 0.])
             text(str(round(label * 10) / 10.),
                     size=0.3 * HEIGHT, halign="center", valign="center");
}


module gap_gemisou() {
    // name hint: "gemi sou! (greek) = fill yourself!"
    color("grey") {
        translate([-GAP, DEPTH - GAP_DEPTH, -GAP])
            cube([GAP, GAP_DEPTH, HEIGHT + GAP]);
        translate([0., DEPTH - GAP_DEPTH, -GAP])
            cube([WIDTH, GAP_DEPTH, GAP]);
    }
}


module wall() {
    translate([0., 0., 0.])
        for (i = [0:ROWS-1]) {
            for (j = [0:COLS-1]) {
                brick(
                        x=(j + 0.5 * (i % 2) - 0.25) * (WIDTH + GAP) -  (COLS-1) * (WIDTH + GAP)/2.,
                        y=(HEIGHT + GAP) * (i - (ROWS-1)/2.)
                );
            }
        }
}


module door() {
    translate([-DOOR_WIDTH/2 - DOOR_FRAME, -DOOR_FRAME, door_shift])
        color("black")
        difference() {
            cube([DOOR_WIDTH + 2*DOOR_FRAME, DOOR_FRAME, DOOR_HEIGHT + DOOR_FRAME]);
            translate([DOOR_FRAME, -DOOR_FRAME, -DOOR_HEIGHT])
            cube([DOOR_WIDTH, 3 * DOOR_FRAME, 2*DOOR_HEIGHT]);
        }
}
