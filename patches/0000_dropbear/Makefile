DROPBEAR_RELEASE = 2020.81
DROPBEAR_TAR = dropbear-$(DROPBEAR_RELEASE).tar.bz2
DROPBEAR_URL = https://matt.ucc.asn.au/dropbear/releases/$(DROPBEAR_TAR)
DROPBEAR_SRC = build/dropbear-$(DROPBEAR_RELEASE)
DROPBEAR_PATCHES = $(addprefix https://raw.githubusercontent.com/openwrt/openwrt/master/package/network/services/dropbear/patches/, \
    100-pubkey_path.patch \
    110-change_user.patch \
    130-ssh_ignore_x_args.patch \
    140-disable_assert.patch \
    600-allow-blank-root-password.patch \
    900-configure-hardening.patch \
    910-signkey-fix-use-of-rsa-sha2-256-pubkeys.patch \
)

DROPBEAR_CONF = \
    --host mips-openwrt-linux-uclibc \
    --disable-lastlog \
    --disable-utmpx \
    --disable-utmp \
    --disable-wtmp \
    --disable-wtmpx \
    --disable-loginfunc \
    --disable-pututline \
    --disable-pututxline \
    --disable-zlib \
    $()

# chacha20-poly1305 is more than 2x slower than aes-ctr for decryption on this HW.
# But it would be more than 2x faster for encryption.
DROPBEAR_DISABLED_FEATURES = \
    INETD_MODE \
    DROPBEAR_CLI_NETCAT \
    DROPBEAR_DSS \
    DO_MOTD \
    DROPBEAR_ECDSA \
    DROPBEAR_ECDH \
    DROPBEAR_CHACHA20POLY1305

all: dropbear

clean:
	rm -rf build

build:
	mkdir -p $@

build/$(DROPBEAR_TAR): | build
	wget -O $@ $(DROPBEAR_URL)

build/.dropbear_patches: | build
	rm -f build/*.patch
	cd build && wget $(DROPBEAR_PATCHES)
	@touch $@

build/.dropbear_unpacked: build/$(DROPBEAR_TAR) build/.dropbear_patches
	tar -C build -xf $<
	set -e; for p in build/*.patch; do patch -d $(DROPBEAR_SRC) -p1 < $$p; done
	@touch $@

build/.dropbear_autoreconf: build/.dropbear_unpacked
	cd $(DROPBEAR_SRC) && autoreconf
	@touch $@

build/.dropbear_configured: build/.dropbear_autoreconf | toolchain
	cd $(DROPBEAR_SRC) && ./configure $(DROPBEAR_CONF)
	printf "#define %s 0\n" $(DROPBEAR_DISABLED_FEATURES) > $(DROPBEAR_SRC)/localoptions.h
	@touch $@

dropbear: build/.dropbear_configured
	$(MAKE) -C $(DROPBEAR_SRC) PROGRAMS="dropbear dbclient dropbearkey scp" MULTI=1 SCPPROGRESS=1
	$(OBJCOPY) --strip-all $(DROPBEAR_SRC)/dropbearmulti dropbear

include ../../toolchain.mk
