
$(call mk-new-lib,test1)
  $(THIS).lang := c++
  $(THIS).cxxflags := test1-private-cxxflags
  $(THIS).pull-cxxflags := test1-pulled-cxxflags
  $(THIS).includes := test1-private-includes
  $(THIS).pull-includes := test1-pulled-includes
  $(THIS).cppflags := test1-private-cppflags
  $(THIS).pull-cppflags := test1-pulled-cppflags
  $(THIS).ldflags := test1-private-ldflags
  $(THIS).pull-ldflags := test1-pulled-ldflags
  $(THIS).ldlibs := test1-private-ldlibs
  $(THIS).pull-ldlibs := test1-pulled-ldlibs

$(call mk-new-lib,test2)
  $(THIS).lang := c++
  $(THIS).pull := lib.test1  
  $(THIS).cxxflags := test2-private-cxxflags
  $(THIS).pull-cxxflags := test2-pulled-cxxflags
  $(THIS).includes := test2-private-includes
  $(THIS).pull-includes := test2-pulled-includes
  $(THIS).cppflags := test2-private-cppflags
  $(THIS).pull-cppflags := test2-pulled-cppflags
  $(THIS).ldflags := test2-private-ldflags
  $(THIS).pull-ldflags := test2-pulled-ldflags
  $(THIS).ldlibs := test2-private-ldlibs
  $(THIS).pull-ldlibs := test2-pulled-ldlibs

$(call mk-new-lib,test3)
  $(THIS).lang := c++
  $(THIS).require := lib.test2

  $(THIS).cxxflags := test3-private-cxxflags
  $(THIS).pull-cxxflags := test3-pulled-cxxflags
  $(THIS).includes := test3-private-includes
  $(THIS).pull-includes := test3-pulled-includes
  $(THIS).cppflags := test3-private-cppflags
  $(THIS).pull-cppflags := test3-pulled-cppflags
  $(THIS).ldflags := test3-private-ldflags
  $(THIS).pull-ldflags := test3-pulled-ldflags
  $(THIS).ldlibs := test3-private-ldlibs
  $(THIS).pull-ldlibs := test3-pulled-ldlibs

$(call mk-new-lib,test4)
  $(THIS).lang := c++
  $(THIS).require := lib.test3

  $(THIS).cxxflags := test4-private-cxxflags
  $(THIS).pull-cxxflags := test4-pulled-cxxflags
  $(THIS).includes := test4-private-includes
  $(THIS).pull-includes := test4-pulled-includes
  $(THIS).cppflags := test4-private-cppflags
  $(THIS).pull-cppflags := test4-pulled-cppflags
  $(THIS).ldflags := test4-private-ldflags
  $(THIS).pull-ldflags := test4-pulled-ldflags
  $(THIS).ldlibs := test4-private-ldlibs
  $(THIS).pull-ldlibs := test4-pulled-ldlibs

$(call mk-new-lib,test5)
  $(THIS).lang := c++
  $(THIS).require := lib.test2

  $(THIS).cxxflags := test5-private-cxxflags
  $(THIS).pull-cxxflags := test5-pulled-cxxflags
  $(THIS).includes := test5-private-includes
  $(THIS).pull-includes := test5-pulled-includes
  $(THIS).cppflags := test5-private-cppflags
  $(THIS).pull-cppflags := test5-pulled-cppflags
  $(THIS).ldflags := test5-private-ldflags
  $(THIS).pull-ldflags := test5-pulled-ldflags
  $(THIS).ldlibs := test5-private-ldlibs
  $(THIS).pull-ldlibs := test5-pulled-ldlibs

