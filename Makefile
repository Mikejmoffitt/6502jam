
TOOL_CC := clang
TOOL_LDF := -lm
AS := ca65
LD := ld65
ASFLAGS := -g 
LDFLAGS := -Ln labels.txt
SRCDIR := src
CONFIGNAME := config.cfg
OBJNAME := main.o
MAPNAME := map.txt
LISTNAME := listing.txt
TRIGFILE := src/trig.asm

TOPLEVEL := main.asm

EXECUTABLE := jam.nes

.PHONY: all build $(EXECUTABLE)

build: $(EXECUTABLE)

all: $(EXECUTABLE)

clean:
	rm -f jam.nes listing.txt main.o map.txt jam.nes.deb jam.cdl

$(EXECUTABLE): trig
	$(AS) $(SRCDIR)/$(TOPLEVEL) $(ASFLAGS) -I $(SRCDIR) -l $(LISTNAME) -o $(OBJNAME)
	$(LD) $(LDFLAGS) -C $(CONFIGNAME) -o $(EXECUTABLE) -m $(MAPNAME) -vm $(OBJNAME)

sintab:
	$(TOOL_CC) tools/sintab.c -o tools/sintab $(TOOL_LDF) 
	
trig: sintab
	tools/sintab sin 0.0 6.2831853 512 24 math_sin_512_24 > $(TRIGFILE)
	tools/sintab cos 0.0 6.2831853 512 24 math_cos_512_24 >> $(TRIGFILE)
	tools/sintab sin 0.0 6.2831853 512 48 math_sin_512_48 >> $(TRIGFILE)
	tools/sintab cos 0.0 6.2831853 512 48 math_cos_512_48 >> $(TRIGFILE)
	tools/sintab sin 0.0 6.2831853 1024 24 math_sin_1024_24 >> $(TRIGFILE)
	tools/sintab cos 0.0 6.2831853 1024 24 math_cos_1024_24 >> $(TRIGFILE)
	tools/sintab sin 0.0 6.2831853 1024 48 math_sin_1024_48 >> $(TRIGFILE)
	tools/sintab cos 0.0 6.2831853 1024 48 math_cos_1024_48 >> $(TRIGFILE)

mednafen: $(EXECUTABLE)
	mednafen ./$(EXECUTABLE)

fceux: $(EXECUTABLE)
	fceux ./$(EXECUTABLE)

run: $(EXECUTABLE)
	nestopia ./$(EXECUTABLE)

debug: $(EXECUTABLE)
	wine tools/fceuxw/fceux.exe ./$(EXECUTABLE)

test: $(EXECUTABLE)
	tools/edn8usb $(EXECUTABLE)
