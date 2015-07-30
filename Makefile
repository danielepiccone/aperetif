all:

.PHONY: rackunit
rackunit:
	racket unit/dispatcher.unit.rkt
	racket unit/model.unit.rkt
	racket unit/response.unit.rkt
	racket unit/schema.unit.rkt
	racket unit/parsers.unit.rkt
