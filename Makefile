all:

.PHONY: test
test:
	raco test --direct --table unit/
