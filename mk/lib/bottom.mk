
# Collect all the sub-directories that will participate in the build
ifeq ($(MK_SUBDIRS),)
  MK_SUBDIRS := $(patsubst ./%/,%,$(dir $(call mk-find-files,.,local.mk)))
endif
ifdef MK_SUBDIRS_EXCLUDED
  MK_SUBDIRS := $(filter-out $(MK_SUBDIRS_EXCLUDED),$(MK_SUBDIRS))
endif
$(call mk-debug,MK_SUBDIRS = $(MK_SUBDIRS))

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
$(call mk-debug,include $(patsubst %,$(mk.mbuild.dir)/lang/%.mk,$(MK_LANGUAGES)))

# Load the toolset. This can use MK_LANGUAGES to set things up.
include $(mk.mbuild.dir)/toolset.mk

# Now we're ready to resolve target inter-dependencies
$(foreach 1,$(MK_ALL_TARGETS),$(mk-target-resolve))

# ...then emit the actual targets
$(foreach t,$(MK_ALL_TARGETS),$(call mk-target-emit,$t))

# Finally, determine the default target.
ifdef MK_LOCAL_DIR
  MK_TARGET_ALL := $(filter $(MK_LOCAL_DIR)@% $(MK_LOCAL_DIR)/%,$(mk.targets.all))
else
  MK_TARGET_ALL := $(mk.targets.all)
endif

$(call mk-debug,MK_TARGET_ALL = $(MK_TARGET_ALL))

.PHONY: all
all: $(MK_TARGET_ALL)
