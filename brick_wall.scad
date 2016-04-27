WIDTH = 48;
HEIGHT = 23.8;
DEPTH = 24;
GAP = 4;
ROWS = 29;
COLS = 7;
GAP_DEPTH = 0.75 * DEPTH;

FRAMES_Z_MAX = [30, 50, 70, 90, 110];

Z_MAX_ANIMATION_STEP = 200;
Z_MAX_ANIMATION_OFFSET = 0;

time = $t;
max_z = time * Z_MAX_ANIMATION_STEP + Z_MAX_ANIMATION_OFFSET;

for (i = [0:ROWS]) {
    for (j = [0:COLS]) {
        translate([
                j * (WIDTH + GAP) + 0.5 * WIDTH * (i % 2),
                z(i, j),
                i * (HEIGHT + GAP)])
            brick();
    }
}

// wow this is not z... just thought this must be z... actually it is y...
function z(row, col) = min(max_z, 20. * sqrt(pow((col - COLS/2.), 2) + pow((row - ROWS/2.), 2)));

module brick() {
    color("red")
         cube([WIDTH, DEPTH, HEIGHT]);
    gap_gemisou();
}

module gap_gemisou() {
    translate([WIDTH, 0., 0.])
        cube([GAP, GAP_DEPTH, HEIGHT + GAP]);
    translate([0., 0., HEIGHT])
        cube([WIDTH, GAP_DEPTH, GAP]);
}
