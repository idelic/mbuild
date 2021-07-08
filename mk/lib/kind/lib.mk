
MK_SLIBEXT ?= .a
MK_SHLIBEXT ?= .so

mk-lib-name.static = lib$1$(MK_SLIBEXT)
mk-lib-name.shared = lib$1$(MK_SHLIBEXT)

define mk-lib-new-aux
  $1.lang := $$(MK_DEFAULT_LANGUAGE)
  $1.link-type ?= $$(MK_LINK_TYPE)
  $1.build-type ?= $$(MK_BUILD_TYPE)
  $1.goal = $$(call mk-lib-name.$$($1.link-type),$(or $3,$$($1.name)))
  $1.link = $$($1.target)
endef

mk-lib.objs = $(patsubst %,$($1.build-dir)/%$(mk.toolset.objext-$($1.link-type)),$(basename $2))
mk-lib.new = $(eval $(call mk-lib-new-aux,$1,$2,$3))

$(call mk-debug,Loaded 'lib' kind)
