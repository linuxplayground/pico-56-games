AS=ca65
LD=ld65
TOP = ..

INCLUDES = -I $(TOP)/lib
LIB = $(TOP)/lib

DEBUG = 0
ASFLAGS = $(INCLUDES) -g --feature labels_without_colons --cpu 65C02 --feature string_escapes -D DEBUG=$(DEBUG)
CFG = $(TOP)/apps.cfg

APPNAME = jj

BUILD_DIR = $(TOP)/build
SOURCES = main.s \
	  $(LIB)/vdp.s \
	  $(LIB)/kbd.s \
	  $(LIB)/ay-3-8910.s \
	  $(LIB)/vectors.s

OBJS = $(addprefix $(BUILD_DIR)/, $(SOURCES:.s=.o))
all: clean emu
clean:
	rm -fr $(BUILD_DIR)/*

$(BUILD_DIR)/%.o: %.s
	@mkdir -p $$(dirname $@)
	$(AS) $(ASFLAGS) -g -l $(BUILD_DIR)/$*.lst $< -o $@

$(BUILD_DIR)/$(APPNAME).o: $(OBJS)
	@mkdir -p $$(dirname $@)
	$(LD) -C $(CFG) $^ -o $@ -m $(BUILD_DIR)/$(APPNAME).map -Ln $(BUILD_DIR)/$(APPNAME).sym

emu: $(BUILD_DIR)/jj.o
	$(TOP)/../emu/Hbc56Emu.exe --rom $(BUILD_DIR)/jj.o
