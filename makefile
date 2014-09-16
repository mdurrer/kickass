all: multi2.prg

multi2.prg: multi2.s
	dasm multi2.s -omulti2.bin -v3 -p3
	pucrunch -x4096 multi2.bin multi2.prg
