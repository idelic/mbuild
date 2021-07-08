
define mk-compile-source-rule
  $$(MK_BUILD_DIR)/%.$$($1.objext) : %.$1 | $$$$(@D)/.
  	$$(mk.toolset.$$($1.lang).compile)
endef

mk-emit-compile-rules = \
  $$(foreach ext,$$($1.srcext),$$(eval $$(call mk-compile-source-rule,$1,$$(ext))))

mk-toolset-compile = $(mk.toolset.$($(MK_TARGET).lang).compile)
mk-toolset-link = $(mk.toolset.$($(MK_TARGET).lang).link-$(MK_LOCAL_LINK_TYPE)
