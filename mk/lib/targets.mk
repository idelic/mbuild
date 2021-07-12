
ifndef MK_TARGETS_MK_

MK_TARGETS_MK_ := $(lastword $(MAKEFILE_LIST))

MK_LANG_DEFAULT ?= c++

define mk-new-target-aux
  ifdef $1.$2.name
    $$(call mk-error,Duplicate definition for target <$1>: Here ($$(HERE)) and in <$$($1.$2.location)>)
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

# Define this as a simple variable, so it stays simple when we do '+='.
mk.targets.registered :=

mk-new-target = $(eval $(call mk-new-target-aux,$1,$2,$3))

# Define the 'kind' constructors.
$(foreach kind,$(MK_ALL_KINDS),\
  $(eval mk-new-$(kind) = $$(call mk-new-target,$(kind),$$1,$$2)))

# If MK_WITH_SYMLINK_TARGET is set to 1, we symlink linked artifacts to
# their location in the build directory.  This is only for convenience
# during development. The symlinks are removed on 'make clean'.
#
ifeq ($(MK_WITH_SYMLINK_TARGET),1)
  mk-symlink-target = \
    $(mk.cmd.lnsf)$(call mk-to-top,$(HERE))/$@ $(HERE)/$(@F)
else
  mk-symlink-target = :
endif

# $(call mk-resolve-pulled-flag,TARGET,PROPERTY)
# ----------------------------------------------
# Resolve a property starting from a target and recursing into its pulled
# targets.
#
# Example:
#   The following expands to the 'cppflags' property of target $1, together
#   with the value of 'pull-cppflags' in targets pulled by $1, and in
#   targets pulled by those, recursively:
#
#   $1.all-cppflags := $(call mk-resolve-pulled-flag,$1,cppflags)
#
define mk-resolve-pulled-flag-aux
  $1.all-$2 = $$(strip $$(foreach r,$$($1.all-required),$$($$(r).$(or $3,pull-$2))) $$($1.$2))
  $$(call mk-lazify,$1.all-$2)
endef
mk-resolve-pulled-flag = $(eval $(call mk-resolve-pulled-flag-aux,$1,$2,$3))

# $(call mk-resolve-pulled-flag,TARGET,PROPERTY)
# ----------------------------------------------
# Like the above, but for properties that contain location-relative values. 
# Each property is localized relative to the target that defines it,
# recursively.
#
# Example:
#   $1.all-includes := $(call mk-localize-pulled-flag,$1,includes)
#
define mk-localize-pulled-flag-aux
  $1.all-$2 = $$(strip \
    $$(foreach r,$$($1.all-required),$$(call $$(r).from-here,$$($$(r).$(or $3,pull-$2)))) $$(call $1.from-here,$$($1.$2)))
  $$(call mk-lazify,$1.all-$2)
endef
mk-localize-pulled-flag = $(eval $(call mk-localize-pulled-flag-aux,$1,$2,$3))

# $(call mk-find-sources,TARGET)
# ------------------------------
# Locate the source files for a target, starting from the value of the
# 'srcdir' property.  The list of source file suffixes is specific to the
# target's language.
#
mk-find-sources = \
  $(call mk-find-files,$($1.srcdir),$(addprefix *,$(mk-lang-$($1.lang).srcext)))

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
  $1.from-here = $$(if $$1,$$(call mk-from-here,$$1,$$($1.location)))

  # Define and lazify. We'll expand later.
  $1.all-required = $$(strip $$($1.require) $$(foreach r,$$($1.require),$$($$(r).all-pulled)))
  $$(call mk-lazify,$1.all-required)
  $1.all-pulled = $$(strip $$(foreach r,$$($1.pull),$$($$(r).all-pulled)) $$($1.pull))
  $$(call mk-lazify,$1.all-pulled)
  
  mk.targets.registered += $1
  mk.targets[$$($1.location)] += $1
endef
mk-target-register = $(eval $(call mk-target-register-aux,$1,$2))

mk-target-common-info = \
  $(info $(call mk-bold,  name)      : $($1.name))\
  $(info $(call mk-bold,  kind)      : $($1.kind))\
  $(info $(call mk-bold,  location)  : $(if $($1.location),$(call mk-byellow,$($1.location)),$(call mk-bbluw,*system*)))\
  $(info $(call mk-bold,  build-dir) : $($1.build-dir))\
  $(info $(call mk-bold,  target)    : $($1.target))\
  $(info $(call mk-bold,  build-type): $($1.build-type))\
  $(info $(call mk-bold,  sources)   : $(if $($1.all-sources),$(call mk-byellow,defined),$(call mk-bblack,*none*)))

mk-target-info = \
  $(if $(mk-$($1.kind).info),$(call mk-$($1.kind).info,$1),$(call mk-target-common-info,$1))  

mk-meets-requirement = $(strip \
  $(if $(and $($1.need-$2),$(call mk-neq,$($1.need-$2),$($3))),\
    $(call mk-warn,Skipping target <$1> since it does not meet the <$2> requirement),1))

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

  $1.buildable := $$(strip \
    $$(and $$(call mk-meets-requirement,$1,toolset,MK_TOOLSET),\
           $$(call mk-meets-requirement,$1,build-type,MK_BUILD_TYPE),\
           $$(call mk-meets-requirement,$1,link-type,MK_LINK_TYPE)))
   
  ifdef $1.lang
    # Resolve compilation/linking flags
    $$(call mk-lang-$$($1.lang).resolve-props,$1)

    # Locate source files
    ifeq (undefined,$$(origin $1.sources))
      $1.sources := $$(filter-out $$($1.exclude-sources),$$(call mk-find-sources,$1))
    endif
    $1.all-sources := $$($1.sources) $$($1.extra-sources)
  
    # Object files, if any
    $1.objs := $$(call mk-$$($1.kind).objs,$1,$$($1.all-sources))
    $1.all-objs := $$($1.objs) $$($1.extra-objs)
  endif

  $1.all-source-prereqs := $$(call mk-localize-pulled-flags,$1,source-prereqs)
  
  ifeq ($$(and $$($1.all-source-prereqs),$$($1.all-sources)),)
    $$($1.all-sources) : $$($1.all-source-prereqs)
  endif
  
  ifdef $1.cleanable
    $1.all-cleanable := $$(call $1.from-here,$$($1.cleanable))
  else
    $1.all-cleanable :=
  endif
  ifeq ($$(MK_WITH_SYMLINK_TARGET),1)
    $1.all-cleanable += $$($1.location)/$$(notdir $$($1.target))
  endif
  $1.all-cleanable += $$($1.all-objs) $$($1.target) $$($1.extra-cleanable)
  ifdef $1.dist-cleanable
    $1.all-dist-cleanable := $$(call $1.from-here,$$($1.dist-cleanable))
  else
    $1.all-dist-cleanable :=
  endif
  $1.all-dist-cleanable += $$($1.extra-dist-cleanable)  
  
  # Populate the lists with targets. We'll define them later.
  ifneq ($$(and $$($1.target),$$($1.buildable)),)
    mk.targets.clean += $$($1.location)@$1.clean      
    mk.targets.distclean += $$($1.location)@$1.distclean
    mk.targets.$$($1.kind) += $$($1.location)@$1    
    mk.targets.all += $$($1.location)@$1 
    ifdef mk.mode.print
      mk.targets.by-kind[$$($1.kind)] += $1
    endif
    ifndef mk.locations[$$($1.location)]
      mk.locations[$$($1.location)] :=
    endif
    mk.locations[$$($1.location)] += $$($1.location)@$1
  endif    
endef
mk-target-resolve = $(eval $(call mk-target-resolve-aux,$1))

##########################################################################
## Emit targets and recipes
##########################################################################

define mk-target-emit-aux
  ifneq ($$(and $$($1.target),$$($1.buildable)),)
    $$($1.target): MK_TARGET := $1
    $$($1.target): MK_KIND := $$($1.kind)
    $$($1.target): MK_LOCAL_LANG := $$($1.lang)
    $$($1.target): MK_LOCAL_BUILD_TYPE := $$($1.build-type)
    $$($1.target): MK_LOCAL_LINK_TYPE := $$($1.link-type)
    $$($1.target): HERE := $$($1.location)
    $$($1.target): THERE := $$($1.there)

    ifdef $1.lang
      # Emit compilation and linking rules
      $$(call mk-lang-$$($1.lang).emit-rules,$1)
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
    
    .PHONY: $$($1.location)@all
    $$($1.location)@%: HERE := $$($1.location)
    $$($1.location)@all: $1.build-target

    $$(call mk-debug,Emitted $1)
  endif
endef
mk-target-emit = $(eval $(call mk-target-emit-aux,$1))

ifdef mk.mode.help
  MK_VARDOC.MK_TOOLSET := Select the toolset to use
  MK_VARDOC.MK_BUILD_TYPE := Select the default build type
  MK_VARDOC.MK_LINK_TYPE := Select the default link type
  mk.help[build][] := Targets to trigger builds
  mk.help[build][exe] := Build executable targets only (and dependencies)
  mk.help[build][lib] := Build library targets only
  mk.help[build][_vars_] := MK_BUILD_TYPE MK_LINK_TYPE MK_TOOLSET
endif

endif # MK_TARGETS_MK_
