
ifneq ($(MK_TOOLSET),gnu)
  $(call mk-error,This flavor requires the GNU toolset)
endif

MK_GCC_CXXFLAGS += -fsse42 -mpopcount
