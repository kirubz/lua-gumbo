PKGCONFIG = pkg-config
PKGCONFIG_Q = $(PKGCONFIG) --silence-errors 2>/dev/null
PKGEXISTS = $(PKGCONFIG_Q) --exists $(1) && echo $(1)
PKGFIND = $(shell for P in $(1); do $(call PKGEXISTS, $$P) && break; done)
PKGMATCH = $(shell $(PKGCONFIG_Q) --exists '$(1) $(2); $(1) $(3)' && echo $(1))
CMDFIND = $(shell for C in $(1); do command -v $$C && break; done)

LUA53_PC ?= $(or \
    $(call PKGFIND, lua53 lua5.3 lua-5.3), \
    $(call PKGMATCH, lua, >= 5.3, < 5.4) \
)

LUA52_PC ?= $(or \
    $(call PKGFIND, lua52 lua5.2 lua-5.2), \
    $(call PKGMATCH, lua, >= 5.2, < 5.3) \
)

LUA51_PC ?= $(or \
    $(call PKGFIND, lua51 lua5.1 lua-5.1), \
    $(call PKGMATCH, lua, >= 5.1, < 5.2), \
    $(call PKGMATCH, luajit, >= 2.0.0, < 2.2.0) \
)

LUA_VERSIONS_FOUND = \
    $(if $(LUA53_PC), 53) \
    $(if $(LUA52_PC), 52) \
    $(if $(LUA51_PC), 51)

LUAS_FOUND = $(addprefix lua, $(LUA_VERSIONS_FOUND))

LUA53_CFLAGS ?= $(shell $(PKGCONFIG_Q) --cflags $(LUA53_PC))
LUA52_CFLAGS ?= $(shell $(PKGCONFIG_Q) --cflags $(LUA52_PC))
LUA51_CFLAGS ?= $(shell $(PKGCONFIG_Q) --cflags $(LUA51_PC))

LUA53_LMODDIR ?= $(shell $(PKGCONFIG_Q) --variable=INSTALL_LMOD $(LUA53_PC))
LUA52_LMODDIR ?= $(shell $(PKGCONFIG_Q) --variable=INSTALL_LMOD $(LUA52_PC))
LUA51_LMODDIR ?= $(shell $(PKGCONFIG_Q) --variable=INSTALL_LMOD $(LUA51_PC))

LUA53_CMODDIR ?= $(shell $(PKGCONFIG_Q) --variable=INSTALL_CMOD $(LUA53_PC))
LUA52_CMODDIR ?= $(shell $(PKGCONFIG_Q) --variable=INSTALL_CMOD $(LUA52_PC))
LUA51_CMODDIR ?= $(shell $(PKGCONFIG_Q) --variable=INSTALL_CMOD $(LUA51_PC))

LUA53 ?= $(call CMDFIND, $(LUA53_PC) lua5.3 lua-5.3 lua53)
LUA52 ?= $(call CMDFIND, $(LUA52_PC) lua5.2 lua-5.2 lua52)
LUA51 ?= $(call CMDFIND, $(LUA51_PC) lua5.1 lua-5.1 lua51)

LUA_VARS = LUAS_FOUND $(foreach V, $(LUA_VERSIONS_FOUND), \
    LUA$(V)_PC LUA$(V)_CFLAGS LUA$(V)_LMODDIR LUA$(V)_CMODDIR LUA$(V) \
)

PRINTVAR = printf '%-14s = %s\n' '$(1)' '$(strip $($(1)))'

config:
	@printf "# $$(date)\n\n" > .config.mk.tmp
	@$(foreach VAR, $(LUA_VARS), $(call PRINTVAR,$(VAR)) >> .config.mk.tmp;)
	@mv -f .config.mk.tmp config.mk


.PHONY: config
