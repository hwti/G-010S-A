TOOLCHAIN_NAME = OpenWrt-Toolchain-lantiq-for-mips_34kc+dsp-gcc-4.8-linaro_uClibc-0.9.33.2
TOOLCHAIN_TAR = $(TOOLCHAIN_NAME).tar.bz2
TOOLCHAIN_URL = https://archive.openwrt.org/barrier_breaker/14.07/lantiq/xrx200/$(TOOLCHAIN_TAR)

ROOT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
CROSS_COMPILE = $(ROOT_DIR)/$(TOOLCHAIN_NAME)/toolchain-mips_34kc+dsp_gcc-4.8-linaro_uClibc-0.9.33.2/bin/mips-openwrt-linux-uclibc-

# We use the *.bin directly : the wrapper is not needed and add rpath...
export AR = $(CROSS_COMPILE)ar
export AS = $(CROSS_COMPILE)as.bin
export CC = $(CROSS_COMPILE)gcc.bin
export CXX = $(CROSS_COMPILE)g++.bin
export LD = $(CROSS_COMPILE)ld.bin
export OBJCOPY = $(CROSS_COMPILE)objcopy
export RANLIB = $(CROSS_COMPILE)ranlib
export STRIP = $(CROSS_COMPILE)strip

# Prevent "warning: environment variable 'STAGING_DIR' not defined"
export STAGING_DIR

toolchain: $(CC)

$(ROOT_DIR)/$(TOOLCHAIN_TAR):
	wget -O $@ $(TOOLCHAIN_URL)

$(CC): | $(ROOT_DIR)/$(TOOLCHAIN_TAR)
	tar -C $(ROOT_DIR) -xf $(TOOLCHAIN_TAR)
