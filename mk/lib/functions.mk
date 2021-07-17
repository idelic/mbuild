
MK_ROOT_DIR := $(CURDIR)

true  := T
false :=

MK_EMPTY  :=
MK_DOLLAR := $$
MK_SPACE  := $(MK_EMPTY) $(MK_EMPTY)
MK_HASH   != printf '\x23'
MK_COMMA  := ,
MK_OP     := (
MK_CP     := )
MK_SQUOTE := '

define MK_NL


endef

MK_SP1 = $(MK_SPACE)
MK_SP2 = $(MK_SP1)$(MK_SP1)

mk-begins-with = $(filter $1%,$2)

# $(call mk-squote,STRING)
# ------------------------
# Quote single quotes.  Use for single-quoted arguments passed to commands
# in recipes.
mk-squote = $(subst $(MK_SQUOTE),'\'',$1)

# $(call mk-under-root,PATH)
# --------------------------
# Determine whether a path lies under the root directory.
mk-under-root = $(call mk-begins-with,$(MK_ROOT_DIR),$(abspath $1))

# $(call mk-dirname,PATH...)
# -----------------------
# Like $(dir), but gets rid of the trailing slash.
mk-dirname = $(foreach d,$1,$(patsubst %/,%,$(dir $1)))

# $(call mk-from-top,PATH...)
# ------------------------
# Produce a canonical top-relative path to the argument.
mk-from-top = $(foreach f,$1,$(subst $(MK_ROOT_DIR)/,,$(abspath $f)))

# $(call mk-to-top,PATH...)
# ----------------------
# Given a canonical path from the top (as produced by $(mk-from-top)),
# produce a path that leads to the root.
mk-to-top = $(foreach f,$1,$(subst $(MK_SPACE),/,$(patsubst %,..,$(subst /, ,$f))))

# $(call mk-from-here,PATH[,HERE])
# --------------------------------
# Produce a canonical top-relative path to a $(HERE)-relative path
mk-from-here = $(call mk-from-top,$(addprefix $(or $2,$(HERE))/,$1))

# $(call mk-vars-names,PATTERN)
# -----------------------------
# Returns the list of all variable names matching a pattern
mk-vars-named = $(filter $1,$(.VARIABLES))

# $(call mk-in-vars,PATTERN)
# --------------------------
# Like mk-vars-named, but returns the stem for each variable name.
mk-in-vars = $(patsubst $1,%,$(filter $1,$(.VARIABLES)))

# $(call mk-shift,WORDLIST)
# -------------------------
# Drops the first word in a list
mk-shift = $(wordlist 2,$(words $1),$1)

# $(call mk-neq,A,B)
# ------------------
# Returns non-empty if the two arguments are NOT equal
mk-neq = $(or $(subst x$1,,x$2),$(subst x$2,,x$1))

# $(call mk-unfold,A.B.C.D) -> A A.B A.B.C A.B.C.D
mk-unfold-sub = \
  $2$(and $2,.)$(firstword $1) \
  $(if $(word 2,$1),$(call $0,$(wordlist 2,$(words $1),$1),$2$(and $2,.)$(firstword $1)))
mk-unfold = $(call mk-unfold-sub,$(subst ., ,$1),)

# $(call mk-find-recursive,ROOT(s),WILDCARD(s))
# ---------------------------------------------
# Returns a list of all path names matching WILDCARD under ROOT.
mk-find-files = $(strip \
  $(foreach root,$1,\
    $(foreach dir,$(wildcard $(root)/*/.),\
      $(call $0,$(patsubst %/.,%,$(dir)),$2))\
    $(wildcard $(addprefix $(root)/,$2))))

# $(call mk-wildcard-from,DIR,WILDCARD)
# -------------------------------------
# Returns all file names matching PATTERN under DIR.  The DIR part of the
# file names is removed.
mk-wildcard-from = $(patsubst $1/%,%,$(wildcard $(addprefix $1/,$2)))

# $(call mk-lazify,VAR_NAME)
# --------------------------
# Re-defines VAR_NAME so that the first time the variable is expanded, it
# becomes a simple variable holding the expansion as value.
mk-lazify = $(eval $1 = $$(eval override $1 := $(value $1))$$($1))

# Calls mk-lazify on a list of variables
mk-lazify-all = $(foreach 1,$1,$(mk-lazify))

# $(call mk-poison,VAR_NAME)
# --------------------------
# Re-defines VAR_NAME so that its expansion produces an error.
mk-poison = $(foreach var,$1,$(eval override $(var) = $$(error Illegal reference to variable <$(var)>)))

# $(call mk-add-hook,HOOK_NAME,MACRO_NAME)
# -----------------------------------
# Adds a macro to a named hook.
mk-add-hook = $(eval mk.hooks.$1 += $2)

# $(call mk-run-hook,HOOK_NAME,ARG(s)...)
# ---------------------------------------
# Evaluates all macros defined in a named hook.
mk-run-hook = $(foreach hook,$(mk.hooks.$1),$(eval $(call $(hook),$1,$2,$3,$4,$5,$6)))

# Drop duplicates but preserve ordering
mk-unique = $(strip \
  $(if $1,\
    $(if $(filter $(firstword $1),$2),\
      $(call $0,$(call mk-shift,$1),$2),\
      $(call $0,$(call mk-shift,$1),$2 $(firstword $1))),$2))

# Reverses a list
mk-reverse = $(strip \
  $(if $1,$(call $0,$(call mk-shift,$1),$(firstword $1) $2),$2))

# Renders a string inside a box.
mk-boxed = \
  t=' $1 '; s=`echo "$$t" | sed 's/./─/g'`; \
  echo "$(blue)┌$$s┐$(normal)"; \
  echo "$(blue)│$(bold)$(white)$$t$(normal)$(blue)│$(normal)"; \
  echo "$(blue)└$$s┘$(normal)"; echo

# $(call mk-try-run,COMMAND,IF_SUCCESS,IF_ERROR)
# ----------------------------------------------
# Runs COMMAND, then returns IF_SUCCESS if the command succeeds and IF_ERROR
# if it fails.
mk-try-run = \
  $(if $(shell $1 >/dev/null 2>&1 && echo "OK"),$2,$3)

# $(call mk-find-in-path,COMMAND[,VARIABLE=PATH])
# -------------------------------
# Finds a command in the colon-delimited list of directories in VARIABLE.
mk-find-in-path = \
  $(firstword $(wildcard $(addsuffix /$(firstword $1),$(subst :, ,$(or $2,$(PATH))))))

mk-max-length = \
  $(or $2,$(shell echo "$1"|tr ' ' '\n'|awk 'length>N{N=length}END{print N}'))

mk-load-required = \
  $(if $2,$(call mk-include,$2),$(call mk-error,Required library '$1' not found))

mk-lib-file = \
  $(firstword $(wildcard $(addsuffix /$1.mk,$(MK_LIB_DIRS))))

mk-require-lib = \
  $(foreach lib,$1,\
    $(call mk-load-required,$(lib),$(call mk-lib-file,$(lib))))

# Copy a recursive variable
define mk-copy-recursive
define $1
$2
endef
endef

# Copies a variable preserving its flavor.
mk-copy-var = $(eval \
  $(if $(filter simple,$(flavor $2)),\
    $1 := $(value $2),\
    $(call mk-copy-recursive,$1,$(value $2))))

# Emits a warning.
mk-warn = $(warning [$(call mk-byellow,WARNING)] $1)

# Emits a fatal error.
mk-error = $(error [$(call mk-bred,ERROR)] $1)

ifeq ($(MK_DEBUG),1)
  # Use warning to get file + line number
  mk-debug = $(warning [$(bold)$(red)DEBUG$(normal)] $1)
else
  mk-debug =
endif
