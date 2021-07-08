
define mk-exe-new-aux
  $1.lang := $$(MK_DEFAULT_LANGUAGE)
  $1.link-type ?= static
  $1.goal := $$(or $2,$$($1.name))
endef

mk-exe-new = $(eval $(call mk-exe-new-aux,$1,$2,$3))

$(call mk-debug,Loaded 'exe' kind)
