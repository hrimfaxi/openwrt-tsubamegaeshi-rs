include $(TOPDIR)/rules.mk

PKG_NAME:=tsubamegaeshi-rs
PKG_VERSION:=0.1.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
#PKG_SOURCE_URL:=https://github.com/hrimfaxi/tsubamegaeshi-rs.git
PKG_SOURCE_URL:=e470:tsubamegaeshi-rs.git
PKG_SOURCE_VERSION:=HEAD

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

ifeq ($(ARCH),aarch64)
  RUST_TARGET:=aarch64-unknown-linux-musl
else ifeq ($(ARCH),x86_64)
  RUST_TARGET:=x86_64-unknown-linux-musl
else ifeq ($(ARCH),mips)
  RUST_TARGET:=mips-unknown-linux-musl
else ifeq ($(ARCH),mipsel)
  RUST_TARGET:=mipsel-unknown-linux-musl
else ifeq ($(ARCH),arm)
  ifneq ($(findstring v7,$(CPU_TYPE)),)
    RUST_TARGET:=armv7-unknown-linux-musleabihf
  else
    RUST_TARGET:=arm-unknown-linux-musleabi
  endif
else
  RUST_TARGET:=$(ARCH)-unknown-linux-musl
endif

CARGO_TARGET_ENV:=CARGO_TARGET_$(shell echo $(RUST_TARGET) | tr 'a-z-' 'A-Z_')_LINKER

define Package/tsubamegaeshi-rs
  SECTION:=net
  CATEGORY:=Network
  TITLE:=tsubamegaeshi-rs DNS splitter
  URL:=https://github.com/hrimfaxi/tsubamegaeshi-rs
  DEPENDS:=+libpthread
endef

define Package/tsubamegaeshi-rs/description
  燕返 — Lightweight dual-rail DNS splitter with IP-based geo decisions,
  caching, and Xray integration.
endef

define Build/Configure
	$(call Build/Configure/Default)
	mkdir -p $(PKG_BUILD_DIR)/.cargo
	printf '[target.$(RUST_TARGET)]\nlinker = "$(TARGET_CC)"\n' > $(PKG_BUILD_DIR)/.cargo/config.toml
endef

define Build/Compile
	cd $(PKG_BUILD_DIR) && \
	CARGO_HOME=$(PKG_BUILD_DIR)/.cargo_home \
	CARGO_TARGET_DIR=$(PKG_BUILD_DIR)/target \
	TARGET_CC=$(TARGET_CC) \
	TARGET_CXX=$(TARGET_CXX) \
	TARGET_AR=$(TARGET_AR) \
	$(CARGO_TARGET_ENV)=$(TARGET_CC) \
	cargo build --release --target $(RUST_TARGET)
endef

define Package/tsubamegaeshi-rs/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/target/$(RUST_TARGET)/release/tsubamegaeshi-rs $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/tsubamegaeshi-rs
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/contrib/etc/tsubamegaeshi-rs/* $(1)/etc/tsubamegaeshi-rs/

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/contrib/etc/config/tsubamegaeshi-rs $(1)/etc/config/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/contrib/etc/init.d/tsubamegaeshi-rs $(1)/etc/init.d/

	$(INSTALL_DIR) $(1)/etc/capabilities
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/contrib/etc/capabilities/tsubamegaeshi-rs.json $(1)/etc/capabilities/

	$(INSTALL_DIR) $(1)/usr/libexec
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/contrib/usr/libexec/update_tsubamegaeshi_files.sh $(1)/usr/libexec/

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/contrib/etc/uci-defaults/luci-app-tsubamegaeshi-rs $(1)/etc/uci-defaults/
endef

$(eval $(call BuildPackage,tsubamegaeshi-rs))
