
MK_LANG_DEFAULT ?= c++

define mk-new-target-aux
  ifdef $1.$2.name
    $$(error Duplicate definition for target <$1>: Here ($$(HERE)) and in <$$($1.location)>)
  endif
  $1.$2.name     := $2
  $1.$2.location := $$(HERE)
  $1.$2.there    := $$(THERE)
  $1.$2.local    := $$($1.$2.location)@$1.$2
  $1.$2.this     := $1.$2
  
  # Kind-specific stuff here
  $$(call mk-$1.new,$1.$2,$3)
  
  ifndef $1.$2.goal
    $1.$2.goal := $(or $3,$2)
  endif

  THIS  := $$($1.$2.this)
  LOCAL := $$($1.$2.local)
endef

mk.targets.registered :=

mk-new-target = $(eval $(call mk-new-target-aux,$1,$2,$3))

mk-new-exe = $(call mk-new-target,exe,$1,$2)
mk-new-lib = $(call mk-new-target,lib,$1,$2)

mk-collect-pulls = \
  $(info - Collecting $2 for <$1>)$(strip $(foreach req,$1,$(call $0,$(req),$2)) $($1.$2) $1)
# $($(req).pull),$(call $0,$($(req).pull),$2))) $1)

mk-collect-use = \
  $(foreach r,$(call $0,$r,$2))  
# The 3-step process of creating a target:
#
# 1. Registration: The target is added to the build machinery.
#
# 2. Resolution: All inter-target dependencies are resolved.
#
# 3. Generation: Actual targets and their rules are generated.

# $(call mk-resolve-pulled-flag,TARGET,SELF_FLAG,PULL_FLAG)
#
define mk-resolve-pulled-flag-aux
  $1.all-$2 = $$(strip $$(foreach r,$$($1.all-required),$$($$(r).$(or $3,pull-$2))) $$($1.$2))
  $$(call mk-lazify,$1.all-$2)
endef
mk-resolve-pulled-flag = $(eval $(call mk-resolve-pulled-flag-aux,$1,$2,$3))

mk-find-sources = \
  $(call mk-find-files,$($1.srcdir),$(addprefix *,$(mk.lang.$($1.lang).srcext)))

mk.targets.all :=

##########################################################################
## Target registration
##########################################################################

define mk-target-register-aux
  ifneq (,$$($1.lang))
    mk-languages.$$($1.lang) := 1
  endif
  # Check that the target is valid
  ifndef $1.kind
    $1.kind := $2
  else
    ifneq ($$($1.kind),$2)
      $$(error Target $1 changed kind!)
    endif
  endif
  ifndef $1.name
    $$(error Target <$1> has no name)
  endif
  ifdef $1.location
    # This is an in-tree target we need to build
    $1.location := $$(call mk-from-top,$$($1.location))
  endif  
  $1.require += $$($1.reqpull)
  $1.pull += $$($1.reqpull)
  $1.from-here = $$(if $$1,$$(call mk-from-top,$$($1.location)/$$1))

  # Define and lazify. We'll expand later.
  $1.all-required = $$(strip $$($1.require) $$(foreach r,$$($1.require),$$($$(r).all-pulled)))
  $$(call mk-lazify,$1.all-required)
  $1.all-pulled = $$(strip $$(foreach r,$$($1.pull),$$($$(r).all-pulled)) $$($1.pull))
  $$(call mk-lazify,$1.all-pulled)
  
  mk.targets.registered += $1
  mk.targets[$$($1.location)] += $1
endef
mk-target-register = $(eval $(call mk-target-register-aux,$1,$2))

##########################################################################
# Handles resolution of buildable targets (i.e. a target with a location).
##########################################################################

define mk-target-resolve-aux
  ifndef $1.srcdir
    $1.srcdir := $$($1.location)
  else
    $1.srcdir := $$(call $1.from-here,$$($1.srcdir))
  endif
  ifndef $1.build-dir
    $1.build-dir := $$(MK_BUILD_DIR)
  else
    $1.build-dir := $$(call $1.from-here,$$($1.build-dir))
  endif
  mk.build-dirs[$$($1.build-dir)] += $1

  ifdef $1.goal
    $1.target := $$($1.build-dir)/$$($1.location)/$$($1.goal)
  endif

  ifdef $1.lang
    # Resolve compilation/linking flags
    $$(call mk.lang.$$($1.lang).resolve-props,$1)

    # Locate source files
    ifeq (undefined,$$(origin $1.sources))
      $1.sources := $$(filter-out $$($1.exclude-sources),$$(call mk-find-sources,$1))
    endif
    $1.all-sources := $$($1.sources) $$($1.extra-sources)
  
    # Object files, if any
    $1.objs := $$(call mk-$$($1.kind).objs,$1,$$($1.all-sources))
    $1.all-objs := $$($1.objs) $$($1.extra-objs)
  endif
  
  ifdef $1.cleanable
    $1.all-cleanable := $$(call $1.from-here,$$($1.cleanable))
  else
    $1.all-cleanable :=
  endif
  $1.all-cleanable += $$($1.all-objs) $$($1.target) $$($1.extra-cleanable)
  ifdef $1.dist-cleanable
    $1.all-dist-cleanable := $$(call $1.from-here,$$($1.dist-cleanable))
  else
    $1.all-dist-cleanable :=
  endif
  $1.all-dist-cleanable += $$($1.extra-dist-cleanable)  
endef
mk-target-resolve = $(eval $(call mk-target-resolve-aux,$1))

##########################################################################
## Emit targets and recipes
##########################################################################

define mk-target-emit-aux
  ifdef $1.target
    $$($1.target): MK_TARGET := $1
    $$($1.target): MK_KIND := $$($1.kind)
    $$($1.target): MK_LOCAL_LANG := $$($1.lang)
    $$($1.target): MK_LOCAL_BUILD_TYPE := $$($1.build-type)
    $$($1.target): MK_LOCAL_LINK_TYPE := $$($1.link-type)
    $$($1.target): HERE := $$($1.location)
    $$($1.target): THERE := $$($1.there)

    ifdef $1.lang
      # Emit compilation and linking rules
      $$(call mk.lang.$$($1.lang).emit-rules,$1)
    endif
    
    .PHONY: $1.build-target
    $1.build-target: $$($1.target)
    
    .PHONY: $$($1.location)@$1
    $$($1.location)@$1: $1.build-target
    
    .PHONY: $1
    $1: $1.build-target

    .PHONY: $$(1.location)@$1.clean $$($1.location)@$1.local-clean
    $$($1.location)@$1.clean: MK_TARGET := $1
    $$($1.location)@$1.clean: MK_KIND := $$($1.kind)
    $$($1.location)@$1.clean: MK_LOCAL_LANG := $$($1.lang)
    $$($1.location)@$1.clean: MK_LOCAL_BUILD_TYPE := $$($1.build-type)
    $$($1.location)@$1.clean: MK_LOCAL_LINK_TYPE := $$($1.link-type)    
    $$($1.location)@$1.clean: $$($1.location)@$1.local-clean
	$$(call mk-do,clean,Cleaning in $$($1.location))\
	$$(mk-toolset-clean) $$($1.all-cleanable)

    .PHONY: $1.clean
    $1.clean: $$($1.location)@$1.clean
    
    mk.targets.clean += $$($1.location)@$1.clean
    
    .PHONY: clean-$$($1.kind)
    clean-$$($1.kind): $1.clean
    
    .PHONY: $$($1.location)@$1.distclean $$($1.location)@$1.local-distclean
    $$($1.location)@$1.distclean: MK_TARGET := $1
    $$($1.location)@$1.distclean: MK_KIND := $$($1.kind)
    $$($1.location)@$1.distclean: MK_LOCAL_LANG := $$($1.lang)
    $$($1.location)@$1.distclean: MK_LOCAL_BUILD_TYPE := $$($1.build-type)
    $$($1.location)@$1.distclean: MK_LOCAL_LINK_TYPE := $$($1.link-type)    
    $$($1.location)@$1.distclean: $1.clean $$($1.location)@$1.local-distclean
	$$(call mk-do,dclean,Dist-cleaning in $$($1.location))\
 	$$(mk-toolset-clean) $$($1.all-dist-cleanable)
 	
    .PHONY: $1.distclean
    $1.distclean: $$($1.location)@$1.distclean
    
    mk.targets.distclean += $$($1.location)@$1.distclean

    mk.targets.$$($1.kind) += $$($1.location)@$1    
    mk.targets.all += $$($1.location)@$1
    
    ifndef mk.locations[$$($1.location)]
      .PHONY: $$($1.location)@all
      $$($1.location)@%: HERE := $$($1.location)
      mk.locations[$$($1.location)] :=
    endif
    $$($1.location)@all: $$($1.build-target)
    mk.locations[$$($1.location)] += $$($1.location)@$1
    $$(call mk-debug,Emitted $1)
  endif
endef
mk-target-emit = $(eval $(call mk-target-emit-aux,$1))
