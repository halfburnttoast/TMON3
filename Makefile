all:
	xa -e tmon3.h -o tmon3.rom tmon3.asm 2>ERROR.log
	python3 convec.py
	cat tmon3.h | column -t

clean:
	rm -f *.rom tmon3.h
	rm -f ERROR.log
	rm -f memdump

install:
	mv *.rom ../romfiles/
