
ifndef MK_INFILE_MK_

MK_INFILE_MK_ := $(lastword $(MAKEFILE_LIST))

mk-process-infile = \
  sed $(foreach var,$(MK_INFILE_VARS),\
    -e 's@$(call mk-infile-quote,$(var))@$(call mk-infile-quote,$(call mk-squote,$($(var))))@g') \
  "$<" > "$@.tmp" && mv -f "$@.tmp" "$@"

define mk-infile-define-target-aux
  $(if $1,$1/)%$3: %$(or $2,.in) | $$$$(@D)/.
	$$(call mk-maybe-run,$$(mk-proces-infile),infile,Creating $$(mk-show-bin))
endef
mk-infile-define-target = $(eval $(call mk-define-infile-target-aux,$1,$2,$3))

$(mk-infile-define-target)
$(call mk-infile-infile-target,$(MK_BUILD_DIR))

define mk-infile-add-var-aux
  ifeq (recursive,$$(flavor $3))
    $1: $2 = $$(value $3)
  else
    $1: $2 := $$($3)
  endif
endef
mk-invild-add-var = $(eval $(call mk-infile-add-var,$1,$2,$3))

define mk-infile-define-vars-aux
  $1: MK_INFILE_VARS := $3  
  $$(foreach var,$$(call mk-in-vars,$2.%),\
    $$(eval $1: MK_INFILE_VARS += $$(var))\
    $$(call mk-infile-add-var,$1,$$(var),$2.$$(var))\
    $$(eval undefine $2.$$(var)))
endef

endif # MK_INFILE_MK_
