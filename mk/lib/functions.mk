
MK_ROOT_DIR := $(CURDIR)
$(info MK_ROOT_DIR = $(MK_ROOT_DIR))

true  := T
false :=

MK_EMPTY  :=
MK_DOLLAR := $$
MK_SPACE  := $(MK_EMPTY) $(MK_EMPTY)
MK_HASH   != printf '\x23'
MK_COMMA  := ,
MK_OP     := (
MK_CP     := )

define MK_NL


endef

MK_SP1 = $(MK_SPACE)
MK_SP2 = $(MK_SP1)$(MK_SP1)

mk-begins-with = $(filter $1%,$2)

mk-under-root = $(call mk-begins-with,$(MK_ROOT_DIR),$(abspath $1))

# Like $(dir), but gets rid of the trailing slash
mk-dirname = $(patsubst %/,%,$(dir $1))

# Produce a canonical top-relative path to the argument.
mk-from-top = $(foreach f,$1,$(subst $(MK_ROOT_DIR)/,,$(abspath $f)))

# Given a canonical path from the top (as produced by $(mk-from-top)),
# produce a path that leads to the root.
mk-to-top = $(foreach f,$1,$(subst $(MK_SPACE),/,$(patsubst %,..,$(subst /, ,$f))))

# Produce a canonical top-relative path to a $(HERE)-relative path
mk-from-here = $(call mk-from-top,$(addprefix $(or $2,$(HERE))/,$1))

mk-vars-named = $(filter $1,$(.VARIABLES))

mk-shift = $(wordlist 2,$(words $1),$1)
mk-neq = $(or $(subst x$1,,x$2),$(subst x$2,,x$1))

# $(call mk-unfold,A.B.C.D) -> A A.B A.B.C A.B.C.D
mk-unfold-sub = \
  $2$(and $2,.)$(firstword $1) \
  $(if $(word 2,$1),$(call $0,$(wordlist 2,$(words $1),$1),$2$(and $2,.)$(firstword $1)))
mk-unfold = $(call mk-unfold-sub,$(subst ., ,$1),)

# $(call mk-find-recursive,ROOT(s),WILDCARD(s))
mk-find-files = $(strip \
  $(foreach root,$1,\
    $(foreach dir,$(wildcard $(root)/*/.),\
      $(call $0,$(patsubst %/.,%,$(dir)),$2))\
    $(wildcard $(addprefix $(root)/,$2))))

mk-wildcard-from = $(patsubst $1/%,%,$(wildcard $(addprefix $1/,$2)))

mk-lazify = $(eval $1 = $$(eval override $1 := $(value $1))$$($1))
mk-lazify-all = $(foreach 1,$1,$(mk-lazify))
mk-poison = $(foreach var,$1,$(eval override $(var) = $$(error Illegal reference to variable <$(var)>)))

# Drop duplicates but preserve ordering
mk-unique = $(strip \
  $(if $1,\
    $(if $(filter $(firstword $1),$2),\
      $(call $0,$(wordlist 2,$(words $1),$1),$2),\
      $(call $0,$(wordlist 2,$(words $1),$1),$2 $(firstword $1))),$2))

mk-reverse = $(strip \
  $(if $1,$(call $0,$(wordlist 2,$(words $1),$1),$(firstword $1) $2),$2))

define mk-copy-recursive
define $1
$2
endef
endef

mk-copy-var = $(eval \
  $(if $(filter simple,$(flavor $2)),\
    $1 := $(value $2),\
    $(call mk-copy-recursive,$1,$(value $2))))

ifeq ($(MK_DEBUG),1)
  # Use warning to get file + line number
  mk-debug = $(warning [$(bold)$(red)DEBUG$(normal)] $1)
else
  mk-debug =
endif

  