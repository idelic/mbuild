
define mk-compile-source-rule
  $$(MK_BUILD_DIR)/%.$$($1.objext) : %.$1 | $$$$(@D)/.
  	$$(mk.toolset.$$($1.lang).compile)
endef

mk-objext.exe = $(mk.toolset.objext-exe)
mk-objext.lib = $(mk.toolset.objext-$(MK_LOCAL_LINK_TYPE))
mk-libext = $(mk.toolset.libext-$(MK_LOCAL_LINK_TYPE))

mk-linkable-exe = $(filter $(mk.toolset.linkable-exe),$1)
mk-linkable-shared = $(filter $(mk.toolset.linkable-shared),$1)
mk-linkable-static = $(filter $(mk.toolset.linkable-static),$1)
mk-linkable-lib = $(call mk-linkable-$(MK_LOCAL_LINK_TYPE),$1)
mk-linkable = $(call mk-linkable-$(MK_KIND),$1)

mk-run-if-nonempty = $(if $2,$1 $2,$3)

# Suffixes of objects that can be linked into a library.
mk-emit-compile-rules = \
  $$(foreach ext,$$($1.srcext),$$(eval $$(call mk-compile-source-rule,$1,$$(ext))))

mk-toolset-compile = \
  $(mk.toolset.$(MK_LOCAL_LANG).compile)

mk-toolset-link = \
  $(mk.toolset.$(MK_LOCAL_LANG).link-$(MK_KIND))

# $(call mk-run-if-nonempty,$(mk.toolset.$(MK_LOCAL_LANG).link-$(MK_KIND)),$(call mk-linkable,$^),: nothing to link for $(MK_TARGET))

mk-toolset-preprocess = $(mk.toolset.$(MK_LOCAL_LANG).preprocess)

mk-toolset-clean = $(mk.cmd.rmf)

include $(mk.mbuild.dir)/toolset/$(MK_TOOLSET).mk

mk-depend-files = \
  $(foreach dir,$(call mk-in-vars,mk.build-dirs[%]),\
    $(call mk-find-files,$(dir),*.d))

mk-depend-hook = include $(mk-depend-files)

$(call mk-add-hook,bottom,mk-depend-hook)
