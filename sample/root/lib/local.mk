
$(call mk-new-lib,my-lib,MyLib)
  $(THIS).lang := c++
  $(THIS).pull-cppflags := -DMY_LIB=1
  $(THIS).pull-includes := ../include ../src
  $(THIS).includes := . ../include
