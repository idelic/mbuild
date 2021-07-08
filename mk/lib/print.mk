
ifdef mk.mode.print
  $(info [$(MK_ARG_FIRST)])
  MK_LINE_HEAD = $(MK_SP2)[$(call mk-green,%-6s)]
  MK_LINE_BODY = %s
  MK_LINE_FOOT = $(call mk-bold,%*s)$(normal)

  # $1=head $2=body $3=footer
  mk-fancy-line = \
    gawk -v H='$1' -v B='$2' -v F='$3' -v COLS=$$(tput cols) '\
      BEGIN { \
        COLS -= length(B) + 14; if (COLS < 0) COLS = 0; \
        printf "$(MK_LINE_HEAD) $(MK_LINE_BODY) $(MK_LINE_FOOT)\n", \
          H, B, COLS, F \
      }' /dev/null

  all:
	@$(call mk-fancy-line,ld,Linking blah blah,lib.target1)
	@$(call mk-fancy-line,ld,Linking blah blah and whack,lib.long-target1)
	@$(call mk-fancy-line,ld,Linking blah d f  a q 2 3,lib.get1)
	@$(call mk-fancy-line,ld,Linking blah,lib.suprt-long-target1)
	@$(call mk-fancy-line,ld,Linking blah)
	@$(call mk-print-tree,mk.mbuild)

  mk-show-tree = \
    echo "$(bold)Variables under <$(yellow)$1$(white)>:$(normal)"; \
    $(foreach var,$(sort $(call mk-vars-named,$1.%)),\
      printf '  $(bold)$(yellow)%-16s$(normal) : %s\n' '$(var)' '$(value $(var))' &&) :

  mk-expand-tree = \
    echo "$(bold)Variables under <$(yellow)$1$(white)>:$(normal)"; \
    $(foreach var,$(sort $(call mk-vars-named,$1.%)),\
      printf '  $(bold)$(yellow)%-16s$(normal) : %s\n' '$(var)' '$($(var))' &&) :

  .PHONY: show
  show:
	@$(foreach t,$(MK_ARG_REST),$(call mk-show-tree,$t) &&) :

  .PHONY: expand
  expand:
	@$(foreach t,$(MK_ARG_REST),$(call mk-expand-tree,$t) &&) :

  .PHONY: get
  get:
  ifneq ($(word 2,$(MK_ARG_REST)),)
	@$(foreach t,$(MK_ARG_REST),\
          printf '  $(bold)%-24s$(normal) :: %s\n' '$t' '$(value $t)' &&) :
  else
	@echo '$(value $(MK_ARG_REST))'
  endif

  .PHONY: xget
  xget:
  ifneq ($(word 2,$(MK_ARG_REST)),)
	@$(foreach t,$(MK_ARG_REST),\
          printf '  $(bold)%-24s$(normal) :: %s\n' '$t' '$($t)' &&) :
  else
	@echo '$($(MK_ARG_REST))'
  endif
  
  ifeq ($(MK_ARG_FIRST),info)
    define mk-show-info-on
      ifneq (undefined,$$(flavor $1))
        $$(info Name <$1> is a variable:)
        $$(info $$(MK_SPACE)  origin    : $$(origin $1))
        $$(info $$(MK_SPACE)  flavor    : $$(flavor $1))
        $$(info $$(MK_SPACE)  value     : $$(value $1))
        $$(info $$(MK_SPACE)  expansion : $$($1))
      endif
      ifdef mk.mbuild.location[$1]
        $$(info Name <$1> is a location:)
        $$(info $$(MK_SPACE)  targets : $$(mk.mbuild.location[$1]))
      endif
      
    endef
    var := $(word 1,$(MK_ARG_REST))
    ifneq (undefined,$(flavor $(var)))
      $(info Variable <$(bold)$(yellow)$(var)$(normal)>:)
      $(info $(MK_SPACE)  Origin    : $(origin $(var)))
      $(info $(MK_SPACE)  Flavor    : $(flavor $(var)))
      $(info $(MK_SPACE)  Value     : $(value $(var)))
      $(info $(MK_SPACE)  Expansion : $($(var)))
    endif
    ifdef MK_LOCATIONS[
    .PHONY: info
    info:
  endif

endif # mk.mode.print

ifdef mk.mode.help
  $(call mk-help-topic,print,Facilities to inspect the build state)
  $(call mk-help-add,show VAR...,Show all variables defined under VAR)
  $(call mk-help-add,expand VAR...,Show the expansion of all variables defined under VAR)
  $(call mk-help-add,get VAR...,Show the definition of variable(s) VAR)
  $(call mk-help-add,xget VAR...,Shot the expansion of variable(s) VAR)
endif
