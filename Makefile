install:
	raco pkg install --force -n aperetif -t dir lib/

uninstall:
	raco pkg remove aperetif

test:
	raco test .

example:
	racket example/app.rkt

