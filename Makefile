# devkitPro / libnds Nintendo DS homebrew Makefile
.SUFFIXES:
ifeq ($(strip $(DEVKITPRO)),)
$(error "Please set DEVKITPRO in your environment.")
endif
include $(DEVKITPRO)/libnds/default_rules
TARGET := Dai-MP4
BUILD := build
SOURCES := source
DATA :=
INCLUDES :=
ARCH := -mthumb -mthumb-interwork
CFLAGS := -g -Wall -O2 -ffunction-sections -fdata-sections $(ARCH) $(INCLUDE) -DARM9
CXXFLAGS := $(CFLAGS) -fno-rtti -fno-exceptions
ASFLAGS := $(ARCH)
LDFLAGS := -specs=ds_arm9.specs -g $(ARCH) -Wl,-Map,$(notdir $*.map)
LIBS := -lfat -lnds9
LIBDIRS :=
.PHONY: all clean
all: $(TARGET).nds
clean:
	@rm -rf $(BUILD) $(TARGET).nds $(TARGET).elf $(TARGET).map
include $(DEVKITPRO)/libnds/base_rules
