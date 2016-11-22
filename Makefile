all: png

stl:
	for t in 0 1 2 3; do \
		openscad -o brick_wall_$$t.stl brick_wall.scad -D wall_number=$$t ; \
	done

png:
	for t in 0 1 2 3; do \
		openscad -o brick_wall_$$t.png brick_wall.scad \
		--imgsize=768,1024 \
		--viewall \
		--projection=ortho\
		--camera=100,-400,100,0,0,0 \
		--autocenter \
		-D wall_number=$$t ; \
	done
