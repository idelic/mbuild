
MK_ALL_KINDS = lib exe data config doc man

mk-kind-from-name = $(word 1,$(subst ., ,$1))
