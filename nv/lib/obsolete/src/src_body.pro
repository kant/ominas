;===========================================================================
; src_body
;
;
;===========================================================================
function src_body, scdp
 nv_notify, scdp, type = 1
 scd = nv_dereference(scdp)
 return, scd.bd
end
;===========================================================================



