
ifndef MK_INCLUDE_MK_

MK_INCLUDE_MK_ := $(lastword $(MAKEFILE_LIST))

# The MK_BUILD_DIR variable can be target-specific.
THERE = $(MK_BUILD_DIR)/$(HERE)

define mk-include-aux
  WHERE := $$(abspath $2)
  
  ifndef _mk_included[$$(WHERE)]
    _mk_included[$$(WHERE)] := $2
    ifneq ($$(wildcard $2),)
      HERE  := $$(call mk-from-top,$$(call mk-dirname,$$(WHERE)))
      
      # Inclusion function is $1, file name is $2
      $1 $2
      
      # Restore
      HERE := $3
    endif
  endif

  WHERE := $4
endef

mk-include-helper = $(eval $(call mk-include-aux,$1,$2,$3,$4))

mk-include = $(call mk-include-helper,include,$1,$(HERE),$(WHERE))
mk-try-include = $(call mk-include-helper,sinclude,$1,$(HERE),$(WHERE))

mk-subdir = $(call mk-include,$1/local.mk)

endif # MK_INCLUDE_MK_
