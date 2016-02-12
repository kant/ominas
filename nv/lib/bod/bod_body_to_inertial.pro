;=============================================================================
;+
; NAME:
;	bod_body_to_inertial
;
;
; PURPOSE:
;	Transforms the given column vectors from the body coordinate
;	system to the inertial coordinate system.
;
;
; CATEGORY:
;	NV/LIB/BOD
;
;
; CALLING SEQUENCE:
;	inertial_pts = bod_body_to_inertial(bx, body_pts)
;
;
; ARGUMENTS:
;  INPUT: 
;	bx:	 	Any subclass of BODY.
;
;	body_pts:	Array (nv,3,nt) of column vectors in the body frame.
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
;	Array (nv,3,nt) of column vectors in the bx inertial frame.
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
function bod_body_to_inertial, bxp, v
@nv_lib.include
 bdp = class_extract(bxp, 'BODY')
 bd = nv_dereference(bdp)

 nt = n_elements(bd)
 sv = size(v)
 nv = sv[1]

 sub = linegen3x(nv,3,nt)

 M0 = (bd.orient[*,0,*])[sub]
 M1 = (bd.orient[*,1,*])[sub]
 M2 = (bd.orient[*,2,*])[sub]

 r = dblarr(nv,3,nt,/nozero)
 r[*,0,*] = total(M0*v,2)
 r[*,1,*] = total(M1*v,2)
 r[*,2,*] = total(M2*v,2)

 return, r
end
;===========================================================================



