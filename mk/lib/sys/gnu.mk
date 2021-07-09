
mk.mbuild.os   := $(or $(MK_BUILD_OS),$(shell uname -s))
mk.mbuild.arch := $(or $(MK_BUILD_ARCH),$(shell uname -m))
mk.mbuild.host := $(or $(MK_BUILD_HOST),$(HOSTNAME),$(shell hostname))
mk.mbuild.user := $(or $(MK_BUILD_USER),$(LOGNAME),$(shell id -un))
mk.cmd.ar      := $(or $(AR),ar)
mk.cmd.mkdirp  := $(or $(MKDIR),mkdir) -p -- 
mk.cmd.rmf     := $(or $(RM),rm -f) --
mk.cmd.rmrf    := $(or $(RM),rm -f) -r -- 
mk.cmd.lnsf    := $(or $(LN_S),ln -s) -f -- 

# bin/gnu/
MK_BUILD_DIR = \
  $(MK_BUILD_TOP)/$(MK_BUILD_TYPE)/$(MK_LINK_TYPE)/$(mk.toolset.tag)/$(mk.mbuild.os)-$(mk.mbuild.arch)

ifdef mk.mode.help
  MK_VARDOC.MK_BUILD_OS   := OS name (as in uname -s)
  MK_VARDOC.MK_BUILD_ARCH := Architecture name (as in uname -m)
  MK_VARDOC.MK_BUILD_HOST := Build host, for configuration
  MK_VARDOC.MK_BUILD_USER := Build user, for configuration
endif
