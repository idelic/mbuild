
MK_TOP_MAKEFILE := $(lastword $(MAKEFILE_LIST))
# We assume we reached this file through a symlink.  The directory part of
# the symlink tells us the location of the build system.
MK_MBUILD_DIR := $(dir $(realpath $(MK_TOP_MAKEFILE)))

MK_ROOT_FILE ?= MBRoot

mk-find-upwards = \
  $(strip $(if $1,$(if $(wildcard $1/$2),$1,$(call $0,$(patsubst %/,%,$(dir $1)),$2))))    

# Directory containing the MBRoot file
ROOT_DIR := $(strip $(call mk-find-upwards,$(CURDIR),$(MK_ROOT_FILE)))

ifneq ($(ROOT_DIR),$(CURDIR))
  # We're in a sub-directory.  Restart the build from the top, but tell the
  # build system to restrict the build to targets under the local directory.
  .PHONY: all
  
  # We're forwarding all out goals, so disable them here
  $(MAKECMDGOALS): all ; @:

  sub_dir := $(patsubst $(ROOT_DIR)/%,%,$(CURDIR))
  .DEFAULT all:
	+@$(MAKE) --no-print-directory -C $(ROOT_DIR) \
	  -f $(abspath $(MK_TOP_MAKEFILE)) MK_LOCAL_DIR="$(sub_dir)" $(MAKECMDGOALS)  
else
  # We're at the top of the tree
  include $(MK_MBUILD_DIR)/top.mk
  include $(ROOT_DIR)/$(MK_ROOT_FILE)
  include $(MK_MBUILD_DIR)/bottom.mk
endif
