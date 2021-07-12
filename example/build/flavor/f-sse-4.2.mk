
ifneq ($(MK_TOOLSET),gnu)
  $(call mk-error,This flavor requires gcc)
endif

MK_GCC_CXXFLAGS += -msse4.2 -mpopcnt

