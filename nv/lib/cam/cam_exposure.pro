;===========================================================================
;+
; NAME:
;	cam_exposure
;
;
; PURPOSE:
;       Returns the exposure duration of each given camera descriptor.
;
;
; CATEGORY:
;	NV/LIB/CAM
;
;
; CALLING SEQUENCE:
;	exposure = cam_exposure(cd)
;
;
; ARGUMENTS:
;  INPUT:
;	cd:	 Array (nt) of CAMERA descriptors.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:  NONE
;
;  OUTPUT: NONE
;
;
; RETURN:
;       Exposure duration associated with each given camera descriptor.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/1998
;	
;-
;===========================================================================
function cam_exposure, cxp
@nv_lib.include
 cdp = class_extract(cxp, 'CAMERA')
 nv_notify, cdp, type = 1
 cd = nv_dereference(cdp)
 return, cd.exposure
end
;===========================================================================



