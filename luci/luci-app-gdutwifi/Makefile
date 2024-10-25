# Copyright (C) 2024 Tom <fjrcn@outlook.com>
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-gdutwifi
LUCI_TITLE:=LuCI support for GDUT WIFI
LUCI_PKGARCH:=all
PKG_RELEASE:=3
PKG_VERSION:=0.9
PKG_LICENSE:=GPLv3
PKG_LINCESE_FILES:=LICENSE
PKG_MAINTAINER:=Tom <fjrcn@outlook.com>
LUCI_DEPENDS:=+jq
		

define Package/$(PKG_NAME)/conffiles
	/etc/config/gdutwifi
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
