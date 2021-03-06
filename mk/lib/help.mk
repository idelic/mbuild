
ifndef MK_HELP_MK_

MK_HELP_MK_ := $(lastword $(MAKEFILE_LIST))

MK_HELP_PATH   ?= $(mk.mbuild.dir)/help
MK_HELP_EXT    := pod
MK_HELP_VIEWER := perldoc
MK_HELP_VAR    ?= mk.help
MK_HELP_VARDOC ?= MK_VARDOC

# Shorthand
H := $(MK_HELP_VAR)
V := $(MK_HELP_VARDOC)

ifdef mk.mode.help
  mk-show-vars = \
    $(if $1,\
      echo '$(bold)Variables$(normal):'; echo; \
      $(eval len := $(call mk-max-length,$1,$(FMT_LEN)))\
      $(foreach t,$(sort $1),\
        printf '  $(bold)$(yellow)%-$(len)s$(normal) : %s\n' \
          '$t' '$(call mk-squote,$(or $($V.$t),(undocumented)))' && \
        printf '  %-$(len)s   [$(bold)$(black)%s$(normal)]\n' \
          '' '$(if $(call mk-neq,undefined,$(origin $t)),$(call mk-squote,$(value $t)),$(red)--undefined--)' &&) echo)

  mk-show-key = \
    printf '  $(bold)$(yellow)%-$3s$(normal) : %s\n' '$(subst |, ,$1)' '$2'

  mk-help-topics = \
    $(filter-out _%,$(patsubst $H[%][],%,$(call mk-vars-named,$H[%][])))
  
  mk-sub-topics = \
    $(filter-out _%,$(patsubst $H[$1][%],%,$(call mk-vars-named,$H[$1][%])))
  
  mk-show-topic = \
    $(if $($H[$1][]),\
      $(call mk-boxed,$($H[$1][])); \
      $(if $($H[$1][_top_]),echo '$(call mk-squote,$($H[$1][_top_]))'; echo;) \
      $(eval len := $(call mk-max-length,$(call mk-sub-topics,$1),$(FMT_LEN)))\
      $(foreach t,$(sort $(call mk-sub-topics,$1)),\
        $(if $t,$(call mk-show-key,$t,$($H[$1][$t]),$(len));))\
      $(if $($H[$1][_bottom_]),echo;echo '$(call mk-squote,$($H[$1][_bottom_]))',:) \
      ,\
      echo "No help for <$1>"); echo; \
      $(call mk-show-vars,$($H[$1][_vars_]))
    
  mk-show-topic-list = \
    $(call mk-boxed,Help topics (see "make help TOPIC")); \
    $(eval len := $(call mk-max-length,$(mk-help-topics),$(FMT_LEN)))\
    $(foreach t,$(mk-help-topics),\
      printf '  $(bold)$(yellow)%-$(len)s$(normal) : %s\n' '$t' '$($H[$t][])' &&) :; echo; \
    $(call mk-show-topic,_help)

  mk-help-file = \
    $(wildcard $(MK_HELP_PATH)/$(subst $(MK_SPACE),/,$1.$(MK_HELP_EXT)))
    
  .PHONY: help-%
  help-%:
  ifneq ($(and $(MK_HELP_PATH),$(call mk-help-file,$(MK_ARG_REST))),)
	@$(MK_HELP_VIEWER) "$(call mk-help-file,$(MK_ARG_REST))"
  else
	@$(call mk-show-topic,$*)
  endif

  ifeq ($(MK_ARG_FIRST),help)
    .PHONY: help
    ifneq ($(MK_ARG_REST),)
      ifneq ($(word 2,$(MK_ARG_REST)),)
        help: FMT_LEN := 24
      endif
      help: $(addprefix help-,$(or $(MK_ARG_REST),all)) 
    else
      help: FMT_LEN := 24
      help:
	@$(mk-show-topic-list)
    endif
  endif

  # Locate all variables that begin with a prefix, excluding those under
  # MK_VARDOC.  
  mk-find-vars = \
    $(filter-out $V.%,$(filter $(addsuffix %,$1),$(.VARIABLES)))

  # Get the list of variables for a target.  If the argument is the name of
  # a target that defines variables, use that list.  Otherwise interpret the
  # argument as a prefix, and select all variables that start with that
  # prefix.
  mk-var-names = \
    $(or $($H[$1][_vars_]),$(call mk-find-vars,$1))

  ifeq ($(MK_ARG_FIRST),vars)
    .PHONY: vars
    vars:
    ifneq ($(MK_ARG_REST),)
	@$(call mk-show-vars,$(call mk-var-names,$(MK_ARG_REST)))
    else
	@$(call mk-show-vars,$(patsubst $V.%,%,$(call mk-vars-named,$V.%)))
    endif
  endif
  
  mk-help-topic = $(eval $H[$1][] := $2)$(eval _MK_HELP_TOPIC := $1)
  mk-help-add   = $(eval $H[$(_MK_HELP_TOPIC)][$1] := $2)
  mk-help-vars  = $(eval $H[$(_MK_HELP_TOPIC)][_vars_] := $1)

  mk.help[_help][] := Pseudo-targets to show help on various topics
  mk.help[_help][help|TOPIC...] := Show help on TOPIC
  mk.help[_help][vars|NAME...] := Show documentation for all variables starting with NAME
  mk.help[help][_vars_] := MK_HELP_PATH MK_HELP_EXT MK_HELP_VIEWER
  MK_VARDOC.MK_HELP_PATH   := Directory for external help files
  MK_VARDOC.MK_HELP_EXT    := Suffix for external help files
  MK_VARDOC.MK_HELP_VIEWER := Command to display external help files

  mk.help[clean][] := Targets to clean up after a build
  mk.help[clean][clean] := Clean up built targets
  mk.help[clean][distclean] := Like clean, but remove files generated during configuration
  
  mk.help[install][] := Targets to install artifacts (not implemented yet)
  mk.help[install][install-exe] := Install executables 
  mk.help[install][install-lib] := Install libraries
  mk.help[install][install-data] := Install data files 
  
  MK_VARDOC.MK_ROOT_DIR := Root directory for source tree
endif

endif # MK_HELP_MK_
