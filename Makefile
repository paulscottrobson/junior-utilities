# ***********************************************************************************
#
#									Builds Utilities			
#
# ***********************************************************************************
#
#		Locations of FoenixMgr and OpenKernal repositories
#
#		Actually you don't need either. Just comment out the first two lines
#		of builder and manager (make and 3 copies) and it should work anyway.
#
MANAGERCODE = /home/paulr/Projects/FoenixMgr
KERNALCODE = /home/paulr/Projects/OpenKERNAL
#
#		Port to be used for the demo uploads.
#
PORT = /dev/ttyUSB0
#
#	NB: Windows SDL2 is hard coded.
#
ifeq ($(OS),Windows_NT)
CCOPY = copy
CMAKE = make
CDEL = del /Q
CDELQ = >NUL
APPSTEM = .exe
S = \\
CXXFLAGS =  -I.
LDFLAGS = -lmingw32 
OSNAME = windows
else
CCOPY = cp
CDEL = rm -f
CDELQ = 
CMAKE = make
APPSTEM =
S = /
CXXFLAGS = -O2 -fmax-errors=5 -I.  
LDFLAGS = 
OSNAME = linux
EXTRAFILES = 
endif
#
#		Root directory
#
ROOTDIR = ..$(S)
#
#		
#
all: manager builder

#
#		Build a standalone fnxmgr.zip - PJW is looking at this, and also the bug that requires foenixmgr.ini to be present.
#
#		Windows zip can be obtained through chocolatey (with make, python and mingw)
#
manager:	
		$(CCOPY) $(MANAGERCODE)$(S)foenixmgr.ini .
		$(CCOPY) $(MANAGERCODE)$(S)FoenixMgr$(S)*.py build
		$(CCOPY) build$(S)fnxmgr.py build$(S)__main__.py 
		$(CDEL) fnxmgr.zip
		zip fnxmgr.zip -j build$(S)__main__.py build$(S)constants.py build$(S)foenix_config.py build$(S)intelhex.py \
				build$(S)pgx.py build$(S)srec.py build$(S)foenix.py build$(S)pgz.py build$(S)wdc.py
#
#		Makes a 6502 binary running at $8010 into a working program that can be uploaded and boots with the kernal
#		
builder:
		make -C $(KERNALCODE)
		$(CCOPY) $(KERNALCODE)$(S)bin$(S)C256jr.bin build
		gcc $(CXXFLAGS) -o makeboot$(APPSTEM) build$(S)makeboot.c
#
#		Make shims
#
shim2:
		64tass -c -b -o test$(S)shim2.bin test$(S)shim2.asm
		.$(S)makeboot$(APPSTEM) test$(S)shim2.bin test$(S)shim2.load
shim3:
		64tass -c -b -o test$(S)shim3.bin test$(S)shim3.asm
		.$(S)makeboot$(APPSTEM) test$(S)shim3.bin test$(S)shim3.load
#
#
#		So can now upload with these sort of things after makeboot(.exe) <binary> <result> 
#	
#		This basic is hacked. It does actually work under the graphic mess :)
#
#		Try 
#			poke 1,0:poke 53248,1
#
goshim2:	shim2
	python fnxmgr.zip --port $(PORT) --binary test/shim2.load --address 8000
goshim3:	shim3
	python fnxmgr.zip --port $(PORT) --binary test/shim3.load --address 8000
gobas:	
	python fnxmgr.zip --port $(PORT) --binary test/basic02.bin --address 8000

