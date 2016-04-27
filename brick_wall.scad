WIDTH = 48;
HEIGHT = 23.8;
DEPTH = 24;
GAP = 10;
ROWS = 29;
COLS = 7;

FRAMES_Z_MAX = [30, 50, 70, 90, 110];

Z_MAX_ANIMATION_STEP = 200;
Z_MAX_ANIMATION_OFFSET = 30;

max_z = $t * Z_MAX_ANIMATION_STEP + Z_MAX_ANIMATION_OFFSET;

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
    cube([WIDTH, HEIGHT, DEPTH]);
}
