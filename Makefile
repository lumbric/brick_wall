all:
	for z in 30 50 70 90 110 ; do \
		openscad -o brick_wall_$$z.stl brick_wall.scad -D max_z=$$z ; \
	done

