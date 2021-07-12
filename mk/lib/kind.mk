
MK_ALL_KINDS = lib exe 
#TODO: data config doc man

mk-kind-from-name = $(word 1,$(subst ., ,$1))

include $(patsubst %,$(mk.mbuild.dir)/kind/%.mk,$(MK_ALL_KINDS))
