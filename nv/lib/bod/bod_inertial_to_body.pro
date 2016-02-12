;=============================================================================
;+
; NAME:
;	bod_inertial_to_body
;
;
; PURPOSE:
;	Transforms the given column vectors from the inertial coordinate
;	system to the body coordinate system.
;
;
; CATEGORY:
;	NV/LIB/BOD
;
;
; CALLING SEQUENCE:
;	body_pts = bod_inertial_to_body(bx, inertial_pts)
;
;
; ARGUMENTS:
;  INPUT: 
;	bx:	 	Any subclass of BODY.
;
;	inertial_pts:	Array (nv,3,nt) of column vectors in the inertial frame.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Array (nv,3,nt) of column vectors in the bx body frame.
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
;=============================================================================
function bod_inertial_to_body, bxp, v
@nv_lib.include
 bdp = class_extract(bxp, 'BODY')
 bd = nv_dereference(bdp)

 nt = n_elements(bd)
 sv = size(v)
 nv = sv[1]

 sub = linegen3x(nv,3,nt)

 M0 = (bd.orientT[*,0,*])[sub]
 M1 = (bd.orientT[*,1,*])[sub]
 M2 = (bd.orientT[*,2,*])[sub]

 r = dblarr(nv,3,nt,/nozero)
 r[*,0,*] = total(M0*v,2)
 r[*,1,*] = total(M1*v,2)
 r[*,2,*] = total(M2*v,2)

 return, r
end
;===========================================================================
