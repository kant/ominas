;===========================================================================
;+
; NAME:
;	bod_pos
;
;
; PURPOSE:
;       Returns the position of body center (in the inertial frame)
;       for each given body descriptor.
;
;
; CATEGORY:
;	NV/LIB/BOD
;
;
; CALLING SEQUENCE:
;	pos = bod_pos(bx)
;
;
; ARGUMENTS:
;  INPUT: NONE
;	bx:	 Array (nt) of any subclass of BODY descriptors.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;
;  OUTPUT: NONE
;
;
; RETURN:
;       Position of body center (in the inertial frame) associated
;       with each given body descriptor.
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
function bod_pos, bxp
@nv_lib.include
 bdp = class_extract(bxp, 'BODY')
 nv_notify, bdp, type = 1
 bd = nv_dereference(bdp)
 return, bd.pos
end
;===========================================================================
