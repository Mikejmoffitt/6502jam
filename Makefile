AS := ca65
LD := ld65
ASFLAGS := 
LDFLAGS := 
SRCDIR := src
CONFIGNAME := config.cfg
OBJNAME := main.o
MAPNAME := map.txt
LISTNAME := listing.txt

TOPLEVEL := main.asm

EXECUTABLE := jam.nes

.PHONY: all

build: $(EXECUTABLE)

all: $(EXECUTABLE)

clean:
	rm -f jam.nes listing.txt main.o map.txt

$(EXECUTABLE):
	$(AS) $(SRCDIR)/$(TOPLEVEL) $(ASFLAGS) -I $(SRCDIR) -l $(LISTNAME) -o $(OBJNAME)
	$(LD) $(LDFLAGS) -C $(CONFIGNAME) -o $(EXECUTABLE) -m $(MAPNAME) -vm $(OBJNAME)

run: $(EXECUTABLE)
	nestopia ./$(EXECUTABLE)

debug: $(EXECUTABLE)
	wine tools/fceuxw/fceux.exe ./$(EXECUTABLE)
