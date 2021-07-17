
# Collect all the sub-directories that will participate in the build
ifeq ($(MK_SUBDIRS),)
  MK_SUBDIRS := $(patsubst ./%/,%,$(dir $(call mk-find-files,.,local.mk)))
endif
ifdef MK_SUBDIRS_EXCLUDED
  MK_SUBDIRS := $(filter-out $(MK_SUBDIRS_EXCLUDED),$(MK_SUBDIRS))
endif
$(call mk-debug,MK_SUBDIRS = $(MK_SUBDIRS))

ifeq ($(MK_SUBDIRS),)
  $(call mk-error,No sub-directories to build!)
endif

include $(mk.mbuild.dir)/emit.mk

ifdef MK_REQUIRED_LIBRARIES
  $(call mk-require-lib,$(MK_REQUIRED_LIBRARIES))
endif

# Include all the local build files
$(foreach dir,$(MK_SUBDIRS),$(call mk-include,$(dir)/local.mk))

include $(mk.mbuild.dir)/kind.mk

MK_ALL_TARGETS := \
  $(patsubst %.name,%,$(call mk-vars-named,$(addsuffix .%.name,$(MK_ALL_KINDS))))

$(call mk-debug,MK_ALL_TARGETS = $(MK_ALL_TARGETS))

# Register all targets
$(foreach t,$(MK_ALL_TARGETS),$(call mk-target-register,$t,$(call mk-kind-from-name,$t)))

# During registration, we collect the languages we need to support.
MK_LANGUAGES := $(patsubst mk-languages.%,%,$(call mk-vars-named,mk-languages.%))

# Then we load them
include $(patsubst %,$(mk.mbuild.dir)/lang/%.mk,$(MK_LANGUAGES))

# Load the toolset. This can use MK_LANGUAGES to set things up.
include $(mk.mbuild.dir)/toolset.mk

# Now we're ready to resolve target inter-dependencies
$(foreach 1,$(MK_ALL_TARGETS),$(mk-target-resolve))

$(foreach t,$(MK_ALL_TARGETS),$(call mk-target-emit,$t))
$(call mk-run-hook,bottom)

# ...then emit the actual targets
ifdef mk.mode.build
  define mk-define-top-target
    .PHONY: $1
    ifdef MK_LOCAL_DIR
      $1: $$(filter $$(MK_LOCAL_DIR)@% $$(MK_LOCAL_DIR)/%,$$(mk.targets.$1))
    else
      $1: $$(mk.targets.$1)
    endif
  endef
  $(foreach 1,$(call mk-in-vars,mk.targets.%),\
    $(eval $(mk-define-top-target)))
endif
