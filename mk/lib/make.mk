
ifndef MK_MAKE_MK_

MK_MAKE_MK_ := $(lastword $(MAKEFILE_LIST))

.SUFFIXES:
.SECONDEXPANSION:
.DELETE_ON_ERROR:
.ONESHELL:

.MK_ON_LOAD:

MK_LINE_HEAD = $(MK_SP2)[$(call mk-green,%-6s)]
MK_LINE_BODY = %s
MK_LINE_FOOT = $(call mk-bold,%*s)

# $1=head $2=body $3=footer
mk-print-command = \
  gawk -v H='$1' -v B='$2' -v F='$3' -v COLS=$$(tput cols) '\
    BEGIN { \
      COLS -= length(B) + 14; if (COLS < 0) COLS = 0; \
      printf "$(MK_LINE_HEAD) $(MK_LINE_BODY) $(MK_LINE_FOOT)\n", \
        H, B, COLS, F \
    }' /dev/null

mk-step = printf '[%-6s] %s' '$1' '$2'

ifeq ($(MK_VERBOSE),1)
  # User wants to see commands without our extra noise
  mk-do =
else
  mk-do = @$(call mk-print-command,$1,$2,$(MK_TARGET));
endif

# Keep things quiet
MAKEFLAGS += --no-print-directory

# Create target directories automagically
.PRECIOUS: %/.
%/.:
	$(call mk-do,mkdir,Creating $(@D))\
	$(mk.cmd.mkdirp)$(@D)

$(mk.dir.mbuild)/%.mk :;
%/local.mk :;

define mk-make-noop
  .PHONY: $1
  $1:;@:
endef

# This only checks for flags we didn't add ourselves.
mk-make-has-flag = $(findstring $1,$(firstword $(MAKEFLAGS)))

# This checks for all flags
mk-make-has-option = $(findstring --%1,$(MAKEFLAGS))

mk.args.all   := print help
mk.args.print := info show expand get xget
mk.args.help  := help vars

MK_ARG_FIRST := $(firstword $(MAKECMDGOALS))
MK_ARG_REST  := $(call mk-shift,$(MAKECMDGOALS))

# Check if our first argument is special
$(foreach t,$(mk.args.all),\
  $(if $(filter $(mk.args.$t),$(MK_ARG_FIRST)),\
    $(eval mk.make.mode := $t)$(eval mk.mode.$t := 1)))

ifneq ($(mk.make.mode),)
  MK_BUILD_MODE := $(mk.make.mode)
  $(eval $(call mk-make-noop,$(MK_ARG_REST)))
else
  MK_BUILD_MODE := build
endif

endif # MK_MAKE_MK_
