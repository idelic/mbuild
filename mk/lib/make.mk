
ifndef MK_MAKE_MK_

MK_MAKE_MK_ := $(lastword $(MAKEFILE_LIST))

.SUFFIXES:
.SECONDEXPANSION:
.DELETE_ON_ERROR:
.ONESHELL:
.DEFAULT_GOAL := all

.MK_ON_LOAD:

MK_LINE_HEAD = $(MK_SP2)[$(bold)$(green)%-6s$(normal)]
MK_LINE_BODY = $(call $4,%s)
MK_LINE_FOOT = $(bold)%*s$(normal)

ifeq ($(call mk-find-in-path,$(mk.cmd.gawk)),)
  mk-print-command = \
    printf '$(MK_LINE_HEAD) $(MK_LINE_BODY)\n' \
           '$(call mk-squote,$1)' '$(call mk-squote,$2)'
else
# $1=head $2=body $3=footer
  mk-print-command = \
    gawk -v H='$(call mk-squote,$1)' \
         -v B='$(call mk-squote,$2)' \
         -v F='$(call mk-squote,$3)' \
         -v COLS=$$(tput cols) '\
      BEGIN { \
        COLS -= length(B) + 14; if (COLS < 0) COLS = 0; \
        printf "$(MK_LINE_HEAD) $(MK_LINE_BODY) $(MK_LINE_FOOT)\n", \
          H, B, COLS, F \
      }' /dev/null
endif

ifeq ($(MK_VERBOSE),1)
  # User wants to see commands without our extra noise
  mk.quiet :=
  mk-do =
else
  mk.quiet := @
  mk-do = @$(call mk-print-command,$1,$2,$(MK_TARGET),$(or $3,mk-normal));
endif

mk-show-bin = \
  $(subst $($(MK_TARGET).build-dir),(BIN),$(or $1,$@))

# Keep things quiet
MAKEFLAGS += --no-print-directory

# Create target directories automagically
.PRECIOUS: %/.
%/.:
	$(call mk-do,mkdir,Creating $(call mk-show-bin,$(@D)))\
	$(mk.cmd.mkdirp)$(@D)

#$(mk.dir.mbuild)/%.mk :;
#%/local.mk :;

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
  mk.mode.build := 1
endif

endif # MK_MAKE_MK_
