;=============================================================================
; gll_spice_lsk_detect
;
;=============================================================================
function gll_spice_lsk_detect, dd, kpath, time=time, strict=strict, all=all

 return, eph_spice_lsk_detect( $
           dd, kpath, time=time, strict=strict, all=all)
end
;=============================================================================