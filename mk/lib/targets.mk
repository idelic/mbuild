
ifndef MK_TARGETS_MK_

MK_TARGETS_MK_ := $(lastword $(MAKEFILE_LIST))

MK_LANG_DEFAULT ?= c++

define mk-new-target-aux
  ifdef $1.$2.name
    $$(call mk-error,Duplicate definition for target <$1>: Here ($$(HERE)) and in <$$($1.$2.location)>)
  endif
  $1.$2.name     := $2
  $1.$2.location := $$(HERE)
  $1.$2.there    := $$(THERE)
  $1.$2.local    := $$($1.$2.location)@$1.$2
  $1.$2.this     := $1.$2
  
  # Kind-specific stuff here
  $$(call mk-$1.new,$1.$2,$3)
  
  ifndef $1.$2.goal
    $1.$2.goal := $(or $3,$2)
  endif

  THIS  := $$($1.$2.this)
  LOCAL := $$($1.$2.local)
endef

# Define this as a simple variable, so it stays simple when we do '+='.
mk.targets.registered :=

mk-new-target = $(eval $(call mk-new-target-aux,$1,$2,$3))

# Define the 'kind' constructors.
$(foreach kind,$(MK_ALL_KINDS),\
  $(eval mk-new-$(kind) = $$(call mk-new-target,$(kind),$$1,$$2)))

endif # MK_TARGETS_MK_
