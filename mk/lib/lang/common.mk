
ifndef MK_LANG_COMMON_MK_

MK_LANG_COMMON_MK_ := $(lastword $(MAKEFILE_LIST))

# 1=lang, 2=srcext, 3=build_dir
define mk-emit-pattern-rulle
  ifndef $1.rules.$2[$3]
    $1.rules.$2[$3] := 1
    $(if $3,$3/)%.$$($1.objext): %.$2 | $$$$(@D)/.
    	$$(call mk-do,$$($1.name),Compiling $<)\
	$$(mk.toolset.$1.compile)
    $(if $3,$3/)%.i: %.$2 | $$$$(@D)/.
    	$$(call mk-do,$$($1.name),Preprocessing $<)\
	$$(mk.toolset.$1.preprocess)
  else
    $$(info $$($1.name): Already emitted rule for directory <$3> and srcext <$2>)
  endif
endef

# 1=lang, 2=build_dir
define mk-emit-pattern-rules
  $$(foreach srcext,$$($1.srcext),\
    $$(call mk-emit-pattern-rule,$1,$$(srcext),$2))
endef

define mk-emit-std-rules-aux
  ifneq ($$($1.all-sources),)
    ifneq ($$($1.srcdir),$$($1.location))
      $$(info Adding vpath: $$($1.build-dir)/$$($1.location)/% $$($1.srcdir))
      vpath $$($1.build-dir)/$$($1.location)/% $$($1.srcdir)
    endif
    ifneq ($$(and $$($1.sources),$$($1.all-sources-prereqs)),)
      $$($1.sources): $$($1.all-source-prereqs)
    endif
    $$(call mk-emit-pattern-rules,mk.lang.$$($1.lang))
    $$(call mk-emit-pattern-rules,mk.lang.$$($1.lang),$$($1.build-dir))
  endif

  # Link files
  $1.ldlibs := $$(foreach tgt,$$($1.all-required),$$($(tgt).link))

  $$($1.target): MK_LOCAL_CPPFLAGS := $$($1.all-cppflags)
  $$($1.target): MK_LOCAL_LDFLAGS  := $$($1.all-ldflags)
  $$($1.target): MK_LOCAL_LDLIBS   := $$($1.ldlibs)
  $$($1.target): MK_LOCAL_OBJS     := $$($1.all-objs)
  
  # Link time!
  #
  # We already have all the libraries we "require".  Now extract the
  # arguments we need to pass to the linker to link them in.
  #
  # First we put them in "link order".
  $$($1.target): $$($1.all-objs) $$($1.ldlibs)
	$$(call mk-do,link,Linking $@)\
	$$(mk.toolset.$$($1.lang).link-$$($1.kind))
endef
mk-emit-std-rules = $(eval $(call mk-emit-std-rules-aux,$1)

define mk-resolve-std-aux
  $$(call mk-resolve-pulled-flag,$1,includes)
  $$(call mk-resolve-pulled-flag,$1,cxxflags)
  $$(call mk-resolve-pulled-flag,$1,cppflags)
  $$(call mk-resolve-pulled-flag,$1,ldflags)
  $$(call mk-resolve-pulled-flag,$1,ldlibs)  
  # Change include directories to they're relative to the top
  $1.all-cppflags += \
    $$(foreach dir,$$($1.all-includes),\
      $$(mk.toolset.$$($1.lang).include-path)$$(call $1.from-here,$$(dir)))
endef
mk-resolve-std-aux = $(eval $(call mk-resolve-std-aux,$1)

endif # MK_LANG_COMMON_MK_
