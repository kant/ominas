;===========================================================================
;+
; NAME:
;	glb_radii
;
;
; PURPOSE:
;       Returns the triaxial radii for each given globe descriptor.
;
;
; CATEGORY:
;	NV/LIB/GLB
;
;
; CALLING SEQUENCE:
;	radii = glb_radii(gbx)
;
;
; ARGUMENTS:
;  INPUT:
;	gbx:	 Array (nt) of any subclass of GLOBE descriptors.
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
;       Triaxial radii associated with each given globe descriptor.
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
function glb_radii, gbxp
 gbdp = class_extract(gbxp, 'GLOBE')
 nv_notify, gbdp, type = 1
 gbd = nv_dereference(gbdp)
 return, gbd.radii
end
;===========================================================================
