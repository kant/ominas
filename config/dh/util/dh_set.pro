;=============================================================================
; dh_set.pro
;
; Places a detached header into the given data descriptor
;
;=============================================================================
pro dh_set, dd, dh
 nv_set_udata, dd, dh, 'DETACHED_HEADER' 
end
;=============================================================================
