;=============================================================================
; gll_spice_ck_detect
;
;=============================================================================
function gll_spice_ck_detect, dd, ckpath, djd=djd, time=time, $
                             all=all, reject=reject, strict=strict

 all_files = file_search(ckpath + '*.plt')

 return, all_files
end
;=============================================================================
