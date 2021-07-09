
$(call mk-new-exe,my-exe,MyExe)
  $(THIS).srcdir := ../srcdir
  $(THIS).require := lib.my-lib
  