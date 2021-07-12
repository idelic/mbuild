
mk-find-origin = \
  $(lastword $(foreach org,$(sort $(call mk-in-vars,MK_ORIGIN.%)),\
    $(if $(findstring %,$(org)),\
      $(if $(filter $(org),$1/.),$(org)),\
      $(if $(filter $(org),$1),$(org)))))

ifndef MK_ORIGIN
  ifdef MK_LOCAL_DIR
    MK_ORIGIN := $(strip $(call mk-find-origin,$(MK_LOCAL_DIR)))
  endif
endif

ifneq ($(strip $(MK_ORIGIN)),)
  $(eval $(MK_ORIGIN.$(MK_ORIGIN)))
endif
