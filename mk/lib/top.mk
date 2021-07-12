
ifndef MK_TOP_MK_

MK_TOP_MK_ := $(lastword $(MAKEFILE_LIST))

# This is the directory where the mbuild files live
mk.mbuild.dir := $(patsubst %/,%,$(dir $(MK_TOP_MK_)))

# Our core goodies
include $(mk.mbuild.dir)/functions.mk

# Load all our configuration files
include $(mk.mbuild.dir)/config.mk

# Determine the build mode, make flags, etc
include $(mk.mbuild.dir)/make.mk

# Other facilities
include $(mk.mbuild.dir)/terminal.mk
include $(mk.mbuild.dir)/include.mk
#include $(mk.mbuild.dir)/install.mk
#include $(mk.mbuild.dir)/clean.mk

# Get the target machinery going
include $(mk.mbuild.dir)/kind.mk
include $(mk.mbuild.dir)/targets.mk
include $(mk.mbuild.dir)/help.mk
include $(mk.mbuild.dir)/print.mk

endif # MK_TOP_MK_
