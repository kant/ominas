;===========================================================================
; cam_nx
;
;
;===========================================================================
function cam_nx, cxp
@nv_lib.include
 cdp = class_extract(cxp, 'CAMERA')
 nv_notify, cdp, type = 1
 cd = nv_dereference(cdp)
 return, (cd.size)[0,*]
end
;===========================================================================



