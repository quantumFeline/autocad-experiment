# thumb_v3 build and verification. See thumb_v3_notes.md for context.

PARTS   = proximal distal nail disk_ring disk_plug plate
SCAD    = thumb_v3.scad
FLEX   ?= 60

.PHONY: stl check sweep views clean

# full-quality STL export of every part plus the print layout
stl: $(PARTS:%=stl/%.stl) stl/print_all.stl

stl/%.stl: $(SCAD)
	@mkdir -p stl
	openscad -o $@ -D 'part="$*"' $(SCAD)

# watertightness + bed-contact report for everything exported
check: stl
	python3 scripts/check_manifold.py stl/*.stl

# hinge interference at FLEX degrees; "empty" in the output = clear.
# Run after ANY change near the hinge (see notes, "Verified mechanism
# numbers", for the expected envelope).
sweep:
	@mkdir -p stl
	openscad -o stl/interference.stl -D 'part="none"' \
	  -D 'test="interference"' -D test_flex=$(FLEX) -D fn_draft=24 \
	  test_mechanism.scad 2>&1 | grep -i 'empty' \
	  && echo "flex $(FLEX): CLEAR" || echo "flex $(FLEX): COLLISION"

# draft renders of the two sketch views, with the axis gizmo
views:
	@mkdir -p renders
	openscad -o renders/side.png  --camera=0,0,28,90,0,0,240 \
	  --projection=ortho -D 'part="preview"' -D show_axes=true \
	  -D fn_draft=24 $(SCAD)
	openscad -o renders/front.png --camera=0,0,28,90,0,90,240 \
	  --projection=ortho -D 'part="preview"' -D show_axes=true \
	  -D fn_draft=24 $(SCAD)

clean:
	rm -rf stl renders
