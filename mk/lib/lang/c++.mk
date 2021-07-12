
include $(mk.mbuild.dir)/lang/common.mk

define mk-lang-c++.emit-rules-aux
  $$(call mk-emit-std-rules,$1)
  $$($1.target) : MK_LOCAL_CXXFLAGS := $$($1.all-cxxflags)
endef
mk-lang-c++.emit-rules = $(eval $(call mk-lang-c++.emit-rules-aux,$1))

define mk-lang-c++.resolve-props-aux
  $$(call mk-resolve-std,$1)
  $$(call mk-resolve-pulled-flags,$1,cxxflags)
endef
mk-lang-c++.resolve-props = $(eval $(call mk-lang-c++.resolve-props-aux,$1))
mk-lang-c++.name   := C++
mk-lang-c++.srcext := .cpp .cc .C .c++
mk-lang-c++.info = $(call mk-lang-info,c++)

