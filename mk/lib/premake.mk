
THIS_FILE := $(realpath $(lastword $(MAKEFILE_LIST)))
ROOT_DIR := $(dir $(abspath $(THIS_FILE)))
TOP_MAKEFILE := $(firstword $(MAKEFILE_LIST))

MK_VARIANT_DELIMITER ?= .
MK_PREMAKE.debug    := MK_PREMAKE_ARGS += MK_BUILD_TYPE=debug
MK_PREMAKE.release  := MK_PREMAKE_ARGS += MK_BUILD_TYPE=release
MK_PREMAKE.profile  := MK_PREMAKE_ARGS += MK_BUILD_TYPE=profile
MK_PREMAKE.coverage := MK_PREMAKE_ARGS += MK_BUILD_TYPE=coverage
MK_PREMAKE.static   := MK_PREMAKE_ARGS += MK_LINK_TYPE=static
MK_PREMAKE.shared   := MK_PREMAKE_ARGS += MK_LINK_TYPE=shared
MK_PREMAKE.verbose  := MK_PREMAKE_ARGS += MK_VERBOSE=1
MK_PREMAKE.gnu      := MK_PREMAKE_ARGS += MK_TOOLSET=gnu
MK_PREMAKE.clang    := MK_PREMAKE_ARGS += MK_TOOLSET=clang

MK_VARIANT.build-type := debug release profile coverage
MK_VARIANT.link-type  := static shared
MK_VARIANT.toolset    := gnu

MK_PREMAKE_TARGETS := variants show-variants

all-variants = $(sort $(patsubst MK_VARIANT.%,%,$(filter MK_VARIANT.%,$(.VARIABLES))))

permute-variants = \
  $(if $1,\
    $(foreach var,$(MK_VARIANT.$(firstword $1)),\
      $(call $0,$(wordlist 2,$(words $1),$1),$2/$(var))),$2)

# Targets we define in this file
premake-targets := show-variants variants

banner = \
  t=" $1 "; s=$$(echo "$$t" | sed s/./=/g); \
  echo "$$s"; echo "$$t"; echo "$$s"
  
ifeq ($(filter $(premake-targets),$(MAKECMDGOALS)),)
  # None of the targets defined here are mentioned on the command line. 
  # This is the common case of a user invoking the actual build.
  
  # First turn ALL targets into no-ops.
  .PHONY: recurse
  $(MAKECMDGOALS) : recurse ; @:
  
  # Extract all the 'premake' goals passed on the command line
  premake-used := \
    $(patsubst MK_PREMAKE.%,%,\
      $(filter $(addprefix MK_PREMAKE.,$(MAKECMDGOALS)),\
        $(filter MK_PREMAKE.%,$(.VARIABLES))))

  # Like of targets on the command line, excluding the ones in this file.
  user-goals := $(filter-out $(MK_PREMAKE_TARGETS) $(premake-used),$(MAKECMDGOALS))

  # Evaluate the code for each 'premake' target.
  $(foreach pm,$(premake-used),$(eval $(MK_PREMAKE.$(pm))))
  
  # Now invoke the 'real' make.  It's important to use "-f" here, and not
  # "-C/-f"!  We want to preserve the origin of the build, so we can do
  # sub-directory builds properly.  With -C that information is lost.  
  recurse:
	+@$(MAKE) --no-print-directory -f $(dir $(TOP_MAKEFILE))Makefile $(MK_PREMAKE_ARGS) $(user-goals)
else
  # We're doing variants!
  
  define emit-variant-target
    .PHONY: $1
    $1:
	+@$$(call banner,Running for the $1 variant); \
 	$$(MAKE) --no-print-directory -f $(TOP_MAKEFILE) $$(subst $(MK_VARIANT_DELIMITER), ,$1) $$(user-goals)
    variants: $1
  endef
  
  user-goals := $(filter-out $(premake-targets),$(MAKECMDGOALS))

  # Collapse the value of any variants explicitly mentioned on the command line.
  $(foreach cmd,$(MAKECMDGOALS),\
    $(foreach var,$(all-variants),\
      $(if $(filter $(cmd),$(MK_VARIANT.$(var))),\
        $(eval MK_VARIANT.$(var) := $(cmd))\
        $(eval user-goals := $(filter-out $(cmd),$(user-goals))))))
  
  permuted-variants = $(strip \
    $(subst /,$(MK_VARIANT_DELIMITER),\
      $(patsubst /%,%,$(call permute-variants,$(all-variants)))))

  $(MAKECMDGOALS): ; @:

  ifneq ($(filter show-variants,$(MAKECMDGOALS)),)
    .PHONY: show-variants
    $(foreach var,$(permuted-variants),$(info $(var)))
  else
    $(foreach var,$(permuted-variants),$(eval $(call emit-variant-target,$(var))))  
  endif
endif
