
.PHONY: build
build:
	lsc --no-header         --bare --output core/scripts  -c src/scripts/*.ls

.PHONY: watch
watch:
	lsc --no-header --watch --bare --output core/scripts  -c src/scripts/*.ls

.PHONY: compile-gulpfile
compile-gulpfile: Gulpfile.ls
	lsc --no-header --bare -c Gulpfile.ls
