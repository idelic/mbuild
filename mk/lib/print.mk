ifndef MK_PRINT_MK_

MK_PRINT_MK_ := $(lastword $(MAKEFILE_LIST))

ifdef mk.mode.print
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

  mk-show-tree = \
    echo "$(bold)Variables under <$(yellow)$1$(white)>:$(normal)"; \
    $(foreach var,$(sort $(call mk-vars-named,$1.%)),\
      printf '  $(bold)$(yellow)%-24s$(normal) : %s\n' '$(var)' '$(call mk-squote,$(value $(var)))' &&) :

  mk-expand-tree = \
    echo "$(bold)Variables under <$(yellow)$1$(white)>:$(normal)"; \
    $(foreach var,$(sort $(call mk-vars-named,$1.%)),\
      printf '  $(bold)$(yellow)%-24s$(normal) : %s\n' '$(var)' '$(call mk-squote,$($(var)))' &&) :

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
          printf '  $(bold)%-24s$(normal) :: %s\n' '$t' '$(call mk-squote,$(value $t))' &&) :
  else
	@echo '$(value $(MK_ARG_REST))'
  endif

  .PHONY: xget
  xget:
  ifneq ($(word 2,$(MK_ARG_REST)),)
	@$(foreach t,$(MK_ARG_REST),\
          printf '  $(bold)%-24s$(normal) :: %s\n' '$t' '$(call mk-squote,$($t))' &&) :
  else
	@echo '$($(MK_ARG_REST))'
  endif
  
  ifeq ($(MK_ARG_FIRST),info)
    mk-var-info = \
      $(info $(call mk-bold,  name)      : $1)\
      $(info $(call mk-bold,  origin)    : $(origin $1))\
      $(info $(call mk-bold,  flavor)    : $(flavor $1))\
      $(info $(call mk-bold,  value)     : $(value $1))\
      $(info $(call mk-bold,  expansion) : $($1))
    
    mk-location-info = \
      $(info $(call mk-bold,  directory) : $1)\
      $(info $(call mk-bold,  targets)   : $(foreach t,$(mk.locations[$1]),$(lastword $(subst @, ,$t))))
     
    define mk-show-info-on
      ifneq (undefined,$$(flavor $1))
        $$(info Name <$$(bold)$1$$(normal)> is a $$(call mk-byellow,variable):)
        $$(call mk-var-info,$1)
      endif
      ifdef mk.locations[$1]
        $$(info Name <$$(bold)$1$$(normal)> is a $$(call mk-byellow,location):)
        $$(call mk-location-info,$1)
      endif
      ifneq ($$(filter $1,$$(mk.targets.all)),)
        $$(info Name <$$(bold)$1$(normal)> is a $$(call mk-byellow,target alias):)
        $$(call mk-target-alias-info,$1)
      endif
      ifneq ($$(filter $1,$$(mk.targets.registered)),)
        $$(info Name <$$(bold)$1$$(normal)> is a $$(call mk-byellow,target):)
        $$(call mk-$$($1.kind).info,$1)
      endif
      ifdef mk-lang-$1.name
        $$(info Name <$$(bold)$1$$(normal)> is a $$(call mk-byellow,language):)
        $$(call mk-lang-$1.info,$1)
      endif
    endef
    .PHONY: info
    info: $$(eval $$(call mk-show-info-on,$$(word 1,$$(MK_ARG_REST)))) ; @:
    ifeq ($(MK_ARG_REST),)
	@$(foreach k,$(MK_ALL_KINDS),\
	  $(if $(mk.targets.by-kind[$k]),\
	    $(call mk-boxed,$(mk-$k.title) targets); \
	    $(foreach t,$(mk.targets.by-kind[$k]),\
	      printf '  $(call mk-byellow,%-24s) : %s\n' \
	        '$t' '$(if $($t.location),$(call mk-bold,$($t.location)),$(call mk-bblue,*system*))';)echo;))\
	echo; \
	echo 'See "$(bold)make {info|show|expand}$(normal) $(under)TARGET$(normal)" for details.'; \
	echo
    endif
  endif

endif # mk.mode.print

ifdef mk.mode.help
  $(call mk-help-topic,print,Facilities to inspect the build state)
  $(call mk-help-add,show|VAR...,Show all variables defined under VAR)
  $(call mk-help-add,expand|VAR...,Show the expansion of all variables defined under VAR)
  $(call mk-help-add,get|VAR...,Show the definition of variable(s) VAR)
  $(call mk-help-add,xget|VAR...,Show the expansion of variable(s) VAR)
  $(call mk-help-add,info,Show targets and their location)
  $(call mk-help-add,info|NAME,Show a description of NAME)
endif

endif # MK_PRINT_MK_
