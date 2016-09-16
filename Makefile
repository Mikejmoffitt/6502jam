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

EXECUTABLE := main.nes

.PHONY: all build $(EXECUTABLE)

build: $(EXECUTABLE)

all: $(EXECUTABLE)

clean:
	rm -f main.nes main.o

$(EXECUTABLE):
	$(AS) $(SRCDIR)/$(TOPLEVEL) $(ASFLAGS) -I $(SRCDIR) -l $(LISTNAME) -o $(OBJNAME)
	$(LD) $(LDFLAGS) -C $(CONFIGNAME) -o $(EXECUTABLE) -m $(MAPNAME) -vm $(OBJNAME)

run: $(EXECUTABLE)
	fceux ./$(EXECUTABLE)
	
debug: $(EXECUTABLE)
	wine tools/fceuxw/fceux.exe ./$(EXECUTABLE)
