
ifndef MK_TERMINAL_MK_

MK_TERMINAL_MK_ := $(lastword $(MAKEFILE_LIST))

# Capabilities we query
mk_cap_bold    := bold
mk_cap_reverse := rev
mk_cap_under   := smul
mk_cap_black   := setaf 0
mk_cap_red     := setaf 1
mk_cap_green   := setaf 2
mk_cap_yellow  := setaf 3
mk_cap_blue    := setaf 4
mk_cap_magenta := setaf 5
mk_cap_cyan    := setaf 6
mk_cap_white   := setaf 7
mk_cap_normal  := sgr0

mk_all_termcap := bold reverse under black red green yellow blue magenta cyan white normal

ifeq ($(MAKE_TERMOUT),)
  MK_NO_COLORS := $(true)
else
  MK_NO_COLORS ?= $(false)
endif

ifneq ($(MK_NO_COLORS),)
  $(foreach cap,$(mk_all_termcap),$(eval undefine mk_cap_$(cap)))
else
  $(foreach cap,$(mk_all_termcap),\
    $(eval override $(cap) := $$(shell tput $(mk_cap_$(or $(MK_COLORMAP.$(cap)),$(cap))) 2>/dev/null)))
endif

$(foreach cap,$(mk_all_termcap),\
  $(eval mk-$(cap) = $$($(cap))$$1$$(mk_term_normal)))

mk-tput = $(info $1$(normal))
mk-bold = $(bold)$1$(normal)

ifdef mk.mode.help
  MK_VARDOC.MK_NO_COLORS := Disable colored output
endif

endif # MK_TERMINAL_MK_
