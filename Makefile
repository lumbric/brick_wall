all: png_relative_labels png_absolute_labels

stl:
	for t in 0 1 2 3; do \
		openscad -o brick_wall_$$t.stl brick_wall.scad -D wall_number=$$t ; \
	done

png:
	for t in 0 1 2 3; do \
		openscad -o brick_wall_$(Z_LABEL)_$$t.png brick_wall.scad \
		--imgsize=2000,3000 \
		--viewall \
		--projection=ortho\
		--camera=100,-400,100,0,0,0 \
		--autocenter \
		-D 'Z_LABEL=$(Z_LABEL)' \
		-D wall_number=$$t ; \
	done

png_relative_labels: export Z_LABEL = "relative"
png_relative_labels:
	$(MAKE) png

png_absolute_labels: export Z_LABEL = "absolute"
png_absolute_labels:
	$(MAKE) png

png_absolute_labels: export Z_LABEL = "relative_right"
png_absolute_labels:
	$(MAKE) png
