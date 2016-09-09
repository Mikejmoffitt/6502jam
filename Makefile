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
	rm -f jam.nes listing.txt main.o map.txt jam.nes.deb jam.cdl labels.txt

$(EXECUTABLE): trig
	$(AS) $(SRCDIR)/$(TOPLEVEL) $(ASFLAGS) -I $(SRCDIR) -l $(LISTNAME) -o $(OBJNAME)
	$(LD) $(LDFLAGS) -C $(CONFIGNAME) -o $(EXECUTABLE) -m $(MAPNAME) -vm $(OBJNAME)

sintab:
	$(TOOL_CC) tools/sintab.c -o tools/sintab $(TOOL_LDF) 
	
trig: sintab
	tools/sintab sin 0.0 6.2831853 128 16 math_sin_128_16 > $(TRIGFILE)
	tools/sintab sin 0.0 6.2831853 512 16 math_sin_512_16 >> $(TRIGFILE)
	tools/sintab sin 0.0 6.2831853 768 16 math_sin_768_16 >> $(TRIGFILE)
	tools/sintab sin 0.0 6.2831853 1536 16 math_sin_1536_16 >> $(TRIGFILE)

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
