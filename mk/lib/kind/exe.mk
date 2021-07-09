
define mk-exe-new-aux
  $1.lang := $$(MK_DEFAULT_LANGUAGE)
  $1.link-type ?= static
  $1.build-type ?= $$(MK_BUILD_TYPE)
  $1.goal := $$(or $2,$$($1.name))
endef

mk-exe.title := Executable
mk-exe.objs = $(patsubst %,$($1.build-dir)/%$(mk.toolset.objext-exe),$(basename $2))
mk-exe.new = $(eval $(call mk-exe-new-aux,$1,$2,$3))

mk-exe.info = \
  $(call mk-target-common-info,$1)\
  $(info $(call mk-bold,  lang)      : $($1.lang))\
  $(info $(call mk-bold,  link-type) : $($1.link-type))\
  $(info $(call mk-bold,  goal)      : $($1.goal))

$(call mk-debug,Loaded 'exe' kind)
