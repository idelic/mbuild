
ifndef MK_LANG_COMMON_MK_

MK_LANG_COMMON_MK_ := $(lastword $(MAKEFILE_LIST))

mk-lang-info = \
  $(info $(call mk-bold,  name)   : $(mk-lang-$1.name))\
  $(info $(call mk-bold,  srcext) : $(mk-lang-$1.srcext))

# 1=lang, 2=srcext, 3=build_dir
define mk-emit-pattern-rule-aux
  $$(call mk-debug,mk-emit-pattern-rule($1,$2,$3,$4))
  ifndef mk-rules-$1$2[$3]
    mk-rules-$1$2[$3] := 1
    $(if $4,$4/)%$1: %$2 | $$$$(@D)/.
	$$(call mk-do,$3,Compiling $$<)\
	$$(mk-toolset-compile)
    $(if $4,$4/)%.i: %.$2 | $$$$(@D)/.
	$$(call mk-do,$3,Preprocessing $$<)\
	$$(mk-toolset-preprocess)
  endif
endef
mk-emit-pattern-rule = $(eval $(call mk-emit-pattern-rule-aux,$1,$2,$3,$4))

# 1=lang, 2=build_dir
mk-emit-pattern-rules = \
  $(foreach srcext,$(mk-lang-$1.srcext),\
    $(foreach objext,$(mk.toolset.objext-all),\
      $(call mk-emit-pattern-rule,$(objext),$(srcext),$(mk-lang-$1.name),$2)))

define mk-emit-std-rules-aux
  ifneq ($$($1.all-sources),)
    ifneq ($$($1.srcdir),$$($1.location))
      $$(call mk-debug,Adding vpath: $$($1.build-dir)/$$($1.location)/% $$($1.srcdir))
      vpath $$($1.build-dir)/$$($1.location)/% $$($1.srcdir)
    endif
    ifneq ($$(and $$($1.sources),$$($1.all-sources-prereqs)),)
      $$($1.sources): $$($1.all-source-prereqs)
    endif
    $$(call mk-emit-pattern-rules,$$($1.lang),$$($1.build-dir))
    ifneq ($$($1.build-dir),)
      $$(call mk-emit-pattern-rules,$$($1.lang))
    endif
  endif

  # Link files
  $1.ldlibs := $$(foreach tgt,$$($1.all-required),$$($$(tgt).link))

  $$($1.target): MK_LOCAL_CPPFLAGS := $$($1.all-cppflags)
  $$($1.target): MK_LOCAL_LDFLAGS  := $$($1.all-ldflags)
  $$($1.target): MK_LOCAL_LDLIBS   := $$($1.ldlibs)
  $$($1.target): MK_LOCAL_OBJS     := $$($1.all-objs)
  $$($1.target): $$($1.ldlibs)
  
  # Link time!
  #
  # We already have all the libraries we "require".  Now extract the
  # arguments we need to pass to the linker to link them in.
  #
  # First we put them in "link order".
  $$($1.target): $$($1.all-objs) $$($1.ldlibs) | $$$$(@D)/.
    ifneq ($$(strip $$($1.all-objs) $$($1.ldlibs)),)
	$$(call mk-do,link,Linking $$(subst $$($1.build-dir),(BIN),$$@),mk-byellow)\
	$$(mk-toolset-link)
    endif
endef
mk-emit-std-rules = $(eval $(call mk-emit-std-rules-aux,$1))

define mk-resolve-std-aux
  $$(call mk-localize-pulled-flag,$1,includes)
  $$(call mk-resolve-pulled-flag,$1,cppflags)
  $$(call mk-resolve-pulled-flag,$1,ldflags)
  $$(call mk-resolve-pulled-flag,$1,ldlibs)  
  # Change include directories to they're relative to the top
  $1.all-cppflags += $$(addprefix $$(mk.toolset.include-path),$$($1.all-includes))
endef
mk-resolve-std = $(eval $(call mk-resolve-std-aux,$1))

endif # MK_LANG_COMMON_MK_
