#; Martian Attack - JagCode2007 entry
#;
#====================================================================
#       Macro & Assembler flags
#====================================================================

STADDR = 4000
MACFLAGS = -fb -s
#MACFLAGS = -fb -s -l
ALNFLAGS = -v -v -e -l -rq -a $(STADDR) x x

# this one makes a mapfile
#ALNFLAGS = -v -v -e -g -l -m -rd -a $(STADDR) x x
# this one makes a bin file 
BINFLAGS = -rd -n -o mou.bin -a $(STADDR) x x $(OBJ)

#====================================================================
#       Default Rules
#====================================================================
.SUFFIXES:      .o .s

.s.o:
#	mac $(MACFLAGS)$*.txt $*
	smac $(MACFLAGS) $*
 
#====================================================================
#       EXECUTABLES
#====================================================================

OBJ = mou_init.o mou_list.o mou_gpu.o gfx.o mou_dsp.o
 
mou.cof: $(OBJ)
	sln $(ALNFLAGS) -o mou.cof $(OBJ)
	sln	$(BINFLAGS)

mou_init.o: mou_init.s mou.inc

mou_list.o: mou_list.s mou.inc

mou_gpu.o: mou_gpu.s mou.inc

kryspron.o: kryspron.s