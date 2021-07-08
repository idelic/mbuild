
define mk-exe-new-aux
  $1.lang := $$(MK_DEFAULT_LANGUAGE)
  $1.link-type ?= static
  $1.build-type ?= $$(MK_BUILD_TYPE)
  $1.goal := $$(or $2,$$($1.name))
endef

mk-exe.objs = $(patsubst %,$($1.build-dir)/%$(mk.toolset.objext-exe),$(basename $2))
mk-exe.new = $(eval $(call mk-exe-new-aux,$1,$2,$3))

$(call mk-debug,Loaded 'exe' kind)
